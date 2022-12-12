pub mod config;
pub mod linker;
mod log;
pub mod merge;

pub use self::log::initialize_logger;
pub use config::load_config;
