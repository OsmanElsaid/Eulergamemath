extends Node

# Player class to store player data
class_name GameManager

# Enums for game states
enum GameMode {
	ONLINE_MULTIPLAYER,
	LOCAL_MULTIPLAYER,
	AI_OPPONENT
}

enum GameState {
	WAITING_FOR_PLAYERS,
	SETTING_TARGET,
	PLAYING,
	EVALUATING,
	FINISHED
}

# Game settings
var game_mode: GameMode
var max_players: int = 4
var min_players: int = 2
var current_turn_time: float = 10.0
var target_number: int = 0
var target_digits: int = 3
var current_turn: int = 1
var max_turns: int = 16

# Player management
var players: Array[Player] = []
var current_player_index: int = 0
var game_state: GameState = GameState.WAITING_FOR_PLAYERS

# Game rules tracking
var winning_player: Player = null
var completed_players: Array[Player] = []

# Signals for game events
signal player_joined(player: Player)
signal player_left(player: Player)
signal turn_changed(player: Player)
signal game_started()
signal game_finished()
signal target_set(target: int)

class Player:
	var id: String
	var name: String
	var is_ai: bool = false
	var is_host: bool = false
	var is_connected: bool = true
	
	# Game state
	var numbers: Array[int] = []
	var operations: Array[String] = []
	var current_expression: String = ""
	var final_result: int = 0
	var has_finished: bool = false
	var badges_earned: Array[String] = []
	var points: int = 0
	
	# Turn management
	var missed_turns: int = 0
	var penalties: int = 0
	var no_button_uses: int = 0
	var free_button_used: bool = false
	var can_use_lottery: bool = true
	
	# Operations tracking for rules
	var used_addition: bool = false
	var used_subtraction: bool = false
	var used_multiplication: bool = false
	var used_division: bool = false
	var open_parentheses_count: int = 0
	
	func _init(player_id: String, player_name: String):
		id = player_id
		name = player_name
	
	func reset_for_new_round():
		numbers.clear()
		operations.clear()
		current_expression = ""
		final_result = 0
		has_finished = false
		badges_earned.clear()
		missed_turns = 0
		penalties = 0
		no_button_uses = 0
		free_button_used = false
		can_use_lottery = true
		used_addition = false
		used_subtraction = false
		used_multiplication = false
		used_division = false
		open_parentheses_count = 0
	
	func can_end_turn() -> bool:
		# Check if all basic operations have been used
		return used_addition and used_subtraction and used_multiplication and used_division
	
	func add_number(number: int):
		numbers.append(number)
		_update_expression()
	
	func add_operation(operation: String):
		operations.append(operation)
		
		# Track which operations have been used
		match operation:
			"+":
				used_addition = true
			"-":
				used_subtraction = true
			"×":
				used_multiplication = true
			"÷":
				used_division = true
			"(":
				open_parentheses_count += 1
			")":
				open_parentheses_count -= 1
		
		_update_expression()
	
	func _update_expression():
		current_expression = ""
		var num_index = 0
		var op_index = 0
		
		while num_index < numbers.size() or op_index < operations.size():
			if num_index < numbers.size():
				current_expression += str(numbers[num_index])
				num_index += 1
			
			if op_index < operations.size():
				current_expression += " " + operations[op_index] + " "
				op_index += 1
	
	func calculate_result() -> int:
		if current_expression.is_empty():
			return 0
		
		# Simple expression evaluation (this would need a proper math parser in production)
		var expression = current_expression.replace("×", "*").replace("÷", "/")
		final_result = _evaluate_expression(expression)
		return final_result
	
	func _evaluate_expression(expr: String) -> int:
		# Use the MathEvaluator to calculate the result
		var result = MathEvaluator.evaluate(expr)
		return int(result)

func _ready():
	# Initialize the game manager
	game_state = GameState.WAITING_FOR_PLAYERS

func add_player(player_name: String, is_ai_player: bool = false) -> Player:
	if players.size() >= max_players:
		return null
	
	var player_id = "player_" + str(players.size())
	var new_player = Player.new(player_id, player_name)
	new_player.is_ai = is_ai_player
	
	if players.is_empty():
		new_player.is_host = true
	
	players.append(new_player)
	player_joined.emit(new_player)
	
	return new_player

func remove_player(player: Player):
	var index = players.find(player)
	if index != -1:
		players.remove_at(index)
		player_left.emit(player)
		
		# Reassign host if needed
		if player.is_host and not players.is_empty():
			players[0].is_host = true

func start_game():
	if players.size() < min_players:
		return false
	
	# Reset all players for new round
	for player in players:
		player.reset_for_new_round()
	
	# Shuffle player order
	players.shuffle()
	current_player_index = 0
	current_turn = 1
	
	game_state = GameState.SETTING_TARGET
	game_started.emit()
	
	return true

func set_target_number(target: int):
	target_number = target
	target_digits = str(target).length()
	game_state = GameState.PLAYING
	target_set.emit(target)

func get_current_player() -> Player:
	if players.is_empty() or current_player_index >= players.size():
		return null
	return players[current_player_index]

func next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	
	# Check if all players have completed their turn
	if current_player_index == 0:
		current_turn += 1
	
	# Check for game end conditions
	if current_turn > max_turns:
		end_game()
	else:
		turn_changed.emit(get_current_player())

func player_finished(player: Player):
	player.has_finished = true
	completed_players.append(player)
	
	# Award badges
	match completed_players.size():
		1:
			player.badges_earned.append("Gold")
		2:
			player.badges_earned.append("Silver")
		3:
			player.badges_earned.append("Bronze")
	
	# Check if this player won
	if player.final_result == target_number and winning_player == null:
		winning_player = player

func end_game():
	game_state = GameState.EVALUATING
	
	# Calculate final scores and rankings
	_calculate_final_scores()
	
	game_state = GameState.FINISHED
	game_finished.emit()

func _calculate_final_scores():
	# Evaluate players who didn't finish
	var unfinished_players = []
	for player in players:
		if not player.has_finished:
			player.calculate_result()
			unfinished_players.append(player)
	
	# Sort by closest to target
	unfinished_players.sort_custom(func(a, b): return abs(a.final_result - target_number) < abs(b.final_result - target_number))
	
	# Award points based on closeness rules
	var target_diff_threshold = 10 if target_digits == 4 else (100 if target_digits == 5 else 0)
	
	if target_digits > 3:  # Only for 4+ digit targets
		var points_awarded = [3, 2, 1]
		for i in range(min(3, unfinished_players.size())):
			var diff = abs(unfinished_players[i].final_result - target_number)
			if diff <= target_diff_threshold:
				unfinished_players[i].points += points_awarded[i]

func reset_game():
	players.clear()
	current_player_index = 0
	current_turn = 1
	target_number = 0
	winning_player = null
	completed_players.clear()
	game_state = GameState.WAITING_FOR_PLAYERS

# Utility functions
func generate_random_target(digits: int) -> int:
	var min_val = int(pow(10, digits - 1))
	var max_val = int(pow(10, digits)) - 1
	return randi_range(min_val, max_val)

func is_valid_operation_sequence(last_op: String, new_op: String) -> bool:
	var basic_ops = ["+", "-", "×", "÷"]
	
	# Basic operation cannot follow another basic operation
	if last_op in basic_ops and new_op in basic_ops:
		return false
	
	return true