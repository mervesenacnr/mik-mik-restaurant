extends SceneTree
var game
var checks = 0
var failures = 0
func check(ok, message):
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func find_button(node, text):
	if node is Button and node.text == text: return node
	for child in node.get_children():
		var found = find_button(child,text)
		if found != null: return found
	return null
func _initialize(): call_deferred("run")
func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	var p = game.profile
	game.profile_menu.show_page("crew")
	game.profile_menu.show_page("crew")
	await process_frame
	check(is_instance_valid(game.profile_menu.preview_model),"Rapid menu rebuild keeps valid preview")
	check(p.character == "mik" and p.wallet == 0,"Fresh profile defaults")
	check(not p.select_character("zip") and not p.select_costume("armor"),"Locked selections rejected")
	check(not p.select_difficulty(2) and p.select_difficulty(1),"Hard is available, nightmare requires victory")
	check(not p.buy("health"),"Training requires earned currency")
	p.record("served",10)
	check(p.wallet == 10 and p.unlocked.has("service"),"Ten meals unlock courier and award tips")
	check(p.select_character("zip") and p.select_costume("scarf"),"Unlocked selections accepted")
	check(p.buy("health") and p.wallet == 0 and p.training.health == 1,"Purchase debits correct price")
	check(p.price("health") == 20,"Training price rises")
	p.record("kills",75)
	check(p.wallet == 7 and p.unlocked.has("hunter"),"Combat milestone awards hunter and currency")
	p.record("served",40)
	check(p.unlocked.has("host"),"Lifetime service unlocks Nane")
	p.record("wave",4)
	check(p.wallet == 67,"Survival bonus paid once")
	p.record("wave",4)
	check(p.wallet == 67,"Repeated milestone does not pay twice")
	p.record("wins")
	check(p.difficulty_open(2) and p.select_costume("royal"),"Victory unlocks costume and nightmare")
	p.record("hard_wins")
	check(p.wallet == 147,"Hard victory bonus")
	p.wallet = 1000
	for i in range(8): p.buy("speed")
	check(p.training.speed == 5 and p.wallet == 850,"Five-tier cap and exact aggregate cost")
	check(not p.buy("unknown"),"Unknown training rejected")
	p.select_palette("fur",2)
	p.select_palette("cloth",3)
	p.select_eyes("sharp")
	p.select_character("tok")
	p.select_difficulty(2)
	var file = "user://profile_test_temporary.cfg"
	check(p.save_profile(file) == OK,"Profile serializes")
	var restored = load("res://scripts/profile.gd").new().setup(game)
	root.add_child(restored)
	restored.read_save(file)
	check(restored.wallet == p.wallet and restored.training == p.training,"Wallet and training persist")
	check(restored.character == "tok" and restored.costume == "royal" and restored.difficulty == 2,"Unlocked selections persist")
	check(restored.fur == p.fur and restored.cloth == p.cloth,"Curated colors persist")
	check(restored.eye_shape == "sharp","Eye shape persists")
	check(restored.unlocked.size() == 6 and restored.stats == p.stats,"Achievement progress persists")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
	find_button(game.modal,"Başlangıç statları").pressed.emit()
	await process_frame
	check(game.profile_menu.page == "training","Training tab button works")
	find_button(game.modal,"Başarımlar").pressed.emit()
	await process_frame
	check(game.profile_menu.page == "achievements","Achievements tab button works")
	find_button(game.modal,"Fareler & stil").pressed.emit()
	await process_frame
	check(game.profile_menu.page == "crew","Crew tab button works")
	find_button(game.modal,"BAŞLA   →").pressed.emit()
	check(game.running and not game.modal.visible,"Start button launches selected build")
	check(is_equal_approx(game.max_health,132) and game.health == 132,"Base health combines training and character")
	check(is_equal_approx(game.speed,5.8*1.15*.92),"Permanent speed and character trait stack")
	check(is_equal_approx(game.monsters.power,1.15),"Fighter damage trait applied")
	check(game.kitchen_slots.is_empty() and game.combat_slots == ["pressure"],"Permanent stats do not occupy run slots")
	check(game.mouse_model.get_meta("chef_hat").all(func(part): return not part.visible),"Royal costume replaces chef hat")
	check(not p.buy("clean") and not p.select_character("mik") and not p.select_difficulty(0),"Build cannot change mid-run")
	var speed = game.speed
	game.apply_starting_build()
	check(game.speed == speed,"Starting bonuses only apply once")
	var enemy = game.monsters.spawn_enemy(0)
	check(is_equal_approx(enemy.max_hp,21.5*1.8),"Nightmare increases enemy HP")
	enemy.node.position = game.player.position+Vector3(0,0,.8)
	enemy.attack = .01
	game.hurt_left = 0
	game.monsters.fire_left = 999
	game.monsters.update(.02)
	check(is_equal_approx(game.health,132-7*1.6),"Nightmare increases attack damage")
	game.health = game.max_health-1
	game.spawn_guest()
	var guest = game.guests[-1]
	game.assign_table(guest)
	game.complete_meal(guest.table)
	check(game.health == game.max_health,"Meal healing respects upgraded health cap")
	var before = p.stats.wins
	game.finish_run(true)
	var wallet = p.wallet
	game.finish_run(true)
	check(p.stats.wins == before+1 and p.wallet == wallet,"Run completion rewards only once")
	# Separate role configurations keep run state fresh.
	for id in ["zip","nane"]:
		var other = load("res://scripts/game.gd").new()
		other.test_mode = true
		root.add_child(other)
		other.set_process(false)
		other.set_physics_process(false)
		other.profile.record("served",50)
		other.profile.select_character(id)
		other.start_run()
		if id == "zip": check(other.capacity == 3 and is_equal_approx(other.speed,5.8*1.15),"Courier starts with carrying and speed bonuses")
		else: check(is_equal_approx(other.cook_rate,1.25) and is_equal_approx(other.clean_rate,1.2),"Nane starts with kitchen bonuses")
		other.queue_free()
		await process_frame
	print("PROFILE TEST: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
