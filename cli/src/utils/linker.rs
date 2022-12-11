use anyhow::Result;
use std::{
	fs::{copy, create_dir_all, File},
	io::Write,
	path::PathBuf,
};

use crate::structures::common::{FileMapping, ServerState};

pub enum LinkTypes {
	Copy(FileMapping),
	Raw(String, PathBuf),
}

impl LinkTypes {
	pub fn get_path(&self) -> PathBuf {
		match &self {
			Self::Copy(f) => f.1.clone(),
			Self::Raw(_, p) => p.clone(),
		}
	}
}

pub fn link_files(directory: &PathBuf, files: &Vec<LinkTypes>) -> Result<()> {
	for file in files {
		match file {
			LinkTypes::Copy(mapping) => {
				let dest_path = directory.join(&mapping.1);
				let parent = dest_path.parent().expect("Unable to get parent of path");
				debug!("Linking Copy: from {:?} to {:?}", &mapping.0, &dest_path);
				create_dir_all(parent)?;
				copy(&mapping.0, dest_path)?;
			}
			LinkTypes::Raw(content, local_dest) => {
				let dest_path = directory.join(local_dest);
				let parent = dest_path.parent().expect("Unable to get parent of path");
				debug!("Linking Raw: to {:?}", &dest_path);
				create_dir_all(parent)?;
				let mut file = File::create(dest_path)?;
				file.write_all(content.as_bytes())?;
			}
		}
	}

	Ok(())
}

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
