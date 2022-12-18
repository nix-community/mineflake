use std::path::{PathBuf, Path};
use std::process::Command;

use serde::{Deserialize, Serialize};

use crate::utils::{
	config::{check_configs_purity, find_collisions},
	linker::{diff_states, link_files, remove_with_parent, LinkTypes},
};

use super::common::{FileMapping, Generator, Server, ServerConfig, ServerState};

/// The configuration for a LuckPerms group
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LuckPermsGroupConfig {
	/// The name of the group
	pub name: String,
	/// Group permissions
	pub permissions: Vec<String>,
}

impl Generator for LuckPermsGroupConfig {
	fn generate(&self, _config: &ServerConfig) -> anyhow::Result<Vec<LinkTypes>> {
		let mut files: Vec<LinkTypes> = Vec::new();

		let name = self.name.clone();
		let path = PathBuf::from(format!("plugins/LuckPerms/json-storage/groups/{name}.json"));
		let content = serde_json::to_string_pretty(&serde_json::json!(
			{
				"name": self.name,
				"permissions": self.permissions.iter().map(|p| serde_json::json!({ "permission": p, "value": true })).collect::<Vec<serde_json::Value>>()
			}
		))?;
		files.push(LinkTypes::Raw(content, path));

		Ok(files)
	}
}

/// The configuration for a Spigot server
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SpigotConfig {
	/// LuckPerms generator configuration
	pub permissions: Option<Vec<LuckPermsGroupConfig>>,
}

impl SpigotConfig {
	fn get_server_path(&self, config: &ServerConfig) -> anyhow::Result<PathBuf> {
		let path = PathBuf::from(format!(
			"{}.jar",
			config.package.load_manifest()?.full_name()
		));
		Ok(path)
	}

	fn prepare_packages(
		&self,
		config: &ServerConfig,
		_directory: &Path,
	) -> anyhow::Result<Vec<LinkTypes>> {
		let ignore_patterns: Vec<PathBuf> =
			vec![PathBuf::from("package.yml"), PathBuf::from("package.jar")];
		let mut files: Vec<FileMapping> = Vec::new();

		// Server package
		let package_dir = config.package.get_path()?;
		let package_jar = package_dir.join("package.jar");
		files.extend(ServerConfig::package_files(&package_dir, &ignore_patterns)?);
		if !package_jar.is_file() {
			return Err(anyhow!(
				"Server package {:?} doesn't contain package.jar",
				package_dir
			));
		}
		files.push(FileMapping(
			package_jar,
			PathBuf::from(format!(
				"{}.jar",
				config.package.load_manifest()?.full_name()
			)),
		));

		// Plugins
		files.extend(config.plugins_mapping(ignore_patterns)?);
		for plugin in &config.plugins {
			let plugin_path = plugin.get_path()?;
			let jar_path = plugin_path.join("package.jar");
			if !jar_path.is_file() {
				return Err(anyhow!(
					"Plugin {:?} doesn't contain package.jar",
					plugin_path
				));
			}
			files.push(FileMapping(
				jar_path,
				PathBuf::from(format!(
					"plugins/{}.jar",
					plugin.load_manifest()?.full_name()
				)),
			));
		}

		debug!("Files: {:?}", files);

		find_collisions(&files)?;

		Ok(files.iter().map(|f| LinkTypes::Copy(f.clone())).collect())
	}
}

impl Server for SpigotConfig {
	fn prepare_directory(&self, config: &ServerConfig, directory: &Path) -> anyhow::Result<()> {
		let prev_state = ServerState::from(directory.to_path_buf().join(".state.json"));

		let mut files = self.prepare_packages(config, directory)?;

		// Generators
		// eula.txt
		files.push(LinkTypes::Raw(
			"eula=true".to_string(),
			PathBuf::from("eula.txt"),
		));

		// LuckPerms
		if let Some(permissions) = &self.permissions {
			for permission in permissions {
				files.extend(permission.generate(config)?);
			}
			files.push(LinkTypes::MergeYAML(
				serde_yaml::to_value(serde_json::json!(
					{
						"split-storage": {
							"enabled": true,
							"methods": {
								"group": "json",
							}
						},
					}
				))?,
				PathBuf::from("plugins/LuckPerms/config.yml"),
			))
		}

		// Configs
		if let Some(configs) = &config.configs {
			for config in configs {
				config.file.process(&mut files, config)?;
			}
		}

		check_configs_purity(&files)?;

		let state = ServerState {
			paths: files.iter().map(|p| p.get_path()).collect(),
		};

		let state_content = serde_json::to_string(&state)?;
		files.push(LinkTypes::Raw(state_content, ".state.json".into()));

		let diff = diff_states(&state, &prev_state);
		for path in &diff {
			remove_with_parent(&directory.join(path));
		}
		if !diff.is_empty() {
			info!("Removed {} diffed files", diff.len());
		}

		debug!("Final files: {:#?}", &files);

		link_files(directory, &files)?;

		info!("Linked {} files", files.len());

		Ok(())
	}

	fn run_server(&self, config: &ServerConfig, directory: &Path) -> anyhow::Result<()> {
		if let Some(command) = &config.command {
			let server_path = self.get_server_path(config)?;
			let command = command.replace("{}", server_path.to_str().unwrap());
			debug!("Running command: {}", command);
			let spl: Vec<&str> = command.split(' ').collect();
			let mut process = Command::new(spl[0])
				.current_dir(directory)
				.args(&spl[1..])
				.spawn()?;
			info!("Started server process, following output");
			let _ = process.wait();
			info!("Server process exited");
			return Ok(());
		}
		Err(anyhow!("No command specifed"))
	}
}
