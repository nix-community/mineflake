use crate::{
    bukkit::linker::{link, server_files},
    structures::{Server, ServerState},
    utils::load_config,
};
use std::{env::current_dir, path::PathBuf};

pub fn apply(
    config: &PathBuf,
    directory: &Option<PathBuf>,
) -> Result<(), Box<dyn std::error::Error>> {
    let directory = match directory {
        Some(directory) => directory.clone(),
        None => current_dir().expect("Failed to get current directory working directory"),
    };
    if !directory.is_dir() {
        return Err("Directory does not exist".into());
    }
    if !config.is_file() {
        return Err("Configuration file does not exist".into());
    }
    info!(
        "Applying configuration {:?} to directory {:?}",
        config, directory
    );

    let config_data = std::fs::read_to_string(config)?;
    let config = load_config(&config_data).expect("Failed to load configuration");

    match config {
        Server::Bukkit(config) => {
            let files = server_files(&config).expect("Failed to get server files");
            debug!("Files to be applied: {:?}", files);

            let paths = files
                .iter()
                .map(|(_, path)| path.clone())
                .collect::<Vec<PathBuf>>();

            // Load previous state, if it exists
            let state_path = directory.join("state.json");
            let state_data = match std::fs::read_to_string(&state_path) {
                Ok(state_data) => Some(state_data),
                Err(_) => {
                    debug!("No previous state found");
                    None
                }
            };
            let state = match state_data {
                Some(state_data) => {
                    let state: ServerState =
                        serde_json::from_str(&state_data).expect("Failed to load previous state");
                    state
                }
                None => ServerState {
                    paths: paths.clone(),
                },
            };

            link(&directory, &files).expect("Failed to link files");

            // Diff state and remove files that are no longer needed
            let mut diff: Vec<PathBuf> = Vec::new();
            for path in state.paths {
                if !paths.contains(&path) {
                    diff.push(path.clone());
                }
            }
            debug!("Files to be removed: {:?}", diff);

            for path in diff {
                let path = directory.join(path);
                debug!("Removing file {:?}", &path);
                let _ = std::fs::remove_file(&path);
                // Delete parent directory if it is empty
                let parent = match path.parent() {
                    Some(parent) => parent.to_path_buf(),
                    None => continue,
                };
                let read_dir = match parent.read_dir() {
                    Ok(read_dir) => read_dir,
                    Err(_) => continue,
                };
                if read_dir.count() == 0 {
                    debug!("Removing directory {:?}", parent);
                    let _ = std::fs::remove_dir(parent);
                }
            }

            // Save state
            let state_data = serde_json::to_string(&ServerState {
                paths: paths.clone(),
            })
            .expect("Failed to serialize state");
            std::fs::write(&state_path, state_data).expect("Failed to save state");
        }
    }

    Ok(())
}
