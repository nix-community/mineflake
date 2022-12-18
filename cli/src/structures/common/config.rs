use super::file::{FileConfig, FileMapping};
use super::package::Package;
use crate::structures::bungee::BungeeConfig;
use crate::structures::spigot::SpigotConfig;
use crate::utils::load_config;
use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::fs::read_to_string;
use std::path::{Path, PathBuf};

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
		load_config(&config_content).expect("Failed to deserialize server config")
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
		ignore_patterns: &[PathBuf],
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

	/// Downloads all packages
	///
	/// For each package it spawns a new thread and downloads the package in parallel.
	///
	/// # Panics
	///
	/// Panics if:
	/// - The package fails to download
	/// - The package fails to move to the cache
	/// - Cannot join a thread
	#[cfg(feature = "net")]
	pub fn download_packages(&self, max_threads: usize) -> Result<()> {
		use std::thread::JoinHandle;

		fn spawn_thread(package: &Package) -> Result<JoinHandle<()>> {
			let package = package.clone();
			debug!("Spawning thread for package: {:?}", package);
			let thread = std::thread::spawn(move || {
				info!("Downloading package: {:?}", package);
				package.move_to_cache().expect("Failed to download package");
			});
			Ok(thread)
		}

		let mut threads = vec![spawn_thread(&self.package)?];

		for plugin in &self.plugins {
			if threads.len() >= max_threads {
				debug!("Max threads reached, joining threads");
				for thread in threads {
					thread.join().expect("Failed to join thread");
				}
				// Reset threads
				threads = Vec::new();
			}

			threads.push(spawn_thread(plugin)?);
		}

		for thread in threads {
			thread.join().expect("Failed to join thread");
		}

		Ok(())
	}
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
	pub fn run_server(&self, config: &ServerConfig, directory: &Path) -> Result<()> {
		self.get_server().run_server(config, directory)
	}

	/// Prepare server directory
	pub fn prepare_directory(&self, config: &ServerConfig, directory: &Path) -> Result<()> {
		self.get_server().prepare_directory(config, directory)
	}
}

/// Server trait
///
/// Defines the methods that must be implemented for a server type.
/// This is used to allow the server to be configured and run.
pub trait Server {
	/// Prepares the server directory (downloads the server if necessary, and copies the plugins and config files)
	fn prepare_directory(&self, config: &ServerConfig, directory: &Path) -> Result<()>;
	/// Runs the server (blocking, launches the server process)
	fn run_server(&self, config: &ServerConfig, directory: &Path) -> Result<()>;
}
