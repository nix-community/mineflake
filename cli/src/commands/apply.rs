use std::{env::current_dir, path::PathBuf};

pub fn apply(
    config: &PathBuf,
    directory: &Option<PathBuf>,
) -> Result<(), Box<dyn std::error::Error>> {
    let directory = match directory {
        Some(directory) => directory.clone(),
        None => current_dir().expect("Failed to get current directory working directory"),
    };
    if !config.is_file() {
        return Err("Configuration file does not exist".into());
    }
    info!(
        "Applying configuration {:?} to directory {:?}",
        config, directory
    );

    Ok(())
}
