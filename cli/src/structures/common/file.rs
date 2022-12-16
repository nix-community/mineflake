use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

use crate::utils::linker::LinkTypes;

#[derive(Debug, Clone)]
pub struct FileMapping(pub PathBuf, pub PathBuf);

/// Configuration file config
///
/// This is used to generate config files in the server directory without writing
/// custom packages. This is useful for updating/generating config files that are not
/// included in the server/plugins package.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct FileConfig {
	pub path: PathBuf,
	#[serde(flatten)]
	pub file: FileConfigEnum,
}

/// Config file types
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum FileConfigEnum {
	/// Raw file content
	Raw(RawFileConfig),
	/// JSON file content
	Json(JsonFileConfig),
	/// YAML file content
	Yaml(YamlFileConfig),
	/// Merge JSON files
	MergeJson(MergeJsonFileConfig),
	/// Merge YAML files
	MergeYaml(MergeYamlFileConfig),
}

impl FileConfigEnum {
	/// Processes the file config and inserts the result into the files vector
	pub fn process(&self, files: &mut Vec<LinkTypes>, config: &FileConfig) -> Result<()> {
		match self {
			Self::Raw(raw) => {
				files.push(LinkTypes::Raw(raw.content.clone(), config.path.clone()));
			}
			Self::Json(json) => {
				files.push(LinkTypes::Raw(
					serde_json::to_string(&json.content)?,
					config.path.clone(),
				));
			}
			Self::Yaml(yaml) => {
				files.push(LinkTypes::Raw(
					serde_yaml::to_string(&yaml.content)?,
					config.path.clone(),
				));
			}
			Self::MergeJson(json) => {
				files.push(LinkTypes::MergeJSON(
					json.content.clone(),
					config.path.clone(),
				));
			}
			Self::MergeYaml(yaml) => {
				files.push(LinkTypes::MergeYAML(
					yaml.content.clone(),
					config.path.clone(),
				));
			}
		}
		Ok(())
	}
}

/// Raw file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct RawFileConfig {
	/// The string content
	pub content: String,
}

/// JSON file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JsonFileConfig {
	/// The complex json content
	pub content: serde_json::Value,
}

/// YAML file content
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct YamlFileConfig {
	/// The complex yaml content
	pub content: serde_yaml::Value,
}

/// Merge JSON files
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MergeJsonFileConfig {
	/// The json config, that will be merged with the previous configs
	pub content: serde_json::Value,
}

/// Merge YAML files
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct MergeYamlFileConfig {
	/// The yaml config, that will be merged with the previous configs
	pub content: serde_yaml::Value,
}
