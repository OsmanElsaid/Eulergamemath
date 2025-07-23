class_name MathEvaluator

# Mathematical expression evaluator for the Euler game
# Handles +, -, ×, ÷, and parentheses with proper order of operations

static func evaluate(expression: String) -> float:
	if expression.is_empty():
		return 0.0
	
	# Clean up the expression
	var clean_expr = expression.strip_edges()
	clean_expr = clean_expr.replace("×", "*")
	clean_expr = clean_expr.replace("÷", "/")
	
	# Remove extra spaces
	clean_expr = _remove_extra_spaces(clean_expr)
	
	# Parse and evaluate the expression
	var tokens = _tokenize(clean_expr)
	if tokens.is_empty():
		return 0.0
	
	var result = _evaluate_tokens(tokens)
	return result

static func _remove_extra_spaces(expr: String) -> String:
	var result = ""
	var prev_char = ""
	
	for i in range(expr.length()):
		var char = expr[i]
		if char == " ":
			if prev_char != " " and prev_char != "" and i < expr.length() - 1:
				result += char
		else:
			result += char
		prev_char = char
	
	return result.strip_edges()

static func _tokenize(expression: String) -> Array:
	var tokens = []
	var current_number = ""
	
	for i in range(expression.length()):
		var char = expression[i]
		
		if char.is_valid_int() or char == ".":
			current_number += char
		else:
			# Finish current number if we have one
			if not current_number.is_empty():
				tokens.append(float(current_number))
				current_number = ""
			
			# Add operator or parenthesis
			if char in ["+", "-", "*", "/", "(", ")"]:
				tokens.append(char)
			# Skip spaces
	
	# Add final number if exists
	if not current_number.is_empty():
		tokens.append(float(current_number))
	
	return tokens

static func _evaluate_tokens(tokens: Array) -> float:
	# Convert infix to postfix (Shunting Yard algorithm)
	var output_queue = []
	var operator_stack = []
	var precedence = {
		"+": 1,
		"-": 1,
		"*": 2,
		"/": 2
	}
	
	for token in tokens:
		if typeof(token) == TYPE_FLOAT:
			output_queue.append(token)
		elif token == "(":
			operator_stack.append(token)
		elif token == ")":
			while not operator_stack.is_empty() and operator_stack[-1] != "(":
				output_queue.append(operator_stack.pop_back())
			if not operator_stack.is_empty():
				operator_stack.pop_back()  # Remove the "("
		elif token in precedence:
			while (not operator_stack.is_empty() and 
				   operator_stack[-1] != "(" and
				   operator_stack[-1] in precedence and
				   precedence[operator_stack[-1]] >= precedence[token]):
				output_queue.append(operator_stack.pop_back())
			operator_stack.append(token)
	
	# Pop remaining operators
	while not operator_stack.is_empty():
		output_queue.append(operator_stack.pop_back())
	
	# Evaluate postfix expression
	return _evaluate_postfix(output_queue)

static func _evaluate_postfix(postfix: Array) -> float:
	var stack = []
	
	for token in postfix:
		if typeof(token) == TYPE_FLOAT:
			stack.append(token)
		elif token in ["+", "-", "*", "/"]:
			if stack.size() < 2:
				return 0.0  # Invalid expression
			
			var b = stack.pop_back()
			var a = stack.pop_back()
			var result = 0.0
			
			match token:
				"+":
					result = a + b
				"-":
					result = a - b
				"*":
					result = a * b
				"/":
					if b == 0:
						return 0.0  # Division by zero
					result = a / b
			
			stack.append(result)
	
	if stack.size() == 1:
		return stack[0]
	else:
		return 0.0  # Invalid expression

# Helper function to check if an expression is valid
static func is_valid_expression(expression: String) -> bool:
	if expression.is_empty():
		return false
	
	var clean_expr = expression.strip_edges()
	clean_expr = clean_expr.replace("×", "*")
	clean_expr = clean_expr.replace("÷", "/")
	
	var tokens = _tokenize(clean_expr)
	return _is_valid_token_sequence(tokens)

static func _is_valid_token_sequence(tokens: Array) -> bool:
	if tokens.is_empty():
		return false
	
	var paren_count = 0
	var expecting_number = true
	
	for i in range(tokens.size()):
		var token = tokens[i]
		
		if typeof(token) == TYPE_FLOAT:
			if not expecting_number:
				return false
			expecting_number = false
		elif token == "(":
			if not expecting_number:
				return false
			paren_count += 1
		elif token == ")":
			if expecting_number:
				return false
			paren_count -= 1
			if paren_count < 0:
				return false
		elif token in ["+", "-", "*", "/"]:
			if expecting_number:
				return false
			expecting_number = true
	
	return paren_count == 0 and not expecting_number