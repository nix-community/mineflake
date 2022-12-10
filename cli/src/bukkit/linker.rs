use std::path::PathBuf;

use crate::structures::bukkit::{BukkitPackage, BukkitPackageManifest, BukkitServer};

pub fn load_package_config(
    directory: &PathBuf,
) -> Result<BukkitPackageManifest, Box<dyn std::error::Error>> {
    let config_path = directory.join("package.yml");
    if !config_path.is_file() {
        return Err(format!("Configuration file {:?} does not exist", config_path).into());
    }

    let config_data = std::fs::read_to_string(config_path)?;
    let config = serde_yaml::from_str(&config_data).expect("Failed to load configuration");

    Ok(config)
}

fn iterate(path: &PathBuf) -> Result<Vec<PathBuf>, Box<dyn std::error::Error>> {
    let mut paths: Vec<PathBuf> = Vec::new();

    for entry in std::fs::read_dir(path)? {
        let entry = entry.expect("Failed to read directory");
        let path = entry.path();
        if path.is_dir() {
            paths.extend(iterate(&path).expect("Failed to iterate directory"));
        } else if path.is_file() {
            paths.push(path.clone());
        }
    }

    Ok(paths)
}

pub fn package_files(
    directory: &PathBuf,
) -> Result<Vec<(PathBuf, PathBuf)>, Box<dyn std::error::Error>> {
    if !directory.join("package.jar").is_file() {
        return Err("Package jar does not exist".into());
    }

    let directory_contents = iterate(directory).expect("Failed to iterate directory");

    // Remove "{directory}/package.jar" and "{directory}/package.yml" from the list
    // Remove "{directory}/" from the start of each path
    let directory_contents: Vec<(PathBuf, PathBuf)> = directory_contents
        .into_iter()
        .filter(|path| {
            path != &directory.join("package.jar") && path != &directory.join("package.yml")
        })
        .map(|path| {
            let stripped_str = path
                .strip_prefix(directory)
                .expect("Failed to strip prefix");
            let stripped_path = PathBuf::from(stripped_str);
            (path, stripped_path)
        })
        .collect();

    debug!(
        "{:?} directory contents: {:?}",
        directory, directory_contents
    );

    Ok(directory_contents)
}

pub fn server_files(
    server: &BukkitServer,
) -> Result<Vec<(PathBuf, PathBuf)>, Box<dyn std::error::Error>> {
    let mut files: Vec<(PathBuf, PathBuf)> = Vec::new();

    let server_package = match &server.package {
        BukkitPackage::Local(local) => &local.path,
        _ => todo!("Remote packages are not yet supported"),
    };
    let server_config = load_package_config(&server_package).expect("Failed to load server config");

    files.extend(package_files(&server_package).expect("Failed to get server files"));
    files.push((
        server_package.join("package.jar"),
        PathBuf::from(format!(
            "{}-{}.jar",
            server_config.name, server_config.version
        )),
    ));

    for plugin in &server.plugins {
        let plugin_package = match &plugin {
            BukkitPackage::Local(local) => &local.path,
            _ => todo!("Remote packages are not yet supported"),
        };
        let plugin_config =
            load_package_config(&plugin_package).expect("Failed to load plugin config");

        files.extend(package_files(&plugin_package).expect("Failed to get plugin files"));
        files.push((
            plugin_package.join("package.jar"),
            PathBuf::from(format!(
                "plugins/{}-{}.jar",
                plugin_config.name, plugin_config.version
            )),
        ));
    }

    // Find collisions
    let mut collisions: Vec<PathBuf> = Vec::new();

    for (i, (_, path)) in files.iter().enumerate() {
        for (j, (_, other_path)) in files.iter().enumerate() {
            if i == j {
                continue;
            }

            if path == other_path {
                collisions.push(path.clone());
            }
        }
    }

    if !collisions.is_empty() {
        return Err(format!("Found collisions in server files: {:?}", collisions).into());
    }

    Ok(files)
}

pub fn link(
    directory: &PathBuf,
    files: &Vec<(PathBuf, PathBuf)>,
) -> Result<(), Box<dyn std::error::Error>> {
    for (source, destination) in files {
        let destination = directory.join(destination);
        let destination_parent = destination.parent().expect("Failed to get parent");

        if !destination_parent.is_dir() {
            std::fs::create_dir_all(destination_parent).expect("Failed to create directory");
        }

        std::fs::copy(source, destination).expect("Failed to copy file");
    }

    Ok(())
}
