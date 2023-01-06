extends Node2D

func _process(_delta):
	$Soul.rotation_degrees = $HSlider.value
	$Soul.blueMaxJumps = $SpinBox.value
