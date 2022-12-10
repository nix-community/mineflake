use crate::structures::*;
use std::path::PathBuf;

pub fn generate(
    server: &String,
    config: &Option<PathBuf>,
    format: &String,
) -> Result<(), Box<dyn std::error::Error>> {
    let config_data = match server.to_lowercase().as_str() {
        "bukkit" => Server::Bukkit(bukkit::BukkitServer::get_example_server()),
        _ => {
            return Err("Unsupported server type".into());
        }
    };

    let config_text = match format.as_str() {
        "json" => {
            serde_json::to_string_pretty(&config_data).expect("Failed to serialize configuration")
        }
        "yaml" => serde_yaml::to_string(&config_data).expect("Failed to serialize configuration"),
        _ => {
            return Err("Unsupported format".into());
        }
    };

    match config {
        Some(config) => {
            std::fs::write(config, config_text)?;
        }
        None => {
            println!("{}", config_text);
        }
    };

    Ok(())
}
