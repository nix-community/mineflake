use std::path::PathBuf;
use std::process::Command;

use serde::{Deserialize, Serialize};

use crate::{
	structures::common::FileConfigEnum,
	utils::{
		config::find_collisions,
		linker::{diff_states, link_files, remove_with_parent, LinkTypes},
	},
};

use super::common::{FileMapping, Server, ServerConfig, ServerState};

/// The configuration for a Spigot server
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SpigotConfig;

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
		_directory: &PathBuf,
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
	fn prepare_directory(&self, config: &ServerConfig, directory: &PathBuf) -> anyhow::Result<()> {
		let prev_state = ServerState::from(directory.clone().join(".state.json"));

		let mut files = self.prepare_packages(config, directory)?;

		// Configs
		if let Some(configs) = &config.configs {
			for config in configs {
				match &config.file {
					FileConfigEnum::Raw(raw) => {
						files.push(LinkTypes::Raw(raw.content.clone(), config.path.clone()));
					}
					FileConfigEnum::Json(json) => {
						files.push(LinkTypes::Raw(
							serde_json::to_string(&json.content)?,
							config.path.clone(),
						));
					}
					FileConfigEnum::Yaml(yaml) => {
						files.push(LinkTypes::Raw(
							serde_yaml::to_string(&yaml.content)?,
							config.path.clone(),
						));
					}
				}
			}
		}

		let state = ServerState {
			paths: files.iter().map(|p| p.get_path()).collect(),
		};

		let state_content = serde_json::to_string(&state)?;
		files.push(LinkTypes::Raw(state_content, ".state.json".into()));

		let diff = diff_states(&state, &prev_state);
		for path in &diff {
			remove_with_parent(&directory.join(path));
		}
		if diff.len() > 0 {
			info!("Removed {} diffed files", diff.len());
		}

		debug!("Final files: {:#?}", &files);

		link_files(directory, &files)?;

		info!("Linked {} files", files.len());

		Ok(())
	}

	fn run_server(&self, config: &ServerConfig, directory: &PathBuf) -> anyhow::Result<()> {
		if let Some(command) = &config.command {
			let server_path = self.get_server_path(config)?;
			let command = command.replace("{}", server_path.to_str().unwrap());
			debug!("Running command: {}", command);
			let spl: Vec<&str> = command.split(" ").collect();
			Command::new(&spl[0])
				.current_dir(directory)
				.args(&spl[1..])
				.spawn()?;
			info!("Started server process and detatched");
			return Ok(());
		}
		Err(anyhow!("No command specifed"))
	}
}
