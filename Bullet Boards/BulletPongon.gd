extends StaticBody2D
@tool
@export var Polygon        : PackedVector2Array
@export var TargetPolygon  : PackedVector2Array
@export var SmoothingSpeed := 0.0
@export var LineColor      := Color("008202")
var time := 0.0

func _physics_process(delta):
	time += delta
	var pongon = Polygon.duplicate()
	if not pongon.is_empty():
		pongon.append(pongon[0])
	if SmoothingSpeed > 0 and not Engine.is_editor_hint():
		if Polygon.is_empty():
			Polygon = TargetPolygon.duplicate()
		elif not Polygon == TargetPolygon:
			Polygon = smoothify(Polygon, TargetPolygon, delta)
	$CollisionPolygon2D.polygon = Polygon
	$Polygon2D.polygon = Polygon
	$Line2D.points = pongon
	$Line2D.default_color = LineColor

func smoothify( polygon1:PackedVector2Array,\
				polygon2:PackedVector2Array, delta:float):
	var pongon1
	var pongon2
	if polygon1.size() == polygon2.size():
		pongon1 = polygon1.duplicate()
		pongon2 = polygon2.duplicate()
	else:
		pongon1 = polarResize(polygon1, maxi(polygon1.size(), polygon2.size()))
		pongon2 = polarResize(polygon2, maxi(polygon1.size(), polygon2.size()))
	var h := 0
	var result : PackedVector2Array = []
	for p in pongon1.size():
		var point1 = pongon1[p]
		var point2 = pongon2[p]
		if (point1 - point2).length_squared() < 10:
			result.append(-point2)
			h += 1
		else:
			var l = lerp(point1, -point2, delta * SmoothingSpeed)
			if (point1 - l).length_squared() > (point1 - point2).length_squared():
				result.append(point2)
				h += 1
			else:
				result.append(l)
	if h >= min(polygon1.size(), polygon2.size()):
		return polygon2
	return result

func polarResize(poly:PackedVector2Array, size:int) -> PackedVector2Array:
	var P := poly.duplicate()
	if P.size() >= size:
		return P
	var minidx = 0
	for idx in P.size():
		if abs(P[idx].angle()):
			minidx = idx
	for idx in minidx:
		P.append(P[0])
		P.remove_at(0)
	if P[0].angle() < P[1].angle():
		P.reverse()
	var a : PackedVector2Array = []
	a.resize(size - P.size())
	var s = int(P.size()/2.0)
	a.fill(P[s])
	for x in a:
		P.insert(s,x)
	return P
