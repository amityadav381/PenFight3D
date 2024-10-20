extends Node3D


# Called when the node enters the scene tree for the first time.
func instantiate_(var_color:Color, var_position:Vector3, var_rotation:Vector3)->void:
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = var_color
	$Top/MeshInstance3D.material_override= new_material
	position = var_position
	rotation = var_rotation
	print("rotation = ",rotation, "position = ", position)

	
func _ready():
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color.BLACK
	$Body/MeshInstance3D.material_override= new_material
	$Bottom/MeshInstance3D.material_override= new_material
	
	var player1_top_material = StandardMaterial3D.new()
	var player2_top_material = StandardMaterial3D.new()
	player1_top_material.albedo_color = Color.CHOCOLATE
	player2_top_material.albedo_color = Color.CORNFLOWER_BLUE
	if get_name() == "PlayerOne":
		$Top/MeshInstance3D.material_override = player1_top_material
	elif get_name() == "PlayerTwo":
		$Top/MeshInstance3D.material_override = player2_top_material

