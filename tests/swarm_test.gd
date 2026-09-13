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
	await process_frame
	check(game.MAP_MAX.x-game.MAP_MIN.x == 64 and game.MAP_MAX.z-game.MAP_MIN.z == 52,"Map is 64 by 52")
	check(game.tables.size() == 10,"Expanded map contains ten tables")
	var min_gap = 999.0
	for i in range(game.tables.size()):
		for j in range(i+1,game.tables.size()): min_gap = minf(min_gap,game.tables[i].pos.distance_to(game.tables[j].pos))
	check(min_gap>=8,"Tables have broad, usable gaps")
	for t in game.tables:
		check(not game.path_between(Vector3(0,0,7.7),game.seat_position(t)).is_empty(),"Every table is reachable from the entrance")
	check(game.is_walkable(Vector3(24,0,10)),"Outer garden is playable outside old bounds")
	var zoom = game.camera.size
	var rotation = game.camera.rotation
	game.player.position = Vector3(20,0,16)
	for i in range(60): game.update_camera(1.0/60)
	check(game.camera.position.x>19,"Camera follows horizontal travel")
	check(absf(game.camera_focus.z-16)<0.2,"Camera follows vertical travel")
	check(game.camera.size == zoom and game.camera.rotation == rotation,"Camera never zooms or changes angle")
	var camera_at = game.camera.position
	game.paused = true
	game.player.position.x -= 6
	game.update_camera(1)
	check(game.camera.position == camera_at,"Paused camera stays still")
	game.paused = false
	game.player.position = Vector3.ZERO
	game.update_camera(2)
	var sectors: Dictionary = {}
	var hidden = true
	var safe = true
	for i in range(40):
		var p = game.monsters.spawn_point()
		var angle = wrapf(atan2(p.z,p.x),0,TAU)
		sectors[int(angle/(TAU/8))] = true
		hidden = hidden and not Rect2(Vector2.ZERO,root.get_visible_rect().size).has_point(game.camera.unproject_position(p+Vector3.UP))
		safe = safe and game.is_walkable(p,0.65) and p.distance_to(game.player.position)>18
	check(sectors.size()>=7,"Packs spawn around the chef in at least seven directions")
	check(hidden,"Enemies spawn outside the visible camera area")
	check(safe,"Spawn points are distant and navigable")
	game.player.position = Vector3(30,0,26)
	game.update_camera(2)
	for i in range(10): check(game.is_walkable(game.monsters.spawn_point(),0.65),"Border spawns remain in the playable map")
	for wave in range(1,7):
		game.wave = wave
		var species: Dictionary = {}
		for i in range(80): species[game.monsters.kind_for_wave()] = true
		check(species.size()>=mini(wave,3),"Later waves add animal species")
		if wave == 1: check(species.has(0) and species.size() == 1,"Opening swarm is cats only")
		if wave>=4: check(species.has(3),"Armoured bulldogs join later waves")
	game.wave = 1
	game.player.position = Vector3(-13,0,5)
	game.update_camera(2)
	var kitchen_before = game.xp
	game.add_combat_xp(8)
	check(game.xp == kitchen_before and game.combat_level == 2,"Combat XP never fills kitchen XP")
	game.show_upgrades(false,"combat")
	check(game.offers.size() == 3 and game.offers.all(func(p): return p[1] == "SAVAŞ"),"Combat level only offers combat upgrades")
	check(game.offers.all(func(p): return p[0] in ["knife","pan","pepper"]),"First combat level guarantees weapon choices")
	game.choose_perk(0)
	var combat_before = game.combat_xp
	game.add_xp(4)
	check(game.combat_xp == combat_before and game.level == 2,"Kitchen XP never fills combat XP")
	check(game.progression_queue == ["combat","kitchen"],"Simultaneous levels preserve source order")
	game.show_upgrades(false,"kitchen")
	check(game.offers.all(func(p): return p[1] != "SAVAŞ"),"Kitchen level never offers weapons")
	game.choose_perk(0)
	game.progression_queue.clear()
	if not game.perks.has("knife"): game.apply_perk("knife")
	var enemy = game.monsters.spawn_enemy(1)
	enemy.node.position = game.player.position+Vector3(3,0,0)
	enemy.hp = 1000
	game.monsters.fire_left = 999
	game.monsters.knife_left = 999
	game.monsters.fire_knives(enemy)
	game.monsters.update_weapons(0.2)
	check(enemy.hp<1000,"Knives hit via swept collision without tunnelling")
	game.apply_perk("pan")
	var before_pan = enemy.hp
	game.monsters.age = 0
	game.monsters.pan_tick = 0
	game.monsters.update_weapons(0.01)
	check(enemy.hp<before_pan and game.monsters.pans.size() == 1,"Orbiting frying pan deals contact damage")
	game.apply_perk("pepper")
	enemy.node.position = game.player.position+Vector3(1.5,0,0)
	game.monsters.make_cloud()
	var before_cloud = enemy.hp
	game.monsters.update_weapons(0.1)
	check(enemy.hp<before_cloud and enemy.slow>0,"Pepper cloud damages and slows")
	var food_xp = game.xp
	var cash = game.money
	var war_xp = game.combat_xp
	game.monsters.hurt(enemy,9999)
	check(game.xp == food_xp and game.money == cash and game.combat_xp != war_xp,"Monster reward goes only to combat progression")
	# Off-screen cards carry the real order state and urgency, then disappear when visible.
	game.spawn_guest()
	var guest = game.guests[-1]
	game.assign_table(guest)
	var table = game.tables[guest.table]
	guest.state = "seated"
	table.state = "order"
	guest.patience = 9.0
	game.player.position = Vector3(25,0,20)
	game.update_camera(3)
	game.indicators.refresh()
	var cards = game.indicators.entries.filter(func(e): return e.title.begins_with("M01"))
	check(cards.size() == 1 and cards[0].seconds == 9 and cards[0].ratio<0.25,"Distant orders show live patience and urgency")
	check(game.indicators.entries.any(func(e): return e.title == "MUTFAK"),"Off-screen kitchen gets a directional card")
	var overlap = false
	for i in range(game.indicators.placed.size()):
		for j in range(i+1,game.indicators.placed.size()):
			if Rect2(game.indicators.placed[i].at,game.indicators.CARD).intersects(Rect2(game.indicators.placed[j].at,game.indicators.CARD)): overlap = true
	check(not overlap,"Edge cards do not overlap")
	game.player.position = table.pos
	game.update_camera(3)
	game.indicators.refresh()
	check(not game.indicators.entries.any(func(e): return e.title.begins_with("M01")),"Visible order no longer has a redundant edge card")
	# A sustained combat simulation catches deleted-target references and unbounded spawns.
	game.player.position = Vector3(0,0,12)
	game.wave = 5
	game.monsters.spawn_left = 0
	var peak = 0
	for i in range(900):
		game.hurt_left = 1
		game.monsters.update(1.0/30)
		peak = maxi(peak,game.monsters.enemies.size())
		if i%60 == 0: await process_frame
	check(peak>=24 and peak<=96,"Sustained waves form a bounded crowd, not isolated enemies")
	check(game.monsters.enemies.all(func(e): return game.is_walkable(e.node.position,0.28)),"Swarm movement respects furniture and map bounds")
	print("SWARM TEST: %d checks, %d failures; peak %d animals" % [checks,failures,peak])
	quit(1 if failures else 0)
