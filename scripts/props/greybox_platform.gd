extends StaticBody2D
## Greybox floor segment; collision + fill match `platform_size`.

@export var platform_size: Vector2 = Vector2(640, 120)


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = platform_size
	$CollisionShape2D.shape = rect
	var hx := platform_size.x * 0.5
	var hy := platform_size.y * 0.5
	$Polygon2D.polygon = PackedVector2Array(
		[Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)]
	)
