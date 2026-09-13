extends Node3D
## Surrounding animal packs and automatic kitchen-themed weapons.
var game
var enemies: Array = []
var shots: Array = []
var clouds: Array = []
var pans: Array = []
var spawn_left = 8.0
var fire_left = 0.0
var knife_left = 0.0
var pepper_left = 0.0
var pan_tick = 0.0
var damage = 14.0
var haste = 1.0
var power = 1.0
var attack_range = 9.0
var kills = 0
var boss_spawned = false
var boss_defeated = false
var age = 0.0
var id_counter = 0
var spawn_sector = 0
var cells: Dictionary = {}
var pending_spawns = 0
var baked_meshes: Dictionary = {}
const NAMES = ["Sokak kedisi","Sokak köpeği","Kara kedi","Zırhlı buldog","Kızıl tilki","Sopalı insan"]

func setup(g):
	game = g
	return self

func wave_description():
	return ["Kedi sürüsü","Kedi + köpek","Kara kediler","Buldog akını","Tilki kuşatması","Alfa sürüsü"][mini(game.wave-1,5)]

func weapon_summary():
	var names = ["Soda"]
	for pair in [["knife","Bıçak"],["pan","Tava"],["pepper","Biber"]]:
		if game.perks.has(pair[0]): names.append("%s %d" % [pair[1],game.perks[pair[0]]])
	return " · ".join(names)

func kind_for_wave():
	var pools = [[0],[0,1,1],[0,0,2,2,1,1,1,1,5],[0,2,2,2,1,1,3,3,5],[2,2,2,1,3,3,3,4,4,5],[2,2,2,1,3,3,3,4,4,5]]
	var pool = pools[mini(game.wave-1,5)]
	return pool[game.rng.randi_range(0,pool.size()-1)]

func spawn_point():
	# Rotate through eight sectors, including behind the chef, not two doors.
	var base = spawn_sector*TAU/8
	spawn_sector = (spawn_sector+1)%8
	for attempt in range(32):
		var angle = base+game.rng.randf_range(-0.18,0.18)+(attempt/4)*PI/4
		var radius = game.rng.randf_range(22.0,25.0)
		var p = game.player.position+Vector3(cos(angle)*radius,0,sin(angle)*radius)
		if not game.is_walkable(p,0.65): continue
		var screen = game.camera.unproject_position(p+Vector3(0,1,0))
		if Rect2(Vector2.ZERO,game.get_viewport().get_visible_rect().size).has_point(screen): continue
		return p
	# At a corner, use the farthest reachable border point rather than spawning on top of the player.
	var result = Vector3(29,0,25)
	var farthest = -1.0
	for p in [Vector3(-29,0,-21),Vector3(29,0,-21),Vector3(-29,0,25),Vector3(29,0,25)]:
		var d = p.distance_to(game.player.position)
		if d>farthest:
			farthest = d
			result = p
	return result

func make_animal(parent, kind, boss):
	if kind == 5: return make_human(parent)
	var model = Node3D.new()
	parent.add_child(model)
	var color = [Color("be9165"),Color("a77a59"),Color("54556c"),Color("92959b"),Color("c87a49")][kind]
	var dog = kind in [1,3] or boss
	var body = game.sphere(model,Vector3(0,0.64,0.1),Vector3(0.9,0.8,1.2),color)
	game.sphere(model,Vector3(0,0.96,-0.47),Vector3(0.75,0.72,0.73),color)
	for x in [-0.28,0.28]:
		if dog:
			var ear = game.sphere(model,Vector3(x*1.4,1.01,-0.4),Vector3(0.27,0.59,0.23),color.darkened(0.2))
			ear.rotation.z = x
		else:
			var ear = MeshInstance3D.new()
			var shape = PrismMesh.new()
			shape.size = Vector3(0.31,0.47,0.22)
			ear.mesh = shape
			ear.material_override = game.mat(color)
			model.add_child(ear)
			ear.position = Vector3(x,1.37,-0.44)
			game.sphere(model,Vector3(x,1.36,-0.57),Vector3(0.12,0.22,0.02),game.CORAL)
		game.sphere(model,Vector3(x*0.63,1.01,-0.8),Vector3(0.13,0.15,0.075),game.GOLD if kind == 2 else game.INK)
	for x in [-1,1]:
		game.sphere(model,Vector3(x*.175,1.015,-.841),Vector3(.048,.065,.025),game.INK)
		game.sphere(model,Vector3(x*.175-.025,1.048,-.86),Vector3.ONE*.027,game.CREAM)
		var brow = game.box(model,Vector3(x*.19,1.13,-.74),Vector3(.19,.045,.07),color.darkened(.3))
		brow.rotation.z = -x*.2
		if dog:
			game.sphere(model,Vector3(x*.22,.73,-.93),Vector3(.11,.12,.1),game.CREAM)
		else:
			for j in range(3):
				var stripe = game.box(model,Vector3(x*(.1+j*.1),1.2-j*.025,-.65),Vector3(.04,.12,.04),color.darkened(.24))
				stripe.rotation.z = -x*.3
	game.sphere(model,Vector3(0,0.8,-0.8),Vector3(0.47,0.29,0.42 if dog else 0.22),color.lightened(0.22))
	game.sphere(model,Vector3(0,0.88,-1.0 if dog else -0.92),Vector3(0.18,0.14,0.1),game.INK)
	if not dog:
		for x in [-1,1]:
			var whisker = game.box(model,Vector3(x*0.28,0.85,-0.9),Vector3(0.28,0.022,0.025),game.CREAM)
			whisker.rotation.z = x*0.15
	if dog:
		var collar = game.ring(model,.43,game.CORAL.darkened(.2))
		collar.position = Vector3(0,.82,-.32)
		collar.rotation.x = PI/2
		game.sphere(model,Vector3(0,.42,-.35),Vector3(.15,.2,.04),game.GOLD)
	var legs: Array = []
	for x in [-0.29,0.29]:
		for z in [-0.29,0.46]:
			legs.append(game.sphere(model,Vector3(x,0.24,z),Vector3(0.25,0.5,0.28),color.darkened(0.07)))
	for i in range(5):
		game.sphere(model,Vector3(sin(i*0.35)*0.25,0.6+i*0.07,0.64+i*0.14),Vector3(0.2,0.2,0.28),color)
	if kind == 3 or boss:
		game.box(model,Vector3(0,0.94,0.15),Vector3(1.0,0.22,0.95),game.TEAL)
		for x in [-0.35,0,0.35]: game.sphere(model,Vector3(x,1.1,0.15),Vector3.ONE*0.16,game.GOLD)
	if boss:
		game.cylinder(model,Vector3(0,1.47,-0.4),0.3,0.26,game.GOLD)
	for part in model.get_children():
		if part is GeometryInstance3D and part != body:
			part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	model.set_meta("legs",legs)
	bake_static_parts(model,legs+[body],str(kind)+str(boss))
	return {"model":model,"body":body,"color":color}

func spawn_enemy(kind = -1, boss = false):
	if enemies.size()>=96 and not boss: return null
	if kind<0: kind = kind_for_wave()
	if boss: kind = 3
	var node = Node3D.new()
	add_child(node)
	node.position = spawn_point()
	var art = make_animal(node,kind,boss)
	var danger = game.ring(node,1.35,game.RED)
	danger.visible = false
	var health = game.box(node,Vector3(0,3.1 if boss else 1.85,0),Vector3(1.0,0.09,0.07),game.RED)
	health.visible = boss
	var hp = 600.0 if boss else (18.0+game.wave*3.5)*[1.0,1.3,0.8,2.8,1.1,1.8][kind]
	if kind == 5: hp = 60.0+clampi(game.wave-3,0,3)*3.0
	hp *= game.run_difficulty[1]
	var e = {"id":id_counter,"node":node,"model":art.model,"body":art.body,"color":art.color,"kind":kind,"boss":boss,"hp":hp,"max_hp":hp,"path":[],"repath":0.0,"hit":0.0,"attack":0.0,"recover":0.3,"danger":danger,"health":health,"slow":0.0}
	id_counter += 1
	enemies.append(e)
	if boss:
		boss_spawned = true
		game.sign3d(node,"KAZAN KIRAN",Vector3(0,3.65,0),34,game.CORAL)
		game.toast("KAZAN KIRAN! Alfa buldog sürünün başında geldi.")
	elif id_counter == 1: game.toast("Kediler dört bir yandan geliyor. Silahların otomatik!")
	return e

func update(delta):
	age += delta
	spawn_left -= delta
	fire_left -= delta
	knife_left -= delta
	pepper_left -= delta
	pan_tick -= delta
	if game.wave == 6 and not boss_spawned and game.wave_time<game.wave_duration-8: spawn_enemy(3,true)
	if spawn_left<=0 and game.wave_time>4:
		pending_spawns += 3+game.wave+game.run_difficulty[4]
		spawn_left = maxf(1.8,3.8-game.wave*0.28)
	if pending_spawns>0:
		spawn_enemy()
		pending_spawns -= 1
	cells.clear()
	for e in enemies:
		var key = Vector2i(floori(e.node.position.x/1.4),floori(e.node.position.z/1.4))
		if not cells.has(key): cells[key] = []
		cells[key].append(e)
	for e in enemies.duplicate():
		if e.hp<=0: continue
		e.hit = maxf(0,e.hit-delta)
		e.slow = maxf(0,e.slow-delta)
		e.recover = maxf(0,e.recover-delta)
		e.body.material_override.albedo_color = game.CREAM if e.hit>0 else e.color
		e.health.scale.x = maxf(0.01,e.hp/e.max_hp)
		e.health.visible = e.boss or e.hp<e.max_hp
		var distance = e.node.position.distance_to(game.player.position)
		if e.attack>0:
			e.attack = maxf(0,e.attack-delta)
			e.danger.visible = true
			e.danger.scale = Vector3.ONE*(0.6+(1-e.attack/0.6)*0.65)*(1.5 if e.boss else 1.0)
			if e.attack<=0:
				if distance<(2.2 if e.boss else 1.3): game.damage_chef((22 if e.boss else 7)*game.run_difficulty[2])
				e.recover = 1.1
				e.danger.visible = false
		elif distance<(1.9 if e.boss else 1.05) and e.recover<=0: e.attack = 0.6
		else: move_enemy(e,delta)
		var scale_factor = 2.0 if e.boss else (1.15 if e.kind == 3 else 0.82)
		e.model.scale = Vector3.ONE*scale_factor
		e.model.position.y = absf(sin(age*8+e.id))*0.055
		if e.kind == 5:
			var arm = e.model.get_meta("club_arm")
			arm.rotation.x = -2.5*(e.attack/0.6) if e.attack>0 else sin(age*10+e.id)*0.35
		var legs = e.model.get_meta("legs")
		for i in range(legs.size()): legs[i].rotation.x = sin(age*10+e.id+(i%2)*PI)*0.33
	update_weapons(delta)

func move_enemy(e, delta):
	var target = game.player.position
	var direction = (target-e.node.position).normalized()
	# Foxes approach a flank instead of following the exact same line.
	if e.kind == 4 and e.node.position.distance_to(target)>5:
		target += Vector3(-direction.z,0,direction.x)*3.0*(1 if e.id%2 == 0 else -1)
		direction = (target-e.node.position).normalized()
	e.repath -= delta
	if not game.is_walkable(e.node.position+direction*0.9,0.4) or not e.path.is_empty():
		if e.repath<=0:
			e.path = game.path_between(e.node.position,target)
			e.repath = 1.0+float(e.id%5)*0.1
		while not e.path.is_empty() and e.node.position.distance_to(e.path[0])<0.2: e.path.pop_front()
		if not e.path.is_empty(): direction = (e.path[0]-e.node.position).normalized()
	var separation = Vector3.ZERO
	var key = Vector2i(floori(e.node.position.x/1.4),floori(e.node.position.z/1.4))
	for dx in range(-1,2):
		for dz in range(-1,2):
			for other in cells.get(key+Vector2i(dx,dz),[]):
				if e.id == other.id: continue
				var away = e.node.position-other.node.position
				var dist = away.length()
				if dist>0.01 and dist<0.85: separation += away/dist*(0.85-dist)*1.6
	var speed = [2.15,2.5,3.3,1.55,3.0,2.8][e.kind]+game.wave*0.045
	if e.boss: speed = 1.65
	speed *= game.run_difficulty[3]
	if e.slow>0: speed *= 0.45
	var move = (direction+separation).limit_length(1.25)*speed*delta
	var next = e.node.position+move
	if game.is_walkable(next,0.32): e.node.position = next
	elif game.is_walkable(e.node.position+Vector3(move.x,0,0),0.32): e.node.position.x += move.x
	elif game.is_walkable(e.node.position+Vector3(0,0,move.z),0.32): e.node.position.z += move.z
	if direction.length()>0.01: e.model.rotation.y = lerp_angle(e.model.rotation.y,atan2(-direction.x,-direction.z),delta*10)

func nearest_enemy(radius):
	var target = null
	for e in enemies:
		var d = e.node.position.distance_to(game.player.position)
		if e.hp>0 and d<radius:
			radius = d
			target = e
	return target

func upgrade_weapon(id):
	if id == "pan":
		for p in pans: p.queue_free()
		pans.clear()
		for i in range(game.perks.pan):
			var p = Node3D.new()
			add_child(p)
			game.cylinder(p,Vector3.ZERO,0.48,0.12,game.INK)
			var rim = game.ring(p,0.43,Color("a3bec3"))
			rim.position.y = 0.075
			game.box(p,Vector3(0,0,0.75),Vector3(0.16,0.13,0.72),Color("a97748"))
			for z in [.54,.73]: game.sphere(p,Vector3(0,.08,z),Vector3.ONE*.07,game.GOLD)
			game.ArtDetail.bake(p,"pan_weapon")
			pans.append(p)

func fire_at(e):
	var origin = game.player.position+Vector3(0.35,1.15,-0.15)
	var n = game.sphere(self,origin,Vector3.ONE*0.23,Color("8ce8e3"))
	n.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shots.append({"node":n,"target":e,"life":1.5,"kind":"soda"})

func fire_knives(target):
	var count = mini(4,game.perks.knife)
	var direction = (target.node.position-game.player.position).normalized()
	for i in range(count):
		var dir = direction.rotated(Vector3.UP,(i-(count-1)/2.0)*0.13)
		var n = Node3D.new()
		add_child(n)
		n.position = game.player.position+Vector3(0,1.0,0)
		n.rotation.y = atan2(-dir.x,-dir.z)
		game.box(n,Vector3(0,0,-0.23),Vector3(0.15,0.045,0.58),game.CREAM)
		game.box(n,Vector3(0,0,0.17),Vector3(0.12,0.09,0.26),Color("925c3f"))
		shots.append({"node":n,"velocity":dir*23,"life":attack_range/20,"kind":"knife","hits":[],"left":2+int(game.perks.knife/2)})

func update_weapons(delta):
	var target = nearest_enemy(attack_range)
	if target != null:
		if fire_left<=0:
			fire_at(target)
			fire_left = 0.52/haste
		if game.perks.has("knife") and knife_left<=0:
			fire_knives(target)
			knife_left = 0.8/haste
		if game.perks.has("pepper") and pepper_left<=0:
			make_cloud()
			pepper_left = 2.7/haste
	for shot in shots.duplicate():
		shot.life -= delta
		if shot.kind == "soda":
			var enemy = shot.target
			if enemy.hp<=0 or not is_instance_valid(enemy.node): shot.life = 0
			else:
				var goal = enemy.node.position+Vector3(0,1,0)
				shot.node.position = shot.node.position.move_toward(goal,delta*19)
				if shot.node.position.distance_to(goal)<0.3:
					hurt(enemy,damage*power)
					shot.life = 0
		else:
			var previous = shot.node.position
			shot.node.position += shot.velocity*delta
			for e in enemies.duplicate():
				if e.id in shot.hits or e.hp<=0: continue
				var pt = e.node.position+Vector3(0,1,0)
				var near = Geometry3D.get_closest_point_to_segment(pt,previous,shot.node.position)
				if near.distance_to(pt)<(0.9 if e.boss else 0.55):
					shot.hits.append(e.id)
					hurt(e,(20+game.perks.knife*6)*power)
					shot.left -= 1
					if shot.left<=0:
						shot.life = 0
						break
		if shot.life<=0:
			shot.node.queue_free()
			shots.erase(shot)
	for i in range(pans.size()):
		var a = age*2.7+i*TAU/pans.size()
		pans[i].position = game.player.position+Vector3(cos(a)*3.0,0.95,sin(a)*3.0)
		pans[i].rotation.y = -a
		if pan_tick<=0:
			for e in enemies.duplicate():
				if e.node.position.distance_to(pans[i].position-Vector3.UP*0.95)<1.0:
					hurt(e,(24+game.perks.pan*6)*power)
					e.slow = 0.3
	if pan_tick<=0: pan_tick = 0.3
	for cloud in clouds.duplicate():
		cloud.life -= delta
		cloud.tick -= delta
		cloud.node.rotation.y += delta*0.4
		if cloud.tick<=0:
			for e in enemies.duplicate():
				if e.node.position.distance_to(cloud.node.position)<cloud.radius:
					e.slow = 0.7
					hurt(e,(7+game.perks.pepper*4)*power)
			cloud.tick = 0.5
		if cloud.life<=0:
			cloud.node.queue_free()
			clouds.erase(cloud)

func make_cloud():
	var n = Node3D.new()
	add_child(n)
	n.position = game.player.position
	var radius = 2.1+game.perks.pepper*0.3
	game.ring(n,radius,game.CORAL)
	for i in range(10):
		var angle = i*TAU/10
		var puff = game.sphere(n,Vector3(cos(angle)*radius*0.55,0.25,sin(angle)*radius*0.55),Vector3(1.2,0.45,1.2),game.CORAL)
		puff.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		puff.material_override.albedo_color.a = 0.22
		puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	clouds.append({"node":n,"radius":radius,"life":4.0,"tick":0.0})

func hurt(e, amount):
	if e.hp<=0: return
	# Human armor guarantees at least three damaging hits, even with upgraded weapons.
	if e.kind == 5: amount = minf(amount,e.max_hp*0.34)
	e.hp -= amount
	e.hit = 0.12
	if e.hp<=0:
		kills += 1
		game.profile.record("kills")
		if e.boss:
			boss_defeated = true
			game.toast("Kazan Kıran yenildi! Son servisi tamamla.")
		game.add_combat_xp(30 if e.boss else 8 if e.kind == 3 else 4)
		game.puff(e.node.position+Vector3(0,0.8,0),Color("bdacec"))
		enemies.erase(e)
		e.node.queue_free()

func service_burst(at):
	if not game.perks.has("bell"): return
	for e in enemies.duplicate():
		if e.node.position.distance_to(at)<4.5: hurt(e,damage*power*game.perks.bell)
	game.floating_text("DİNG!",at+Vector3(0,2,0),game.GOLD)

func make_human(parent):
	var model = Node3D.new()
	parent.add_child(model)
	var color = Color("ad6550")
	var body = game.box(model,Vector3(0,1.2,0),Vector3(0.8,0.85,0.45),color)
	game.sphere(model,Vector3(0,1.92,0),Vector3(0.63,0.7,0.6),Color("e4ba91"))
	game.box(model,Vector3(0,2.23,0.02),Vector3(0.68,0.16,0.62),game.INK)
	for x in [-0.14,0.14]: game.sphere(model,Vector3(x,1.95,-0.29),Vector3.ONE*0.07,game.INK)
	game.box(model,Vector3(0,1.8,-0.29),Vector3(0.25,0.035,0.04),game.INK)
	var legs: Array = []
	for x in [-0.23,0.23]:
		var leg = Node3D.new()
		model.add_child(leg)
		leg.position = Vector3(x,0.83,0)
		game.box(leg,Vector3(0,-0.32,0),Vector3(0.29,0.66,0.34),game.INK)
		game.box(leg,Vector3(0,-0.7,-0.12),Vector3(0.32,0.15,0.53),Color("64483b"))
		legs.append(leg)
	var arm = Node3D.new()
	model.add_child(arm)
	arm.position = Vector3(0.52,1.53,0)
	game.box(arm,Vector3(0,-0.3,0),Vector3(0.22,0.65,0.25),color)
	game.sphere(arm,Vector3(0,-0.61,0),Vector3.ONE*0.25,Color("e4ba91"))
	var club = game.cylinder(arm,Vector3(0,-0.68,-0.48),0.105,1.3,Color("81502f"))
	club.rotation.x = PI/2
	game.box(model,Vector3(-0.5,1.18,0),Vector3(0.23,0.75,0.27),color)
	model.set_meta("legs",legs)
	for x in [-.18,.18]:
		game.box(model,Vector3(x,1.44,-.24),Vector3(.16,.17,.025),Color("c48761"))
		game.sphere(model,Vector3(x,1.43,-.264),Vector3.ONE*.035,game.GOLD)
	game.box(model,Vector3(0,.88,0),Vector3(.85,.1,.48),Color("675043"))
	game.box(model,Vector3(0,.88,-.26),Vector3(.14,.11,.04),game.GOLD)
	for y in [1.15,1.3]: game.sphere(model,Vector3(0,y,-.245),Vector3.ONE*.04,game.INK)
	for z in [-.8,-.45]: game.box(arm,Vector3(0,-.68,z),Vector3(.22,.22,.06),Color("bba080"))
	model.set_meta("club_arm",arm)
	bake_static_parts(model,[body],"human")
	return {"model":model,"body":body,"color":color}

func bake_static_parts(model, moving, key):
	# Static facial details share one vertex-colored mesh; limbs remain articulated.
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count = 0
	for part in model.get_children():
		if not part is MeshInstance3D or moving.has(part): continue
		if baked_meshes.has(key):
			model.remove_child(part)
			part.queue_free()
			count += 1
			continue
		var arrays = part.mesh.surface_get_arrays(0)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var normals = arrays[Mesh.ARRAY_NORMAL]
		var indices = arrays[Mesh.ARRAY_INDEX]
		var tint = part.material_override.albedo_color
		for i in range(indices.size() if indices != null and indices.size()>0 else vertices.size()):
			var index = indices[i] if indices != null and indices.size()>0 else i
			surface.set_color(tint)
			surface.set_normal((part.transform.basis.inverse().transposed()*normals[index]).normalized())
			surface.add_vertex(part.transform*vertices[index])
		count += 1
		model.remove_child(part)
		part.queue_free()
	if count == 0: return
	var combined = MeshInstance3D.new()
	if not baked_meshes.has(key): baked_meshes[key] = surface.commit()
	combined.mesh = baked_meshes[key]
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.85
	combined.material_override = material
	combined.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	model.add_child(combined)
