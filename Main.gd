extends Node2D

const SHEET = 0

# Position variables for snake and fruit
var fruit_pos
var snake_pos = [Vector2(5,6), Vector2(5,7), Vector2(5,8)]

# Initial snake direction when the game starts
var snake_direction = Vector2.UP

# Variable for controlling the inputs: (fixing a bug where a game over state is initialized if multiple inputs are pressed quickly)
var allow_moving = true

# Variable for determining whether to add the new fruit on the screen
var add_fruit = false

func _ready():
	Engine.target_fps = 60
	fruit_pos = generate_pos()
	draw_fruit()
	draw_snake()
	
# Generate random position which is used to place a fruit
func generate_pos():
	randomize()
	var x = randi() % 20
	var y = randi() % 20
	return Vector2(x, y)

# Drawing fruit sprite from the spritesheet
func draw_fruit():
	$SnakeTileSheet.set_cell(fruit_pos.x, fruit_pos.y, SHEET, false, false, false, Vector2(1,1))

# Drawing snake parts from the spritesheet (head and body parts)
func draw_snake():
	for i in snake_pos.size():
		var block = snake_pos[i]
		
		if i == 0:
			$SnakeTileSheet.set_cell(block.x, block.y, SHEET, false, false, false, Vector2(0,0))
		else:
			$SnakeTileSheet.set_cell(block.x, block.y, SHEET, false, false, false, Vector2(1,0))

func _input(event):
	# Movement inputs, check if snake is allowed to move
	# Without allow_moving variable there's a bug if multiple inputs are pressed quickly
	if Input.is_action_just_pressed("ui_up"):
		if snake_direction != Vector2.DOWN and allow_moving:
			snake_direction = Vector2.UP
			allow_moving = false
	if Input.is_action_just_pressed("ui_down"): 
		if snake_direction != Vector2.UP and allow_moving:
			snake_direction = Vector2.DOWN
			allow_moving = false
	if Input.is_action_just_pressed("ui_right"):
		if snake_direction != Vector2.LEFT and allow_moving:
			snake_direction = Vector2.RIGHT
			allow_moving = false
	if Input.is_action_just_pressed("ui_left"):
		if snake_direction != Vector2.RIGHT and allow_moving:
			snake_direction = Vector2.LEFT
			allow_moving = false

# Moving the snake
# Game is 'borderless', that is if the snake leaves the screen it will come out on the other side of the screen
func move_snake():
	var head = snake_pos[0]
	clear_tiles(SHEET)
	if add_fruit:
		clear_tiles(SHEET)
		
		var body_new = snake_pos.slice(0, snake_pos.size() - 1)
		var head_new = snake_pos[0] + snake_direction
		
		if head.x > 19:
			head_new = Vector2(-1, head.y) + snake_direction
		if head.x < 0:
			head_new = Vector2(20, head.y) + snake_direction
		if head.y > 19:
			head_new = Vector2(head.x, -1) + snake_direction	
		if head.y < 0:
			head_new = Vector2(head.x, 20) + snake_direction
		
		body_new.insert(0, head_new)
		snake_pos = body_new
		add_fruit = false
	else:
		clear_tiles(SHEET)
		var body_new = snake_pos.slice(0, snake_pos.size() - 2)
		var head_new = snake_pos[0] + snake_direction
		
		if head.x > 19:
			head_new = Vector2(-1, head.y) + snake_direction
		if head.x < 0:
			head_new = Vector2(20, head.y) + snake_direction
		if head.y > 19:
			head_new = Vector2(head.x, -1) + snake_direction	
		if head.y < 0:
			head_new = Vector2(head.x, 20) + snake_direction
		
		body_new.insert(0, head_new)
		snake_pos = body_new

func check_eating():
	if fruit_pos == snake_pos[0]:
		fruit_pos = generate_pos()
		# Speed up the timer / make the game harder the more points the player scores
		$Tick.wait_time -= 0.0005
		add_fruit = true
		get_tree().call_group('scoreGroup', 'update_score', snake_pos.size() - 2)
	
# Check if game reached some of the game over states
func check_game_over():
	var head = snake_pos[0]
	# Snake bite itself
	for i in snake_pos.slice(1, snake_pos.size() - 1):
		if i == head:
			reset()

# Reset the game
func reset():
	$Tick.wait_time = 0.1
	snake_pos = [Vector2(5,6), Vector2(5,7), Vector2(5,8)]
	draw_snake()
	get_tree().call_group('scoreGroup', 'update_score', 0)

# Clear tiles
func clear_tiles(x:int):
	var cells = $SnakeTileSheet.get_used_cells_by_id(x)
	for i in cells:
		$SnakeTileSheet.set_cell(i.x, i.y, -1)

# Keep checking if the game is over or if fruit has been placed on a tile which is a part of snake's body
func _process(delta):
	check_game_over	()
	if fruit_pos in snake_pos:
		fruit_pos = generate_pos()
	
func _on_Tick_timeout():
	move_snake()
	draw_fruit()
	draw_snake()
	check_eating()
	# Don't allow multiple inputs pressed quickly as this could cause the game over state
	allow_moving = true
	# Don't allow inputs for a game tick when snake leaves the borders
	if snake_pos[0].y < 0 or snake_pos[0].x < 0 or snake_pos[0].x > 19 or snake_pos[0].y > 19:
		allow_moving = false
