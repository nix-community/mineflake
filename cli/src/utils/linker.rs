use anyhow::Result;
use std::{
	env::vars,
	fs::{copy, create_dir_all, File},
	io::Write,
	path::PathBuf,
};

use crate::{
	structures::common::{FileMapping, ServerState},
	utils::merge::merge_json,
};

/// A type of file to link
#[derive(Debug)]
pub enum LinkTypes {
	/// Copy a file from one path to another
	Copy(FileMapping),

	/// Write a raw string to a file
	///
	/// The first argument is the content, the second is the path.
	/// Used for writing config files.
	Raw(String, PathBuf),

	/// Merge a JSON file with another
	MergeJSON(serde_json::Value, PathBuf),

	/// Merge a YAML file with another
	MergeYAML(serde_yaml::Value, PathBuf),
}

impl LinkTypes {
	/// Get the path of the file to link
	pub fn get_path(&self) -> PathBuf {
		match &self {
			Self::Copy(f) => f.1.clone(),
			Self::Raw(_, p) => p.clone(),
			Self::MergeJSON(_, p) => p.clone(),
			Self::MergeYAML(_, p) => p.clone(),
		}
	}
}

/// Write a file to the given path, replacing {{VAR}} with the value of the environment variable VAR
fn write_file(path: &PathBuf, content: &str) -> Result<()> {
	let mut file = File::create(&path)?;
	let mut content = content.to_string();
	for var in vars() {
		// {{VAR}}
		content = content.replace(&format!("{{{{{}}}}}", var.0), &var.1);
	}
	file.write_all(content.as_bytes())?;
	Ok(())
}

/// Link files to the given directory
pub fn link_files(directory: &PathBuf, files: &Vec<LinkTypes>) -> Result<()> {
	for file in files {
		debug!("Linking {:?}", file);
		let dest_path = directory.join(file.get_path());
		let parent = dest_path.parent().unwrap();
		create_dir_all(parent)?;
		match file {
			LinkTypes::Copy(mapping) => {
				copy(&mapping.0, dest_path)?;
			}
			LinkTypes::Raw(content, _) => {
				write_file(&dest_path, content)?;
			}
			LinkTypes::MergeJSON(content, _) => {
				let mut new_content = if dest_path.is_file() {
					// Load the existing file
					// If errors occur, use an empty object
					if let Ok(read) = std::fs::read_to_string(&dest_path) {
						if let Ok(obj) = serde_json::from_str(&read) {
							obj
						}
					}
					serde_json::Value::Object(serde_json::Map::new())
				} else {
					serde_json::Value::Object(serde_json::Map::new())
				};
				merge_json(&mut new_content, &content);
				write_file(&dest_path, &serde_json::to_string(&new_content)?)?;
			}
			LinkTypes::MergeYAML(content, _) => {
				let mut new_content: serde_json::Value = if dest_path.is_file() {
					// Load the existing file
					// If errors occur, use an empty object
					let mut ret = None;
					if let Ok(read) = std::fs::read_to_string(&dest_path) {
						if let Ok(obj) = serde_yaml::from_str::<serde_yaml::Value>(&read) {
							if let Ok(val) = serde_json::to_value(obj) {
								ret = Some(val);
							}
						}
					};
					// If the above fails, use an empty object
					if ret.is_none() {
						ret = Some(serde_json::Value::Object(serde_json::Map::new()));
					}
					ret.unwrap()
				} else {
					serde_json::Value::Object(serde_json::Map::new())
				};
				let content = &serde_json::to_value(content)?;
				merge_json(&mut new_content, &content);
				write_file(&dest_path, &serde_yaml::to_string(&new_content)?)?;
			}
		}
	}

	Ok(())
}

/// Diff two server states and return a list of paths that are in the previous state but not in the current state
///
/// This is used to remove files that are no longer needed.
pub fn diff_states(curr_state: &ServerState, prev_state: &ServerState) -> Vec<PathBuf> {
	let mut out = Vec::new();
	for prev_path in &prev_state.paths {
		let mut collision = false;
		for curr_path in &curr_state.paths {
			if prev_path == curr_path {
				collision = true;
				break;
			}
		}
		if !collision {
			out.push(prev_path.clone());
		}
	}
	out
}

/// Remove a file and its parent directory if it is empty
pub fn remove_with_parent(path: &PathBuf) {
	debug!("Removing file {:?}", &path);
	let _ = std::fs::remove_file(&path);
	// Delete parent directory if it is empty
	let parent = match path.parent() {
		Some(parent) => parent.to_path_buf(),
		None => return,
	};
	let read_dir = match parent.read_dir() {
		Ok(read_dir) => read_dir,
		Err(_) => return,
	};
	if read_dir.count() == 0 {
		debug!("Removing empty directory {:?}", parent);
		let _ = std::fs::remove_dir(parent);
	}
}
