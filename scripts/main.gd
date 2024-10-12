extends Node3D

var dragging               := false
var ray_length             := 10000
var length_vector          := Vector3.ZERO
var initial_click_position := Vector3.ZERO
var power                  := 0.0
var cam_animation_ongoing  := false


var active_player:=WHOSE_PLAYING.PLAYER_ONE
var passive_player:= WHOSE_PLAYING.PLAYER_TWO



enum WHOSE_PLAYING {PLAYER_ONE, PLAYER_TWO}

const RADIAL_CAM_DIST:int             = 150
const CAM_HEIGHT:int                  = 40
const INIT_CAM_POS: Vector3           = Vector3(-159.0, 38.0, 63.0)
const RESET_ANIME_END_CAM_POS:Vector3 = Vector3(159.0, 38.0, 63.0)
const TOP_CAM_POS:Vector3             = Vector3(1.0, 50.0, 1.0) # Real pos is (0,100,0) but bcz of cam type a diff value made sense.
const TOP_CAM_ROT:Vector3             = Vector3(-90.0, 0.0, 0.0)
const LOOK_AT_RESET_ANIM:Vector3      = Vector3(0,3,0)



const TWOD_TOP_RIGHT_CAM_POS: Vector3    = Vector3(159.0, 38.0, -63.0)
const TWOD_TOP_LEFT_CAM_POS: Vector3     = Vector3(-159.0, 38.0, -63.0)
const TWOD_BOTTOM_RIGHT_CAM_POS: Vector3 = Vector3(159.0, 38.0, 63.0)
const TWOD_BOTTOM_LEFT_CAM_POS: Vector3  = Vector3(-159.0, 38.0, 63.0)

const MAX_POWER = 100

var PlayerOne:Node3D
var PlayerTwo:Node3D
var reset_tween: Tween
var ImpulseOnObject: RigidBody3D
var reset_the_game: bool
var raycast_result: Dictionary

#@onready var TopCamera: Camera3D = $TopCamera
var PPen:PackedScene = preload("res://scenes/pen.tscn")
var OPen:PackedScene = preload("res://scenes/pen.tscn")


func _input(event)->void:
	if Input.is_action_just_pressed("camera_view_1"):
		$FrontCamera.current = true
		#print("FROONTVIEW")
	elif Input.is_action_just_pressed("camera_view_2"):
		#print("TOPVIEW")
		pass
	elif Input.is_action_just_pressed("camera_view_3"):
		$PlayerViewCamera.current = true
		#print("PLAYERVIEW")
	elif Input.is_action_just_pressed("reset_game"): #button in num5
		reset_game()
		
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
				print("SHOW ARROW")
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
				#print("RAY CAST POINT @",raycast_result.position)
				#print("RAY CAST RADIOUS = ", $Hitter.position.distance_to(raycast_result.position))
				#print("THE FORCE VECTOR = ", ($Hitter.position - raycast_result.position))
				var look_at_this:Vector3 = $Hitter.position - diff_vector
				length_vector = - diff_vector
				$Hitter.look_at(look_at_this,Vector3(0,1,0))
				#$Hitter.rotation = ($Hitter.position - raycast_result.position).normalized()
		#length_vector = get_global_mouse_position() - initial_click_position
		#print("POWER LEVEL =", power)

	if cam_animation_ongoing:
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
	print("GAME RESET STARTED")
	active_player = WHOSE_PLAYING.PLAYER_ONE
	if has_node("PlayerOne"):
		#print("deleting pen nodes = ",get_node("PlayerOne"))
		$PlayerOne.queue_free()
		$PlayerTwo.queue_free()
		remove_child($PlayerOne)
		remove_child($PlayerTwo)
	
	PlayerOne = PPen.instantiate()
	PlayerTwo = OPen.instantiate()
	add_child(PlayerOne)
	add_child(PlayerTwo)
	#print("PlayerOne = ", PlayerOne)
	PlayerOne.set_name("PlayerOne")
	PlayerTwo.set_name("PlayerTwo")
	#print("PlayerOne = ", PlayerOne)
	$PlayerOne.instantiate_(Color.DARK_RED, Vector3(-20, 30, 0), Vector3(0, PI/2, 0))
	$PlayerTwo.instantiate_(Color.BLUE, Vector3(20, 30, 0), Vector3(0, PI/2, 0))
	reset_cam_animation(true)
	print("GAME RESET COMPLETED")

func playercam_animation_done()->void:
	print("camera_loading_camera_animation_done")
	cam_animation_ongoing = false
	$PlayerViewCamera.clear_current()
	$TopCamera.make_current()
	
func switch_active_pen()->void:
	if active_player == WHOSE_PLAYING.PLAYER_ONE:
		active_player = WHOSE_PLAYING.PLAYER_TWO
		passive_player = WHOSE_PLAYING.PLAYER_ONE
		ai_pen_turn()
	else:
		active_player = WHOSE_PLAYING.PLAYER_ONE
		passive_player = WHOSE_PLAYING.PLAYER_TWO

func reset_cam_animation(reset:bool)->void:
	cam_animation_ongoing = true
	$TopCamera.clear_current()
	$PlayerViewCamera.make_current()
	print("cam_animation_ongoing = ",cam_animation_ongoing)
	if reset == false:
		await get_tree().create_timer(3.5).timeout
		playercam_animation_done()
		switch_active_pen()
	else:
		if reset_tween:
			reset_tween.kill()
		reset_tween = get_tree().create_tween().bind_node($PlayerViewCamera)
		reset_tween.tween_property($PlayerViewCamera, "position", RESET_ANIME_END_CAM_POS, 4).from(INIT_CAM_POS)
		reset_tween.tween_property($PlayerViewCamera, "position", TOP_CAM_POS, 3)
		reset_tween.tween_callback(playercam_animation_done)
		print("reset_cam_animation completed")

func ai_pen_turn()->void:
	var length_vector_:Vector3
	length_vector_   = $PlayerOne/Body.position - $PlayerTwo/Body.position
	length_vector_.y = 0
	hit_then_begin_cam_anim(length_vector_)
	
func hit_then_begin_cam_anim(impulse_:Vector3)->void:
	if active_player == WHOSE_PLAYING.PLAYER_ONE:
		$PlayerOne/Top.apply_central_impulse(impulse_*2)
	elif active_player == WHOSE_PLAYING.PLAYER_TWO:
		$PlayerTwo/Top.apply_central_impulse(impulse_*2)
		
	await get_tree().create_timer(1.5).timeout
	if impulse_.normalized().x <= 0:
		if impulse_.normalized().z <= 0:
			$PlayerViewCamera.position = TWOD_TOP_LEFT_CAM_POS
		else:
			$PlayerViewCamera.position = TWOD_BOTTOM_LEFT_CAM_POS
	else:
		if impulse_.normalized().z <= 0:
			$PlayerViewCamera.position = TWOD_TOP_RIGHT_CAM_POS
		else:
			$PlayerViewCamera.position = TWOD_BOTTOM_RIGHT_CAM_POS
	reset_cam_animation(false)
