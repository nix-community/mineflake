use std::{fs::read_dir, path::PathBuf};

use reqwest::Url;
use serde::{Deserialize, Serialize};

use super::spigot::SpigotConfig;
use crate::utils::{linker::LinkTypes, load_config, net::download_and_unzip_file};
use anyhow::Result;
use std::fs::read_to_string;

#[derive(Debug, Clone)]
pub struct FileMapping(pub PathBuf, pub PathBuf);

/// The configuration for a server
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

/// Raw file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct RawFileConfig {
	/// The file content
	pub content: String,
}

/// JSON file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JsonFileConfig {
	/// The file content
	pub content: serde_json::Value,
}

/// YAML file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct YamlFileConfig {
	/// The file content
	pub content: serde_yaml::Value,
}

/// Merge JSON files
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MergeJsonFileConfig {
	/// The file content
	pub content: serde_json::Value,
}

/// Merge YAML files
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MergeYamlFileConfig {
	/// The file content
	pub content: serde_yaml::Value,
}

/// Package types
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum Package {
	/// Local path package
	Local(LocalPackage),
	/// Remote package
	Remote(RemotePackage),
}

impl Package {
	/// Returns the path to the package (downloads it if necessary)
	pub fn get_path(&self) -> Result<PathBuf> {
		match self {
			Package::Local(path) => path.get_path(),
			Package::Remote(remote) => remote.get_path(),
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
pub trait PackageTrait {
	/// Returns the path to the package
	fn get_path(&self) -> Result<PathBuf>;
}

/// Local package
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LocalPackage {
	/// The path to the package
	pub path: PathBuf,
}

impl PackageTrait for LocalPackage {
	/// Returns the path to the package
	///
	/// # Errors
	/// There is no error, so you can unwrap the result
	fn get_path(&self) -> Result<PathBuf> {
		Ok(self.path.clone())
	}
}

/// Remote package
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct RemotePackage {
	/// The URL to the package zip file
	pub url: String,
}

impl PackageTrait for RemotePackage {
	/// Returns the path to the package (downloads it if necessary)
	fn get_path(&self) -> Result<PathBuf> {
		let url = Url::parse(&self.url)?;
		let path = download_and_unzip_file(&url)?;
		// If path contains a single directory, return that directory instead
		let path = if path.is_dir() {
			let mut entries = read_dir(&path)?;
			if let Some(Ok(entry)) = entries.next() {
				if entries.next().is_none() {
					let entry_path = entry.path();
					if entry_path.is_dir() {
						entry_path
					} else {
						path
					}
				} else {
					path
				}
			} else {
				path
			}
		} else {
			path
		};
		Ok(path)
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
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum ServerSpecificConfig {
	/// Bukkit-based server (Spigot, Paper, etc.)
	Spigot(SpigotConfig),
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
pub trait Generator {
	/// Generates the server files from the given config
	fn generate(&self, config: &ServerConfig) -> Result<Vec<LinkTypes>>;
}

/// Server state (used to store the server state between runs)
///
/// This is used to determine which files have changed since the last run and can be removed
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
