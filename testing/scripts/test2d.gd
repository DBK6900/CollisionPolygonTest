extends Sprite2D


func _ready() -> void:

	var area: Area2D = $Area2D
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

	var bitmap: BitMap = BitMap.new()
	bitmap.create_from_image_alpha(texture.get_image())

	var polys: Array[PackedVector2Array] = bitmap.opaque_to_polygons(rect, 10.0) # PackedVector2Array = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture.get_size()), 1.0) this was my mistake
	for poly in polys:
		var collision_polygon: CollisionPolygon2D = CollisionPolygon2D.new()
		collision_polygon = poly # .append(poly) and here
		area.add_child(collision_polygon)

		# Generated polygon will not take into account the half-width and half-height offset
		# of the image when "centered" is on. So move it backwards by this amount so it lines up.
		if centered:
			collision_polygon.position -= bitmap.get_size()/2.0

func _on_mouse_entered() -> void:
	print("Sucess")

func _on_mouse_exited() -> void:
	print("Sucess Exit")
