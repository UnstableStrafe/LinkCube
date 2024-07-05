class_name Settings
extends ConfigFile

# If you are adding a setting it needs to have an entry in all the below functions :)
@export var fullscreen := true

const SECTION = "settings"


func set_val(property: String, value: Variant) -> void:
	set_value(SECTION, property, value)

func get_val(property) -> Variant:
	return get_value(SECTION, property)


## Create a new instance of Settings using the current state of the engine
static func from_current() -> Settings:
	var settings := Settings.new()

	settings.set_val(
		"fullscreen",
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	settings.set_val(
		"volume",
		db_to_linear(AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("Master")
		)) * 100
	)

	return settings

## Create a new instance of Settings from the given config file
static func from_file(file: String) -> Settings:
	var settings := Settings.new()
	settings.load(file)
	return settings

## Modify the engine according to this object's settings
func apply() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if get_val("fullscreen") else DisplayServer.WINDOW_MODE_WINDOWED
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(get_val("volume") / 100)
	)

	# Save the applied settings
	save(Global.SETTINGS_FILE)
