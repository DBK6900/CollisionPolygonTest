@tool
extends Sprite3D

@export var generate_poly: bool:
	set(value):
		set_poly()

func _on_Area_input_event(_camera: Camera3D, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx:int)-> void:  
	  
	if event is InputEventMouseButton:	
		print("click")

func test_print() -> void:
	print("Test")

func set_poly() -> void:

	var target_parent: Area3D = self.get_child(0)
	var source_sprite: Sprite3D = self
	var standing_up: bool = true
	for node in target_parent.get_children():
		node.queue_free()

	# Generate Bitmap from Sprite3D
	var image : Image = source_sprite.get_texture().get_image()
	var format: int = image.get_format()
	print("Image Format before decompress: " + str(format))
	var ret: int = image.decompress()
	var format_after: int = image.get_format()
	print("Image Format: " + str(format_after))
	print("Image Decompressing: " + str(ret == Error.OK))

	var bitmap: BitMap = BitMap.new()
	bitmap.create_from_image_alpha(image, 0.1) # Opacity treshhold
	
	var bs: Vector2i = bitmap.get_size()
	print("BitMap Size: " + str(bs))

	# for i in range(bs.x):
	# 	for j in range(bs.y):
	# 		print(bitmap.get_bit(i,j))

	# Create Collision Polygon from Opaque Pixels
	var _scale: float = source_sprite.pixel_size
	var rect: Rect2 = Rect2(0,0,image.get_width(),image.get_height())
	print("Rect2: " + str(rect))
	var polys: PackedVector2Array = bitmap.opaque_to_polygons(rect, 10.0) # Set to 0.0 for pixel perfect
	print("Polys: " + str(polys))
	# Flip and resize for 3D
	var _transform: Transform2D = Transform2D.FLIP_Y * Transform2D(0, Vector2(_scale, _scale), 0, Vector2.ZERO)
	for poly in polys:
		var collision_polygon: CollisionPolygon3D = CollisionPolygon3D.new()
		collision_polygon.depth = 0.05 # Increase if you want fake depth (e.g. with stacked sprites)
		collision_polygon.polygon.append(poly * _transform)
		print("Poly * transform: " + str(poly * _transform))
		target_parent.add_child(collision_polygon)
		# Shift the shape to match the sprite (it's usually centered)
		collision_polygon.position.x -= image.get_width() * _scale / 2
		if standing_up:
			collision_polygon.position.y += image.get_height() * _scale # /2 if the sprite isn't anchored down
		else:
			collision_polygon.set_rotation_degrees(Vector3(-90, 0, 0))
			collision_polygon.position.z -= image.get_height() * _scale / 2

	print("Done!")

	target_parent.input_event.connect(_on_Area_input_event)
	#var child: CollisionPolygon3D = target_parent.get_child(0)
	#print(child.polygon)

func _ready() -> void:
	set_poly()
