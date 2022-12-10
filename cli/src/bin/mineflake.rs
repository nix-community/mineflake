#[macro_use]
extern crate log;

use std::path::PathBuf;

use clap::{Parser, Subcommand};
use mineflake;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Apply a configuration to directory.
    Apply {
        /// Configuration to apply.
        config: PathBuf,
        /// Directory to apply configuration.
        directory: Option<PathBuf>,
    },

    /// Generate a configuration.
    Generate {
        /// Server type to generate configuration for. Currently only Bukkit is supported.
        server: String,
        /// Configuration path. If not specified, a configuration will be printed to stdout.
        config: Option<PathBuf>,
    },
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    mineflake::utils::log::initialize_logger();

    let cli = Cli::parse();

    // You can check for the existence of subcommands, and if found use their
    // matches just as you would the top level cmd
    match &cli.command {
        Some(Commands::Apply { config, directory }) => {
            mineflake::commands::apply(config, directory)?
        }
        Some(Commands::Generate { server, config }) => {
            mineflake::commands::generate(server, config)?
        }
        None => {
            error!("No subcommand was used. Use --help for more information.");
        }
    }

    Ok(())
}
