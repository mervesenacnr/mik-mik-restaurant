extends SceneTree
var failures = 0
var checks = 0
var game

func check(value, message):
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize():
	call_deferred("run")

func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.start_run()
	for kind in range(4):
		var food = game.FoodVisual.new()
		game.world.add_child(food)
		food.setup(kind)
		food.advance(0.1,1)
		check(food.portions.all(func(p): return p.visible),"Every dish starts with all portions")
		food.advance(0.4,0.4)
		check(food.portions.filter(func(p): return p.visible).size()<food.portions.size(),"Bites remove edible portions")
		check(food.crumbs.visible,"Eating leaves crumbs")
		food.advance(0.1,0,false)
		check(food.portions.all(func(p): return not p.visible),"Finished plate has no remaining food")
		check(food.steam.all(func(p): return not p.visible),"Empty plate must not steam")
		food.queue_free()
	game.spawn_guest()
	var guest = game.guests[0]
	guest.dish = 1
	game.assign_table(guest)
	for frame in range(200): game.update_guests(0.1)
	check(guest.state == "seated","Customer navigates to a real side chair")
	var t = game.tables[guest.table]
	game.player.position = t.pos+Vector3(0,0,1.8)
	game.auto_service(0.8)
	game.update_orders(5)
	check(game.orders[0].visual.kind == 1 and game.orders[0].visual.visible,"Kitchen displays the ordered pizza")
	game.player.position = Vector3(0,0,-4)
	game.auto_service(0.1)
	check(game.mouse_model.get_node("Tray").get_child(0).kind == 1,"Tray preserves the ordered dish")
	game.player.position = t.pos+Vector3(0,0,1.8)
	game.auto_service(0.1)
	check(t.food.flying,"Delivery animates from the chef to the table")
	game.update_tables(0.5)
	check(not t.food.flying and t.food.position.is_equal_approx(Vector3(0,1.32,0.15)),"Dish lands exactly on the table")
	var rig = guest.model.get_meta("rig")
	check(rig.spoon.visible and absf(rig.arms[1].rotation.x)>0.5,"Eating moves the arm and utensil")
	check(rig.morsel.global_position.distance_to(rig.jaw.global_position)<0.45,"Utensil must reach the mouth, not swing behind the head")
	game.update_tables(1.8)
	check(t.food.portions.filter(func(p): return p.visible).size()<6,"Table pizza loses slices during eating")
	game.update_tables(2)
	check(t.state == "dirty" and not rig.spoon.visible,"Finishing restores the guest pose and leaves dirty plate")
	game.apply_perk("speed")
	check(game.power_effects.size() == 1,"Choosing a power spawns a character celebration")
	game.animate_power(0.3)
	check(game.mouse_model.scale.y>1 and game.mouse_model.position.y>0,"Power gain animates the chef")
	game.paused = true
	var age = game.power_effects[0].age
	var monster_age = game.monsters.age
	game._process(1)
	check(game.power_effects[0].age == age and game.monsters.age == monster_age,"Pause freezes VFX and monsters")
	game.paused = false
	game.choosing = true
	game._process(1)
	check(game.power_effects[0].age == age,"Upgrade cards freeze celebration until resumed")
	game.choosing = false
	game.animate_power(1.3)
	check(game.power_effects.is_empty() and game.mouse_model.scale == Vector3.ONE,"Celebration cleans up and resets character")
	var enemy = game.monsters.spawn_enemy(0)
	enemy.node.position = game.player.position+Vector3(2,0,0)
	enemy.hp = 100
	var before = enemy.hp
	game.monsters.fire_at(enemy)
	game.monsters.update(0.2)
	check(enemy.hp<before,"Automatic soda projectile damages monsters")
	game.dash_time = 0.1
	game.damage_chef(10)
	check(game.health == 100,"Dash protects against monster damage")
	game.dash_time = 0
	game.damage_chef(10)
	game.damage_chef(10)
	check(game.health == 90,"Brief immunity prevents repeated damage stacking")
	game.hurt_left = 0
	var old_xp = game.xp
	var old_combat_xp = game.combat_xp
	game.monsters.hurt(enemy,999)
	check(game.monsters.kills == 1 and game.xp == old_xp and game.combat_xp != old_combat_xp,"Defeating a monster grants XP exactly once")
	var boss = game.monsters.spawn_enemy(2,true)
	check(game.monsters.boss_spawned and boss.max_hp>300,"Alpha boss has stronger health")
	game.monsters.hurt(boss,999)
	check(game.monsters.boss_defeated,"Defeating the boss records completion")
	game.pending_levels = 0
	game.progression_queue.clear()
	game.wave = 6
	game.wave_time = 0
	game.tick_game(0.01)
	check(game.ended,"Final wave ends after the boss is defeated")
	print("FEATURE TEST: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
