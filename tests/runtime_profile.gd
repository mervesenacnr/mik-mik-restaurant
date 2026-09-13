extends SceneTree
var game
func _initialize(): call_deferred("run")
func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.start_run()
	game.player.position = Vector3(-13,0,7)
	game.update_camera(3)
	game.wave = 5
	for id in ["knife","pan","pepper"]: game.apply_perk(id)
	for i in range(32): game.monsters.spawn_enemy(i%5)
	game.monsters.spawn_left = 0.1
	var frames: Array = []
	var simulation: Array = []
	var spawns: Array = []
	var prev = Time.get_ticks_usec()
	for frame in range(720):
		var now = Time.get_ticks_usec()
		var dt = minf((now-prev)/1000000.0,0.05)
		prev = now
		game.hurt_left = 1
		game.health = 100
		game.rep = 100
		var count = game.monsters.id_counter
		game._process(maxf(dt,1.0/60))
		if game.choosing: game.choose_perk(0)
		var cpu = (Time.get_ticks_usec()-now)/1000.0
		if game.monsters.id_counter>count: spawns.append(cpu)
		await process_frame
		if frame>60 and (Time.get_ticks_usec()-now)>50000:
			print("SLOW FRAME %d wall=%.2f ms cpu=%.2f ms spawn=%s guests=%d" % [frame,(Time.get_ticks_usec()-now)/1000.0,cpu,game.monsters.id_counter>count,game.guests.size()])
		if frame>60:
			frames.append((Time.get_ticks_usec()-now)/1000.0)
			simulation.append(cpu)
	frames.sort()
	simulation.sort()
	spawns.sort()
	print("RUNTIME PROFILE frames=%d p50=%.2f p95=%.2f p99=%.2f max=%.2f ms; simulation p95=%.2f max=%.2f ms; spawn max=%.2f ms; draws=%d; mobs=%d" % [frames.size(),frames[int(frames.size()*0.5)],frames[int(frames.size()*0.95)],frames[int(frames.size()*0.99)],frames[-1],simulation[int(simulation.size()*0.95)],simulation[-1],spawns[-1] if not spawns.is_empty() else 0,Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),game.monsters.enemies.size()])
	quit()
