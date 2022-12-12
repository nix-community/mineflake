use crate::structures::common::{FileMapping, ServerConfig};
use anyhow::Result;

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
