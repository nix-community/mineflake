use std::path::PathBuf;

use serde::{Deserialize, Serialize};

use super::bukkit::BukkitServer;

/// Mineflake server configuration.
#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum Server {
    /// Bukkit-based server.
    Bukkit(BukkitServer),
}

/// Current state of the server.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ServerState {
    /// Generated server paths that are save to delete.
    pub paths: Vec<PathBuf>,
}

/// Types of files that can be generated.
#[derive(Debug)]
pub enum GeneratedFileType {
    File(PathBuf),
    Yaml(serde_yaml::Value),
    Json(serde_json::Value),
    Raw(String),
}
