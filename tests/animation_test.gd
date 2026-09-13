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
	game.spawn_guest()
	var g = game.guests[0]
	game.assign_table(g)
	var t = game.tables[g.table]
	g.state = "seated"
	g.path.clear()
	g.node.position = game.seat_position(t)+Vector3(0,.28,0)
	t.state = "order"
	var rig = g.model.get_meta("rig")
	g.patience = 10
	g.wait_age = 0
	game.animate_waiting(g,.15)
	check(rig.arms[1].rotation.x>1 and rig.feet.any(func(f): return f.position.y>.13),"Bored guest taps feet and raises hand")
	g.wait_age = 7.8
	game.animate_waiting(g,.1)
	check(rig.mouth.visible and rig.mouth.scale.y>.1,"Long-waiting guest yawns")
	game.player.position = t.pos+Vector3(0,0,1.8)
	game.auto_service(.8)
	game.update_orders(5)
	game.player.position = Vector3(0,0,-4)
	game.auto_service(.1)
	game.player.position = t.pos+Vector3(0,0,1.8)
	game.auto_service(.1)
	check(t.food.flying and game.gesture_kind == "ready","Serving starts food flight and chef gesture")
	game.update_tables(.2)
	check(not rig.spoon.visible,"Guest waits for flying plate to arrive")
	game.update_tables(.24)
	check(not t.food.flying and rig.spoon.visible,"Guest starts eating after landing")
	check(game.action_fx.effects.any(func(f): return f.kind == "impact"),"Plate landing creates a small impact effect")
	game.update_tables(.2)
	check(rig.arms[1].rotation.x>.5,"Eating has utensil arm motion")
	game.update_tables(5)
	var gold = game.money
	var tips = game.profile.wallet
	check(g.pay_left>0 and game.action_fx.effects.any(func(f): return f.kind == "tip"),"Guest leaves animated coins")
	var at = g.node.position
	game.update_guests(.2)
	check(g.node.position == at and rig.arms[1].rotation.x>.5,"Customer reaches to pay before walking out")
	game.action_fx.advance(.5)
	var coins = game.action_fx.effects.filter(func(f): return f.kind == "tip")[0]
	check(coins.node.position.distance_to(coins.table)<.1,"Coins rest on table before collection")
	game.action_fx.advance(.4)
	check(coins.pickup and game.gesture_kind == "collect","Coin collection triggers chef gesture")
	game.paused = true
	var age = coins.age
	game._process(1)
	check(coins.age == age,"Pause freezes coins")
	game.paused = false
	game.choosing = true
	game._process(1)
	check(coins.age == age,"Upgrade selection freezes coins")
	game.choosing = false
	game.action_fx.advance(1)
	check(game.money == gold and game.profile.wallet == tips,"Visual collection never duplicates income")
	check(not game.action_fx.effects.any(func(f): return f.kind == "tip"),"Collected coins are cleaned up")
	game.update_guests(.5)
	check(g.pay_left == 0 and not rig.mouth.visible,"Payment pose resets before departure")
	game.monsters.spawn_left = 999
	game.monsters.fire_left = 999
	for kind in [0,1,5]:
		var e = game.monsters.spawn_enemy(kind)
		e.node.position = game.player.position+Vector3(4,0,0)
		game.monsters.hurt(e,1)
		game.monsters.update(.05)
		check(absf(e.model.rotation.z)>.01,"Every enemy type flinches on hit")
		var kills = game.monsters.kills
		for i in range(3): game.monsters.hurt(e,10000)
		check(not game.monsters.enemies.has(e) and game.action_fx.deaths.any(func(f): return f.node == e.node),"Defeated enemy leaves combat and enters death animation")
		check(game.monsters.kills == kills+1,"Death rewards once")
		game.action_fx.advance(.3)
		check(absf(e.model.rotation.z)>.5 and e.model.scale.x<1,"Enemy topples and shrinks")
		game.action_fx.advance(.5)
		check(not game.action_fx.deaths.any(func(f): return f.node == e.node),"Death animation cleans up")
		await process_frame
	game.action_pose = ""
	game.gesture_left = 0
	game.swing_chef("knife")
	game.animate_strike(.12)
	check(game.mouse_model.get_meta("rig").knife.visible,"Chef displays held knife during throwing animation")
	game.animate_strike(.2)
	check(not game.mouse_model.get_meta("rig").knife.visible,"Throwing prop resets after attack")
	game.action_fx.tip(Vector3.ZERO,Vector3.UP,1)
	for i in range(100): game.action_fx.impact(Vector3.ZERO,game.GOLD)
	check(game.action_fx.effects.size()<=game.action_fx.MAX_EFFECTS,"Impact effects are bounded")
	check(game.action_fx.effects.any(func(f): return f.kind == "tip"),"Crowded combat preserves coin animations")
	game.action_fx.advance(2)
	check(game.action_fx.effects.is_empty() and game.action_fx.impact_pool.size()<=16,"Finished effects recycle within pool limit")
	print("ANIMATION TEST: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
