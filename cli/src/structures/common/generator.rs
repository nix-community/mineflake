use super::ServerConfig;
use crate::utils::linker::LinkTypes;
use anyhow::Result;

/// Generator trait
///
/// Generator is a method that generates the server files from the given config.
/// For example, generators allows configure LuckPerms configs declaratively
/// from the config file, without having to write a bunch of configs entries.
pub trait Generator {
	/// Generates the server files from the given config
	fn generate(&self, config: &ServerConfig) -> Result<Vec<LinkTypes>>;
}
