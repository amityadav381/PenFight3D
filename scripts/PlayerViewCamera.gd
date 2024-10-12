extends Camera3D
signal loadingCameraAnimationDone
#var tween: Tween

#const INIT_CAM_POS: Vector3           = Vector3(-159.0, 38.0, 63.0)
#const RESET_ANIME_END_CAM_POS:Vector3 = Vector3(159.0, 38.0, 63.0)
#const TOP_CAM_POS:Vector3             = Vector3(1.0, 50.0, 1.0) # Real pos is (0,100,0) but bcz of cam type a diff value made sense.
#const TOP_CAM_ROT:Vector3             = Vector3(-90.0, 0.0, 0.0)
#const LOOK_AT_RESET_ANIM:Vector3      = Vector3(0,3,0)
#
#
#
#const TWOD_TOP_RIGHT_CAM_POS: Vector3    = Vector3(159.0, 38.0, -63.0)
#const TWOD_TOP_LEFT_CAM_POS: Vector3     = Vector3(-159.0, 38.0, -63.0)
#const TWOD_BOTTOM_RIGHT_CAM_POS: Vector3 = Vector3(159.0, 38.0, 63.0)
#const TWOD_BOTTOM_LEFT_CAM_POS: Vector3  = Vector3(-159.0, 38.0, 63.0)


var look_at_pos:Vector3                  = Vector3.ZERO
var keep_looking:bool 
var is_reset_cam_animation:bool          = true
var which_pen:int                        = 0

#@export var object_to_look_at: Node3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#animate_camera(0,true)
	#tween.connect("finished",get_parent()._on_player_view_camera_loading_camera_animation_done)

func animate_camera(_which_pen:int, reset:bool):
	pass
	#self.make_current()
	#is_reset_cam_animation = reset
	#which_pen = _which_pen
	#if reset:
		#if tween:
			#tween.kill()
		#tween = get_tree().create_tween().bind_node(self)
		#keep_looking = true
		#tween.tween_property(self, "position", RESET_ANIME_END_CAM_POS, 4).from(INIT_CAM_POS)
		#tween.tween_property(self, "position", TOP_CAM_POS, 3)
		##tween.tween_property(self, "rotation.y", -90, 2)
		#tween.tween_callback(_on_tween_finished)
	#else :
		#keep_looking = true
		#await get_tree().create_timer(5).timeout
		#_on_tween_finished()


func _on_tween_finished():
	pass
	#keep_looking = false
	#loadingCameraAnimationDone.emit()
	
	

func _process(_delta):
	pass
	#if keep_looking:
		#if is_reset_cam_animation:
			#if which_pen: # 0 = PLAYER1
				#look_at($"../PlayerTwo/Body".position, Vector3(0,1,0))
			#else:
				#look_at($"../PlayerOne/Body".position, Vector3(0,1,0))
		#else:
			#if $"../PlayerOne/Body".position.x >= 0:
				#if $"../PlayerOne/Body".position.z >=0:
					#position = TWOD_BOTTOM_RIGHT_CAM_POS
				#else:
					#position = TWOD_TOP_RIGHT_CAM_POS
			#else:
				#if $"../PlayerOne/Body".position.z >=0:
					#position = TWOD_BOTTOM_LEFT_CAM_POS
				#else:
					#position = TWOD_TOP_LEFT_CAM_POS
			#if which_pen: # 0 = PLAYER1
				#look_at($"../PlayerTwo/Body".position, Vector3(0,1,0))
			#else:
				#look_at($"../PlayerOne/Body".position, Vector3(0,1,0))
