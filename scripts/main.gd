extends Node3D


# Var declarataion
var raycast_result: Dictionary
var dragging := false
var ray_length := 10000
var length_vector := Vector3.ZERO
var initial_click_position := Vector3.ZERO
var power: float = 0.0
const MAX_POWER = 100
var ImpulseOnObject: RigidBody3D
var reset_the_game: bool

var PPen:PackedScene = preload("res://scenes/pen.tscn")
var OPen:PackedScene = preload("res://scenes/pen.tscn")

var PlayerPen:Node3D
var OpponentPen:Node3D

@onready var TopCamera: Camera3D = $TopCamera


func _input(event)->void:
	if Input.is_action_just_pressed("camera_view_1"):
		$FrontCamera.current = true
		#print("FROONTVIEW")
	elif Input.is_action_just_pressed("camera_view_2"):
		#$FrontCamera.clear_current()
		$TopCamera.current = true
		#print("TOPVIEW")
	elif Input.is_action_just_pressed("camera_view_3"):
		$PlayerViewCamera.current = true
		#print("PLAYERVIEW")
	elif Input.is_action_just_pressed("camera_view_4"):
		$OpponentViewCamera.current = true
	elif Input.is_action_just_pressed("reset_game"): #button in num5
		reset_game()
		
	if event.is_action_pressed("pointer_anchor"):
		# Mouse button just pressed
		update_raycastresult(get_viewport().get_mouse_position())
		print(raycast_result)
		if raycast_result and (raycast_result.collider is RigidBody3D):
			ImpulseOnObject = raycast_result.collider
			if (ImpulseOnObject == $PlayerPen/Top) or (ImpulseOnObject == $OpponentPen/Top):
				#print("YES YOU'RE TOUCHING THE PLAYER PEN")
				$Hitter.position = raycast_result.position
				initial_click_position = $Hitter.position
				print("SHOW ARROW")
				dragging = true
				$Hitter.show()
	elif event.is_action_released("pointer_anchor"):
		# Mouse button released
		dragging = false
		power = 0.0;
		#length_vector = Vector3(100,0,0)
		print("HIDE ARROW and SHOOOOT!!! = ",length_vector)
		$Hitter.hide()
		#PlayerPen.apply_central_impulse(length_vector)
		length_vector.y = 0
		print("IMPULSE = ",length_vector)
		print("POSITION =", initial_click_position)
		print("IMPULSE OBJECT = ",ImpulseOnObject)
		#$PlayerPen.apply_central_impulse(length_vector*0.2, initial_click_position - $PlayerPen.position)
		if ImpulseOnObject != null:
			ImpulseOnObject.apply_central_impulse(length_vector*2)
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

func _ready()->void:
	$Hitter.hide()
	#Connect signal from PlayerViewCamera node
	#$PlayerViewCamera.connect("loadingCameraAnimationDone",_on_player_view_camera_loading_camera_animation_done)
	reset_game()


func update_raycastresult(mouse_pos:Vector2)->void:
	var from := TopCamera.project_ray_origin(mouse_pos)
	var to   := from + TopCamera.project_ray_normal(mouse_pos)*ray_length
	var space := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	raycast_result = space.intersect_ray(ray_query)

func reset_game()->void:
	print("GAME RESET STARTED")
	if has_node("PlayerPen"):
		#print("deleting pen nodes = ",get_node("PlayerPen"))
		$PlayerPen.queue_free()
		$OpponentPen.queue_free()
		remove_child($PlayerPen)
		remove_child($OpponentPen)
	
	$PlayerViewCamera.current = true
	PlayerPen = PPen.instantiate()
	OpponentPen = OPen.instantiate()
	add_child(PlayerPen)
	add_child(OpponentPen)
	#print("PlayerPen = ", PlayerPen)
	PlayerPen.set_name("PlayerPen")
	OpponentPen.set_name("OpponentPen")
	#print("PlayerPen = ", PlayerPen)
	$PlayerPen.instantiate_(Color.DARK_RED, Vector3(-20, 30, 0), Vector3(0, PI/2, 0))
	$OpponentPen.instantiate_(Color.BLUE, Vector3(20, 30, 0), Vector3(0, PI/2, 0))
	print("GAME RESET COMPLETED")


func _on_player_view_camera_loading_camera_animation_done():
	print("camera_loading_camera_animation_done")
	$TopCamera.current = true
