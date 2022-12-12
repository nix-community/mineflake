use std::path::PathBuf;

use crate::structures::common::{FileMapping, ServerConfig};
use anyhow::Result;

use super::linker::LinkTypes;

/// Try to load Server configuration from string.
pub fn load_config(config_data: &str) -> Result<ServerConfig> {
	let config: ServerConfig = match serde_yaml::from_str(config_data) {
		Ok(config) => config,
		Err(e1) => match serde_json::from_str(config_data) {
			Ok(config) => config,
			Err(e2) => {
				debug!("Error 1 while parsing yaml: {}", e1);
				debug!("Error 2 while parsing json: {}", e2);
				return Err(anyhow!("Error parsing config file: {:?} and {:?}", e1, e2));
			}
		},
	};

	debug!("Loaded configuration {:#?}", config);

	Ok(config)
}

/// Find collisions in file mappings.
pub fn find_collisions(files: &Vec<FileMapping>) -> Result<()> {
	for (i, mapping1) in files.iter().enumerate() {
		for (j, mapping2) in files.iter().enumerate() {
			if i == j {
				continue;
			}

			if mapping1.1 == mapping2.1 {
				return Err(anyhow!(
					"Found collision in file mappings: {:?}",
					mapping1.1,
				));
			}
		}
	}

	Ok(())
}

pub fn check_configs_purity(configs: &Vec<LinkTypes>) -> Result<()> {
	let mut pure_paths: Vec<PathBuf> = Vec::new();
	for config in configs {
		match config {
			LinkTypes::Copy(mapping) => {
				pure_paths.push(mapping.1.clone());
			}
			LinkTypes::Raw(_, path) => {
				pure_paths.push(path.clone());
			}
			LinkTypes::MergeJSON(_, path) => {
				if !pure_paths.contains(path) {
					return Err(anyhow!("Found impure file mapping: {:?}", path));
				}
			}
			LinkTypes::MergeYAML(_, path) => {
				if !pure_paths.contains(path) {
					return Err(anyhow!("Found impure file mapping: {:?}", path));
				}
			}
		}
	}
	Ok(())
}

#[cfg(test)]
mod tests {
	use super::*;
	use std::path::PathBuf;

	#[test]
	fn test_find_collisions() {
		let files = vec![
			FileMapping(PathBuf::from("a"), PathBuf::from("b")),
			FileMapping(PathBuf::from("c"), PathBuf::from("d")),
			FileMapping(PathBuf::from("e"), PathBuf::from("f")),
		];
		assert_eq!(find_collisions(&files).is_ok(), true);
	}

	#[test]
	fn test_find_collisions_collision() {
		let files = vec![
			FileMapping(PathBuf::from("a"), PathBuf::from("b")),
			FileMapping(PathBuf::from("c"), PathBuf::from("d")),
			FileMapping(PathBuf::from("e"), PathBuf::from("f")),
			FileMapping(PathBuf::from("g"), PathBuf::from("d")),
		];
		assert_eq!(find_collisions(&files).is_ok(), false);
	}

	#[test]
	fn test_check_configs_purity() {
		let configs = vec![
			LinkTypes::Raw("".to_string(), PathBuf::from("d")),
			LinkTypes::MergeJSON(
				serde_json::Value::Object(serde_json::Map::new()),
				PathBuf::from("d"),
			),
		];
		assert_eq!(check_configs_purity(&configs).is_ok(), true);
	}

	#[test]
	fn test_check_configs_purity_impure() {
		let configs = vec![
			LinkTypes::Raw("".to_string(), PathBuf::from("d")),
			LinkTypes::MergeJSON(
				serde_json::Value::Object(serde_json::Map::new()),
				PathBuf::from("e"),
			),
		];
		assert_eq!(check_configs_purity(&configs).is_ok(), false);
	}
}
