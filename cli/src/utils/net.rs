use anyhow::Result;
use std::{
	env::var,
	fs::{create_dir_all, File},
	io,
	path::PathBuf,
};

/// Download a file from a URL to a local path.
pub fn download_file(url: &url::Url, path: &PathBuf) -> Result<()> {
	let url = url.clone();
	debug!("Downloading {} to {:?}", url, path);
	// Check if path is not a directory
	if path.is_dir() {
		return Err(anyhow!("Path is a directory"));
	}
	// Create the parent directory if it doesn't exist
	let parent = path.parent().unwrap();
	create_dir_all(parent)?;
	// Download the file
	let mut resp = reqwest::blocking::get(url)?;
	let mut out = File::create(path)?;
	io::copy(&mut resp, &mut out)?;
	Ok(())
}

/// Get path to cache directory
///
/// This function will return the path to the $HOME/.cache directory, or to /tmp/mineflake if $HOME is not set.
/// On Windows, this function will return the path to the %LOCALAPPDATA% directory, or to %TEMP% if %LOCALAPPDATA% is not set.
pub fn get_cache_dir() -> PathBuf {
	#[cfg(target_os = "windows")]
	{
		let path = var("MINEFLAKE_CACHE").unwrap_or_else(|_| {
			var("TEMP").unwrap_or_else(|_| {
				var("LOCALAPPDATA").unwrap_or_else(|_| {
					var("TEMP").unwrap_or_else(|_| "C:\\Windows\\Temp".to_string())
				})
			})
		});
		let mut path = PathBuf::from(path);
		path.push("mineflake");
		path
	}
	#[cfg(not(target_os = "windows"))]
	{
		let path = var("MINEFLAKE_CACHE")
			.unwrap_or_else(|_| var("HOME").unwrap_or_else(|_| "/tmp".to_string()));
		let mut path = PathBuf::from(path);
		path.push(".cache");
		path.push("mineflake");
		path
	}
}

/// Split a hash into 4 parts of 2 characters each and remaining characters
pub fn split_hash(hash: &str) -> PathBuf {
	let mut path = PathBuf::new();
	let mut chars = hash.chars();
	for _ in 0..4 {
		path.push(chars.by_ref().take(2).collect::<String>());
	}
	path.push(chars.collect::<String>());
	path
}

/// Get sha256 hash of URL and download it to cache directory $CACHE_DIR/$HA/SH
///
/// Download only if file doesn't exist in cache directory.
///
/// # Returns
/// sha256 hash of URL
pub fn download_file_to_cache(url: &url::Url, extension: &str) -> Result<String> {
	let hash = sha256::digest(url.to_string().as_bytes());
	let hash_path = split_hash(&hash);
	let mut path = get_cache_dir();
	path.push(hash_path);
	path.set_extension(extension);
	if !path.exists() {
		download_file(url, &path)?;
	} else {
		debug!("File already exists in cache");
	}
	Ok(hash)
}

/// Get sha256 hash of URL and download it to cache directory $CACHE_DIR/$HA/SH.$EXTENSION
/// and return the full path to the file.
pub fn download_file_to_cache_full_path(url: &url::Url, extension: &str) -> Result<PathBuf> {
	let hash = download_file_to_cache(url, extension)?;
	let hash_path = split_hash(&hash);
	let mut path = get_cache_dir();
	path.push(hash_path);
	path.set_extension(extension);
	Ok(path)
}

/// Unzip a $CACHE_DIR/$HA/SH.zip file to $CACHE_DIR/$HA/SH
pub fn unzip_file_from_cache(hash: &str) -> Result<PathBuf> {
	let cache = get_cache_dir();
	let hash_path = split_hash(hash);
	let mut zip_path = cache.clone();
	zip_path.push(&hash_path);
	zip_path.set_extension("zip");
	let mut dir_path = cache;
	dir_path.push(&hash_path);
	if dir_path.exists() {
		return Ok(dir_path);
	}
	if !zip_path.exists() {
		return Err(anyhow!("File doesn't exist in cache"));
	}
	if !dir_path.exists() {
		zip::read::ZipArchive::new(File::open(zip_path)?)?.extract(&dir_path)?;
	} else {
		debug!("File already unzipped in cache");
	}
	Ok(dir_path)
}

/// Download a file from a URL to a local path, and unzip it.
pub fn download_and_unzip_file(url: &url::Url) -> Result<PathBuf> {
	let hash = download_file_to_cache(url, "zip")?;
	unzip_file_from_cache(&hash)
}

#[cfg(test)]
mod tests {
	#[test]
	pub fn test_split_hash() {
		assert_eq!(
			super::split_hash("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"),
			std::path::PathBuf::from(
				"01/23/45/67/89abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
			)
		);
	}
}
