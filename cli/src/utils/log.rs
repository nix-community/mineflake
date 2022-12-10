use pretty_env_logger;

/// Initialize the logger.
pub fn initialize_logger() {
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
