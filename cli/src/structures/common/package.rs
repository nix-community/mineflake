use std::{fs::read_to_string, path::PathBuf};

use anyhow::Result;
use serde::{Deserialize, Serialize};

#[cfg(feature = "net")]
use reqwest::Url;
#[cfg(not(feature = "net"))]
use std::collections::HashMap;

/// Package types
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum Package {
	/// Local path package
	Local(LocalPackage),
	/// Remote package
	#[cfg(feature = "net")]
	Remote(RemotePackage),
	#[cfg(not(feature = "net"))]
	Remote(NetPackageStub),
	/// Remote package from repository
	#[cfg(feature = "net")]
	Repository(RepositoryPackage),
	#[cfg(not(feature = "net"))]
	Repository(NetPackageStub),
	/// Spigot package
	#[cfg(feature = "net")]
	Spigot(SpigotPackage),
	#[cfg(not(feature = "net"))]
	Spigot(NetPackageStub),
}

impl Package {
	/// Get package
	pub fn get_package(&self) -> &dyn PackageTrait {
		match self {
			Package::Local(local) => local,
			Package::Remote(remote) => remote,
			Package::Repository(repository) => repository,
			Package::Spigot(spigot) => spigot,
		}
	}

	/// Returns the path to the package (downloads it if necessary)
	pub fn get_path(&self) -> Result<PathBuf> {
		self.get_package().get_path()
	}

	/// Moves the package to the cache directory
	#[cfg(feature = "net")]
	pub fn move_to_cache(&self) -> Result<PathBuf> {
		self.get_package().move_to_cache()
	}

	/// Returns the package manifest
	pub fn load_manifest(&self) -> Result<PackageManifest> {
		let path = self.get_path()?;
		let manifest_path = path.join("package.yml");
		let manifest_content = read_to_string(manifest_path)?;
		let manifest: PackageManifest = serde_yaml::from_str(&manifest_content)?;
		debug!(
			"Loaded {:?} package manifest: {:?}",
			&manifest.full_name(),
			&manifest
		);
		Ok(manifest)
	}
}

/// Package trait
///
/// Packages should return the path to the folder with "package.yml" manifest file
pub trait PackageTrait {
	/// Returns the path to the package
	fn get_path(&self) -> Result<PathBuf>;
	/// Moves the package to the cache directory
	#[cfg(feature = "net")]
	fn move_to_cache(&self) -> Result<PathBuf>;
}

/// Local package
///
/// Local packages are just a local filesystem path to the package
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LocalPackage {
	/// The path to the package
	pub path: PathBuf,
}

impl PackageTrait for LocalPackage {
	/// Returns the path to the package
	///
	/// If package exists in the cache, returns the path to the cache
	fn get_path(&self) -> Result<PathBuf> {
		#[cfg(feature = "net")]
		{
			use crate::utils::net::{get_cache_dir, split_hash};
			let path = self.path.clone();
			let hash_str = sha256::digest(path.to_str().unwrap());
			let hash = split_hash(&hash_str);
			let cache_dir = get_cache_dir();
			let cache_path = cache_dir.join(hash);
			if cache_path.exists() {
				debug!("Package {:?} found in cache, using it", &path);
				return Ok(cache_path);
			}
			if path.exists() {
				return Ok(path);
			}
			Err(anyhow!("Package path {:?} not found", &path))
		}
		#[cfg(not(feature = "net"))]
		{
			Ok(self.path.clone())
		}
	}

	#[cfg(feature = "net")]
	fn move_to_cache(&self) -> Result<PathBuf> {
		use crate::utils::net::{get_cache_dir, split_hash};
		let path = self.get_path()?;
		let hash_str = sha256::digest(path.to_str().unwrap());
		debug!("Moving {:?} to cache", &path);
		let hash = split_hash(&hash_str);
		let cache_dir = get_cache_dir();
		let cache_path = cache_dir.join(hash);
		if !cache_path.exists() {
			debug!("Moving {:?} to cache", &path);
			std::fs::create_dir_all(cache_path.parent().unwrap())?;
			// Copy the directory
			copy_dir::copy_dir(&path, &cache_path)?;
		}
		Ok(cache_path)
	}
}

/// Remote package
///
/// Remote packages are zip files that are downloaded from the internet
/// and extracted to the cache directory.
#[cfg(feature = "net")]
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct RemotePackage {
	/// The URL to the package zip file
	pub url: url::Url,
}

#[cfg(feature = "net")]
fn get_package_dir(path: &PathBuf) -> Result<PathBuf> {
	use std::fs::read_dir;
	let path = if path.is_dir() {
		let mut entries = read_dir(path)?;
		if let Some(Ok(entry)) = entries.next() {
			if entries.next().is_none() {
				let entry_path = entry.path();
				if entry_path.is_dir() {
					entry_path
				} else {
					path.clone()
				}
			} else {
				path.clone()
			}
		} else {
			path.clone()
		}
	} else {
		path.clone()
	};
	Ok(path)
}

#[cfg(feature = "net")]
impl PackageTrait for RemotePackage {
	fn get_path(&self) -> Result<PathBuf> {
		use crate::utils::net::download_and_unzip_file;
		let path = download_and_unzip_file(&self.url)?;
		// If path contains a single directory, return that directory instead
		let path = get_package_dir(&path)?;
		Ok(path)
	}

	fn move_to_cache(&self) -> Result<PathBuf> {
		self.get_path()
	}
}

/// Repository package
///
/// Repository is a mapping of package names to package URLs (like in RemotePackage).
/// Repository manifests is cached forever, so URL must be changed manually to update the packages.
#[cfg(feature = "net")]
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct RepositoryPackage {
	/// Package name
	pub name: String,
	/// Package repository URL
	#[serde(alias = "repo", alias = "repository")]
	pub repository: url::Url,
}

#[cfg(feature = "net")]
impl PackageTrait for RepositoryPackage {
	fn get_path(&self) -> Result<PathBuf> {
		use crate::utils::net::{download_and_unzip_file, download_file_to_cache_full_path};
		use std::collections::HashMap;
		debug!(
			"Downloading package {} from repository {}",
			&self.name, &self.repository
		);
		let path = download_file_to_cache_full_path(&self.repository, "json")?;
		let content = read_to_string(path)?;
		// Parse repository index
		let repo: HashMap<String, String> = serde_json::from_str(&content)?;
		debug!("Repository index: {:?}", &repo);
		// Get package URL
		let url = match repo.get(&self.name) {
			Some(url) => url,
			None => {
				return Err(anyhow!(
					"Package {} not found in repository {}",
					&self.name,
					&self.repository
				))
			}
		};
		debug!("Package URL: {}", &url);
		// Download package
		let url = Url::parse(url)?;
		let path = download_and_unzip_file(&url)?;
		// If path contains a single directory, return that directory instead
		let path = get_package_dir(&path)?;
		Ok(path)
	}

	fn move_to_cache(&self) -> Result<PathBuf> {
		self.get_path()
	}
}

/// Spigot package.
///
/// Spigot packages are downloaded from the spigotmc.org repository via spiget API.
#[cfg(feature = "net")]
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SpigotPackage {
	/// Package name (optional)
	pub name: Option<String>,
	/// Package resource ID
	pub id: u64,
	/// Package version (optional)
	pub version: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
struct SpigetResource {
	/// Resource ID
	id: u64,
	/// Resource name
	name: String,
	/// Package versions
	versions: Vec<SpigetVersion>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
struct SpigetVersion {
	/// Version ID
	id: u64,
	/// Version UUID
	uuid: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
struct SpigetVersionInfo {
	/// Version ID
	id: u64,
	/// Version name
	name: String,
}

#[cfg(feature = "net")]
impl PackageTrait for SpigotPackage {
	fn get_path(&self) -> Result<PathBuf> {
		use crate::utils::net::{download_file, get_cache_dir, split_hash};
		use reqwest::blocking::Client;
		use std::fs::{create_dir_all, write};

		debug!(
			"Downloading package {}-{:?} from spigotmc.org",
			&self.id, &self.version
		);

		// Get hash and cache dir
		let full_name = match &self.version {
			Some(version) => format!("spigot-{}-{}", &self.id, version),
			None => format!("spigot-{}", &self.id),
		};
		let hash = sha256::digest(full_name);
		let spl_hash = split_hash(&hash);
		let cache_dir = get_cache_dir();
		let package_path = cache_dir.join(spl_hash);

		debug!("Package path: {:?}", package_path);

		// Check if package is already downloaded
		if package_path.exists() {
			debug!("Package already downloaded");
			return Ok(package_path);
		}

		let client = Client::new();

		let info_url = format!("https://api.spiget.org/v2/resources/{}", &self.id);
		debug!("Requesting package info from {}", &info_url);

		// Request resource info
		let info: SpigetResource = client.get(&info_url).send()?.error_for_status()?.json()?;

		// Find download URL
		let download_url: String = match &self.version {
			Some(version_name) => {
				let mut ret: Option<String> = None;
				for version in &info.versions {
					let version_info: SpigetVersionInfo = client
						.get(format!(
							"https://api.spiget.org/v2/resources/{}/versions/{}",
							&self.id, version.id
						))
						.send()?
						.error_for_status()?
						.json()?;
					if &version_info.name == version_name {
						ret = Some(format!(
							"https://api.spiget.org/v2/resources/{}/versions/{}/download",
							&self.id, version.id
						));
						break;
					}
				}
				match ret {
					Some(url) => url,
					None => {
						return Err(anyhow!(
							"Version {} not found for package {}",
							&self.version.as_ref().unwrap(),
							&self.id
						));
					}
				}
			}
			None => format!("https://api.spiget.org/v2/resources/{}/download", &self.id),
		};

		debug!("Downloading package {} from {}", &self.id, &download_url);

		let download_url = url::Url::parse(&download_url)?;

		// Create package dir
		create_dir_all(&package_path)?;

		// Download package
		download_file(&download_url, &package_path.join("package.jar"))?;

		// Create manifest
		let manifest = PackageManifest {
			name: info.name,
			version: self.version.as_ref().map(|version| version.to_string()),
		};
		let manifest_path = package_path.join("package.yml");
		let manifest_content = serde_yaml::to_string(&manifest)?;
		write(manifest_path, manifest_content)?;

		debug!("Package downloaded to {:?}", &package_path);

		// Return package path
		Ok(package_path)
	}

	fn move_to_cache(&self) -> Result<PathBuf> {
		self.get_path()
	}
}

#[cfg(not(feature = "net"))]
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NetPackageStub {
	#[serde(flatten)]
	data: HashMap<String, String>,
}

#[cfg(not(feature = "net"))]
impl PackageTrait for NetPackageStub {
	fn get_path(&self) -> Result<PathBuf> {
		Err(anyhow!("To use remote packages, enable the 'net' feature"))
	}
}

/// Package manifest
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PackageManifest {
	/// The package name
	pub name: String,
	/// The package version (optional)
	pub version: Option<String>,
}

impl PackageManifest {
	/// Returns the full package name (name-version)
	pub fn full_name(&self) -> String {
		match &self.version {
			Some(ver) => format!("{}-{}", self.name, ver),
			None => self.name.clone(),
		}
	}
}
