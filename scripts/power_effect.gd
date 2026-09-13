extends Node3D
## Lives on the chef; its clock is advanced only while the run is active.
var age = 0.0
var hoops: Array = []
var sparks: Array = []
var color = Color("f1c56c")

func glow_material():
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func setup(tint):
	color = tint
	for i in range(3):
		var n = MeshInstance3D.new()
		var t = TorusMesh.new()
		t.inner_radius = 0.64
		t.outer_radius = 0.70
		t.rings = 40
		t.ring_segments = 8
		n.mesh = t
		n.material_override = glow_material()
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(n)
		hoops.append(n)
	for i in range(14):
		var n = MeshInstance3D.new()
		var s = PrismMesh.new()
		s.size = Vector3(0.13,0.23,0.13)
		n.mesh = s
		n.material_override = glow_material()
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(n)
		sparks.append(n)
	advance(0)
	return self

func advance(delta):
	age += delta
	var t = minf(1,age/1.5)
	for i in range(hoops.size()):
		var p = fmod(t+i*0.27,1)
		hoops[i].position.y = 0.15+p*2.4
		hoops[i].scale = Vector3.ONE*(0.7+p*1.5)
		hoops[i].material_override.albedo_color.a = (1-t)*(1-p)*0.8
	for i in range(sparks.size()):
		var a = i*TAU/sparks.size()+age*3.8
		var radius = 0.65+t*0.75
		sparks[i].position = Vector3(cos(a)*radius,0.35+t*2.0+sin(a*2)*0.3,sin(a)*radius)
		sparks[i].rotation = Vector3(t*4,a,t*2)
		sparks[i].scale = Vector3.ONE*sin((0.12+t*0.88)*PI)
		sparks[i].material_override.albedo_color.a = 1-t
	return age>=1.5
