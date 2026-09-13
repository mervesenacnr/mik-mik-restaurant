extends Node3D
## A dish has separate edible portions, porcelain, crumbs and looping steam.
## Updated by the simulation, so pause and upgrade selection freeze it too.
const ArtDetail = preload("res://scripts/art_detail.gd")
static var portion_cache: Dictionary = {}
const NAMES = ["Peynir burger", "Sebzeli pizza", "Balkabağı çorbası", "Peynir tabağı"]
var kind = 0
var portions: Array = []
var steam: Array = []
var crumbs: Node3D
var liquid: MeshInstance3D
var age = 0.0
var fraction = 1.0
var flying = false
var flight_age = 0.0
var flight_from = Vector3.ZERO
var resting_at = Vector3.ZERO

func material(color):
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(color)
	m.roughness = 0.65
	return m

func mesh_part(parent, shape, at, color):
	var m = MeshInstance3D.new()
	m.mesh = shape
	m.material_override = material(color)
	parent.add_child(m)
	m.position = at
	return m

func ball(parent, at, size, color):
	var s = SphereMesh.new()
	s.radius = 0.5
	s.height = 1.0
	s.radial_segments = 16
	s.rings = 8
	var n = mesh_part(parent,s,at,color)
	n.scale = size
	return n

func disc(parent, at, radius, height, color):
	var s = CylinderMesh.new()
	s.top_radius = radius
	s.bottom_radius = radius
	s.height = height
	s.radial_segments = 24
	return mesh_part(parent,s,at,color)

func wedge(parent, radius, height, color):
	# A curved 60-degree slice with thickness, rather than a flat food icon.
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(6):
		var a = -PI/6+i*PI/18
		var b = a+PI/18
		var p = Vector3(sin(a)*radius,0,cos(a)*radius)
		var q = Vector3(sin(b)*radius,0,cos(b)*radius)
		var up = Vector3(0,height,0)
		for v in [up,p+up,q+up,Vector3.ZERO,q,p,p,p+up,q+up,p,q+up,q]: st.add_vertex(v)
	for angle in [-PI/6,PI/6]:
		var p = Vector3(sin(angle)*radius,0,cos(angle)*radius)
		var up = Vector3(0,height,0)
		for v in [Vector3.ZERO,up,p+up,Vector3.ZERO,p+up,p]: st.add_vertex(v)
	st.generate_normals()
	var n = mesh_part(parent,st.commit(),Vector3.ZERO,color)
	n.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	return n

func setup(dish_kind):
	kind = dish_kind % NAMES.size()
	name = "Dish"
	disc(self,Vector3(0,0.025,0),0.68,0.06,"f8eed9")
	disc(self,Vector3(0,0.06,0),0.59,0.025,"e5dbbf")
	var rim = TorusMesh.new()
	rim.inner_radius = 0.59
	rim.outer_radius = 0.66
	rim.rings = 32
	rim.ring_segments = 8
	mesh_part(self,rim,Vector3(0,0.073,0),"f8eed9")
	match kind:
		0: make_burgers()
		1: make_pizza()
		2: make_soup()
		3: make_cheese()
	for i in range(portions.size()):
		var key = str(kind)+":"+str(i)
		var p = portions[i]
		if portion_cache.has(key):
			for child in p.get_children():
				p.remove_child(child)
				child.queue_free()
			var merged = MeshInstance3D.new()
			merged.mesh = portion_cache[key][0]
			merged.material_override = portion_cache[key][1]
			merged.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.add_child(merged)
		else:
			ArtDetail.bake(p)
			portion_cache[key] = [p.get_child(0).mesh,p.get_child(0).material_override]
	crumbs = Node3D.new()
	add_child(crumbs)
	for i in range(9):
		var a = i*2.399
		ball(crumbs,Vector3(cos(a)*(0.16+i*0.04),0.095,sin(a)*(0.16+i*0.04)),Vector3(0.07,0.035,0.05),"b98748")
	ArtDetail.bake(crumbs,"dish_crumbs")
	crumbs.visible = false
	for i in range(4):
		var n = ball(self,Vector3.ZERO,Vector3.ONE*0.15,"fff9e7")
		n.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		n.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		steam.append(n)
	return self

func portion(at = Vector3.ZERO):
	var n = Node3D.new()
	add_child(n)
	n.position = at
	portions.append(n)
	return n

func make_burgers():
	for i in range(3):
		var a = i*TAU/3
		var p = portion(Vector3(cos(a)*0.29,0.085,sin(a)*0.29))
		disc(p,Vector3(0,0.055,0),0.24,0.09,"d39543")
		ball(p,Vector3(0,0.12,0),Vector3(0.55,0.065,0.5),"79a44b")
		disc(p,Vector3(0,0.155,0),0.23,0.075,"75442d")
		disc(p,Vector3(0,0.205,0),0.25,0.035,"ffc44b")
		disc(p,Vector3(0,0.237,0),0.21,0.035,"d95c42")
		ball(p,Vector3(0,0.31,0),Vector3(0.51,0.22,0.51),"e8ad58")
		for j in range(6):
			var edge = j*TAU/6
			ball(p,Vector3(cos(edge)*.22,.13,sin(edge)*.22),Vector3(.16,.045,.13),"6f974b")
			ball(p,Vector3(cos(edge)*.14,.37,sin(edge)*.14),Vector3(.045,.035,.11),"d79548")
		for j in range(9):
			var angle = j*2.4
			ball(p,Vector3(cos(angle)*0.13,0.404,sin(angle)*0.13),Vector3(0.035,0.014,0.07),"fff0bd")

func make_pizza():
	for i in range(6):
		var p = portion(Vector3(0,0.085,0))
		p.rotation.y = i*TAU/6
		wedge(p,0.56,0.085,"c48a42")
		var cheese = wedge(p,0.51,0.03,"f4c952")
		cheese.position.y = 0.085
		disc(p,Vector3(0,0.135,0.32),0.085,0.025,"d76245")
		ball(p,Vector3(0.09,0.145,0.38),Vector3(0.09,0.035,0.14),"589953")
		ball(p,Vector3(-0.075,0.143,0.25),Vector3(0.06,0.035,0.06),"443d36")
		for j in range(4):
			var a = -.36+j*.24
			ball(p,Vector3(sin(a)*.53,.14,cos(a)*.53),Vector3(.13,.12,.1),"d99a51")
		ball(p,Vector3(-.07,.16,.38),Vector3(.13,.035,.08),"ecdec4")
		ball(p,Vector3(-.07,.14,.34),Vector3(.04,.06,.06),"ac8d70")

func make_soup():
	var bowl = disc(self,Vector3(0,0.14,0),0.51,0.19,"518d89")
	bowl.mesh.cap_top = false
	var lip = TorusMesh.new()
	lip.inner_radius = 0.42
	lip.outer_radius = 0.51
	lip.rings = 32
	lip.ring_segments = 8
	mesh_part(self,lip,Vector3(0,0.24,0),"f8eed9")
	liquid = disc(self,Vector3(0,0.269,0),0.415,0.025,"e89d3c")
	for i in range(6):
		var a = i*TAU/6
		var p = portion(Vector3(cos(a)*0.23,0.292,sin(a)*0.23))
		ball(p,Vector3.ZERO,Vector3(0.13,0.08,0.14),"ffd67b" if i%2 == 0 else "74a457")
		ball(p,Vector3(.05,.018,.02),Vector3(.06,.018,.12),"467b51")
		ball(p,Vector3(-.03,.014,-.07),Vector3(.07,.018,.045),"fff0ca")

func make_cheese():
	for i in range(4):
		var a = i*PI/2
		var p = portion(Vector3(cos(a)*0.29,0.08,sin(a)*0.29))
		p.rotation.y = -a
		wedge(p,0.32,0.19,"f6c447")
		for j in range(2): disc(p,Vector3(-0.045+j*0.09,0.196,0.19),0.025,0.006,"d4992a")
		ball(p,Vector3(0.17,0.055,0.12),Vector3.ONE*0.12,"715475")
		ball(p,Vector3(0.19,0.10,0.19),Vector3.ONE*0.11,"94628c")
		for j in range(3): ball(p,Vector3(.19+j*.035,.065,.23+j*.045),Vector3.ONE*.09,"65486c")
		disc(p,Vector3(-.12,.035,.14),.105,.04,"ccab70")
		for j in range(3): ball(p,Vector3(-.16+j*.035,.06,.14),Vector3(.012,.01,.012),"97764b")

func serve_from(local_origin):
	resting_at = position
	flight_from = local_origin
	flight_age = 0
	flying = true
	position = flight_from

func advance(delta, remaining = 1.0, hot = true):
	age += delta
	fraction = clampf(remaining,0,1)
	if flying:
		flight_age += delta
		var t = minf(1,flight_age/0.42)
		position = flight_from.lerp(resting_at,t)+Vector3.UP*sin(t*PI)*0.55
		rotation.z = sin(t*PI)*0.12
		if t >= 1:
			flying = false
			position = resting_at
			rotation.z = 0
	for i in range(portions.size()):
		portions[i].visible = i < ceili(fraction*portions.size())
		if kind == 2: portions[i].position.y = 0.165+0.129*fraction
	crumbs.visible = fraction<0.99
	if liquid != null:
		liquid.position.y = 0.14+0.129*fraction
		liquid.visible = fraction>0
	for i in range(steam.size()):
		var t = fmod(age*0.65+i*0.25,1.0)
		var n = steam[i]
		n.visible = hot and fraction>0
		n.position = Vector3(sin(age*1.5+i)*0.18,0.42+t*0.8,cos(i*2.4)*0.18)
		n.scale = Vector3.ONE*(0.09+t*0.2)
		n.material_override.albedo_color.a = sin(t*PI)*0.27
