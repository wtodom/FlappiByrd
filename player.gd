extends Area2D

signal crashed
signal score_increased

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed('up'):
		velocity.y -= 1
		rotation = -PI/6
	if Input.is_action_pressed('down'):
		velocity.y += 1
		rotation = PI/6
	if not Input.is_anything_pressed():
		rotation = 0

	if Input.is_action_pressed('flap'):
		pass
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_body_entered(body):
	# TODO: Why doesn't this always get hit?
	match body.name:
		'Gap':
			score_increased.emit()
		_:
			hide() # Player disappears after being hit.
			crashed.emit()
			# Must be deferred as we can't change physics properties on a physics callback.
			$CollisionShape2D.set_deferred("disabled", true)
