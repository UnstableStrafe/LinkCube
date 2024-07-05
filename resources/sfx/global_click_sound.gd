## Injects click sound into UI items that spawn in the node tree
extends AudioStreamPlayer

var click := preload("res://resources/sfx/click.wav")

func _enter_tree() -> void:
	stream = click
	bus = "SFX"

	get_tree().node_added.connect(_on_Tree_node_added)

func _on_Tree_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(_on_Button_clicked)
	elif node is Slider:
		node.drag_ended.connect(_on_Slider_changed)

func _on_Button_clicked() -> void:
	play()

func _on_Slider_changed(_value) -> void:
	play()
