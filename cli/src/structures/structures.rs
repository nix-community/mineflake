use serde::{Deserialize, Serialize};

use super::bukkit::BukkitServer;

/// Mineflake server configuration.
#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum Server {
    /// Bukkit-based server.
    Bukkit(BukkitServer),
}
