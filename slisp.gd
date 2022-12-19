class_name Slisp

enum {
	ATOM
	CHAR
	STR
}

enum {
	STR_MODE
	EXPR_MODE
}

var template = null
var index = 0
var length = null
var current = null
var tokens = []
var finished = false
var depth = 0
var output = PoolStringArray()
var mode = STR_MODE
var stack = []

func _init(template: String):
	self.template = template
	self.length = template.length()
	self.current = template[0]
	_tokenise()

func _advance():
	if index < length - 1:
		index += 1
		current = template[index]
	else:
		finished = true

func _tail():
	var tail = tokens
	var n = 0
	while n < depth:
		tail = tail[tail.size() - 1]
		n += 1
	
	return tail

func _begin_expr():
	_advance()
	_tail().push_back([])
	depth += 1

func _end_expr():
	_advance()
	depth -= 1

func _take_string():
	#begin_expr()
	_advance()
	var buffer = PoolStringArray()
	while !finished:
		if '"' == current:
			#end_expr()
			_advance()
			break
		buffer.push_back(current)
		_advance()
	_tail().push_back({'type': STR, 'value': buffer.join('')})

func _add_identifiers(expr):
	for identifier in expr.join('').split(' '):
		if identifier != '':
			_tail().push_back({'type': ATOM, 'value': identifier})

func _take_expr():
	var expr = PoolStringArray()
	while !finished:
		match current:
			'>': break
			'<': break
			'"':
				_add_identifiers(expr)
				expr = PoolStringArray()
				_take_string()
			_:
				expr.push_back(current)
				_advance()
	_add_identifiers(expr)
	

func _DEBUG_print_tokens(t, level):
	match typeof(t):
		TYPE_ARRAY:
			print('[', level, ']')
			for _t in t:
				_DEBUG_print_tokens(_t, level + 1)
		TYPE_DICTIONARY: print(' '.repeat(level * 2), ' ', t['type'], '::', t['value'])
		_: print('unreachable')

func _tokenise():
	while !finished:
		match current:
			'<':
				mode = EXPR_MODE
				_begin_expr()
			'>':
				_end_expr()
				if depth == 0:
					mode = STR_MODE
			_:
				if mode == STR_MODE:
					_tail().push_back({'type': CHAR, 'value': current})
					_advance()
				else:
					_take_expr()

func _func_put(list, state: Dictionary) -> void:
	_process(list[1], state)
	var n = 1
	while n < list.size():
		_process(list[n], state)
		output.push_back(stack.pop_back())
		n += 1

func _func_when(list, state: Dictionary) -> void:
	_process(list[1], state)
	var result = stack.pop_back()
	if result:
		_process(list[2], state)
		output.push_back(stack.pop_back())

func _func_if(list, state: Dictionary) -> void:
	_process(list[1], state)
	if stack.pop_back():
		_process(list[2], state)
	else:
		_process(list[3], state)
	output.push_back(stack.pop_back())

func _func_str(list, state: Dictionary) -> void:
	var i = 1
	var buffer = PoolStringArray()
	while i < list.size():
		_process(list[i], state)
		buffer.push_back(stack.pop_back())
		i += 1
	stack.push_back(buffer.join(''))

func _func_eq(list, state: Dictionary) -> void:
	_process(list[1], state)
	_process(list[2], state)
	
	var s2 = stack.pop_back()
	var s1 = stack.pop_back()
	
	if s1 == s2:
		stack.push_back(true)
	else:
		stack.push_back(false)

func _process_list(list, state):
	var head = list[0]
	if typeof(head) == TYPE_DICTIONARY and head['type'] == ATOM:
		match head['value']:
					'if':   _func_if(list, state)
					'put':  _func_put(list, state)
					'when': _func_when(list, state)
					'str':  _func_str(list, state)
					'eq':   _func_eq(list, state)
					_:      push_error('Unrecognised atom: {name}'.format({'name': head['value']}))
	else:
		for t in list:
			_process(t, state)

func _process(tokens, state):
	match typeof(tokens):
		TYPE_ARRAY:
			_process_list(tokens, state)
		TYPE_DICTIONARY:
			var type = tokens['type']
			var value = tokens['value']
			match type:
				ATOM: stack.push_back(state.get(value))
				CHAR: output.push_back(value)
				STR: stack.push_back(value)
				_: push_error("Unexpected token when processing Slisp {t}".format({'t': tokens}))

func render(state: Dictionary) -> String:
	_process(tokens, state)
	var result = output.join('')
	output = PoolStringArray()
	return result
