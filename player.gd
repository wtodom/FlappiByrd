extends Area2D

signal crashed
signal score_increased

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var flap_start
var progress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func start(pos):
	position = pos
	show()
	$AnimatedSprite2D.play()
	$CollisionShape2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2(0, delta * 9.8)
	rotation = PI / 6

	if Input.is_action_pressed('flap'):
		if $FlapDebounce.is_stopped():
			flap_start = position
			velocity = Vector2.ZERO
			$FlapTimer.start()
			$FlapDebounce.start()
			$FlapSound.play()

	if not $FlapTimer.is_stopped():
		progress = $FlapTimer.time_left / $FlapTimer.wait_time
		var next_point = _quadratic_bezier(
			flap_start,
			Vector2(flap_start.x + 150, flap_start.y - 300),
			Vector2(flap_start.x + 280, flap_start.y),
			progress
		)
		position.y = next_point.y
		if progress < 0.4:
			rotation = PI / 6
		elif progress < 0.6:
			rotation = 0
		else:
			rotation = -PI / 6


	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_body_entered(body):
	match body.name:
		'Gap':
			score_increased.emit()
		_:
			hide() # Player disappears after being hit.
			crashed.emit()
			# Must be deferred as we can't change physics properties on a physics callback.
			$CollisionShape2D.set_deferred("disabled", true)

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var point = q0.lerp(q1, t)
	return point
