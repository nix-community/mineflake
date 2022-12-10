use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use url::Url;

/// Configuration for a Bukkit-based server.
#[derive(Serialize, Deserialize, Debug)]
pub struct BukkitServer {
    /// Server package.
    pub package: BukkitPackage,
    /// Server plugins.
    pub plugins: Vec<BukkitPackage>,
}

impl BukkitServer {
    /// Get server package if this server is a Bukkit server.
    pub fn get_example_server() -> Self {
        BukkitServer {
            package: BukkitPackage::Local(BukkitPackageLocal {
                path: PathBuf::from("/path/to/server.jar"),
            }),
            plugins: vec![
                BukkitPackage::Local(BukkitPackageLocal {
                    path: PathBuf::from("/path/to/plugin/data"),
                }),
                BukkitPackage::Remote(BukkitPackageRemote {
                    url: "https://example.com/plugin.zip".to_string(),
                }),
            ],
        }
    }
}

/// Package metadata.
#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum BukkitPackage {
    /// Package from a local directory.
    Local(BukkitPackageLocal),
    /// Package from a remote URL. This is a direct URL to a ZIP file.
    Remote(BukkitPackageRemote),
}

#[derive(Serialize, Deserialize, Debug)]
pub struct BukkitPackageLocal {
    /// Path to package.
    pub path: PathBuf,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct BukkitPackageRemote {
    /// Direct URL to package zip.
    pub url: String,
}

impl BukkitPackageRemote {
    /// Get remote URL if this package is remote.
    pub fn get_remote_url(&self) -> Option<Url> {
        match Url::parse(&self.url) {
            Ok(url) => Some(url),
            Err(_) => None,
        }
    }
}

/// Package package manifest. This is the `package.json` file in the package data directory.
#[derive(Serialize, Deserialize, Debug)]
pub struct BukkitPackageManifest {
    /// Plugin name.
    pub name: String,
    /// Plugin version.
    pub version: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_remote_url() {
        let package = BukkitPackageRemote {
            url: "https://example.com".to_string(),
        };
        assert_eq!(
            package.get_remote_url().unwrap(),
            Url::parse("https://example.com").unwrap()
        );
    }

    #[test]
    fn test_get_remote_url_invalid() {
        let package = BukkitPackageRemote {
            url: "invalid".to_string(),
        };
        assert_eq!(package.get_remote_url(), None);
    }
}
