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
enum WHOSE_PLAYING {PLAYER_ONE, PLAYER_TWO}
var active_player:=WHOSE_PLAYING.PLAYER_ONE
var passive_player:= WHOSE_PLAYING.PLAYER_TWO

var PPen:PackedScene = preload("res://scenes/pen.tscn")
var OPen:PackedScene = preload("res://scenes/pen.tscn")

const RADIAL_CAM_DIST:int             = 150
const CAM_HEIGHT:int                  = 40

var PlayerOne:Node3D
var PlayerTwo:Node3D

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
	elif event.is_action_released("pointer_anchor"):
		# Mouse button released
		dragging = false
		power = 0.0;
		#length_vector = Vector3(100,0,0)
		print("HIDE ARROW and SHOOOOT!!! = ",length_vector)
		$Hitter.hide()
		#PlayerOne.apply_central_impulse(length_vector)
		length_vector.y = 0
		print("IMPULSE = ",length_vector)
		print("POSITION =", initial_click_position)
		print("IMPULSE OBJECT = ",ImpulseOnObject)
		#$PlayerOne.apply_central_impulse(length_vector*0.2, initial_click_position - $PlayerOne.position)
		if ImpulseOnObject != null:
			#before I hit the pen, let me save its location
			#var look_At_local:Vector3
			var pen_position_local := ImpulseOnObject.position 
			pen_position_local.y    = CAM_HEIGHT
			if ImpulseOnObject == $PlayerOne/Top:
				#look_At_local  =  $PlayerTwo/Top.position - ImpulseOnObject.position
				ImpulseOnObject.apply_central_impulse(length_vector*2)
				await get_tree().create_timer(1.5).timeout
				$PlayerViewCamera.animate_camera(passive_player,false)
			else:
				#look_At_local  =  $PlayerOne/Top.position - ImpulseOnObject.position
				ImpulseOnObject.apply_central_impulse(length_vector*2)
				await get_tree().create_timer(1.5).timeout
				$PlayerViewCamera.animate_camera(passive_player,false)
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
	else:
		print("POSITION OF PEN 1 = ",$PlayerOne/Body.position)
		print("POSITION OF PEN 2 = ",$PlayerTwo/Body.position)

func _ready()->void:
	$Hitter.hide()
	#Connect signal from PlayerViewCamera node
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
	active_player = WHOSE_PLAYING.PLAYER_ONE
	$TopCamera.clear_current()
	if has_node("PlayerOne"):
		#print("deleting pen nodes = ",get_node("PlayerOne"))
		$PlayerOne.queue_free()
		$PlayerTwo.queue_free()
		remove_child($PlayerOne)
		remove_child($PlayerTwo)
	
	$PlayerViewCamera.make_current()
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
	print("GAME RESET COMPLETED")


func _on_player_view_camera_loading_camera_animation_done():
	print("camera_loading_camera_animation_done")
	$PlayerViewCamera.clear_current()
	if active_player == WHOSE_PLAYING.PLAYER_ONE:
		active_player = WHOSE_PLAYING.PLAYER_TWO
		passive_player = WHOSE_PLAYING.PLAYER_ONE
	else:
		active_player = WHOSE_PLAYING.PLAYER_ONE
		passive_player = WHOSE_PLAYING.PLAYER_TWO
	$TopCamera.make_current()
