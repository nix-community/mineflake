use std::{fs, env};
use std::path::PathBuf;
use clap::{Parser, Subcommand};

#[derive(clap::ValueEnum, Clone, Debug)]
enum DataType {
  Json,
	Yaml,
	Toml,
}

#[derive(Parser)]
#[clap(author, version, about, long_about = None)]
struct Cli {
	#[clap(subcommand)]
	command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
	/// Convert one data format to another
	Convert {
		/// To data format
		#[clap(short, long, value_enum)]
		to: DataType,
		/// Path to read from
    #[clap(short, long, value_parser, value_name = "FILE")]
    path: PathBuf,
	},

	ReplaceSecrets {
		/// Path to read from
    #[clap(value_parser, value_name = "FILE")]
    path: PathBuf,
	},
}

fn convert(to: &DataType, data: &str ) -> String {
	let from_struct: serde_json::Value = serde_json::from_str(data).expect("cannot deserialize data");
	match to {
		DataType::Json => serde_json::to_string(&from_struct).expect("cannot serialize data"),
		DataType::Yaml => serde_yaml::to_string(&from_struct).expect("cannot serialize data"),
		DataType::Toml => toml::to_string(&from_struct).expect("cannot serialize data"),
	}
}

fn replace_secrets(data: String) -> String {
	let mut text = data;
	for var in env::vars() {
		text = text.replace(&format!("#{}#", var.0), &var.1);
	};
	text
}

fn main() {
	let cli = Cli::parse();

	match &cli.command {
		Some(Commands::Convert { to, path }) => {
			print!("{}", convert(to, &fs::read_to_string(path).expect("cannot read file")))
		}
		Some(Commands::ReplaceSecrets { path }) => {
			print!("{}", replace_secrets(fs::read_to_string(path).expect("cannot read file")))
		}
		None => {
			println!("Call --help flag!")
		}
	}
}
