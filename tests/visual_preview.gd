extends SceneTree
var game

func _initialize():
	call_deferred("run")

func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.start_run()
	game.player.position = Vector3(-2.7,0,-0.3)
	game.mouse_model.rotation.y = -2.7
	for i in range(4):
		game.spawn_guest()
		var g = game.guests[-1]
		g.dish = i
		game.assign_table(g)
		var t = game.tables[g.table]
		g.path.clear()
		g.state = "seated"
		g.node.position = game.seat_position(t)+Vector3(0,0.28,0)
		g.model.rotation.y = -PI/2 if t.pos.x<0 else PI/2
		t.state = "eating"
		t.progress = 6.5
		t.eat_duration = 6.5
		t.food.visible = true
		t.food.serve_from(t.root.to_local(game.player.position+Vector3(0.5,1.3,0)))
	var enemy = game.monsters.spawn_enemy(1)
	enemy.node.position = Vector3(6,0,6.5)
	var ghost = game.monsters.spawn_enemy(2)
	ghost.node.position = Vector3(8.2,0,1)
	game.apply_perk("speed")
	game.toast("Yeni yemekler, yeme animasyonları ve otomatik canavar savunması")
	DirAccess.make_dir_recursive_absolute("res://captures/animation")
	for frame in range(135):
		var dt = 1.0/30.0
		game._process(dt)
		if frame == 60: game.apply_perk("pressure")
		await process_frame
		await RenderingServer.frame_post_draw
		if frame%3 == 0:
			root.get_texture().get_image().save_png("res://captures/animation/frame_%03d.png" % (frame/3))
		if frame == 15: root.get_texture().get_image().save_png("res://captures/new-features.png")
	game.hud.visible = false
	game.camera.size = 9
	game.camera.position = Vector3(-7,12,9)
	game.camera.look_at(Vector3(-6,0,0))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/food-detail.png")
	quit()
