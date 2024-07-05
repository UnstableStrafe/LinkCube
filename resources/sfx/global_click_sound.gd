## Injects itself into all buttons that spawn in the node tree
extends AudioStreamPlayer

var click :=  preload("res://resources/sfx/click.wav")

func _enter_tree() -> void:
	stream = click
	get_tree().node_added.connect(_on_Tree_node_added)

func _on_Tree_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(func(): _on_Button_clicked(node))

func _on_Button_clicked(_button: BaseButton) -> void:
	play()
