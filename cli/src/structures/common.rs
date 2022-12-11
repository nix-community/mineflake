use std::path::PathBuf;

use serde::{Deserialize, Serialize};

use super::spigot::SpigotConfig;
use crate::utils::load_config;
use anyhow::Result;
use std::fs::read_to_string;

#[derive(Debug, Clone)]
pub struct FileMapping(pub PathBuf, pub PathBuf);

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct FileConfig {
	pub path: PathBuf,
	pub format: String,
	pub content: String,
}

impl ToString for FileConfig {
	fn to_string(&self) -> String {
		match self.format.as_str() {
			"raw" => self.content.clone(),
			_ => {
				warn!("Unknow config type, assuming as raw");
				self.content.clone()
			}
		}
	}
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ServerConfig {
	pub package: Package,
	pub plugins: Vec<Package>,
	#[serde(flatten)]
	pub server: ServerSpecificConfig,
	pub command: Option<String>,
	pub configs: Option<Vec<FileConfig>>,
}

impl From<PathBuf> for ServerConfig {
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

	pub fn plugins_mapping(&self, ignore_patterns: Vec<PathBuf>) -> Result<Vec<FileMapping>> {
		let mut out = Vec::new();
		for plugin in &self.plugins {
			out.extend(Self::package_files(&plugin.get_path()?, &ignore_patterns)?)
		}
		Ok(out)
	}
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum Package {
	Local(LocalPackage),
}

impl Package {
	pub fn get_path(&self) -> Result<PathBuf> {
		match self {
			Package::Local(path) => Ok(path.get_path()),
		}
	}

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

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LocalPackage {
	pub path: PathBuf,
}

impl LocalPackage {
	pub fn get_path(&self) -> PathBuf {
		self.path.clone()
	}
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PackageManifest {
	pub name: String,
	pub version: Option<String>,
}

impl PackageManifest {
	pub fn full_name(&self) -> String {
		match &self.version {
			Some(ver) => format!("{}-{}", self.name, ver),
			None => self.name.clone(),
		}
	}
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum ServerSpecificConfig {
	Spigot(SpigotConfig),
}

pub trait Server {
	fn prepare_directory(&self, config: &ServerConfig, directory: &PathBuf) -> Result<()>;
	fn run_server(&self, config: &ServerConfig, directory: &PathBuf) -> Result<()>;
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ServerState {
	pub paths: Vec<PathBuf>,
}

impl From<PathBuf> for ServerState {
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
