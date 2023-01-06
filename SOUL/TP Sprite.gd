extends Sprite2D

func _process(delta):
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	modulate.a -= delta / 2
