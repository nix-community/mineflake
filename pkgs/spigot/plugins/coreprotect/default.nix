{ lib, stdenv, fetchurl, ... }:

let
  hash = "sha256-BPMbYJ0ePhxT6ZqqBsoQ6mvfUXLJS/WvjM8QiwvEuXc=";
  version = "21.2";
  url = "https://github.com/PlayPro/CoreProtect/releases/download/v${version}/CoreProtect-${version}.jar";
in
stdenv.mkDerivation {
  inherit hash version;

  pname = "CoreProtect";
  src = fetchurl {
    url = url;
    hash = hash;
  };

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "CoreProtect is a blazing fast data logging and anti-griefing tool for Minecraft servers";
    longDescription = ''
      CoreProtect is a fast, efficient, data logging and anti-griefing tool. Rollback and restore any amount of damage. Designed with large servers in mind, CoreProtect will record and manage data without impacting your server performance.
    '';
    homepage = "https://www.spigotmc.org/resources/coreprotect.8631/";
    # TODO: find artistik license
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/CoreProtect/config.yml" = {
        type = "yaml";
        data = {
          "donation-key" = null;
          "use-mysql" = false;
          "table-prefix" = "co_";
          "mysql-host" = "127.0.0.1";
          "mysql-port" = 3306;
          "mysql-database" = "database";
          "mysql-username" = "root";
          "mysql-password" = null;
          "language" = "en";
          "check-updates" = true;
          "api-enabled" = true;
          "verbose" = true;
          "default-radius" = 10;
          "max-radius" = 100;
          "rollback-items" = true;
          "rollback-entities" = true;
          "skip-generic-data" = true;
          "block-place" = true;
          "block-break" = true;
          "natural-break" = true;
          "block-movement" = true;
          "pistons" = true;
          "block-burn" = true;
          "block-ignite" = true;
          "explosions" = true;
          "entity-change" = true;
          "entity-kills" = true;
          "sign-text" = true;
          "buckets" = true;
          "leaf-decay" = true;
          "tree-growth" = true;
          "mushroom-growth" = true;
          "vine-growth" = true;
          "portals" = true;
          "water-flow" = true;
          "lava-flow" = true;
          "liquid-tracking" = true;
          "item-transactions" = true;
          "item-drops" = true;
          "item-pickups" = true;
          "hopper-transactions" = true;
          "player-interactions" = true;
          "player-messages" = true;
          "player-commands" = true;
          "player-sessions" = true;
          "username-changes" = true;
          "worldedit" = true;
        };
      };
      "plugins/CoreProtect/language.yml" = {
        type = "yaml";
        data = {
          "ACTION_NOT_SUPPORTED" = "That action is not supported by the command.";
          "AMOUNT_BLOCK" = "{0} {block|blocks}";
          "AMOUNT_CHUNK" = "{0} {chunk|chunks}";
          "AMOUNT_ENTITY" = "{0} {entity|entities}";
          "AMOUNT_ITEM" = "{0} {item|items}";
          "API_TEST" = "API test successful.";
          "CACHE_ERROR" = "WARNING: Error while validating {0} cache.";
          "CACHE_RELOAD" = "Forcing reload of {mapping|world} caches from database.";
          "CHECK_CONFIG" = "Please check config.yml";
          "COMMAND_CONSOLE" = "Please run the command from the console.";
          "COMMAND_NOT_FOUND" = "Command \"{0}\" not found.";
          "COMMAND_THROTTLED" = "Please wait a moment and try again.";
          "CONSUMER_ERROR" = "Consumer queue processing already {paused|resumed}.";
          "CONSUMER_TOGGLED" = "Consumer queue processing has been {paused|resumed}.";
          "CONTAINER_HEADER" = "Container Transactions";
          "DATABASE_BUSY" = "Database busy. Please try again later.";
          "DATABASE_INDEX_ERROR" = "Unable to validate database indexes.";
          "DATABASE_LOCKED_1" = "Database locked. Waiting up to 15 seconds...";
          "DATABASE_LOCKED_2" = "Database is already in use. Please try again.";
          "DATABASE_LOCKED_3" = "To disable database locking, set \"database-lock: false\".";
          "DATABASE_LOCKED_4" = "Disabling database locking can result in data corruption.";
          "DATABASE_UNREACHABLE" = "Database is unreachable. Discarding data and shutting down.";
          "DEVELOPMENT_BRANCH" = "Development branch detected, skipping patch scripts.";
          "DIRT_BLOCK" = "Placed a dirt block under you.";
          "DISABLE_SUCCESS" = "Success! Disabled {0}";
          "ENABLE_FAILED" = "{0} was unable to start.";
          "ENABLE_SUCCESS" = "{0} has been successfully enabled!";
          "ENJOY_COREPROTECT" = "Enjoy {0}? Join our Discord!";
          "FINISHING_CONVERSION" = "Finishing up data conversion. Please wait...";
          "FINISHING_LOGGING" = "Finishing up data logging. Please wait...";
          "FIRST_VERSION" = "Initial DB: {0}";
          "GLOBAL_LOOKUP" = "Don't specify a radius to do a global lookup.";
          "GLOBAL_ROLLBACK" = "Use \"{0}\" to do a global {rollback|restore}";
          "HELP_ACTION_1" = "Restrict the lookup to a certain action.";
          "HELP_ACTION_2" = "Examples: [a:block], [a:+block], [a:-block] [a:click], [a:container], [a:inventory], [a:item], [a:kill], [a:chat], [a:command], [a:sign], [a:session], [a:username]";
          "HELP_COMMAND" = "Display more info for that command.";
          "HELP_EXCLUDE_1" = "Exclude blocks/users.";
          "HELP_EXCLUDE_2" = "Examples: [e:stone], [e:Notch], [e:stone,Notch]";
          "HELP_HEADER" = "{0} Help";
          "HELP_INCLUDE_1" = "Include specific blocks/entities.";
          "HELP_INCLUDE_2" = "Examples: [i:stone], [i:zombie], [i:stone,wood,bedrock]";
          "HELP_INSPECT_1" = "With the inspector enabled, you can do the following:";
          "HELP_INSPECT_2" = "Left-click a block to see who placed that block.";
          "HELP_INSPECT_3" = "Right-click a block to see what adjacent block was broken.";
          "HELP_INSPECT_4" = "Place a block to see what block was broken at that location.";
          "HELP_INSPECT_5" = "Place a block in liquid (etc) to see who placed it.";
          "HELP_INSPECT_6" = "Right-click on a door, chest, etc, to see who last used it.";
          "HELP_INSPECT_7" = "Tip: You can use just \"/co i\" for quicker access.";
          "HELP_INSPECT_COMMAND" = "Turns the block inspector on or off.";
          "HELP_LIST" = "Displays a list of all commands.";
          "HELP_LOOKUP_1" = "Command shortcut.";
          "HELP_LOOKUP_2" = "Use after inspecting a block to view logs.";
          "HELP_LOOKUP_COMMAND" = "Advanced block data lookup.";
          "HELP_NO_INFO" = "Information for command \"{0}\" not found.";
          "HELP_PARAMETER" = "Please see \"{0}\" for detailed parameter info.";
          "HELP_PARAMS_1" = "Perform the {lookup|rollback|restore}.";
          "HELP_PARAMS_2" = "Specify the user(s) to {lookup|rollback|restore}.";
          "HELP_PARAMS_3" = "Specify the amount of time to {lookup|rollback|restore}.";
          "HELP_PARAMS_4" = "Specify a radius area to limit the {lookup|rollback|restore} to.";
          "HELP_PARAMS_5" = "Restrict the {lookup|rollback|restore} to a certain action.";
          "HELP_PARAMS_6" = "Include specific blocks/entities in the {lookup|rollback|restore}.";
          "HELP_PARAMS_7" = "Exclude blocks/users from the {lookup|rollback|restore}.";
          "HELP_PURGE_1" = "Delete data older than specified time.";
          "HELP_PURGE_2" = "For example, \"{0}\" will delete all data older than one month, and only keep the last 30 days of data.";
          "HELP_PURGE_COMMAND" = "Delete old block data.";
          "HELP_RADIUS_1" = "Specify a radius area.";
          "HELP_RADIUS_2" = "Examples: [r:10] (Only make changes within 10 blocks of you)";
          "HELP_RELOAD_COMMAND" = "Reloads the configuration file.";
          "HELP_RESTORE_COMMAND" = "Restore block data.";
          "HELP_ROLLBACK_COMMAND" = "Rollback block data.";
          "HELP_STATUS" = "View the plugin status and version information.";
          "HELP_STATUS_COMMAND" = "Displays the plugin status.";
          "HELP_TELEPORT" = "Teleport to a location.";
          "HELP_TIME_1" = "Specify the amount of time to lookup.";
          "HELP_TIME_2" = "Examples: [t:2w,5d,7h,2m,10s], [t:5d2h], [t:2.50h]";
          "HELP_USER_1" = "Specify the user(s) to lookup.";
          "HELP_USER_2" = "Examples: [u:Notch], [u:Notch,#enderman]";
          "INCOMPATIBLE_ACTION" = "\"{0}\" can't be used with that action.";
          "INSPECTOR_ERROR" = "Inspector already {enabled|disabled}.";
          "INSPECTOR_TOGGLED" = "Inspector now {enabled|disabled}.";
          "INTEGRATION_ERROR" = "Unable to {initialize|disable} {0} logging.";
          "INTEGRATION_SUCCESS" = "{0} logging successfully {initialized|disabled}.";
          "INTEGRATION_VERSION" = "Invalid {0} version found.";
          "INTERACTIONS_HEADER" = "Player Interactions";
          "INVALID_ACTION" = "That is not a valid action.";
          "INVALID_BRANCH_1" = "Invalid plugin version (branch has not been set).";
          "INVALID_BRANCH_2" = "To continue, set project branch to \"development\".";
          "INVALID_BRANCH_3" = "Running development code may result in data corruption.";
          "INVALID_CONTAINER" = "Please inspect a valid container first.";
          "INVALID_DONATION_KEY" = "Invalid donation key.";
          "INVALID_INCLUDE" = "\"{0}\" is an invalid block/entity name.";
          "INVALID_INCLUDE_COMBO" = "That is an invalid block/entity combination.";
          "INVALID_RADIUS" = "Please enter a valid radius.";
          "INVALID_SELECTION" = "{0} selection not found.";
          "INVALID_USERNAME" = "\"{0}\" is an invalid username.";
          "INVALID_WORLD" = "Please specify a valid world.";
          "LATEST_VERSION" = "Latest Version: {0}";
          "LINK_DISCORD" = "Discord: {0}";
          "LINK_DOWNLOAD" = "Download: {0}";
          "LINK_PATREON" = "Patreon: {0}";
          "LINK_WIKI_BLOCK" = "Block Names: {0}";
          "LINK_WIKI_ENTITY" = "Entity Names: {0}";
          "LOGGING_ITEMS" = "{0} items left to log. Please wait...";
          "LOGGING_TIME_LIMIT" = "Logging time limit reached. Discarding data and shutting down.";
          "LOOKUP_BLOCK" = "{0} {placed|broke} {1}.";
          "LOOKUP_CONTAINER" = "{0} {added|removed} {1} {2}.";
          "LOOKUP_HEADER" = "{0} Lookup Results";
          "LOOKUP_INTERACTION" = "{0} {clicked|killed} {1}.";
          "LOOKUP_ITEM" = "{0} {picked up|dropped} {1} {2}.";
          "LOOKUP_LOGIN" = "{0} logged {in|out}.";
          "LOOKUP_PAGE" = "Page {0}";
          "LOOKUP_PROJECTILE" = "{0} {threw|shot} {1} {2}.";
          "LOOKUP_ROWS_FOUND" = "{0} {row|rows} found.";
          "LOOKUP_SEARCHING" = "Lookup searching. Please wait...";
          "LOOKUP_STORAGE" = "{0} {deposited|withdrew} {1} {2}.";
          "LOOKUP_TIME" = "{0} ago";
          "LOOKUP_USERNAME" = "{0} logged in as {1}.";
          "MAXIMUM_RADIUS" = "The maximum {lookup|rollback|restore} radius is {0}.";
          "MISSING_ACTION_USER" = "To use that action, please specify a user.";
          "MISSING_LOOKUP_TIME" = "Please specify the amount of time to {lookup|rollback|restore}.";
          "MISSING_LOOKUP_USER" = "Please specify a user or {block|radius} to lookup.";
          "MISSING_PARAMETERS" = "Please use \"{0}\".";
          "MISSING_ROLLBACK_RADIUS" = "You did not specify a {rollback|restore} radius.";
          "MISSING_ROLLBACK_USER" = "You did not specify a {rollback|restore} user.";
          "MYSQL_UNAVAILABLE" = "Unable to connect to MySQL server.";
          "NO_DATA" = "No data found at {0}.";
          "NO_DATA_LOCATION" = "No {data|transactions|interactions|messages} found at this location.";
          "NO_PERMISSION" = "You do not have permission to do that.";
          "NO_RESULTS" = "No results found.";
          "NO_RESULTS_PAGE" = "No {results|data} found for that page.";
          "NO_ROLLBACK" = "No {pending|previous} rollback/restore found.";
          "PATCH_INTERRUPTED" = "Upgrade interrupted. Will try again on restart.";
          "PATCH_OUTDATED_1" = "Unable to upgrade databases older than {0}.";
          "PATCH_OUTDATED_2" = "Please upgrade with a supported version of CoreProtect.";
          "PATCH_PROCESSING" = "Processing new data. Please wait...";
          "PATCH_SKIP_UPDATE" = "Skipping {table|index} {update|creation|removal} on {0}.";
          "PATCH_STARTED" = "Performing {0} upgrade. Please wait...";
          "PATCH_SUCCESS" = "Successfully upgraded to {0}.";
          "PATCH_UPGRADING" = "Database upgrade in progress. Please wait...";
          "PLEASE_SELECT" = "Please select: \"{0}\" or \"{1}\".";
          "PREVIEW_CANCELLED" = "Preview cancelled.";
          "PREVIEW_CANCELLING" = "Cancelling preview...";
          "PREVIEW_IN_GAME" = "You can only preview rollbacks in-game.";
          "PREVIEW_TRANSACTION" = "You can't preview {container|inventory} transactions.";
          "PURGE_ABORTED" = "Purge failed. Database may be corrupt.";
          "PURGE_ERROR" = "Unable to process {0} data!";
          "PURGE_FAILED" = "Purge failed. Please try again later.";
          "PURGE_IN_PROGRESS" = "Purge in progress. Please try again later.";
          "PURGE_MINIMUM_TIME" = "You can only purge data older than {0} {days|hours}.";
          "PURGE_NOTICE_1" = "Please note that this may take some time.";
          "PURGE_NOTICE_2" = "Do not restart your server until completed.";
          "PURGE_OPTIMIZING" = "Optimizing database. Please wait...";
          "PURGE_PROCESSING" = "Processing {0} data...";
          "PURGE_REPAIRING" = "Attempting to repair. This may take some time...";
          "PURGE_ROWS" = "{0} {row|rows} of data deleted.";
          "PURGE_STARTED" = "Data purge started on \"{0}\".";
          "PURGE_SUCCESS" = "Data purge successful.";
          "RELOAD_STARTED" = "Reloading configuration - please wait.";
          "RELOAD_SUCCESS" = "Configuration successfully reloaded.";
          "ROLLBACK_ABORTED" = "Rollback or restore aborted.";
          "ROLLBACK_CHUNKS_FOUND" = "Found {0} {chunk|chunks} to modify.";
          "ROLLBACK_CHUNKS_MODIFIED" = "Modified {0}/{1} {chunk|chunks}.";
          "ROLLBACK_COMPLETED" = "{Rollback|Restore|Preview} completed for \"{0}\".";
          "ROLLBACK_EXCLUDED_USERS" = "Excluded {user|users}: \"{0}\".";
          "ROLLBACK_INCLUDE" = "{Included|Excluded} {block|entity|target} {type|types}: \"{0}\".";
          "ROLLBACK_IN_PROGRESS" = "A rollback/restore is already in progress.";
          "ROLLBACK_LENGTH" = "Time taken: {0} {second|seconds}.";
          "ROLLBACK_MODIFIED" = "{Modified|Modifying} {0}.";
          "ROLLBACK_RADIUS" = "Radius: {0} {block|blocks}.";
          "ROLLBACK_SELECTION" = "Radius set to \"{0}\".";
          "ROLLBACK_STARTED" = "{Rollback|Restore|Preview} started on \"{0}\".";
          "ROLLBACK_TIME" = "Time range: {0}.";
          "ROLLBACK_WORLD_ACTION" = "Restricted to {world|action} \"{0}\".";
          "SIGN_HEADER" = "Sign Messages";
          "STATUS_CONSUMER" = "Consumer: {0} {item|items} in queue.";
          "STATUS_DATABASE" = "Database: Using {0}.";
          "STATUS_INTEGRATION" = "{0}: Integration {enabled|disabled}.";
          "STATUS_LICENSE" = "License: {0}";
          "STATUS_VERSION" = "Version: {0}";
          "TELEPORTED" = "Teleported to {0}.";
          "TELEPORTED_SAFETY" = "Teleported you to safety.";
          "TELEPORT_PLAYERS" = "Teleport command can only be used by players.";
          "TIME_DAYS" = "{0} {day|days}";
          "TIME_HOURS" = "{0} {hour|hours}";
          "TIME_MINUTES" = "{0} {minute|minutes}";
          "TIME_SECONDS" = "{0} {second|seconds}";
          "TIME_WEEKS" = "{0} {week|weeks}";
          "UPDATE_ERROR" = "An error occurred while checking for updates.";
          "UPDATE_HEADER" = "{0} Update";
          "UPDATE_NOTICE" = "Notice: {0} is now available.";
          "UPGRADE_IN_PROGRESS" = "Upgrade in progress. Please try again later.";
          "USER_NOT_FOUND" = "User \"{0}\" not found.";
          "USER_OFFLINE" = "The user \"{0}\" is not online.";
          "USING_MYSQL" = "Using MySQL for data storage.";
          "USING_SQLITE" = "Using SQLite for data storage.";
          "VALID_DONATION_KEY" = "Valid donation key.";
          "VERSION_NOTICE" = "Version {0} is now available.";
          "VERSION_REQUIRED" = "{0} {1} or higher is required.";
          "WORLD_NOT_FOUND" = "World \"{0}\" not found.";
        };
      };
    };
    server = "spigot";
    type = "result";
    folders = [
      "plugins/CoreProtect"
    ];
  };
}
