use crate::structures::Server;

pub fn load_config(config_data: &str) -> Result<Server, Box<dyn std::error::Error>> {
    let config: Server = match serde_yaml::from_str(config_data) {
        Ok(config) => config,
        Err(_) => match serde_json::from_str(config_data) {
            Ok(config) => config,
            Err(_) => {
                return Err("Failed to parse configuration".into());
            }
        },
    };

    debug!("Loaded configuration {:#?}", config);

    Ok(config)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_load_config() {
        let config = load_config(
            r#"
type: bukkit
package:
  type: local
  path: /path/to/server.jar
plugins:
- type: local
  path: /path/to/plugin/data
"#,
        )
        .expect("Failed to load configuration");

        match config {
            Server::Bukkit(_) => {}
            _ => {
                panic!("Failed to load configuration");
            }
        }
    }
}
