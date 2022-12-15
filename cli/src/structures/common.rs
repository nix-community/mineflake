use std::path::PathBuf;

#[cfg(feature = "net")]
use reqwest::Url;
use serde::{Deserialize, Serialize};
#[cfg(not(feature = "net"))]
use std::collections::HashMap;

use super::{bungee::BungeeConfig, spigot::SpigotConfig};
use crate::utils::{linker::LinkTypes, load_config};
use anyhow::Result;
use std::fs::read_to_string;

#[derive(Debug, Clone)]
pub struct FileMapping(pub PathBuf, pub PathBuf);

/// The configuration for a server
///
/// This is the main configuration file for a server. It contains the server package,
/// plugins, server specific configuration, command to run the server and configs to
/// generate to the server directory.
///
/// # Example
/// ```yaml
/// type: spigot
///
/// command: java -Xms1G -Xmx1G -jar {}
///
/// package:
///   type: remote
///   url: https://example.com/paper.zip
///
/// plugins:
/// - type: remote
///   url: https://example.com/essentials.zip
///
/// configs:
/// - path: server.properties
///   type: raw
///   content: online-mode=false
/// ```
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ServerConfig {
	/// Server package
	pub package: Package,
	/// Plugins
	pub plugins: Vec<Package>,
	/// Server specific configuration
	#[serde(flatten)]
	pub server: ServerSpecificConfig,
	/// Command to run the server
	pub command: Option<String>,
	/// Configs to generate to the server directory
	pub configs: Option<Vec<FileConfig>>,
}

impl From<PathBuf> for ServerConfig {
	/// Loads a server config from a file
	///
	/// # Panics
	/// Panics if the file doesn't exist or if the config is invalid
	fn from(value: PathBuf) -> Self {
		let config_content = read_to_string(value).expect("Failed to read server config");
		let config = load_config(&config_content).expect("Failed to deserialize server config");
		config
	}
}

impl ServerConfig {
	fn iterate(path: &PathBuf) -> Result<Vec<PathBuf>> {
		let mut paths: Vec<PathBuf> = Vec::new();

		for entry in std::fs::read_dir(path)? {
			let entry = entry?;
			let path = entry.path();
			if path.is_dir() {
				paths.extend(Self::iterate(&path)?);
			} else if path.is_file() {
				paths.push(path.clone());
			}
		}

		Ok(paths)
	}

	/// Returns a list of all files in a directory, excluding the directory itself and any files that match the ignore patterns
	pub fn package_files(
		directory: &PathBuf,
		ignore_patterns: &Vec<PathBuf>,
	) -> Result<Vec<FileMapping>> {
		let directory_contents = Self::iterate(directory)?;

		let ignore_patterns: Vec<PathBuf> = ignore_patterns
			.iter()
			.map(|path| directory.join(path))
			.collect();

		// Remove ignore_patterns from the list
		// Remove "{directory}/" from the start of each path
		let directory_contents: Vec<FileMapping> = directory_contents
			.into_iter()
			.filter(|path| !ignore_patterns.contains(path))
			.map(|path| {
				let stripped_str = path
					.strip_prefix(directory)
					.expect("Failed to strip prefix");
				let stripped_path = PathBuf::from(stripped_str);
				FileMapping(path, stripped_path)
			})
			.collect();

		debug!(
			"{:?} directory contents: {:?}",
			directory, directory_contents
		);

		Ok(directory_contents)
	}

	/// Returns a list of all files in the server plugins, excluding the plugins directory itself and any files that match the ignore patterns
	pub fn plugins_mapping(&self, ignore_patterns: Vec<PathBuf>) -> Result<Vec<FileMapping>> {
		let mut out = Vec::new();
		for plugin in &self.plugins {
			out.extend(Self::package_files(&plugin.get_path()?, &ignore_patterns)?)
		}
		Ok(out)
	}
}

/// Configuration file config
///
/// This is used to generate config files in the server directory without writing
/// custom packages. This is useful for updating/generating config files that are not
/// included in the server/plugins package.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct FileConfig {
	pub path: PathBuf,
	#[serde(flatten)]
	pub file: FileConfigEnum,
}

/// Config file types
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum FileConfigEnum {
	/// Raw file content
	Raw(RawFileConfig),
	/// JSON file content
	Json(JsonFileConfig),
	/// YAML file content
	Yaml(YamlFileConfig),
	/// Merge JSON files
	MergeJson(MergeJsonFileConfig),
	/// Merge YAML files
	MergeYaml(MergeYamlFileConfig),
}

impl FileConfigEnum {
	/// Processes the file config and inserts the result into the files vector
	pub fn process(&self, files: &mut Vec<LinkTypes>, config: &FileConfig) -> Result<()> {
		match self {
			Self::Raw(raw) => {
				files.push(LinkTypes::Raw(raw.content.clone(), config.path.clone()));
			}
			Self::Json(json) => {
				files.push(LinkTypes::Raw(
					serde_json::to_string(&json.content)?,
					config.path.clone(),
				));
			}
			Self::Yaml(yaml) => {
				files.push(LinkTypes::Raw(
					serde_yaml::to_string(&yaml.content)?,
					config.path.clone(),
				));
			}
			Self::MergeJson(json) => {
				files.push(LinkTypes::MergeJSON(
					json.content.clone(),
					config.path.clone(),
				));
			}
			Self::MergeYaml(yaml) => {
				files.push(LinkTypes::MergeYAML(
					yaml.content.clone(),
					config.path.clone(),
				));
			}
		}
		Ok(())
	}
}

/// Raw file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct RawFileConfig {
	/// The string content
	pub content: String,
}

/// JSON file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JsonFileConfig {
	/// The complex json content
	pub content: serde_json::Value,
}

/// YAML file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct YamlFileConfig {
	/// The complex yaml content
	pub content: serde_yaml::Value,
}

/// Merge JSON files
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MergeJsonFileConfig {
	/// The json config, that will be merged with the previous configs
	pub content: serde_json::Value,
}

/// Merge YAML files
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MergeYamlFileConfig {
	/// The yaml config, that will be merged with the previous configs
	pub content: serde_yaml::Value,
}

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
}

impl Package {
	/// Returns the path to the package (downloads it if necessary)
	pub fn get_path(&self) -> Result<PathBuf> {
		match self {
			Package::Local(path) => path.get_path(),
			Package::Remote(remote) => remote.get_path(),
			Package::Repository(repository) => repository.get_path(),
		}
	}

	/// Moves the package to the cache directory
	#[cfg(feature = "net")]
	pub fn move_to_cache(&self) -> Result<PathBuf> {
		match self {
			Package::Local(local) => local.move_to_cache(),
			Package::Remote(remote) => remote.move_to_cache(),
			Package::Repository(repository) => repository.move_to_cache(),
		}
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
			std::fs::create_dir_all(&cache_path.parent().unwrap())?;
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
		let mut entries = read_dir(&path)?;
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
		let content = read_to_string(&path)?;
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

/// Server configuration types
///
/// This is allows multiple server types to be supported without having to
/// global configuration options for each server type.
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum ServerSpecificConfig {
	/// Bukkit-based server (Spigot, Paper, etc.)
	Spigot(SpigotConfig),
	/// Bungee-based server (Bungeecord, Waterfall, etc.)
	Bungee(BungeeConfig),
}

impl ServerSpecificConfig {
	/// Get server
	pub fn get_server(&self) -> &dyn Server {
		match self {
			ServerSpecificConfig::Spigot(server) => server,
			ServerSpecificConfig::Bungee(server) => server,
		}
	}

	/// Run server
	pub fn run_server(&self, config: &ServerConfig, directory: &PathBuf) -> Result<()> {
		self.get_server().run_server(config, directory)
	}

	/// Prepare server directory
	pub fn prepare_directory(&self, config: &ServerConfig, directory: &PathBuf) -> Result<()> {
		self.get_server().prepare_directory(config, directory)
	}
}

/// Server trait
///
/// Defines the methods that must be implemented for a server type.
/// This is used to allow the server to be configured and run.
pub trait Server {
	/// Prepares the server directory (downloads the server if necessary, and copies the plugins and config files)
	fn prepare_directory(&self, config: &ServerConfig, directory: &PathBuf) -> Result<()>;
	/// Runs the server (blocking, launches the server process)
	fn run_server(&self, config: &ServerConfig, directory: &PathBuf) -> Result<()>;
}

/// Generator trait
///
/// Generator is a method that generates the server files from the given config.
/// For example, generators allows configure LuckPerms configs declaratively
/// from the config file, without having to write a bunch of configs entries.
pub trait Generator {
	/// Generates the server files from the given config
	fn generate(&self, config: &ServerConfig) -> Result<Vec<LinkTypes>>;
}

/// Server state (used to store the server state between runs)
///
/// This is used to determine which files have changed since the last run and can be removed.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ServerState {
	/// The paths of the files that were created
	pub paths: Vec<PathBuf>,
}

impl From<PathBuf> for ServerState {
	/// Loads the server state from the given path
	///
	/// If the file does not exist, an empty state is returned
	fn from(value: PathBuf) -> Self {
		match read_to_string(value) {
			Ok(data) => match serde_json::from_str(&data) {
				Ok(d) => {
					debug!("Loaded server state: {:?}", &d);
					d
				}
				Err(_) => Self { paths: vec![] },
			},
			Err(_) => Self { paths: vec![] },
		}
	}
}
