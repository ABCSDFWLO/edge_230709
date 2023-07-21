extends Camera2D


const SPEED: float = 0.03;

var player: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("../Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.position+=(player.position-self.position)*SPEED
