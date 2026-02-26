@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	# Registering custom nodes or types if needed (other than class_name)
	print("Indie Game Components plugin initialized.")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	print("Indie Game Components plugin disabled.")
