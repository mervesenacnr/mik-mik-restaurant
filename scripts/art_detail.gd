extends RefCounted
## Merge decorative parts so richer models don't add one draw call per stitch.
static var mesh_cache: Dictionary = {}
static func bake(root, cache_key = ""):
	if cache_key != "" and mesh_cache.has(cache_key):
		for part in root.get_children():
			if part is MeshInstance3D:
				root.remove_child(part)
				part.queue_free()
		var cached = MeshInstance3D.new()
		cached.mesh = mesh_cache[cache_key][0]
		cached.material_override = mesh_cache[cache_key][1]
		cached.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(cached)
		return
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count = 0
	for part in root.get_children():
		if not part is MeshInstance3D: continue
		var arrays = part.mesh.surface_get_arrays(0)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var normals = arrays[Mesh.ARRAY_NORMAL]
		var indices = arrays[Mesh.ARRAY_INDEX]
		for i in range(indices.size() if indices != null and indices.size()>0 else vertices.size()):
			var k = indices[i] if indices != null and indices.size()>0 else i
			st.set_color(part.material_override.albedo_color)
			st.set_normal((part.transform.basis.inverse().transposed()*normals[k]).normalized())
			st.add_vertex(part.transform*vertices[k])
		root.remove_child(part)
		part.queue_free()
		count += 1
	if count == 0: return
	var mesh = MeshInstance3D.new()
	mesh.mesh = st.commit()
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = .8
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mesh)
	if cache_key != "": mesh_cache[cache_key] = [mesh.mesh,material]

static func root_at(parent, pos = Vector3.ZERO):
	var n = Node3D.new()
	parent.add_child(n)
	n.position = pos
	return n

static func rod(g, parent, a, b, radius, color):
	var n = g.cylinder(parent,(a+b)/2,radius,a.distance_to(b),color)
	var axis = (b-a).normalized()
	var side = axis.cross(Vector3.FORWARD).normalized()
	if side.length()<.1: side = axis.cross(Vector3.RIGHT).normalized()
	n.basis = Basis(side,axis,side.cross(axis))
	return n

static func face(g, model, fur, eye):
	var rig = model.get_meta("rig")
	for old in rig.get("eyes",[]): old.visible = false
	var head = rig.head
	var face_root = root_at(head)
	face_root.name = "FaceDetails"
	for x in [-1,1]:
		g.sphere(face_root,Vector3(x*.18,-.02,-.42),Vector3(.28,.20,.2),fur.lightened(.3))
		g.sphere(face_root,Vector3(x*.29,.01,-.37),Vector3(.11,.06,.02),Color("c88c87"))
		for j in range(3):
			rod(g,face_root,Vector3(x*.23,-.005+j*.025,-.48),Vector3(x*(.47+j*.025),-.04+j*.065,-.47),.008,fur.darkened(.45))
		g.sphere(face_root,Vector3(x*.043,-.125,-.49),Vector3(.078,.095,.055),g.CREAM)
		var brow = g.sphere(face_root,Vector3(x*.21,.33,-.34),Vector3(.20,.035,.045),fur.darkened(.4))
		brow.rotation.z = x*(.23 if eye == "sharp" else -.12)
		var at = Vector3(x*.205,.19,-.373)
		if eye == "sleepy":
			var eye_part = g.sphere(face_root,at,Vector3(.18,.065,.07),g.INK)
			eye_part.rotation.z = x*.15
			g.sphere(face_root,at+Vector3(-.015,.012,-.041),Vector3(.034,.017,.01),g.CREAM)
		else:
			var shape = Vector3(.185,.22,.085) if eye == "round" else Vector3(.21,.13,.08) if eye == "sharp" else Vector3(.14,.24,.075)
			var white = g.sphere(face_root,at,shape,Color("faf3dd"))
			white.rotation.z = x*.22 if eye == "sharp" else 0
			g.sphere(face_root,at+Vector3(0,-.005,-.046),shape*Vector3(.55,.68,.5),Color("4b6562"))
			g.sphere(face_root,at+Vector3(0,-.005,-.064),shape*Vector3(.28,.48,.24),g.INK)
			g.sphere(face_root,at+Vector3(-.022,.032,-.079),Vector3(.045,.047,.018),Color.WHITE)
	g.sphere(face_root,Vector3(-.025,.063,-.626),Vector3(.052,.025,.01),Color("ffd3c5"))
	bake(face_root,"face:"+fur.to_html()+":"+eye)
	model.set_meta("eye_shape",eye)

static func tailoring(g, model, cloth):
	var detail = root_at(model)
	detail.name = "Tailoring"
	for x in [-.13,.13]:
		for y in [.55,.71,.87]: g.sphere(detail,Vector3(x,y,-.346),Vector3.ONE*.045,g.GOLD)
	g.box(detail,Vector3(0,.4,-.32),Vector3(.34,.15,.055),cloth.lightened(.22))
	for x in [-.17,.17]: rod(g,detail,Vector3(x,.32,-.35),Vector3(x,.47,-.35),.009,g.CREAM)
	for side in [-1,1]:
		var collar = g.box(detail,Vector3(side*.115,1,-.32),Vector3(.19,.12,.08),g.CREAM)
		collar.rotation.z = side*.4
		for i in range(3): g.box(detail,Vector3(side*.2+(i-1)*.055,.16,-.295),Vector3(.012,.026,.07),cloth.darkened(.4))
	bake(detail,"tailor:"+cloth.to_html())

static func table_details(g, parent, index):
	var d = root_at(parent)
	d.name = "TableDetails"
	var rim = g.ring(d,1.025,g.GOLD.darkened(.15))
	rim.position.y = 1.29
	# Runner, folded napkin, fork, salt and pepper, stitched chair cushions.
	g.box(d,Vector3(0,1.299,0),Vector3(.44,.012,1.87),g.CREAM)
	for x in [-.19,.19]: g.box(d,Vector3(x,1.309,0),Vector3(.018,.008,1.8),g.TEAL)
	g.box(d,Vector3(.65,1.315,.12),Vector3(.26,.025,.48),g.CREAM)
	rod(g,d,Vector3(.76,1.34,-.03),Vector3(.76,1.34,.24),.012,g.INK)
	for z in [-.09,-.055,-.02]: rod(g,d,Vector3(.76,1.34,z),Vector3(.82,1.34,z),.008,g.INK)
	for x in [-.34,-.14]:
		g.cylinder(d,Vector3(x,1.4,-.65),.065,.19,Color("ede1c8") if x<-.2 else Color("815847"))
		g.sphere(d,Vector3(x,1.5,-.65),Vector3(.13,.045,.13),g.INK)
	for side in [-1,1]:
		g.box(d,Vector3(side*1.43,.76,0),Vector3(.58,.08,.60),g.CORAL if index%2 == 0 else g.MINT)
		for z in [-.23,.23]: g.box(d,Vector3(side*1.43,.807,z),Vector3(.52,.012,.015),g.CREAM)
	bake(d,"table:"+str(index%2))

static func kitchen_details(g):
	var d = root_at(g.world)
	d.name = "KitchenDetails"
	# Shelf brackets, stacked crockery, hanging utensils and a brick oven face.
	for x in [-5.5,5.5]:
		g.box(d,Vector3(x,2.15,-8.08),Vector3(3.1,.12,.6),Color("886044"))
		for dx in [-1.2,1.2]: rod(g,d,Vector3(x+dx,1.65,-8.3),Vector3(x+dx,2.1,-7.9),.035,g.INK)
		for i in range(5):
			g.cylinder(d,Vector3(x-1+i*.48,2.43,-8.08),.16,.44,[g.CORAL,g.MINT,g.GOLD][i%3])
			g.cylinder(d,Vector3(x-1+i*.48,2.68,-8.08),.18,.07,g.CREAM)
	for i in range(7):
		g.box(d,Vector3(-9.7+i*.36,1.72,-5.99),Vector3(.32,.19,.06),Color("b76b4d") if i%2 == 0 else Color("dda079"))
	for x in [-9.25,-8.85,-8.45,-8.05]: g.cylinder(d,Vector3(x,2.045,-6.3),.11,.04,g.INK)
	for i in range(4): g.cylinder(d,Vector3(9.1,1.58+i*.06,-6.8),.42,.045,g.CREAM)
	for x in [-2.4,-.8,.8,2.4]:
		for side in [-1,1]: g.box(d,Vector3(x+side*.4,1.67,-5.8),Vector3(.19,.07,.13),g.INK)
		g.ring(d,.15,g.GOLD).position = Vector3(x,1.8,-5.8)
	bake(d)
