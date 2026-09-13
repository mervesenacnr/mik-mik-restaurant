extends SceneTree
var game
var checks = 0
var failures = 0
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize(): call_deferred("run")
func contains_picker(node):
	if node is ColorPickerButton or node is ColorPicker: return true
	return node.get_children().any(func(child): return contains_picker(child))
func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	var p = game.profile
	check(p.FUR_PALETTE.size() == 4 and p.CLOTH_PALETTE.size() == 4,"Four curated colors per category")
	check(not contains_picker(game.modal),"RGB picker removed from UI")
	check(not p.select_palette("fur",4) and not p.select_palette("rgb",0),"Invalid palette selections rejected")
	check(not p.select_eyes("unknown"),"Unknown eyes rejected")
	var custom = Color("ff0033")
	var mapped = p.nearest_palette(custom,p.FUR_PALETTE)
	check(p.FUR_PALETTE.any(func(c): return c[1] == mapped),"Old custom colors map to curated palette")
	p.record("served",50)
	p.record("kills",75)
	for i in range(4):
		p.select_character(p.CHARACTERS[i][0])
		p.select_eyes(p.EYES[i][0])
		game.profile_menu.show_page("crew")
		var model = game.profile_menu.preview_model
		check(model.get_meta("eye_shape") == p.EYES[i][0],"Selected eyes appear on model")
		check(model.get_meta("character_style") == p.CHARACTERS[i][0],"Character signature appears on preview")
		check(model.get_node("CharacterSignature").get_child_count() == 1,"Character details batched")
		await process_frame
	game.start_run()
	check(game.mouse_model.get_meta("eye_shape") == "oval","Selected eyes carry into gameplay")
	var esc = InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	game._input(esc)
	check(game.paused and game.modal.visible,"Escape pauses and opens menu")
	var time = game.wave_time
	var position = game.player.position
	var elapsed = game.elapsed
	Input.action_press("right")
	game._physics_process(1)
	game._process(1)
	Input.action_release("right")
	check(game.wave_time == time and game.player.position == position and game.elapsed == elapsed,"Pause freezes clock movement and animations")
	esc.echo = true
	game._input(esc)
	check(game.paused,"Held Escape does not repeatedly toggle")
	esc.echo = false
	game._input(esc)
	check(not game.paused and not game.modal.visible,"Second Escape resumes")
	game.show_upgrades(false,"kitchen")
	var offers = game.offers.duplicate()
	game._input(esc)
	check(game.choosing and game.offers == offers,"Escape never skips mandatory upgrade choice")
	check(game.world.has_node("KitchenDetails"),"Kitchen detail geometry exists")
	check(game.tables.all(func(t): return t.root.has_node("TableDetails")),"All tables have detailed settings")
	for i in range(4):
		var food = game.FoodVisual.new().setup(i)
		root.add_child(food)
		check(food.portions.all(func(portion): return portion.get_child_count() == 1),"Edible detail meshes batched")
		food.advance(1,0)
		check(food.portions.all(func(portion): return not portion.visible),"Detailed food still disappears when eaten")
		food.queue_free()
	print("STYLE TEST: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
