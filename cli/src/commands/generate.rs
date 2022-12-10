use crate::structures::*;
use std::path::PathBuf;

pub fn generate(
    server: &String,
    config: &Option<PathBuf>,
) -> Result<(), Box<dyn std::error::Error>> {
    let config_data = match server.to_lowercase().as_str() {
        "bukkit" => Server::Bukkit(bukkit::BukkitServer::get_example_server()),
        _ => {
            return Err("Unsupported server type".into());
        }
    };

    let config_text =
        serde_yaml::to_string(&config_data).expect("Failed to serialize configuration");

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
