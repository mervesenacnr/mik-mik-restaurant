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
	game.rng.seed = 2468
	for wave in range(3,7):
		game.wave = wave
		var cats = 0
		var dogs = 0
		var humans = 0
		for i in range(10000):
			var kind = game.monsters.kind_for_wave()
			if kind in [0,2]: cats += 1
			if kind in [1,3]: dogs += 1
			if kind == 5: humans += 1
		check(humans>=800 and humans<=1300 and humans<cats and humans<dogs,"Humans are roughly ten percent, rarer than cats and dogs")
		for damage in [14.0,26.0,30.0,10000.0]:
			var human = game.monsters.spawn_enemy(5)
			var before = game.monsters.kills
			var hits = 0
			while human.hp>0 and hits<10:
				game.monsters.hurt(human,damage)
				hits += 1
			check(hits == (5 if damage == 14 else 3),"Soda needs five hits; knives, pans and huge hits need three")
			check(game.monsters.kills == before+1,"Human kill rewarded exactly once")
			game.monsters.hurt(human,damage)
			check(game.monsters.kills == before+1,"Repeated damage never awards a second kill")
		await process_frame
	var dog = game.monsters.spawn_enemy(1)
	game.monsters.hurt(dog,10000)
	check(dog.hp<=0,"Animal damage is not capped")
	game.run_difficulty = game.profile.DIFFICULTIES[2].duplicate()
	var hard = game.monsters.spawn_enemy(5)
	check(is_equal_approx(hard.max_hp,69*1.8),"Hard-mode health scaling is preserved")
	print("HUMAN BALANCE TEST: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
