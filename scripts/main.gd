extends Node3D

var dragging                     := false
var ray_length                   := 10000
var length_vector                := Vector3.ZERO
var initial_click_position       := Vector3.ZERO
var collision_count              := 0
var reset_cam_animation_ongoing  := false
var action_cam_animation_ongoing := false
var shoot_pen                    := false
var points:Array
var lines:Array


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

const MAX_POWER                         := 250
const TOP_CAM_INIT_SIZE                 := 180
const MAX_COLLISION                     := 1


var PlayerOne:RigidBody3D
var PlayerTwo:RigidBody3D
var reset_tween: Tween
var action_tween:Tween
var ImpulseOnObject: RigidBody3D
var reset_the_game: bool
var raycast_result: Dictionary


@onready var bg_sfx := $Game_background_music
@export_file() var main_menu_scene
#@onready var TopCamera: Camera3D = $TopCamera
#var PPen:PackedScene = preload("res://scenes/pen.tscn")
#var OPen:PackedScene = preload("res://scenes/pen.tscn")


func _input(event)->void:
	if Input.is_action_just_pressed("Escape"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		
	if event.is_action_pressed("pointer_anchor"):
		# Mouse button just pressed
		update_raycastresult(get_viewport().get_mouse_position())
		print("RAY_CAST RESULT = ",raycast_result)
		if raycast_result and (raycast_result.collider is RigidBody3D):
			ImpulseOnObject = raycast_result.collider
			if (ImpulseOnObject == $PlayerOne/Top) or (ImpulseOnObject == $PlayerOne/Bottom):
				#print("YES YOU'RE TOUCHING THE PLAYER PEN")
				$Hitter.position = raycast_result.position
				initial_click_position = $Hitter.position
				#print("SHOW ARROW")
				dragging = true
				$Hitter.show()
	elif event.is_action_released("pointer_anchor") and (active_player == WHOSE_PLAYING.PLAYER_ONE):
		# Mouse button released
		dragging = false
		#power = 0.0;
		$Hitter.hide()
		length_vector.y = 0
		if ImpulseOnObject != null:
			#before I hit the pen, let me save its location
			#var look_At_local:Vector3
			var pen_position_local := ImpulseOnObject.position 
			pen_position_local.y    = CAM_HEIGHT
			if (ImpulseOnObject == $PlayerOne/Top) or (ImpulseOnObject == $PlayerOne/Bottom):
				#shoot_pen = true
				hit_then_begin_cam_anim(length_vector, ImpulseOnObject)
		length_vector = Vector3.ZERO


func _process(_delta)->void:
	if dragging:
		# If dragging, update the sprite's rotation to point at the mouse
		update_raycastresult(get_viewport().get_mouse_position())
		raycast_result.position.y = 5
		if raycast_result:
			if $Hitter.position.distance_to(raycast_result.position) > 16.2:
				var diff_vector:Vector3 = raycast_result.position - $Hitter.position
				var look_at_this:Vector3 = $Hitter.position - diff_vector
				length_vector = - diff_vector*4
				if length_vector.length()/MAX_POWER <= 1:
					$PlayerOne/Body/Label3D.text = str(int((length_vector.length()/MAX_POWER)*100))
				else:
					$PlayerOne/Body/Label3D.text = str(100)
					length_vector = length_vector.normalized()*MAX_POWER
				$Hitter.look_at(look_at_this,Vector3(0,1,0))

	if reset_cam_animation_ongoing:
		if active_player == WHOSE_PLAYING.PLAYER_ONE:
			$PlayerViewCamera.look_at($PlayerTwo/Body.position)
		elif active_player == WHOSE_PLAYING.PLAYER_TWO:
			$PlayerViewCamera.look_at($PlayerOne/Body.position)

	#if Draw3d.games_count == Draw3d.MAX_GAMES:
		#if Draw3d.global_score != 3:
			#$YOULOST.visible = true
			#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			#await get_tree().create_timer(1.5).timeout
			#get_tree().reload_current_scene()

func _ready()->void:
	#print("SFX VOLUME = ",bg_sfx.volume_db)
	$YOULOST.visible = false
	collision_count = 0
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
	#$PlayerScore.text = "SCORE = " + str(Draw3d.global_score) 
	active_player = WHOSE_PLAYING.PLAYER_ONE
	bg_sfx.volume_db = -10
	bg_sfx.play()
	reset_cam_animation(true)
	#print("GAME RESET COMPLETED")

func playercam_animation_done(reset:bool)->void:
	#print("camera_animation_done")
	bg_sfx.volume_db = -15
	print("SFX VOLUME = ",bg_sfx.volume_db)
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
		#action_tween.tween_property($TopCamera, "size", 90, 2.5).from(TOP_CAM_INIT_SIZE)
		if active_player == WHOSE_PLAYING.PLAYER_ONE:
			pass
			#action_tween.tween_property($TopCamera, "position:x", $PlayerTwo/Body.global_position.x, 0.5)
			#action_tween.tween_property($TopCamera, "position:z", $PlayerTwo/Body.global_position.z, 0.5)
		elif active_player == WHOSE_PLAYING.PLAYER_TWO:
			pass
			#action_tween.tween_property($TopCamera, "position:x", $PlayerOne/Body.global_position.x, 0.5)
			#action_tween.tween_property($TopCamera, "position:z", $PlayerOne/Body.global_position.z, 0.5)
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
		#reset_tween.tween_property($PlayerViewCamera, "position", TOP_CAM_POS, 3)
		reset_tween.tween_callback(playercam_animation_done.bind(reset))
		#print("reset_cam_animation completed")


func _draw_point_and_line(point:Vector3)->void:
	var mouse_pos = point
	if mouse_pos != null:
		var mouse_pos_V3:Vector3 = mouse_pos
		points.append(await Draw3d.point(mouse_pos_V3,0.05))
		
		#If there are at least 2 points...
		if points.size() > 1:
			#Draw a line from the position of the last point placed to the position of the second to last point placed
			var point1 = points[points.size()-1]
			var point2 = points[points.size()-2]
			var line = await Draw3d.line(point1.position, point2.position)
			lines.append(line)


func ai_pen_turn()->void:
	await get_tree().create_timer(0.5).timeout
	var length_vector_:Vector3
	var ImpulseOnObject_:RigidBody3D
	var top_dist_:float = 0.0
	var bottom_dist_:float = 0.0
	
	##Choosing where to hit the pen best
	top_dist_ = ($PlayerOne/Top.global_position - $PlayerTwo/Top.global_position).length()
	top_dist_ += ($PlayerOne/Bottom.global_position - $PlayerTwo/Top.global_position).length()
	
	bottom_dist_ = ($PlayerOne/Top.global_position - $PlayerTwo/Bottom.global_position).length()
	bottom_dist_ += ($PlayerOne/Bottom.global_position - $PlayerTwo/Bottom.global_position).length()
	
	if top_dist_ >= bottom_dist_:
		ImpulseOnObject_ = $PlayerTwo/Top
	else:
		ImpulseOnObject_ = $PlayerTwo/Bottom
	
	##AI pen fighting loogic
	var space_state = get_world_3d().direct_space_state
	var origin      = ImpulseOnObject_.global_position
	var end         = ImpulseOnObject_.global_position + ($PlayerOne/Body.global_position - ImpulseOnObject_.global_position)*400
	var query       = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude   = [$PlayerOne/Top, $PlayerOne/Body, $PlayerOne/Bottom, $PlayerTwo/Top, $PlayerTwo/Body, $PlayerTwo/Bottom]
	var result      = space_state.intersect_ray(query)
	#print("RAYCAST COLLISION REPORT = ",result)
	_draw_point_and_line(origin)
	_draw_point_and_line(result.position)
	await get_tree().create_timer(2).timeout
	_clear_points_and_lines()
	
		
	length_vector_   = result.position - origin
	length_vector_.y = 0
	#shoot_pen = true
	hit_then_begin_cam_anim(length_vector_*2.2, ImpulseOnObject_)

func _clear_points_and_lines()->void:
	for p in points:
		p.queue_free()
	points.clear()
		
	for l in lines:
		l.queue_free()
	lines.clear()

	
func hit_then_begin_cam_anim(impulse_:Vector3, ImpulseOnObject_:RigidBody3D)->void:
	if impulse_.length() >= MAX_POWER:
		impulse_ = impulse_.normalized()*MAX_POWER
	if active_player == WHOSE_PLAYING.PLAYER_ONE:
		if ImpulseOnObject_ == $PlayerOne/Top:
			$PlayerOne/Top.apply_central_impulse(impulse_)
		elif ImpulseOnObject_ == $PlayerOne/Bottom:
			$PlayerOne/Bottom.apply_central_impulse(impulse_)
	elif active_player == WHOSE_PLAYING.PLAYER_TWO:
		if ImpulseOnObject_ == $PlayerTwo/Top:
			$PlayerTwo/Top.apply_central_impulse(impulse_)
		elif ImpulseOnObject_ == $PlayerTwo/Bottom:
			$PlayerTwo/Bottom.apply_central_impulse(impulse_)
	#print("HIT VECTOR = ",impulse_)
	#shoot_pen = false		
	await get_tree().create_timer(1.5).timeout
	reset_cam_animation(false)


func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("BODY ENTERED body.name = ", body.name)
	#print("BODY ENTERED root node body.name = ", body.get_parent_node_3d().name)
	#print("collision_count = ",collision_count)
	if collision_count < MAX_COLLISION:
		collision_count = MAX_COLLISION
		if body.get_parent_node_3d().name == "PlayerOne" or body.get_parent_node_3d().name == "PlayerTwo":
			if body.get_parent_node_3d().name == "PlayerOne":
				#Draw3d.global_score -=1
				#$PlayerScore.text = "SCORE = " + str(Draw3d.global_score)
				$YOULOST.modulate = Color.DARK_RED
				$YOULOST.text = "YOU LOST!!!"
				$YOULOST.visible = true
				await get_tree().create_timer(1.5).timeout
				get_tree().change_scene_to_file(main_menu_scene)
			elif body.get_parent_node_3d().name == "PlayerTwo":
				Draw3d.global_score +=1
				#$PlayerScore.text = "SCORE = " + str(Draw3d.global_score
				$YOULOST.modulate = Color.GREEN
				$YOULOST.text = "YOU WON!!!"
				$YOULOST.visible = true
				await get_tree().create_timer(1.5).timeout
				get_tree().change_scene_to_file(main_menu_scene)
			#Draw3d.games_count = Draw3d.games_count + 1
			#if (Draw3d.games_count == Draw3d.MAX_GAMES) and (Draw3d.global_score != 1) :
				#$YOULOST.modulate = Color.GREEN
				#$YOULOST.text = "YOU WON!!!"
				#$YOULOST.visible = true
				#await get_tree().create_timer(1.5).timeout
				#get_tree().change_scene_to_file(main_menu_scene)
			#else:
				#$YOULOST.modulate = Color.DARK_RED
				#$YOULOST.text = "YOU LOST!!!"
				#$YOULOST.visible = true
				#await get_tree().create_timer(1.5).timeout
				#get_tree().reload_current_scene()
				#print("collision_count = ",collision_count)
