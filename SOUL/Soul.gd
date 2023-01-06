extends CharacterBody2D

@export var inverted_controls = false
var TPd := []
const tp := preload("res://Audio/TP.wav")
const ow := preload("res://Audio/Ouch.wav")
var inv = 0
var dp := position

func _process(delta):
	if inv == 0:
		for Obj in get_node("TP").get_overlapping_areas():
			if (zero(Obj.get("atkType")) & Atk.Blue and not get_velocity() == Vector2.ZERO) or \
			(zero(Obj.get("atkType")) & Atk.Orange   and get_velocity() == Vector2.ZERO):
				if TPd.has(Obj):
					emit_signal("TP", delta)
					if not ($Aud.playing or $Aud.volume_db > -1):
						get_node("TP Sprite2D").modulate.a = .25
						get_node("Aud").stream = tp
						get_node("Aud").volume_db = -10
						get_node("Aud").play()
				else:
					emit_signal("TP", 0.75)
					TPd.append(Obj)
					get_node("TP Sprite2D").modulate.a = .75
					get_node("Aud").stream = tp
					get_node("Aud").volume_db = -0.5
					get_node("Aud").play()
		for Obj in get_node("HitBox").get_overlapping_areas():
			if (zero(Obj.get("atkType")) & Atk.Blue and not get_velocity() == Vector2.ZERO) or \
			(zero(Obj.get("atkType")) & Atk.Orange   and get_velocity() == Vector2.ZERO):
				emit_signal("hurt", zero(Obj.get("damage")))
				inv = 2
				get_node("Aud").stop()
				get_node("Aud").stream = ow
				get_node("Aud").volume_db = 0
				get_node("Aud").play()
			match (zero(Obj.get("atkType"))) & Atk.Emotions:
				Atk.Happy:
					emit_signal("emo", "H")
				Atk.Sad:
					emit_signal("emo", "S")
				Atk.Angry:
					emit_signal("emo", "A")
	else:
		for Obj in get_node("HitBox").get_overlapping_areas():
			if zero(Obj.get("delete")):
				Obj.queue_free()

func get_velocity():
	return dp - position

func invincible():
	return inv > 0

func set_inv(lenght):
	inv = lenght

func zero(Var):
	if Var == null:
		return 0
	else:
		return Var

func move(vec):
	if inverted_controls:
		self.set_velocity(-vec)
		self.move_and_slide()
	else:
		self.set_velocity(vec)
		self.move_and_slide()

signal emo(emotion)
signal hurt(damage)
signal TP(amount)
