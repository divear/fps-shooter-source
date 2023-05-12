extends Node3D

var t := 0.0
func _physics_process(delta: float):
	t+=delta
#	$Path3D/PathFollow3D.progress_ratio = t/100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
