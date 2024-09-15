extends Camera3D
signal loadingCameraAnimationDone
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self, "position:x", 159, 5)
	tween.tween_callback(_on_tween_finished)
	#tween.emit_signal("finished")
	#tween.connect("finished",get_parent()._on_player_view_camera_loading_camera_animation_done)
	#tween.tween_method(loadingCameraAnimationDone.emit())

func _on_tween_finished():
	loadingCameraAnimationDone.emit()
	

func _process(_delta):
	look_at(Vector3(0, 3, 0), Vector3(0,1,0))
