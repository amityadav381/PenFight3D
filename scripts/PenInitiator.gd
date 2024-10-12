extends Node3D
var PPen = preload("res://assets/player_pen.glb")
var OPen = preload("res://assets/enemy_pen.glb")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset_game"):
		print("RESET FLAG HAS BEEN SET")
		if self.get_child_count() > 0:
			self.get_child(0).queue_free()
		var PlayerOne = PPen.instantiate()
		var PlayerTwo = OPen.instantiate()
		#$PlayerOne.instantiate_(Color.DARK_RED, Vector3(-20, 30, 0), Vector3(0, PI/2, 0))
		#$PlayerTwo.instantiate_(Color.BLUE, Vector3(20, 30, 0), Vector3(0, PI/2, 0))
		add_child(PlayerOne)
		add_child(PlayerTwo)
