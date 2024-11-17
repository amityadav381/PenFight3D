extends Control

@onready var sfx_play := $MarginContainer/VBoxContainer/Play/Play_audio
@onready var sfx_quit := $MarginContainer/VBoxContainer/Quit/Quit_audio
func _on_play_pressed():
	sfx_play.play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	sfx_quit.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
