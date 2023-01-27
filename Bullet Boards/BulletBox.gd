@tool
extends CanvasGroup
const default = Color(0,0.5,0,1)
@export var Size: Vector2
@export var color: Color = default
var size = Size

func _ready():
	size = Size
	changeSize(Size, .1/6)

func _process(delta):
	if color == default:
		$Walls.collision_layer = 1
		$Walls.collision_mask  = 1
	else:
		$Walls.collision_layer = 2
		$Walls.collision_mask  = 2
	$Green.color = color
	if Size != size:
		changeSize(Size, delta)
		sizeChanged()
	if has_node("Hide"):
		$Hide.size            = $Black.size
		$Hide.global_position = $Black.global_position
		$Hide.clip_contents = true
		$Hide.color = Color.BLACK

func changeSize(N : Vector2, dt):
	InstChangeSize(lerp(size, N, dt*3))

func InstChangeSize(N : Vector2):
	for j in get_children():
		j.position = -N/2
	$Black.position += Vector2(5,5)
	size = N
	sizeChanged()

func sizeChanged():
	var HCollision = $Walls/T.shape
	HCollision.a = size.x/2 * Vector2.LEFT
	HCollision.b = size.x/2 * Vector2.RIGHT
	var VCollision = $Walls/L.shape
	VCollision.a = size.y/2 * Vector2.UP
	VCollision.b = size.y/2 * Vector2.DOWN
	
	$Green.size = size
	$Black.size = Vector2(size.x - 9, size.y - 9)
	$Walls/T.position  = Vector2(size.x / 2, 2.5)
	$Walls/B.position  = Vector2(size.x / 2, size.y - 2.5)
	$Walls/L.position  = Vector2(2.5, size.y / 2)
	$Walls/R.position  = Vector2(size.x - 2.5, size.y / 2)
