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
func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.start_run()
	check(game.combat_slots == ["pressure"],"Starting soda uses one slot")
	check(game.available_perks().all(func(p): return p[0] not in ["robot","belt"]),"No early automation")
	game.apply_perk("robot")
	game.apply_perk("belt")
	check(not game.perks.has("robot") and not game.perks.has("belt"),"Cannot bypass prerequisites")
	for id in ["clean","capacity","hands","speed","oven","decor"]: game.apply_perk(id)
	check(game.kitchen_slots.size() == 6,"Six kitchen slots")
	game.apply_perk("tips")
	check(not game.perks.has("tips"),"Seventh kitchen item rejected")
	check(game.available_perks().all(func(p): return game.perks.has(p[0])),"Full loadout upgrades owned items")
	for i in range(3):
		game.apply_perk("clean")
		game.apply_perk("capacity")
	check(game.perks.clean == 4 and game.clean_rate>3,"Cleaning reaches IV")
	game.show_upgrades(false,"kitchen")
	check(game.offers.filter(func(p): return p[0] in ["robot","belt"]).size() == 2,"Maxed prerequisites offer both evolutions")
	game.choose_perk(game.offers.find(game.offers.filter(func(p): return p[0] == "robot")[0]))
	check(game.perks.has("robot") and game.kitchen_slots.has("robot") and not game.kitchen_slots.has("clean"),"Evolution replaces base slot")
	check(game.kitchen_slots.size() == 6,"Evolution doesn't exceed cap")
	game.show_upgrades(false,"kitchen")
	check(game.offers.all(func(p): return p[0] not in ["robot","belt"]),"Declined evolution is offered only once")
	game.resume_after_upgrade()
	for id in ["knife","pan","pepper","reload","reach"]: game.apply_perk(id)
	check(game.combat_slots.size() == 6,"Six combat slots independent of kitchen")
	game.apply_perk("might")
	check(not game.perks.has("might"),"Seventh combat item rejected")
	for i in range(6): game.apply_perk("knife")
	check(game.perks.knife == 4,"Weapon tiers capped at IV")
	check(game.available_perks("","combat").all(func(p): return game.combat_slots.has(p[0]) and p[0] != "knife"),"Max weapons leave offer pool")
	for wave in range(1,7):
		game.wave = wave
		var kinds: Array = []
		for i in range(200): kinds.append(game.monsters.kind_for_wave())
		check(kinds.has(5) if wave>=3 else not kinds.has(5),"Humans arrive after dogs")
	var human = game.monsters.spawn_enemy(5)
	check(human.model.has_meta("club_arm"),"Human has animated club rig")
	human.node.position = game.player.position+Vector3(0,0,-0.9)
	human.attack = 0.6
	game.monsters.fire_left = 999
	game.monsters.knife_left = 999
	game.monsters.pepper_left = 999
	game.monsters.pan_tick = 999
	game.monsters.update(.1)
	check(human.model.get_meta("club_arm").rotation.x< -1,"Human telegraphs club swing")
	var hp = game.health
	game.hurt_left = 0
	game.monsters.update(.51)
	check(game.health<hp,"Club hits within range")
	game.power_time = 0
	game.animate_action("order")
	check(game.mouse_model.get_meta("rig").pad.visible,"Order animation displays notepad")
	game.animate_action("dirty")
	check(game.mouse_model.get_meta("rig").sponge.visible,"Cleaning animation displays sponge")
	game.reset_animal_pose(game.mouse_model)
	check(not game.mouse_model.get_meta("rig").sponge.visible,"Action prop resets")
	game.monsters.spawn_left = 0
	var before = game.monsters.id_counter
	game.monsters.update(.01)
	check(game.monsters.id_counter-before == 1 and game.monsters.pending_spawns>0,"Wave creation spread over frames")
	print("LOADOUT TEST: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
