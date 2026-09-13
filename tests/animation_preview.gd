extends SceneTree
var game
func _initialize(): call_deferred("run")
func shot(name):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/anim-"+name+".png")
func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.start_run()
	game.player.position = game.tables[0].pos+Vector3(0,0,2)
	game.update_camera(4)
	# Close-up for checking hands, food, coins and reactions; shipping zoom stays unchanged.
	game.camera.size = 7.0
	for i in range(2):
		game.spawn_guest()
		var guest = game.guests[-1]
		game.assign_table(guest)
		guest.state = "seated"
		guest.path.clear()
		guest.node.position = game.seat_position(game.tables[guest.table])+Vector3(0,.28,0)
		guest.model.rotation.y = -PI/2
		game.tables[guest.table].state = "order"
	var g = game.guests[0]
	var table = game.tables[0]
	g.patience = 9
	g.wait_age = 7.8
	game.animate_waiting(g,.1)
	await shot("bekleme")
	game.auto_service(.8)
	game.update_orders(5)
	game.carried.append(0)
	game.auto_service(.01)
	for i in range(6):
		game.update_tables(.025)
		game.gesture_left -= .025
		game.animate_action("ready")
	await shot("servis")
	for i in range(15): game.update_tables(.025)
	await shot("yeme")
	game.complete_meal(0)
	game.update_tables(.01)
	game.action_fx.advance(.5)
	game.update_guests(.25)
	await shot("para-birakma")
	game.action_fx.advance(.65)
	game.animate_action("collect")
	await shot("para-toplama")
	game.monsters.spawn_left = 999
	game.monsters.fire_left = 999
	for i in range(3):
		var e = game.monsters.spawn_enemy([0,1,5][i])
		e.node.position = game.player.position+Vector3(-1.4+i*1.4,0,2)
		game.monsters.hurt(e,1)
	game.monsters.update(.05)
	game.swing_chef("knife")
	game.action_pose = ""
	game.gesture_left = 0
	game.animate_strike(.12)
	await shot("vurma")
	for e in game.monsters.enemies.duplicate():
		for i in range(3): game.monsters.hurt(e,10000)
	game.action_fx.advance(.3)
	await shot("yenilme")
	print("ANIMATION PREVIEW: seven scenes rendered")
	quit()
