extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.start_run()
	game.player.position = Vector3(-13,0,7)
	game.update_camera(3)
	game.monsters.spawn_left = 999
	game.monsters.fire_left = 999
	for i in range(80):
		var e = game.monsters.spawn_enemy(i%5)
		var a = i*TAU/80
		var p = game.player.position+Vector3(cos(a),0,sin(a))*(6+i%7)
		if game.is_walkable(p,0.4): e.node.position = p
	for i in range(10): await process_frame
	var start = Time.get_ticks_msec()
	var simulation_us = 0
	for frame in range(120):
		var now = Time.get_ticks_usec()
		game.hurt_left = 1
		game.monsters.update(1.0/60)
		simulation_us += Time.get_ticks_usec()-now
		await process_frame
	print("BENCH 80 animals: %.1f rendered fps, %.2f ms simulation/frame" % [120000.0/(Time.get_ticks_msec()-start),simulation_us/120000.0])
	quit()
