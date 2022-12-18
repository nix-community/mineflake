use std::env;

/// Initialize the logger.
pub fn initialize_logger() {
	if env::var("RUST_LOG").is_err() {
		env::set_var("RUST_LOG", "info");
	}
	pretty_env_logger::init();
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_logger_init() {
		initialize_logger();
		assert_eq!(2 + 2, 4);
	}
}
