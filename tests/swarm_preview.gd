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
	game.player.position = Vector3(-13,0,6)
	game.update_camera(3)
	game.wave = 4
	for i in range(10):
		game.spawn_guest()
		var guest = game.guests[-1]
		guest.dish = i%4
		game.assign_table(guest)
		var t = game.tables[guest.table]
		guest.path.clear()
		guest.state = "seated"
		guest.node.position = game.seat_position(t)+Vector3(0,0.28,0)
		guest.model.rotation.y = -PI/2 if t.pos.x<0 else PI/2
		guest.patience = 12+i*5
		t.state = "order"
		if i%3 == 0:
			t.state = "eating"
			t.progress = 8
			t.eat_duration = 8
			t.food.visible = true
		elif i%3 == 1:
			game.create_order(i)
			game.orders[-1].remaining = 0
			t.state = "ready"
	for id in ["knife","pan","pan","pepper"]: game.apply_perk(id)
	for i in range(36):
		var e = game.monsters.spawn_enemy(i%6)
		var angle = i*TAU/36
		var p = game.player.position+Vector3(cos(angle),0,sin(angle))*(7.5+(i%3)*2.0)
		if game.is_walkable(p,0.4): e.node.position = p
	game.toast("Geniş bahçe · çevreleyen sürüler · iki ayrı deneyim")
	DirAccess.make_dir_recursive_absolute("res://captures/swarm")
	var start = Time.get_ticks_msec()
	for frame in range(150):
		var dt = 1.0/30
		if frame>40:
			game.player.position.z += 0.055
			game.mouse_model.rotation.y = PI
		game._process(dt)
		if game.choosing: game.choose_perk(0)
		await process_frame
		await RenderingServer.frame_post_draw
		if frame%3 == 0: root.get_texture().get_image().save_png("res://captures/swarm/frame_%03d.png" % (frame/3))
		if frame == 30: root.get_texture().get_image().save_png("res://captures/swarm-garden.png")
		if frame == 130: root.get_texture().get_image().save_png("res://captures/swarm-follow.png")
	print("Rendered 150 frames in %d ms, %d animals remain" % [Time.get_ticks_msec()-start,game.monsters.enemies.size()])
	game.progression_queue.clear()
	game.show_upgrades(false,"combat")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/combat-upgrades.png")
	quit()
