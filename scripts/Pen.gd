extends Node3D

@onready var whopwhop := $WhopWhop
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
	new_material.albedo_color = Color.DARK_GRAY
	$Body/MeshInstance3D.material_override= new_material
	$Bottom/MeshInstance3D.material_override= new_material
	
	var player1_top_material = StandardMaterial3D.new()
	var player2_top_material = StandardMaterial3D.new()
	player1_top_material.albedo_color = Color.DODGER_BLUE
	player2_top_material.albedo_color = Color.INDIAN_RED
	if get_name() == "PlayerOne":
		$Top/MeshInstance3D.material_override = player1_top_material
		$Body/Label3D.text = "You"
		$Body/Label3D.modulate = Color.DODGER_BLUE
		#$Hook/MeshInstance3D.material_override = player1_top_material
	elif get_name() == "PlayerTwo":
		$Top/MeshInstance3D.material_override = player2_top_material
		$Body/Label3D.text = "Opponent"
		$Body/Label3D.modulate = Color.INDIAN_RED
		#$Hook/MeshInstance3D.material_override = player2_top_material

func _physics_process(_delta):
	if $Body.angular_velocity.length() > 0:
		whopwhop.play()
		print("whopwhpowhopwhpowhowhpow")
	else:
		whopwhop.stop()
		print("^_^_^_^_^_^_^_^_^_^_^_^_^_")


func _on_body_body_entered(body):
	if body.get_parent_node_3d().name == "PlayerOne" or body.get_parent_node_3d().name == "PlayerTwo":
		$Impact.play()


func _on_top_body_entered(body):
	if body.get_parent_node_3d().name == "PlayerOne" or body.get_parent_node_3d().name == "PlayerTwo":
		$Impact.play()


func _on_bottom_body_entered(body):
	if body.get_parent_node_3d().name == "PlayerOne" or body.get_parent_node_3d().name == "PlayerTwo":
		$Impact.play()
