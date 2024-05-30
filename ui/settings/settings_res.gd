class_name Settings
extends Resource

# If you are adding a setting it needs to have an entry in all the below functions :)
@export var fullscreen := true

## Create a new instance of Settings using the current state of the engine
static func Current() -> Settings:
	var settings := Settings.new()

	settings.fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	return settings

## Modify the engine according to this object's settings
func apply() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_MAXIMIZED
	)

	# Save the applied settings
	var config := to_config_file()
	config.save(Global.SETTINGS_FILE)

## Dump settings in a ConfigFile
func to_config_file() -> ConfigFile:
	var config := ConfigFile.new()

	config.set_value("video", "fullscreen", fullscreen)

	return config

# Load a ConfigFile into a Settings resource
static func from_config_file(config: ConfigFile) -> Settings:
	var settings := Settings.new()

	settings.fullscreen = config.get_value("video", "fullscreen", settings.fullscreen)

	return settings
