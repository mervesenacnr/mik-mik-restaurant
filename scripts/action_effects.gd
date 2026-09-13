extends Node3D
## Visual events only: rewards and damage are resolved once by game simulation.
## No independent process/tweens; Escape and upgrade choices freeze every effect.
var game
var effects: Array = []
var deaths: Array = []
var impact_pool: Array = []
const MAX_EFFECTS = 48
const MAX_DEATHS = 24
func setup(g):
	game = g
	return self
func retire(fx):
	if fx.kind == "impact" and impact_pool.size()<16:
		fx.node.visible = false
		impact_pool.append(fx.node)
	else: fx.node.queue_free()
func add_effect(fx):
	if effects.size()>=MAX_EFFECTS:
		var disposable = effects.filter(func(e): return e.kind == "impact")
		var oldest = disposable[0] if not disposable.is_empty() else effects[0]
		effects.erase(oldest)
		retire(oldest)
	effects.append(fx)
func impact(at, color, strong = false):
	var node
	if not impact_pool.is_empty(): node = impact_pool.pop_back()
	else:
		node = Node3D.new()
		add_child(node)
		for i in range(4):
			var shard = game.box(node,Vector3.ZERO,Vector3(.075,.18,.075),color)
			shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.visible = true
	node.position = at
	node.scale = Vector3.ONE
	for part in node.get_children():
		part.material_override.albedo_color = color
		part.scale = Vector3.ZERO
	add_effect({"kind":"impact","node":node,"age":0.0,"life":.26,"strong":strong})
func tip(at, hand, amount):
	var node = Node3D.new()
	add_child(node)
	for i in range(3):
		var coin = game.cylinder(node,Vector3.ZERO,.10,.035,game.GOLD)
		coin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		game.sphere(coin,Vector3(0,.027,0),Vector3(.035,.012,.07),game.CREAM).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.position = hand
	add_effect({"kind":"tip","node":node,"age":0.0,"life":1.65,"hand":hand,"table":at,"amount":amount,"pickup":false})
func death(enemy):
	if deaths.size()>=MAX_DEATHS:
		deaths.pop_front().node.queue_free()
	enemy.danger.visible = false
	enemy.health.visible = false
	enemy.body.material_override.albedo_color = enemy.color
	deaths.append({"node":enemy.node,"model":enemy.model,"age":0.0,"life":.72,"scale":enemy.model.scale,"rotation":enemy.model.rotation,"at":enemy.model.position,"side":1 if enemy.id%2 == 0 else -1})
	impact(enemy.node.position+Vector3(0,1,0),game.GOLD,true)
func advance(delta):
	if delta<=0: return
	for fx in effects.duplicate():
		fx.age += delta
		var t = clampf(fx.age/fx.life,0,1)
		if fx.kind == "impact":
			for i in range(fx.node.get_child_count()):
				var part = fx.node.get_child(i)
				var a = i*TAU/4+.4
				part.position = Vector3(cos(a),sin(a),sin(a)*.35)*(.06+t*(.6 if fx.strong else .35))
				part.rotation = Vector3(0,a,a)
				part.scale = Vector3.ONE*sin(t*PI)
		elif fx.kind == "tip":
			if fx.age<.38:
				var drop = fx.age/.38
				fx.node.position = fx.hand.lerp(fx.table,drop)+Vector3.UP*sin(drop*PI)*.22
			elif fx.age<.85:
				fx.node.position = fx.table+Vector3.UP*absf(sin((fx.age-.38)*15))*.07*(1-(fx.age-.38)/.47)
			else:
				if not fx.pickup:
					fx.pickup = true
					game.gesture_kind = "collect"
					game.gesture_left = .35
					game.tone(1040,.06,.04)
					game.floating_text("+%d" % fx.amount,game.player.position+Vector3(0,2.1,0),game.GOLD)
				var collect = clampf((fx.age-.85)/.8,0,1)
				var goal = game.player.global_position+Vector3(0,1.1,0)
				fx.node.position = fx.table.lerp(goal,smoothstep(0,1,collect))+Vector3.UP*sin(collect*PI)*.65
			for i in range(fx.node.get_child_count()):
				var coin = fx.node.get_child(i)
				coin.position = Vector3((i-1)*.12,i*.04,0)
				coin.rotation.z = fx.age*9 if fx.age>.85 else 0
			fx.node.scale = Vector3.ONE*(1-smoothstep(.88,1,t))
		if fx.age>=fx.life:
			retire(fx)
			effects.erase(fx)
	for fx in deaths.duplicate():
		fx.age += delta
		var t = clampf(fx.age/fx.life,0,1)
		fx.model.rotation.z = fx.rotation.z+fx.side*PI*.48*smoothstep(0,.55,t)
		fx.model.rotation.y = fx.rotation.y+fx.side*t*.5
		fx.model.position = fx.at+Vector3(fx.side*.25*t,sin(t*PI)*.35,0)
		fx.model.scale = fx.scale*(1-smoothstep(.35,1,t))
		if fx.age>=fx.life:
			fx.node.queue_free()
			deaths.erase(fx)
