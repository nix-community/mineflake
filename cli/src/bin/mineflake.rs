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
        #[clap(default_value = "mineflake.yml", long = "config", short = 'c')]
        config: PathBuf,
        /// Directory to apply configuration. If not specified, the current directory will be used.
        directory: Option<PathBuf>,
    },

    /// Generate a configuration.
    Generate {
        /// Server type to generate configuration for. Currently only Bukkit is supported.
        #[clap(default_value = "bukkit")]
        server: String,
        /// Configuration path. If not specified, a configuration will be printed to stdout.
        #[clap(long = "output", short = 'o')]
        config: Option<PathBuf>,
        /// File format to use. Possible values: yaml, json. Defaults to yaml.
        #[clap(long = "format", short = 'f', default_value = "yaml")]
        format: String,
    },
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    mineflake::utils::initialize_logger();

    let cli = Cli::parse();

    // You can check for the existence of subcommands, and if found use their
    // matches just as you would the top level cmd
    match &cli.command {
        Some(Commands::Apply { config, directory }) => {
            mineflake::commands::apply(config, directory)?
        }
        Some(Commands::Generate {
            server,
            config,
            format,
        }) => mineflake::commands::generate(server, config, format)?,
        None => {
            error!("No subcommand was used. Use --help for more information.");
        }
    }

    Ok(())
}
