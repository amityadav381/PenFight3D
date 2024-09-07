extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func initialise_material(color:Color):
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = color
	#Color(randf(), randf(), randf())#get_parent().pen_color_from_main
	#print("get_parent() = ",get_parent())
	material_override = new_material
	
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
