extends Node3D

var dragging                     := false
var ray_length                   := 10000
var length_vector                := Vector3.ZERO
var initial_click_position       := Vector3.ZERO
var power                        := 0.0
var reset_cam_animation_ongoing  := false
var action_cam_animation_ongoing := false
var shoot_pen                    := false


var active_player:=WHOSE_PLAYING.PLAYER_ONE
var passive_player:= WHOSE_PLAYING.PLAYER_TWO


enum WHOSE_PLAYING {PLAYER_ONE, PLAYER_TWO}

const RADIAL_CAM_DIST:int             = 150
const CAM_HEIGHT:int                  = 40
const INIT_CAM_POS: Vector3           = Vector3(-159.0, 38.0, 63.0)
const RESET_ANIME_END_CAM_POS:Vector3 = Vector3(159.0, 38.0, 63.0)
const TOP_CAM_POS:Vector3             = Vector3(1, 100, 0) # Real pos is (0,100,0) but bcz of cam type a diff value made sense.
const TOP_CAM_ROT:Vector3             = Vector3(-90.0, 0.0, 0.0)
const LOOK_AT_RESET_ANIM:Vector3      = Vector3(0,3,0)


const TWOD_TOP_RIGHT_CAM_POS: Vector3    = Vector3(159.0, 38.0, -63.0)
const TWOD_TOP_LEFT_CAM_POS: Vector3     = Vector3(-159.0, 38.0, -63.0)
const TWOD_BOTTOM_RIGHT_CAM_POS: Vector3 = Vector3(159.0, 38.0, 63.0)
const TWOD_BOTTOM_LEFT_CAM_POS: Vector3  = Vector3(-159.0, 38.0, 63.0)

const MAX_POWER                         := 100
const TOP_CAM_INIT_SIZE                 := 180


var PlayerOne:RigidBody3D
var PlayerTwo:RigidBody3D
var reset_tween: Tween
var action_tween:Tween
var ImpulseOnObject: RigidBody3D
var reset_the_game: bool
var raycast_result: Dictionary

#@onready var TopCamera: Camera3D = $TopCamera
#var PPen:PackedScene = preload("res://scenes/pen.tscn")
#var OPen:PackedScene = preload("res://scenes/pen.tscn")


func _input(event)->void:
	#if Input.is_action_just_pressed("camera_view_1"):
		#$FrontCamera.current = true
		##print("FROONTVIEW")
	#elif Input.is_action_just_pressed("camera_view_2"):
		##print("TOPVIEW")
		#pass
	#elif Input.is_action_just_pressed("camera_view_3"):
		#$PlayerViewCamera.current = true
		##print("PLAYERVIEW")
	#elif Input.is_action_just_pressed("reset_game"): #button in num5
		#reset_game()
		
	if event.is_action_pressed("pointer_anchor"):
		# Mouse button just pressed
		update_raycastresult(get_viewport().get_mouse_position())
		print(raycast_result)
		if raycast_result and (raycast_result.collider is RigidBody3D):
			ImpulseOnObject = raycast_result.collider
			if (ImpulseOnObject == $PlayerOne/Top) or (ImpulseOnObject == $PlayerTwo/Top):
				#print("YES YOU'RE TOUCHING THE PLAYER PEN")
				$Hitter.position = raycast_result.position
				initial_click_position = $Hitter.position
				#print("SHOW ARROW")
				dragging = true
				$Hitter.show()
	elif event.is_action_released("pointer_anchor") and (active_player == WHOSE_PLAYING.PLAYER_ONE):
		# Mouse button released
		dragging = false
		power = 0.0;
		$Hitter.hide()
		length_vector.y = 0
		if ImpulseOnObject != null:
			#before I hit the pen, let me save its location
			#var look_At_local:Vector3
			var pen_position_local := ImpulseOnObject.position 
			pen_position_local.y    = CAM_HEIGHT
			if ImpulseOnObject == $PlayerOne/Top:
				#shoot_pen = true
				hit_then_begin_cam_anim(length_vector)
		length_vector = Vector3.ZERO


func _process(_delta)->void:
	if dragging:
		# If dragging, update the sprite's rotation to point at the mouse
		update_raycastresult(get_viewport().get_mouse_position())
		raycast_result.position.y = 5
		if raycast_result:
			if $Hitter.position.distance_to(raycast_result.position) > 16.2:
				if power <= MAX_POWER:
					power = $Hitter.position.distance_to(raycast_result.position) - 16
				else:
					power = MAX_POWER
				var diff_vector:Vector3 = raycast_result.position - $Hitter.position
				var look_at_this:Vector3 = $Hitter.position - diff_vector
				length_vector = - diff_vector
				$Hitter.look_at(look_at_this,Vector3(0,1,0))

	if reset_cam_animation_ongoing:
		if active_player == WHOSE_PLAYING.PLAYER_ONE:
			$PlayerViewCamera.look_at($PlayerTwo/Body.position)
		elif active_player == WHOSE_PLAYING.PLAYER_TWO:
			$PlayerViewCamera.look_at($PlayerOne/Body.position)



func _ready()->void:
	$Hitter.hide()
	#Connect signal from PlayerViewCamera node
	reset_game()

func update_raycastresult(mouse_pos:Vector2)->void:
	var from = $TopCamera.project_ray_origin(mouse_pos)
	var to   = from + $TopCamera.project_ray_normal(mouse_pos)*ray_length
	var space := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	raycast_result = space.intersect_ray(ray_query)

func reset_game()->void:
	#print("GAME RESET STARTED")
	active_player = WHOSE_PLAYING.PLAYER_ONE
	reset_cam_animation(true)
	#print("GAME RESET COMPLETED")

func playercam_animation_done(reset:bool)->void:
	#print("camera_animation_done")
	$TopCamera.size              = TOP_CAM_INIT_SIZE
	$TopCamera.position          = TOP_CAM_POS
	reset_cam_animation_ongoing  = false
	action_cam_animation_ongoing = false
	$PlayerViewCamera.clear_current()
	$TopCamera.make_current()
	if !reset:
		switch_active_pen()
	
func switch_active_pen()->void:
	print("3sec wait start")
	await get_tree().create_timer(3).timeout
	print("3sec wait end")
	if active_player == WHOSE_PLAYING.PLAYER_ONE:
		active_player = WHOSE_PLAYING.PLAYER_TWO
		passive_player = WHOSE_PLAYING.PLAYER_ONE
		ai_pen_turn()
	else:
		active_player = WHOSE_PLAYING.PLAYER_ONE
		passive_player = WHOSE_PLAYING.PLAYER_TWO

func reset_cam_animation(reset:bool)->void:
	#cam_animation_ongoing = true
	#$TopCamera.clear_current()
	#$PlayerViewCamera.make_current()
	if reset == false:
		action_cam_animation_ongoing = true
		if action_tween:
			action_tween.kill()
		action_tween = get_tree().create_tween().bind_node($TopCamera)
		action_tween.set_parallel()
		action_tween.tween_property($TopCamera, "size", 90, 3).from(TOP_CAM_INIT_SIZE)
		if active_player == WHOSE_PLAYING.PLAYER_ONE:
			action_tween.tween_property($TopCamera, "position:x", $PlayerTwo/Body.global_position.x, 1)
			action_tween.tween_property($TopCamera, "position:z", $PlayerTwo/Body.global_position.z, 1)
		elif active_player == WHOSE_PLAYING.PLAYER_TWO:
			action_tween.tween_property($TopCamera, "position:x", $PlayerOne/Body.global_position.x, 1)
			action_tween.tween_property($TopCamera, "position:z", $PlayerOne/Body.global_position.z, 1)
		action_tween.chain().tween_callback(playercam_animation_done.bind(reset))
	else:
		reset_cam_animation_ongoing = true
		$TopCamera.clear_current()
		$PlayerViewCamera.make_current()
		#cam_animation_ongoing = true
		if reset_tween:
			reset_tween.kill()
		reset_tween = get_tree().create_tween().bind_node($PlayerViewCamera)
		reset_tween.tween_property($PlayerViewCamera, "position", RESET_ANIME_END_CAM_POS, 4).from(INIT_CAM_POS)
		reset_tween.tween_property($PlayerViewCamera, "position", TOP_CAM_POS, 3)
		reset_tween.tween_callback(playercam_animation_done.bind(reset))
		#print("reset_cam_animation completed")

func ai_pen_turn()->void:
	await get_tree().create_timer(1).timeout
	var length_vector_:Vector3
	length_vector_   = $PlayerOne/Top.global_position - $PlayerTwo/Top.global_position
	length_vector_.y = 0
	#shoot_pen = true
	hit_then_begin_cam_anim(length_vector_)
	
func hit_then_begin_cam_anim(impulse_:Vector3)->void:
	if active_player == WHOSE_PLAYING.PLAYER_ONE:
		$PlayerOne/Top.apply_central_impulse(impulse_*2)
	elif active_player == WHOSE_PLAYING.PLAYER_TWO:
		$PlayerTwo/Top.apply_central_impulse(impulse_*2)
	#print("HIT VECTOR = ",impulse_)
	#shoot_pen = false		
	await get_tree().create_timer(1.5).timeout
	reset_cam_animation(false)


func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("BODY ENTERED body.name = ", body.name)
	#print("BODY ENTERED root node body.name = ", body.get_parent_node_3d().name)
	if body.get_parent_node_3d().name == "PlayerOne" or body.get_parent_node_3d().name == "PlayerTwo":
		#print("You Lost!")
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()
	#elif body.get_parent_node_3d().name == "PlayerTwo":
		##print("You Won!")
		#get_tree().reload_current_scene()

