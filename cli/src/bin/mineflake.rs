#[cfg(not(feature = "cli"))]
compile_error!("For compiling binary, you need to enable `cli` feature");

#[macro_use]
extern crate log;

use std::{env::current_dir, path::PathBuf};

use clap::{Parser, Subcommand};
use mineflake::{self, structures::common::ServerConfig};

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
		/// Whether to run server after applying configuration.
		#[clap(default_value = "false", long = "run", short = 'r')]
		run: bool,
		/// Directory to apply configuration. If not specified, the current directory will be used.
		directory: Option<PathBuf>,
	},
	/// Run server.
	Run {
		/// Configuration to apply.
		#[clap(default_value = "mineflake.yml", long = "config", short = 'c')]
		config: PathBuf,
		/// Directory to apply configuration. If not specified, the current directory will be used.
		directory: Option<PathBuf>,
	},
	/// Vendor packages.
	///
	/// Packages will be downloaded or moved to cache directory (you can override it with `MINEFLAKE_CACHE` environment variable).
	///
	/// This is useful for CI/CD, when you want to cache plugins and don't want to download them every time.
	/// Or if you want to use remote packages with Nix and fixed-output derivations.
	///
	/// This command is only available with `net` feature.
	Vendor {
		/// Configuration to take plugins from.
		#[clap(default_value = "mineflake.yml", long = "config", short = 'c')]
		config: PathBuf,
		/// Thread count to use for processing.
		/// If not specified, the number of logical CPU cores will be used.
		#[clap(long = "threads", short = 't')]
		threads: Option<usize>,
	},
}
fn main() -> Result<(), Box<dyn std::error::Error>> {
	mineflake::utils::initialize_logger();

	const VERSION: &str = env!("CARGO_PKG_VERSION");
	debug!("Running mineflake v{}", VERSION);

	let cli = Cli::parse();

	// You can check for the existence of subcommands, and if found use their
	// matches just as you would the top level cmd
	match &cli.command {
		Some(Commands::Apply {
			config,
			directory,
			run,
		}) => {
			let config = ServerConfig::from(config.clone());
			let directory = match directory {
				Some(dir) => dir.clone(),
				None => current_dir()?,
			};

			config.server.prepare_directory(&config, &directory)?;
			if *run {
				config.server.run_server(&config, &directory)?;
			}
		}
		Some(Commands::Run { config, directory }) => {
			let config = ServerConfig::from(config.clone());
			let directory = match directory {
				Some(dir) => dir.clone(),
				None => current_dir()?,
			};

			config.server.run_server(&config, &directory)?;
		}
		#[cfg(feature = "net")]
		Some(Commands::Vendor { config, threads }) => {
			let threads = match threads {
				Some(threads) => *threads,
				None => num_cpus::get(),
			};
			debug!("Using {} threads for downloading packages.", threads);
			let config = ServerConfig::from(config.clone());
			config.download_packages(threads)?;
		}
		#[cfg(not(feature = "net"))]
		Some(Commands::Vendor {
			config: _,
			threads: _,
		}) => {
			return Err("Vendoring is not supported without `net` feature.".into());
		}
		None => {
			return Err("No subcommand was used. Use --help for more information.".into());
		}
	}

	Ok(())
}
