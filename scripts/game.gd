extends Node3D
## All game assets are original procedural geometry; no external dependencies.

const OrderIndicators = preload("res://scripts/order_indicators.gd")
const MonsterSystem = preload("res://scripts/monster_system.gd")
const FoodVisual = preload("res://scripts/food_visual.gd")
const ArtDetail = preload("res://scripts/art_detail.gd")
const PowerEffect = preload("res://scripts/power_effect.gd")

const CREAM = Color("f8eed9")
const INK = Color("163d42")
const TEAL = Color("28756e")
const MINT = Color("93c8ac")
const CORAL = Color("e87958")
const GOLD = Color("f1c56c")
const RED = Color("d95151")
const MAP_MIN = Vector3(-32,0,-24)
const MAP_MAX = Vector3(32,0,28)
const TABLE_SPOTS = [Vector3(-8,0,-1),Vector3(8,0,-1),Vector3(-8,0,8),Vector3(8,0,8),Vector3(-18,0,0),Vector3(18,0,0),Vector3(-18,0,13),Vector3(18,0,13),Vector3(-7,0,20),Vector3(7,0,20)]

const PERKS = [
	["clean", "RESTORAN", "Köpük ustası", "Temizlik +%35 hızlı.\nIV: Bulaşık perisi evrimi açılır.", "25"],
	["speed", "FARE", "Minik turbo", "Hareket hızı +%18.\nDaha çok masa, daha az telaş.", "01"],
	["range", "FARE", "Uzun patiler", "Otomatik işlem alanı +0,6 m.\nİki masaya birden yetiş.", "02"],
	["capacity", "FARE", "Denge ustası", "Tepsi kapasitesi +1 tabak.\nIV: Servis bandı evrimi açılır.", "03"],
	["dash", "FARE", "Peynir gibi kay", "Dash beklemesi −%25.\nDash boyunca hareket hızı artar.", "04"],
	["hands", "FARE", "Seri patiler", "Sipariş alma +%30 hızlı.\nYaklaş; gerisini Mik halleder.", "05"],
	["oven", "RESTORAN", "Taş fırın", "Yemekler +%30 hızlı pişer.\nMutfak tüm siparişleri otomatik hazırlar.", "06"],
	["robot", "RESTORAN", "Bulaşık perisi", "Kirli masalar 7 saniyede\nkendiliğinden temizlenir.", "07"],
	["belt", "RESTORAN", "Servis bandı", "Hazır tabaklar uzaktan\notomatik olarak tepsine gelir.", "08"],
	["decor", "RESTORAN", "Sıcacık bir köşe", "Tüm müşterilerin sabrı +%25.\nRestorana çiçekler eklenir.", "09"],
	["vip", "MÜŞTERİ", "Gurme kulübü", "Altın ceketli gurmeler açılır.\nDaha az sabır, 3 kat bahşiş.", "10"],
	["student", "MÜŞTERİ", "Kampüs müdavimi", "Öğrenciler açılır: +%70 sabır,\n%50 daha fazla deneyim.", "11"],
	["regular", "MÜŞTERİ", "Mahallenin favorisi", "Müdavimler açılır.\nDaha hızlı yer, itibarı onarır.", "12"],
	["tips", "MÜŞTERİ", "Tadına doyamadık", "Her servisten +%30 bahşiş.\nBütün müşteri türlerine uygulanır.", "13"],
	["boulevard", "YOL", "Açık bulvar", "Orta bölmeler kalkar.\nRestoranda doğrudan rota açılır.", "14"],
	["express", "YOL", "Ekspres hat", "Orta koridora hız şeridi: +%45 hız.\nMutfak ile salon arasında ak.", "15"],
	["portal", "YOL", "Fare tünelleri", "İki yandaki tüneller arasında\nyürüyerek anında geçiş yap.", "16"],
	["pressure", "SAVAŞ", "Soda basıncı", "Otomatik soda atışı +%30 hasar.\nYakındaki canavarları püskürt.", "17"],
	["reload", "SAVAŞ", "Seri soda", "Otomatik atış hızı +%25.\nServis yaparken savaşmaya devam et.", "18"],
	["bell", "SAVAŞ", "Savunma zili", "Her serviste yakındaki canavarlara\nhasar veren bir zil çalar.", "19"],
	["knife", "SAVAŞ", "Şef bıçakları", "Otomatik, delici bıçaklar açılır.\nHer seviye hasarı ve bıçak sayısını artırır.", "20"],
	["pan", "SAVAŞ", "Dönen tavalar", "Çevrende dönen tavalar açılır.\nYaklaşan canavarlara temas hasarı.", "21"],
	["pepper", "SAVAŞ", "Acı biber bulutu", "Ardında hasarlı biber bulutları bırak.\nKedi ve köpekleri yavaşlatır.", "22"],
	["reach", "SAVAŞ", "Usta menzili", "Otomatik silah menzili +2 metre.\nBıçaklar daha uzağa ulaşır.", "23"],
	["might", "SAVAŞ", "Döküm ustası", "Bütün silahların hasarı +%25.\nSoda, bıçak, tava ve biber güçlenir.", "24"],
]

var rng = RandomNumberGenerator.new()
var world: Node3D
var furniture: Node3D
var road_root: Node3D
var player: CharacterBody3D
var mouse_model: Node3D
var aura: MeshInstance3D
var camera: Camera3D
var tables: Array = []
var guests: Array = []
var orders: Array = []
var carried: Array = []
var obstacles: Array = []
var astar = AStarGrid2D.new()
var canvas: CanvasLayer
var ui: Control
var modal: Control
var hud: Control
var toast_label: Label
var status_label: Label
var money_label: Label
var wave_label: Label
var time_label: Label
var rep_label: Label
var tray_label: Label
var dash_label: Label
var build_label: Label
var xp_bar: ProgressBar
var rep_bar: ProgressBar
var clock_bar: ProgressBar
var dash_bar: ProgressBar
var kitchen_label: Label3D
var help_label: Label
var running = false
var paused = false
var choosing = false
var ended = false
var wave = 1
var wave_time = 60.0
var wave_duration = 60.0
var spawn_timer = 1.0
var action_timer = 0.0
var rep = 100.0
var money = 0
var served = 0
var missed = 0
var xp = 0
var level = 1
var next_xp = 4
var pending_levels = 0
var speed = 5.8
var service_range = 2.65
var capacity = 2
var work_rate = 1.0
var cook_rate = 1.0
var patience_mult = 1.0
var tip_mult = 1.0
var dash_cooldown = 3.2
var dash_left = 0.0
var dash_time = 0.0
var dash_dir = Vector3.FORWARD
var facing = Vector3.FORWARD
var portal_cd = 0.0
var perks: Dictionary = {"pressure":1}
var kitchen_slots: Array = []
var combat_slots: Array = ["pressure"]
var evolution_offered: Dictionary = {}
var clean_rate = 1.0
var action_pose = ""
var gesture_left = 0.0
var gesture_kind = ""
var compact_hud
const SLOT_LIMIT = 6
const SINGLE_ITEMS = ["robot","belt","vip","student","regular","boulevard","express","portal"]
var offers: Array = []
var next_wave_pending = false
var particles: Array = []
var elapsed = 0.0
var toast_time = 0.0
var best = 0
var music: AudioStreamPlayer
var sound: AudioStreamPlayer
var muted = false
var test_mode = false
var capture_mode = false
var capture_frames = 0
var title_intro = true
var guide: Label3D
var capture_kind = "gameplay"
var power_effects: Array = []
var power_time = 0.0
var monsters
var health = 100.0
var hurt_left = 0.0
var health_label: Label
var combat_label: Label
var health_bar: ProgressBar
var combat_xp = 0
var combat_level = 1
var next_combat_xp = 8
var progression_queue: Array = []
var upgrade_source = "kitchen"
var combat_xp_bar: ProgressBar
var combat_xp_label: Label
var kitchen_xp_label: Label
var weapon_label: Label
var indicators
var action_fx
var strike_left = 0.0
var strike_kind = "soda"
var profile
var profile_menu
var run_initialized = false
var max_health = 100.0
var run_difficulty = ["Öğle",1.0,1.0,1.0,0]
var achievement_banner: Label
var achievement_left = 0.0
var shared_sphere: SphereMesh
var camera_focus = Vector3(0,0,-0.8)
const CAMERA_OFFSET = Vector3(0,25,27.8)

func _ready():
	rng.randomize()
	test_mode = test_mode or "--smoke-test" in OS.get_cmdline_user_args()
	capture_mode = "--capture" in OS.get_cmdline_user_args() or "--capture-menu" in OS.get_cmdline_user_args() or "--capture-upgrade" in OS.get_cmdline_user_args()
	if "--capture-menu" in OS.get_cmdline_user_args(): capture_kind = "menu"
	if "--capture-upgrade" in OS.get_cmdline_user_args(): capture_kind = "upgrade"
	if test_mode or capture_mode: rng.seed = 87
	configure_input()
	profile = preload("res://scripts/profile.gd").new()
	add_child(profile)
	profile.setup(self)
	profile_menu = preload("res://scripts/profile_menu.gd").new().setup(self)
	load_best()
	build_world()
	monsters = MonsterSystem.new()
	add_child(monsters)
	monsters.setup(self)
	action_fx = preload("res://scripts/action_effects.gd").new()
	add_child(action_fx)
	action_fx.setup(self)
	# Warm each customer face and coat before the run, avoiding mesh baking during an arrival.
	for i in range(4):
		var warm = animal(world,Color("c4ad91"),[Color("6d939e"),GOLD,Color("b7a1c9"),MINT][i],false,["round","sharp","sleepy","oval"][i])
		world.remove_child(warm)
		warm.queue_free()
	build_ui()
	indicators = OrderIndicators.new()
	hud.add_child(indicators)
	indicators.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	indicators.setup(self)
	build_audio()
	show_title()
	if "--smoke-test" in OS.get_cmdline_user_args(): call_deferred("smoke_test")
	if capture_mode and capture_kind != "menu":
		start_run()
		for i in range(4): spawn_guest()
		toast("Öğle servisi başladı. Minik patiler, büyük işler!")
		if capture_kind == "upgrade": show_upgrades(true)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if running and not choosing and not ended:
			toggle_pause()
			get_viewport().set_input_as_handled()

func configure_input():
	for pair in [["left", KEY_A], ["right", KEY_D], ["up", KEY_W], ["down", KEY_S], ["left", KEY_LEFT], ["right", KEY_RIGHT], ["up", KEY_UP], ["down", KEY_DOWN], ["dash", KEY_SPACE]]:
		if not InputMap.has_action(pair[0]): InputMap.add_action(pair[0])
		var event = InputEventKey.new()
		event.physical_keycode = pair[1]
		InputMap.action_add_event(pair[0], event)

func mat(color: Color, roughness = 0.8):
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m

func box(parent, pos: Vector3, size: Vector3, color: Color):
	var n = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.material_override = mat(color)
	parent.add_child(n)
	n.position = pos
	return n

func sphere(parent, pos: Vector3, size: Vector3, color: Color):
	var n = MeshInstance3D.new()
	if shared_sphere == null:
		shared_sphere = SphereMesh.new()
		shared_sphere.radius = 0.5
		shared_sphere.height = 1.0
		shared_sphere.radial_segments = 16
		shared_sphere.rings = 8
	var mesh = shared_sphere
	n.mesh = mesh
	n.material_override = mat(color)
	parent.add_child(n)
	n.position = pos
	n.scale = size
	return n

func cylinder(parent, pos: Vector3, radius: float, height: float, color: Color):
	var n = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	n.mesh = mesh
	n.material_override = mat(color)
	parent.add_child(n)
	n.position = pos
	return n

func ring(parent, radius: float, color: Color):
	var n = MeshInstance3D.new()
	var mesh = TorusMesh.new()
	mesh.inner_radius = radius - 0.035
	mesh.outer_radius = radius + 0.035
	mesh.rings = 48
	mesh.ring_segments = 8
	n.mesh = mesh
	var m = mat(color)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	n.material_override = m
	parent.add_child(n)
	n.position.y = 0.08
	return n

func sign3d(parent, text_value, pos, size = 32, color = CREAM):
	var l = Label3D.new()
	l.text = text_value
	l.font_size = size * 2
	l.pixel_size = 0.007
	l.modulate = color
	l.outline_size = 8
	l.outline_modulate = INK
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	parent.add_child(l)
	l.position = pos
	return l

func solid(parent, pos, size):
	var b = StaticBody3D.new()
	var c = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	c.shape = shape
	b.add_child(c)
	parent.add_child(b)
	b.position = pos
	obstacles.append({"pos": pos, "size": size, "body": b})
	return b

func build_world():
	world = Node3D.new()
	add_child(world)
	furniture = Node3D.new()
	world.add_child(furniture)
	road_root = Node3D.new()
	world.add_child(road_root)
	var env = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("183b43")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("dfe9ed")
	e.ambient_light_energy = 0.3
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.environment = e
	add_child(env)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -25, 0)
	sun.light_color = Color("fff1de")
	sun.light_energy = 0.65
	sun.shadow_enabled = true
	add_child(sun)
	camera = Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 23.5
	camera.position = Vector3(0, 25, 27)
	camera.look_at(Vector3(0, 0, -0.8))
	camera.current = true
	build_large_floor()
	# A kitchen pavilion inside the larger garden; both sides remain open.
	box(world,Vector3(0,1.7,-8.8),Vector3(23.8,3.5,0.35),Color("efd9b5"))
	box(world,Vector3(0,0.65,-8.55),Vector3(23.4,1.3,0.15),TEAL)
	box(world,Vector3(0,1.35,-8.42),Vector3(23.4,0.12,0.2),GOLD)
	solid(world,Vector3(0,1.2,-8.8),Vector3(23.8,3,0.35))
	# Wall sign, windows and striped awnings.
	box(world,Vector3(0,2.65,-8.48),Vector3(6.5,1.2,0.2),INK)
	sign3d(world,"M I K  M I K",Vector3(0,2.85,-8.25),54,GOLD)
	for x in [-8.5,8.5]:
		box(world,Vector3(x,2.45,-8.46),Vector3(3.7,1.7,0.15),Color("7ebac1"))
		for dx in [-1.9,0,1.9]: box(world,Vector3(x+dx,2.45,-8.3),Vector3(0.12,1.85,0.18),CREAM)
		box(world,Vector3(x,2.45,-8.28),Vector3(3.8,0.1,0.2),CREAM)
		for i in range(8): box(world,Vector3(x-1.65+i*0.47,3.5,-8.05),Vector3(0.46,0.13,1.1), CORAL if i%2 == 0 else CREAM)
	# Kitchen island and visible cooking equipment.
	box(world,Vector3(0,0.65,-5.8),Vector3(7.5,1.3,1.35),TEAL)
	box(world,Vector3(0,1.37,-5.8),Vector3(7.8,0.18,1.6),CREAM)
	solid(world,Vector3(0,0.7,-5.8),Vector3(7.6,1.5,1.4))
	for x in [-2.4,-0.8,0.8,2.4]:
		box(world,Vector3(x,0.65,-5.08),Vector3(1.4,0.95,0.05),Color("215b56"))
		box(world,Vector3(x,1,-5.02),Vector3(0.5,0.07,0.08),GOLD)
		cylinder(world,Vector3(x,1.52,-5.8),0.44,0.08,INK)
		cylinder(world,Vector3(x,1.64,-5.8),0.33,0.22,Color("b56543"))
		sphere(world,Vector3(x,1.77,-5.8),Vector3(0.58,0.1,0.58),GOLD)
	kitchen_label = sign3d(world,"MUTFAK  ·  OTOMATİK",Vector3(0,2.3,-5.8),30)
	box(world,Vector3(-8.6,1,-6.8),Vector3(2.5,2,1.5),CORAL)
	box(world,Vector3(-8.6,1.2,-5.99),Vector3(1.9,0.85,0.1),INK)
	box(world,Vector3(-8.6,1.9,-5.94),Vector3(0.9,0.12,0.12),GOLD)
	box(world,Vector3(8.5,0.7,-6.8),Vector3(3,1.4,1.5),Color("b5845c"))
	box(world,Vector3(8.5,1.46,-6.8),Vector3(3.2,0.15,1.7),CREAM)
	for i in range(3): cylinder(world,Vector3(7.7+i*0.65,1.63,-6.8),0.22,0.22,CREAM)
	solid(world,Vector3(-8.6,1,-6.8),Vector3(2.5,2,1.5))
	solid(world,Vector3(8.5,1,-6.8),Vector3(3,2,1.5))
	for i in range(TABLE_SPOTS.size()): make_table(TABLE_SPOTS[i],i)
	for x in [-10.4,10.4]:
		for z in [-3.3,5.7]: plant(Vector3(x,0,z))
	# Entry rug and lanterns.
	box(world,Vector3(0,0.035,7.5),Vector3(4.7,0.035,2.4),CORAL)
	for x in [-2.2,2.2]: box(world,Vector3(x,0.06,7.5),Vector3(0.07,0.02,2.2),GOLD)
	sign3d(world,"HOŞ GELDİNİZ",Vector3(0,0.1,8.5),24,CREAM)
	for x in [-10.4,10.4]:
		cylinder(world,Vector3(x,0.1,7.4),0.4,0.2,INK)
		cylinder(world,Vector3(x,1.1,7.4),0.05,2.1,GOLD)
		cylinder(world,Vector3(x,2.1,7.4),0.4,0.45,CREAM)
	ArtDetail.kitchen_details(self)
	build_roads()
	create_player()
	rebuild_navigation()

func build_large_floor():
	box(world,Vector3(0,-0.5,2),Vector3(65,0.8,53),Color("957758"))
	# Multimesh tiles keep the much larger map inexpensive to render.
	for tile_type in range(4):
		var points: Array = []
		for x in range(-32,32):
			for z in range(-24,28):
				var inside = absf(x+0.5)<12 and z<11 and z>-9
				var kind = (x+z+100)%2 + (0 if inside else 2)
				if kind == tile_type: points.append(Vector3(x+0.5,-0.02,z+0.5))
		var mesh = BoxMesh.new()
		mesh.size = Vector3(0.985,0.06,0.985)
		mesh.material = mat([Color("e8d7b5"),Color("dfcba5"),Color("91a88f"),Color("95ac92")][tile_type])
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh
		mm.instance_count = points.size()
		for i in range(points.size()): mm.set_instance_transform(i,Transform3D(Basis.IDENTITY,points[i]))
		var draw = MultiMeshInstance3D.new()
		draw.multimesh = mm
		draw.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		world.add_child(draw)
	for x in [-18,18]:
		box(world,Vector3(x,0.025,5),Vector3(5.5,0.02,43),Color("ccbfa0"))
	for z in [0,13,20]:
		box(world,Vector3(0,0.026,z),Vector3(60,0.025,3),Color("ccbfa0"))
	for x in range(-30,31,6):
		for z in [-22,26]:
			plant(Vector3(x,0,z))
			cylinder(world,Vector3(x,0.7,z),0.13,1.4,Color("846446"))
			sphere(world,Vector3(x,2.1,z),Vector3(2.3,2.4,2.1),TEAL)
	for z in range(-18,24,6):
		for x in [-30,30]: plant(Vector3(x,0,z))
	for z in [-24,28]: box(world,Vector3(0,0.22,z),Vector3(65,0.44,0.25),TEAL)
	for x in [-32,32]: box(world,Vector3(x,0.22,2),Vector3(0.25,0.44,52),TEAL)
	for x in [-24,24]:
		box(world,Vector3(x,0.45,19),Vector3(3,0.18,0.65),Color("a6744c"))
		box(world,Vector3(x,0.85,19.3),Vector3(3,0.8,0.12),TEAL)
	sign3d(world,"BAHÇE SALONU",Vector3(0,1,18),32,GOLD)

func update_camera(delta):
	if not running or paused or choosing or ended: return
	camera_focus = camera_focus.lerp(player.position,1-exp(-delta*6))
	camera.position = camera_focus+CAMERA_OFFSET
	# Camera size and angle stay fixed: travel reveals the map, never zooms out.

func is_walkable(pos, radius = 0.3):
	if pos.x<MAP_MIN.x+radius or pos.x>MAP_MAX.x-radius or pos.z<MAP_MIN.z+radius or pos.z>MAP_MAX.z-radius: return false
	for o in obstacles:
		if absf(pos.x-o.pos.x)<o.size.x*0.5+radius and absf(pos.z-o.pos.z)<o.size.z*0.5+radius: return false
	return true

func plant(pos):
	var p = ArtDetail.root_at(world,pos)
	cylinder(p,Vector3(0,.28,0),.35,.55,Color("b97554"))
	ring(p,.34,Color("d39973")).position.y = .52
	cylinder(p,Vector3(0,.54,0),.29,.04,Color("68543e"))
	for i in range(7):
		var angle = i*TAU/7
		var leaf = sphere(p,Vector3(cos(angle)*.22,.9,sin(angle)*.22),Vector3(.27,.93,.15),MINT if i%2 == 0 else TEAL)
		leaf.rotation.z = cos(angle)*.5
		ArtDetail.rod(self,p,Vector3.ZERO+Vector3(0,.5,0),Vector3(cos(angle)*.3,1.1,sin(angle)*.3),.016,Color("5c8060"))
		if i%2 == 0:
			for j in range(4): sphere(p,Vector3(cos(angle)*.3+cos(j*PI/2)*.07,1.21,sin(angle)*.3+sin(j*PI/2)*.07),Vector3(.12,.065,.12),CORAL)
			sphere(p,Vector3(cos(angle)*.3,1.24,sin(angle)*.3),Vector3.ONE*.08,GOLD)
	ArtDetail.bake(p,"flowerpot")

func make_table(pos, index):
	var root = Node3D.new()
	furniture.add_child(root)
	root.position = pos
	cylinder(root,Vector3(0,0.12,0),0.52,0.2,INK)
	cylinder(root,Vector3(0,0.65,0),0.13,1.1,INK)
	cylinder(root,Vector3(0,1.15,0),1.12,0.18,Color("a96d49"))
	cylinder(root,Vector3(0,1.26,0),1.04,0.05,CORAL if index%2 == 0 else MINT)
	cylinder(root,Vector3(0,1.31,-0.28),0.13,0.08,CREAM)
	sphere(root,Vector3(0,1.47,-0.28),Vector3(0.23,0.28,0.23),GOLD)
	for side in [-1,1]:
		var x = side*1.43
		box(root,Vector3(x,0.65,0),Vector3(0.68,0.18,0.7),TEAL)
		box(root,Vector3(x+side*0.29,1,0),Vector3(0.12,0.7,0.7),TEAL)
		for z in [-0.25,0.25]: box(root,Vector3(x,0.3,z),Vector3(0.12,0.6,0.1),Color("8c664e"))
	ArtDetail.table_details(self,root,index)
	solid(furniture,pos+Vector3(0,0.6,0),Vector3(2.15,1.3,2.15))
	var label = sign3d(root,"",Vector3(0,2.7,0),30)
	var food = FoodVisual.new()
	root.add_child(food)
	food.setup(index % 4)
	food.landed.connect(func(): action_fx.impact(pos+Vector3(0,1.35,0),CREAM))
	food.position = Vector3(0,1.32,0.15)
	food.visible = false
	var patience_bg = box(root,Vector3(0,2.14,0),Vector3(1.3,0.1,0.07),INK)
	var bar = box(root,Vector3(0,2.15,0.01),Vector3(1.25,0.11,0.08),MINT)
	patience_bg.visible = false
	bar.visible = false
	tables.append({"root":root,"pos":pos,"state":"empty","guest":null,"progress":0.0,"label":label,"food":food,"bar":bar,"bar_bg":patience_bg,"dirty_age":0.0,"dish":index%4,"eat_age":0.0,"eat_duration":4.0,"last_bite":0})

func build_roads():
	for o in obstacles.duplicate():
		if o.get("road",false):
			o.body.free()
			obstacles.erase(o)
	for child in road_root.get_children(): child.free()
	if not perks.has("boulevard"):
		for z in [-1.7,2.3]:
			box(road_root,Vector3(0,0.42,z),Vector3(1.25,0.84,1.7),TEAL)
			box(road_root,Vector3(0,0.86,z),Vector3(1.45,0.08,1.9),Color("a8c8a5"))
			for zz in [-0.55,0,0.55]: sphere(road_root,Vector3(0,1,z+zz),Vector3(0.85,0.45,0.5),MINT)
			solid(road_root,Vector3(0,0.5,z),Vector3(1.4,1.2,1.9))
			obstacles[-1]["road"] = true
	if perks.has("express"):
		for x in [-1.55,1.55]:
			box(road_root,Vector3(x,0.05,9.5),Vector3(1.1,0.04,28.0),Color("609d8c"))
			for z in range(-4,24,2):
				var a = box(road_root,Vector3(x-0.12,0.085,z),Vector3(0.08,0.02,0.4),GOLD)
				a.rotation.y = -0.6
				var b = box(road_root,Vector3(x+0.12,0.085,z),Vector3(0.08,0.02,0.4),GOLD)
				b.rotation.y = 0.6
	if perks.has("portal"):
		for x in [-23.0,23.0]:
			var r = ring(road_root,0.85,GOLD)
			r.position = Vector3(x,0.12,10)
			cylinder(road_root,Vector3(x,0.05,10),0.75,0.05,INK)
			sign3d(road_root,"TÜNEL",Vector3(x,1.1,10),24,GOLD)

func create_player():
	player = CharacterBody3D.new()
	player.name = "MouseChef"
	add_child(player)
	var c = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.4
	c.shape = shape
	c.position.y = 0.7
	player.add_child(c)
	mouse_model = animal(player,Color("a8a5a0"),CORAL,true)
	aura = ring(player,service_range,MINT)
	player.position = Vector3(-2.2,0,0)
	guide = sign3d(world,"",Vector3.ZERO,32,GOLD)

func animal(parent, fur, coat, chef = false, eye_override = ""):
	var n = Node3D.new()
	parent.add_child(n)
	sphere(n,Vector3(0,0.65,0),Vector3(0.75,0.95,0.65),coat)
	var head = Node3D.new()
	n.add_child(head)
	head.position = Vector3(0,1.22,0)
	sphere(head,Vector3(0,0.13,-0.04),Vector3(0.8,0.7,0.72),fur)
	var arms: Array = []
	var feet: Array = []
	var eyes: Array = []
	var ears: Array = []
	for x in [-0.39,0.39]:
		ears.append(sphere(head,Vector3(x,0.47,0),Vector3(0.48,0.52,0.2),fur))
		sphere(head,Vector3(x,0.47,-0.105),Vector3(0.29,0.33,0.035),Color("dfa6a0"))
		eyes.append(sphere(head,Vector3(x*0.52,0.19,-0.365),Vector3(0.09,0.12,0.06),INK))
		feet.append(sphere(n,Vector3(x*0.5,0.12,-0.1),Vector3(0.28,0.2,0.4),fur))
		var arm = Node3D.new()
		n.add_child(arm)
		arm.position = Vector3(x*1.03,0.96,-0.1)
		sphere(arm,Vector3(0,-0.21,0),Vector3(0.19,0.43,0.22),fur)
		arms.append(arm)
	var jaw = sphere(head,Vector3(0,-0.02,-0.39),Vector3(0.42,0.3,0.34),fur.lightened(0.2))
	sphere(head,Vector3(0,0.03,-0.57),Vector3(0.15,0.12,0.12),Color("d98b8f"))
	var spoon = Node3D.new()
	arms[1].add_child(spoon)
	box(spoon,Vector3(0,-0.47,-0.025),Vector3(0.045,0.30,0.045),CREAM)
	sphere(spoon,Vector3(0,-0.66,-0.025),Vector3(0.15,0.09,0.08),CREAM)
	var morsel = sphere(spoon,Vector3(0,-0.66,-0.07),Vector3(0.13,0.11,0.09),GOLD)
	spoon.visible = false
	for i in range(7):
		sphere(n,Vector3(sin(i*0.4)*0.2,0.25-i*0.025,0.3+i*0.13),Vector3(0.09,0.09,0.2),Color("d99da1"))
	if chef:
		var head_before = head.get_child_count()
		box(n,Vector3(0,0.69,-0.326),Vector3(0.43,0.6,0.05),CREAM)
		cylinder(head,Vector3(0,0.55,0),0.28,0.2,CREAM)
		for x in [-0.17,0,0.17]: sphere(head,Vector3(x,0.74,0),Vector3(0.34,0.33,0.4),CREAM)
		box(n,Vector3(0,1,-0.34),Vector3(0.25,0.1,0.1),GOLD)
		n.set_meta("chef_hat",head.get_children().slice(head_before))
	var mouth = sphere(head,Vector3(0,-.105,-.552),Vector3(.16,.018,.04),INK)
	mouth.visible = false
	n.set_meta("rig",{"head":head,"arms":arms,"jaw":jaw,"spoon":spoon,"morsel":morsel,"feet":feet,"eyes":eyes,"ears":ears,"mouth":mouth})
	if chef:
		var pad = box(arms[0],Vector3(0,-0.45,-0.07),Vector3(0.29,0.36,0.04),CREAM)
		pad.visible = false
		var sponge = box(arms[1],Vector3(0,-0.44,-0.1),Vector3(0.3,0.13,0.19),MINT)
		sponge.visible = false
		n.get_meta("rig")["pad"] = pad
		n.get_meta("rig")["sponge"] = sponge
		var knife = ArtDetail.root_at(arms[1])
		box(knife,Vector3(0,-.49,-.04),Vector3(.10,.19,.09),Color("925c3f"))
		box(knife,Vector3(0,-.75,-.04),Vector3(.11,.36,.035),CREAM)
		ArtDetail.bake(knife,"held_knife")
		knife.visible = false
		var soda = ArtDetail.root_at(arms[1])
		cylinder(soda,Vector3(0,-.47,-.08),.075,.26,MINT)
		cylinder(soda,Vector3(0,-.3,-.08),.04,.10,CREAM)
		ArtDetail.bake(soda,"held_soda")
		soda.visible = false
		n.get_meta("rig")["knife"] = knife
		n.get_meta("rig")["soda"] = soda
	ArtDetail.tailoring(self,n,coat)
	if not chef: ArtDetail.face(self,n,fur,eye_override if eye_override != "" else ["round","sharp","sleepy","oval"][guests.size()%4])
	return n

func reset_animal_pose(model):
	var rig = model.get_meta("rig")
	rig.head.rotation = Vector3.ZERO
	rig.jaw.scale = Vector3(0.42,0.3,0.34)
	for arm in rig.arms: arm.rotation = Vector3.ZERO
	rig.spoon.visible = false
	rig.mouth.visible = false
	for foot in rig.feet: foot.position.y = .12
	model.rotation.z = 0
	if rig.has("pad"):
		rig.pad.visible = false
		rig.sponge.visible = false
		rig.knife.visible = false
		rig.soda.visible = false
	model.position.y = 0

func animate_eating(g, t):
	var rig = g.model.get_meta("rig")
	var cycle = fmod(t.eat_age,0.95)/0.95
	var lift = smoothstep(0.10,0.46,cycle)*(1-smoothstep(0.68,0.97,cycle))
	rig.arms[1].rotation.x = lerpf(0.7,2.05,lift)
	rig.arms[1].rotation.z = -0.55*lift
	rig.arms[0].rotation.x = 0.6
	rig.head.rotation.x = 0.08+sin(cycle*TAU)*0.1
	rig.head.rotation.z = sin(t.eat_age*2)*0.035
	var chew = maxf(0,sin((cycle-0.5)*TAU*5)) if cycle>0.5 and cycle<0.88 else 0.0
	rig.jaw.scale = Vector3(0.42+chew*0.045,0.3-chew*0.035,0.34)
	rig.mouth.visible = chew>0
	rig.mouth.scale.y = .018+chew*.045
	for i in range(rig.feet.size()): rig.feet[i].position.y = .12+maxf(0,sin(t.eat_age*5+i))*.03
	rig.spoon.visible = true
	rig.morsel.visible = cycle>0.12 and cycle<0.6
	rig.morsel.material_override.albedo_color = [Color("dba64d"),Color("efba51"),Color("e69a42"),GOLD][t.dish]
	g.model.position.y = 0.08+sin(cycle*TAU)*0.025
	var bite = int((t.eat_age+0.35)/0.95)
	if bite > t.last_bite:
		t.last_bite = bite
		puff(g.model.to_global(Vector3(0,1.2,-0.55)),GOLD)

func celebrate_power(id):
	var category = "FARE"
	for perk in PERKS:
		if perk[0] == id: category = perk[1]
	var tint = {"FARE":GOLD,"RESTORAN":MINT,"MÜŞTERİ":CORAL,"YOL":Color("a7b5e4"),"SAVAŞ":Color("bdacec")}[category]
	var fx = PowerEffect.new()
	player.add_child(fx)
	fx.setup(tint)
	power_effects.append(fx)
	power_time = 1.5
	floating_text("+",player.position+Vector3(0,2.7,0),tint)

func animate_power(delta):
	for fx in power_effects.duplicate():
		if fx.advance(delta):
			fx.queue_free()
			power_effects.erase(fx)
	if power_time<=0: return
	power_time = maxf(0,power_time-delta)
	var t = 1.5-power_time
	var bounce = sin(minf(t/0.65,1)*PI)
	mouse_model.scale = Vector3(1-bounce*0.08,1+bounce*0.15,1-bounce*0.08)
	mouse_model.position.y = maxf(mouse_model.position.y,bounce*0.45)
	var rig = mouse_model.get_meta("rig")
	rig.arms[0].rotation.z = -bounce*2.4
	rig.arms[1].rotation.z = bounce*2.4
	rig.head.rotation.z = sin(t*10)*0.1*(power_time/1.5)
	if power_time<=0:
		mouse_model.scale = Vector3.ONE
		reset_animal_pose(mouse_model)

func rebuild_navigation():
	astar.region = Rect2i(-63,-47,127,103)
	astar.cell_size = Vector2(0.5,0.5)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for o in obstacles:
		for x in range(floori((o.pos.x-o.size.x*0.5-0.3)*2),ceili((o.pos.x+o.size.x*0.5+0.3)*2)+1):
			for z in range(floori((o.pos.z-o.size.z*0.5-0.3)*2),ceili((o.pos.z+o.size.z*0.5+0.3)*2)+1):
				var cell = Vector2i(x,z)
				if astar.is_in_boundsv(cell) and not is_walkable(Vector3(x*0.5,0,z*0.5),0.28): astar.set_point_solid(cell)

func nearest_free_cell(point):
	var cell = Vector2i(roundi(point.x*2),roundi(point.z*2))
	cell.x = clampi(cell.x,-63,63)
	cell.y = clampi(cell.y,-47,55)
	if not astar.is_point_solid(cell): return cell
	for radius in range(1,8):
		for dx in range(-radius,radius+1):
			for dz in range(-radius,radius+1):
				var p = cell+Vector2i(dx,dz)
				if astar.is_in_boundsv(p) and not astar.is_point_solid(p): return p
	return cell

func path_between(from: Vector3, to: Vector3):
	var a = nearest_free_cell(from)
	var b = nearest_free_cell(to)
	var result: Array = []
	for p in astar.get_point_path(a,b): result.append(Vector3(p.x,0,p.y))
	return result

func style(bg, border = Color.TRANSPARENT, radius = 16):
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 15
	s.content_margin_bottom = 15
	return s

func panel(parent, pos, size, bg = INK):
	var p = Panel.new()
	parent.add_child(p)
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel",style(bg,Color(1,1,1,0.12)))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p

func label(parent, value, pos, font_size = 20, color = CREAM, width = 0):
	var l = Label.new()
	parent.add_child(l)
	l.position = pos
	l.text = value
	l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if width > 0:
		l.size.x = width
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func button(parent, value, pos, size, callback, color = TEAL):
	var b = Button.new()
	parent.add_child(b)
	b.position = pos
	b.size = size
	b.text = value
	b.add_theme_font_size_override("font_size",20)
	b.add_theme_color_override("font_color",CREAM)
	b.add_theme_stylebox_override("normal",style(color,color.lightened(0.15),12))
	b.add_theme_stylebox_override("hover",style(color.lightened(0.12),GOLD,12))
	b.add_theme_stylebox_override("pressed",style(color.darkened(0.1),GOLD,12))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(callback)
	return b

func bar(parent, pos, size, color):
	var b = ProgressBar.new()
	parent.add_child(b)
	b.position = pos
	b.size = size
	b.show_percentage = false
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background_style = style(Color("102e33"),Color.TRANSPARENT,5)
	var fill_style = style(color,Color.TRANSPARENT,5)
	for sb in [background_style,fill_style]:
		sb.content_margin_top = 0
		sb.content_margin_bottom = 0
		sb.content_margin_left = 0
		sb.content_margin_right = 0
	b.add_theme_stylebox_override("background",background_style)
	b.add_theme_stylebox_override("fill",fill_style)
	# Reset after removing the default percentage label minimum height.
	b.size = size
	return b

func build_ui():
	canvas = CanvasLayer.new()
	add_child(canvas)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	var top = panel(hud,Vector2(24,20),Vector2(1392,90))
	label(top,"MIK MIK",Vector2(24,9),34,GOLD)
	label(top,"MINIK PATILER. BÜYÜK SERVIS.",Vector2(26,54),11,MINT)
	wave_label = label(top,"01 / 06   ÖĞLE VARDİYASI",Vector2(320,13),19)
	time_label = label(top,"01:00",Vector2(660,10),27,GOLD)
	clock_bar = bar(top,Vector2(320,53),Vector2(405,6),CORAL)
	rep_label = label(top,"İTİBAR  100",Vector2(790,17),17)
	rep_bar = bar(top,Vector2(790,51),Vector2(170,7),MINT)
	money_label = label(top,"0  ALTIN",Vector2(1010,20),25,GOLD)
	button(top,"Ⅱ",Vector2(1240,20),Vector2(48,48),toggle_pause)
	button(top,"♪",Vector2(1300,20),Vector2(48,48),toggle_audio)
	var tip = panel(hud,Vector2(24,129),Vector2(260,152),Color("20494b"))
	label(tip,"SERVİSİN RİTMİ",Vector2(18,13),13,GOLD)
	help_label = label(tip,"1  Masaya yaklaş → sipariş\n2  Mutfağa yaklaş → tabak\n3  Masaya dön → servis\n4  Boş masaya yaklaş → temizle",Vector2(18,41),15,CREAM)
	var build = panel(hud,Vector2(1180,129),Vector2(236,134),Color("20494b"))
	label(build,"BU KOŞUNUN TARİFİ",Vector2(16,12),12,GOLD)
	build_label = label(build,"Fare şef · Seviye 1\nKlasik salon\nMahalle müşterileri",Vector2(16,40),15,CREAM,205)
	var combat_panel = panel(hud,Vector2(1180,279),Vector2(236,198),Color("20494b"))
	health_label = label(combat_panel,"ŞEF CANI  100",Vector2(16,12),16,CORAL)
	health_bar = bar(combat_panel,Vector2(16,44),Vector2(204,7),CORAL)
	combat_label = label(combat_panel,"Soda savunması · OTOMATİK\nCanavarlar yaklaşıyor…",Vector2(16,67),13,CREAM)
	combat_xp_label = label(combat_panel,"SAVAŞ · SV 1",Vector2(16,108),12,Color("bdacec"))
	combat_xp_bar = bar(combat_panel,Vector2(16,132),Vector2(204,7),Color("bdacec"))
	weapon_label = label(combat_panel,"Soda I",Vector2(16,151),13,CREAM,208)
	var bottom = panel(hud,Vector2(300,786),Vector2(840,90))
	label(bottom,"W A S D",Vector2(22,14),23,GOLD)
	label(bottom,"HAREKET",Vector2(24,52),11,MINT)
	dash_label = label(bottom,"SPACE  /  DASH",Vector2(190,15),17)
	dash_bar = bar(bottom,Vector2(190,54),Vector2(150,5),GOLD)
	tray_label = label(bottom,"TEPSİ  0 / 2",Vector2(385,14),21)
	status_label = label(bottom,"Otomatik servis hazır",Vector2(385,48),13,MINT)
	kitchen_xp_label = label(bottom,"MUTFAK · SV 1",Vector2(652,16),11,GOLD)
	xp_bar = bar(bottom,Vector2(652,49),Vector2(158,7),MINT)
	toast_label = label(hud,"",Vector2(300,733),21,CREAM)
	toast_label.size = Vector2(840,35)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal = Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(modal)
	for old_panel in hud.get_children(): old_panel.visible = false
	compact_hud = preload("res://scripts/compact_hud.gd").new()
	hud.add_child(compact_hud)
	compact_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	compact_hud.game = self
	achievement_banner = label(hud,"",Vector2(410,168),20,GOLD)
	achievement_banner.size = Vector2(620,32)
	achievement_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_banner.add_theme_stylebox_override("normal",style(INK,GOLD,8))
	achievement_banner.visible = false
	button(hud,"Ⅱ",Vector2(1314,24),Vector2(44,44),toggle_pause)
	button(hud,"♪",Vector2(1366,24),Vector2(44,44),toggle_audio)
	update_hud()

func clear_modal():
	for child in modal.get_children(): child.queue_free()
	modal.visible = true

func veil(alpha = 0.7):
	var c = ColorRect.new()
	c.color = Color(0.035,0.105,0.115,alpha)
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(c)

func show_title():
	profile_menu.show_page("crew")

func apply_starting_build():
	if run_initialized: return
	run_initialized = true
	run_difficulty = profile.DIFFICULTIES[profile.difficulty].duplicate()
	max_health += 8*profile.training.get("health",0)
	speed *= 1+0.03*profile.training.get("speed",0)
	monsters.power *= 1+0.05*profile.training.get("damage",0)
	cook_rate *= 1+0.05*profile.training.get("cook",0)
	clean_rate *= 1+0.05*profile.training.get("clean",0)
	match profile.character:
		"zip":
			speed *= 1.15
			capacity += 1
		"tok":
			max_health += 24
			monsters.power *= 1.15
			speed *= .92
		"nane":
			cook_rate *= 1.25
			clean_rate *= 1.2
	health = max_health
	var old = mouse_model
	player.remove_child(old)
	old.queue_free()
	mouse_model = animal(player,profile.fur,profile.cloth,true)
	profile.dress(mouse_model)
	profile.record("wave",1)
	profile.save_profile()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST and profile != null: profile.save_profile()

func start_run():
	if running or ended: return
	apply_starting_build()
	for child in modal.get_children(): child.queue_free()
	modal.visible = false
	hud.visible = true
	running = true
	paused = false
	choosing = false
	title_intro = false
	toast("İlk sipariş yolda. Masadaki … işaretine yaklaş!")

func _physics_process(delta):
	if not running or paused or choosing or ended: return
	var input = Input.get_vector("left","right","up","down")
	var dir = Vector3(input.x,0,input.y)
	dash_left = maxf(0,dash_left-delta)
	portal_cd = maxf(0,portal_cd-delta)
	hurt_left = maxf(0,hurt_left-delta)
	mouse_model.visible = hurt_left<=0 or int(hurt_left*18)%2 == 0
	if dir.length() > 0.1: facing = dir.normalized()
	if Input.is_action_just_pressed("dash") and dash_left <= 0:
		dash_time = 0.2
		dash_left = dash_cooldown
		dash_dir = facing
		tone(660,0.08,0.08)
	var move_speed = speed
	if perks.has("express") and absf(absf(player.position.x)-1.55)<0.7 and absf(player.position.z-9.5)<14.0: move_speed *= 1.45
	if dash_time > 0:
		dash_time -= delta
		dir = dash_dir
		move_speed *= 3.0
		if Engine.get_physics_frames()%3 == 0: puff(player.position+Vector3(0,0.4,0),GOLD)
	player.velocity = dir*move_speed
	player.move_and_slide()
	player.position.y = 0
	player.position.x = clampf(player.position.x,MAP_MIN.x+0.6,MAP_MAX.x-0.6)
	player.position.z = clampf(player.position.z,MAP_MIN.z+0.6,MAP_MAX.z-0.6)
	if dir.length()>0.1:
		mouse_model.rotation.y = lerp_angle(mouse_model.rotation.y,atan2(-dir.x,-dir.z),delta*15)
		mouse_model.position.y = absf(sin(elapsed*15))*0.08
		var rig = mouse_model.get_meta("rig")
		for i in range(2): rig.feet[i].position.z = -0.1+sin(elapsed*15+i*PI)*0.16
	else: mouse_model.position.y = 0
	if perks.has("portal") and portal_cd <= 0:
		for x in [-23.0,23.0]:
			if player.position.distance_to(Vector3(x,0,10))<0.85:
				player.position = Vector3(-x,0,10)
				portal_cd = 2.5
				puff(player.position+Vector3(0,1,0),GOLD)
				break

func _process(delta):
	if running and not paused and not choosing:
		achievement_left = maxf(0,achievement_left-delta)
		if achievement_left<=0 and not profile.notices.is_empty():
			achievement_banner.text = "★  " + profile.notices.pop_front()
			achievement_left = 3.5
		achievement_banner.visible = achievement_left>0
	var active = running and not paused and not choosing and not ended
	var visual_delta = delta if active else 0.0
	elapsed += visual_delta
	if action_fx != null: action_fx.advance(visual_delta)
	for p in particles.duplicate():
		p.life -= visual_delta
		p.node.position.y += visual_delta*1.2
		p.node.scale *= maxf(0,1-visual_delta*2)
		if p.life <= 0:
			p.node.queue_free()
			particles.erase(p)
	if toast_time > 0:
		toast_time -= visual_delta
		toast_label.modulate.a = minf(1,toast_time)
	if running and not paused and not choosing and not ended:
		tick_game(delta)
		if not choosing and not ended:
			animate_strike(delta)
			animate_power(delta)
		update_camera(delta)
		update_hud()
	if indicators != null: indicators.refresh()
	if capture_mode:
		capture_frames += 1
		if capture_frames == (420 if capture_kind == "gameplay" else 150):
			get_viewport().get_texture().get_image().save_png("res://captures/%s.png" % capture_kind)
			get_tree().quit()

func tick_game(delta):
	wave_time = maxf(0,wave_time-delta)
	spawn_timer -= delta
	if spawn_timer <= 0 and wave_time > 5:
		spawn_guest()
		spawn_timer = maxf(2.7,7.5-wave*0.65)+rng.randf_range(-0.5,1)
	update_guests(delta)
	update_orders(delta)
	update_tables(delta)
	auto_service(delta)
	monsters.update(delta)
	if health <= 0 or rep <= 0: finish_run(false)
	elif not progression_queue.is_empty():
		var source = progression_queue.pop_front()
		if source == "kitchen": pending_levels = maxi(0,pending_levels-1)
		show_upgrades(false,source)
	elif wave_time <= 0:
		if wave == 6:
			if monsters.boss_defeated: finish_run(true)
			else: status_label.text = "Son görev: Kazan Kıran’ı yen!"
		else: show_upgrades(true)

func spawn_guest():
	if guests.size() >= 12: return
	var kind = "normal"
	var types = ["normal"]
	for id in ["vip","student","regular"]:
		if perks.has(id): types.append(id)
	kind = types[rng.randi_range(0,types.size()-1)]
	var coat = {"normal":Color("6d939e"),"vip":GOLD,"student":Color("b7a1c9"),"regular":MINT}[kind]
	var node = Node3D.new()
	world.add_child(node)
	node.position = Vector3(rng.randf_range(-0.5,0.5),0,7.7)
	var model = animal(node,Color("c4ad91"),coat)
	model.scale = Vector3.ONE*0.85
	if kind == "vip": cylinder(model,Vector3(0,1.85,0),0.28,0.18,INK)
	if kind == "student": box(model,Vector3(0,1.77,0),Vector3(0.65,0.12,0.65),Color("77609c"))
	var base_patience = maxf(48,82-wave*4.0)*patience_mult
	if kind == "vip": base_patience *= 0.8
	if kind == "student": base_patience *= 1.7
	var g = {"node":node,"model":model,"kind":kind,"state":"queue","path":[],"table":-1,"patience":base_patience,"max_patience":base_patience,"seat_wait":0.0,"dish":rng.randi_range(0,3)}
	guests.append(g)

func seat_position(t):
	return t.pos+Vector3(-1.6 if t.pos.x<0 else 1.6,0,0)

func assign_table(g):
	for i in range(tables.size()):
		var t = tables[i]
		if t.state != "empty": continue
		t.state = "arriving"
		t.guest = g
		set_table_dish(t,g.dish)
		g.table = i
		g.state = "walking"
		g.path = path_between(g.node.position,seat_position(t))
		return true
	return false

func update_guests(delta):
	for g in guests.duplicate():
		if g.get("pay_left",0)>0:
			g.pay_left = maxf(0,g.pay_left-delta)
			var rig = g.model.get_meta("rig")
			var reach = sin((.6-g.pay_left)/.6*PI)
			rig.arms[1].rotation.x = 1.3*reach
			rig.head.rotation.x = .15*reach
			if g.pay_left<=0:
				reset_animal_pose(g.model)
				g.node.position.y = 0
			continue
		if g.state == "queue":
			if not assign_table(g):
				g.patience -= delta*0.5
				g.seat_wait += delta
				animate_waiting(g,delta)
				g.node.position.x = sin(g.seat_wait)*0.25 + (guests.find(g)%4-1.5)*0.8
				if g.patience <= 0: lose_guest(g)
		elif g.state == "walking" or g.state == "leaving":
			if g.path.size()>0:
				var target = g.path[0]
				var dir = target-g.node.position
				if dir.length()<0.1: g.path.pop_front()
				else:
					g.node.position = g.node.position.move_toward(target,delta*2.8)
					g.model.rotation.y = lerp_angle(g.model.rotation.y,atan2(-dir.x,-dir.z),delta*12)
					g.model.position.y = absf(sin(elapsed*12))*0.045
					var walk = g.model.get_meta("rig")
					for i in range(2):
						walk.feet[i].position.y = .12+maxf(0,sin(elapsed*12+i*PI))*.08
						walk.arms[i].rotation.x = sin(elapsed*12+i*PI)*.2
			else:
				if g.state == "leaving":
					g.node.queue_free()
					guests.erase(g)
				else:
					reset_animal_pose(g.model)
					g.state = "seated"
					g.model.rotation.y = -PI/2 if tables[g.table].pos.x<0 else PI/2
					g.node.position.y = 0.28
					tables[g.table].state = "order"
		elif g.state == "seated":
			var t = tables[g.table]
			if t.state in ["order","cooking","ready"]:
				g.patience -= delta
				animate_waiting(g,delta)
				if g.patience <= 0: lose_guest(g)

func lose_guest(g):
	rep = maxf(0,rep-12)
	missed += 1
	if g.table >= 0:
		var t = tables[g.table]
		t.state = "dirty"
		t.progress = 0.0
		t.dirty_age = 0.0
		t.guest = null
		remove_order(g.table)
		carried.erase(g.table)
	reset_animal_pose(g.model)
	g.node.position.y = 0
	g.state = "leaving"
	g.path = path_between(g.node.position,Vector3(0,0,8))
	toast("Bir müşteri beklemekten yoruldu. İtibar −12")
	tone(130,0.17,0.08)

func update_orders(delta):
	for o in orders:
		if o.remaining > 0:
			o.remaining -= delta*cook_rate
			if o.remaining <= 0:
				tables[o.table].state = "ready"
		o.visual.visible = o.remaining<=0 and not carried.has(o.table)
		if o.visual.visible: o.visual.advance(delta)
	var ready_count = orders.filter(func(o): return o.remaining <= 0 and not carried.has(o.table)).size()
	kitchen_label.visible = false
	kitchen_label.modulate = GOLD if ready_count > 0 else CREAM

func update_tables(delta):
	for i in range(tables.size()):
		var t = tables[i]
		t.label.visible = false
		t.label.modulate = GOLD if t.state in ["order","ready"] else (CORAL if t.state == "dirty" else CREAM)
		t.bar.visible = t.guest != null and t.state in ["order","cooking","ready"]
		t.bar_bg.visible = t.bar.visible
		if t.bar.visible:
			var ratio = clampf(t.guest.patience/t.guest.max_patience,0.01,1)
			t.bar.scale.x = ratio
			t.bar.material_override.albedo_color = MINT if ratio>0.4 else RED
		if t.state == "eating":
			t.progress -= delta
			t.eat_age += delta
			t.food.advance(delta,maxf(0,t.progress/t.eat_duration))
			if not t.food.flying: animate_eating(t.guest,t)
			if t.progress <= 0: complete_meal(i)
		if t.state == "dirty":
			t.food.advance(delta,0,false)
			t.dirty_age += delta
			if perks.has("robot") and t.dirty_age >= 7: clean_table(t)
		t.food.visible = t.state in ["eating","dirty"]

func auto_service(delta):
	if action_pose != "" and power_time<=0:
		reset_animal_pose(mouse_model)
		mouse_model.rotation.z = 0
	action_pose = ""
	gesture_left = maxf(0,gesture_left-delta)
	if gesture_left>0: animate_action(gesture_kind)
	status_label.text = "Yaklaşınca her şey otomatik"
	var at_kitchen = player.position.distance_to(Vector3(0,0,-4.5)) < service_range+1.4
	if at_kitchen or perks.has("belt"):
		for o in orders:
			if o.remaining <= 0 and not carried.has(o.table) and carried.size()<capacity:
				carried.append(o.table)
				gesture_left = 0.45
				gesture_kind = "ready"
				animate_action("ready")
				puff(player.position+Vector3(0,1.7,0),GOLD)
				tone(540,0.07,0.05)
		for o in orders:
			if o.remaining>0 and at_kitchen: status_label.text = "Mutfakta yemekler hazırlanıyor…"
	for i in range(tables.size()):
		var t = tables[i]
		if player.position.distance_to(t.pos)>service_range: continue
		if t.state == "order":
			t.progress += delta*work_rate
			animate_action("order")
			status_label.text = "Sipariş alınıyor  %%%d" % mini(100,int(t.progress/0.65*100))
			if t.progress >= 0.65:
				t.state = "cooking"
				t.progress = 0.0
				create_order(i)
				tone(440,0.06,0.04)
		elif t.state == "ready" and carried.has(i):
			gesture_left = 0.45
			gesture_kind = "ready"
			animate_action("ready")
			carried.erase(i)
			remove_order(i)
			t.state = "eating"
			t.progress = 2.5 if t.guest.kind == "regular" else 4.0
			t.eat_duration = t.progress
			t.eat_age = 0
			t.last_bite = 0
			t.food.visible = true
			reset_animal_pose(t.guest.model)
			t.food.serve_from(t.root.to_local(player.position+Vector3(0.5,1.3,-0.4)))
			monsters.service_burst(t.pos)
			status_label.text = "Afiyet olsun!"
			puff(t.pos+Vector3(0,1.4,0),MINT)
			tone(780,0.1,0.05)
		elif t.state == "dirty":
			t.progress += delta*clean_rate
			animate_action("dirty")
			status_label.text = "Masa temizleniyor  %%%d" % mini(100,int(t.progress/0.85*100))
			if t.progress >= 0.85: clean_table(t)
	update_tray_visual()
	update_guide()

func update_guide():
	guide.visible = false

func animate_action(kind):
	action_pose = kind
	if power_time>0: return
	var rig = mouse_model.get_meta("rig")
	rig.knife.visible = false
	rig.soda.visible = false
	if kind in ["ready","collect"]:
		var reach = sin(clampf(1-gesture_left/.45,0,1)*PI)
		rig.arms[0].rotation.x = .8+reach*.45
		rig.arms[1].rotation.x = 1.1+reach*.6
		rig.head.rotation.x = .18*reach
		rig.pad.visible = false
		rig.sponge.visible = false
		return
	rig.pad.visible = kind == "order"
	rig.sponge.visible = kind == "dirty"
	var arms = rig.arms
	arms[0].rotation.x = -0.9 if kind == "order" else -0.4
	arms[1].rotation.x = -1.1+sin(elapsed*18)*0.35
	arms[1].rotation.z = sin(elapsed*13)*0.4 if kind == "dirty" else -0.3
	mouse_model.get_meta("rig").head.rotation.x = 0.12+sin(elapsed*10)*0.06
	if kind == "dirty": mouse_model.rotation.z = sin(elapsed*12)*0.09

func complete_meal(i):
	var t = tables[i]
	var g = t.guest
	if g == null: return
	var tip = int((12+wave*2)*(3 if g.kind == "vip" else 1)*tip_mult)
	money += tip
	served += 1
	profile.record("served")
	add_xp(3 if g.kind == "student" else 2)
	health = minf(max_health,health+4)
	rep = minf(100,rep+(6 if g.kind == "regular" else 1))
	reset_animal_pose(g.model)
	var coin_at = t.pos+Vector3(-.65 if t.pos.x<0 else .65,1.4,.45)
	action_fx.tip(coin_at,g.model.get_meta("rig").arms[1].to_global(Vector3(0,-.38,0)),tip)
	g.pay_left = .6
	g.state = "leaving"
	g.path = path_between(g.node.position,Vector3(0,0,8))
	t.guest = null
	t.state = "dirty"
	t.progress = 0.0
	t.dirty_age = 0.0

func add_xp(amount):
	xp += amount
	while xp >= next_xp:
		xp -= next_xp
		level += 1
		next_xp += 3
		pending_levels += 1
		progression_queue.append("kitchen")

func add_combat_xp(amount):
	combat_xp += amount
	while combat_xp>=next_combat_xp:
		combat_xp -= next_combat_xp
		combat_level += 1
		next_combat_xp += 6
		progression_queue.append("combat")

func damage_chef(amount):
	if dash_time>0 or hurt_left>0 or ended: return
	health = maxf(0,health-amount)
	hurt_left = 0.95
	action_fx.impact(player.position+Vector3(0,1.2,0),CORAL)
	floating_text("−%d" % int(amount),player.position+Vector3(0,2.1,0),CORAL)
	tone(150,0.1,0.05)

func clean_table(t):
	t.state = "empty"
	t.progress = 0.0
	t.food.visible = false
	t.food.flying = false
	t.food.position = Vector3(0,1.32,0.15)
	puff(t.pos+Vector3(0,1.5,0),CREAM)

func set_table_dish(t, kind):
	var previous = t.food
	t.root.remove_child(previous)
	previous.queue_free()
	t.dish = kind
	t.food = FoodVisual.new()
	t.root.add_child(t.food)
	t.food.setup(kind)
	t.food.landed.connect(func(): action_fx.impact(t.pos+Vector3(0,1.35,0),CREAM))
	t.food.position = Vector3(0,1.32,0.15)
	t.food.visible = false

func create_order(i):
	var dish = FoodVisual.new()
	world.add_child(dish)
	dish.setup(tables[i].dish)
	dish.position = Vector3(-3.1+(i%6)*1.22,1.51,-5.23-int(i/6)*0.6)
	dish.scale = Vector3.ONE*0.7
	dish.visible = false
	orders.append({"table":i,"remaining":4.5,"visual":dish})

func remove_order(i):
	for o in orders.duplicate():
		if o.table == i:
			o.visual.queue_free()
			orders.erase(o)

func update_tray_visual():
	var old = mouse_model.get_node_or_null("Tray")
	# Compare identities, not only count: a pickup/delivery can replace a dish.
	if old != null and old.get_meta("ids") == carried: return
	if old != null:
		mouse_model.remove_child(old)
		old.queue_free()
	var tray = Node3D.new()
	tray.name = "Tray"
	tray.set_meta("ids",carried.duplicate())
	mouse_model.add_child(tray)
	for i in range(carried.size()):
		var dish = FoodVisual.new()
		tray.add_child(dish)
		dish.setup(tables[carried[i]].dish)
		dish.scale = Vector3.ONE*0.48
		dish.position = Vector3(0.46+(i%2)*0.51,1.03+int(i/2)*0.30,-0.44)
		dish.advance(0,1,false)

func update_hud():
	if compact_hud != null: compact_hud.queue_redraw()

func perk_allowed(id):
	var data = PERKS.filter(func(p): return p[0] == id)
	if data.is_empty(): return false
	if perks.get(id,0) >= (1 if id in SINGLE_ITEMS else 4): return false
	if id in ["robot","belt"]:
		return perks.get("clean" if id == "robot" else "capacity",0) == 4
	var slots = combat_slots if data[0][1] == "SAVAŞ" else kitchen_slots
	return slots.has(id) or slots.size()<SLOT_LIMIT

func available_perks(category = "", source = "kitchen"):
	var result: Array = []
	var slots = combat_slots if source == "combat" else kitchen_slots
	for p in PERKS:
		if (p[1] == "SAVAŞ") != (source == "combat"): continue
		if not perk_allowed(p[0]): continue
		if p[0] in ["robot","belt"]:
			if not evolution_offered.has(p[0]): result.append(p)
			continue
		if category != "" and p[1] != category: continue
		if slots.size()<SLOT_LIMIT and perks.has(p[0]): continue
		result.append(p)
	return result

func show_upgrades(between_waves, source = "kitchen"):
	upgrade_source = source
	choosing = true
	next_wave_pending = between_waves
	clear_modal()
	veil(0.85)
	label(modal,"SAVAŞ DENEYİMİ" if source == "combat" else "MUTFAK DENEYİMİ",Vector2(155,137),15,MINT)
	label(modal,"Cephaneliğini büyüt." if source == "combat" else "Yeni bir tarif seç.",Vector2(150,171),52,CREAM)
	var subtitle = "Vardiya %d tamamlandı. Bir yükseltme seç; sonraki dalgaya geç." % wave if between_waves else "Seviye %d! Koşunun tarifini değiştir. Bir yükseltme seç." % level
	if source == "combat": subtitle = "Savaş seviyesi %d! Canavarlardan kazandığın XP ile silah seç." % combat_level
	label(modal,subtitle,Vector2(155,247),20,Color("b9d0c4"))
	offers.clear()
	var pool = available_perks("",source)
	for p in pool:
		if p[0] in ["robot","belt"]:
			offers.append(p)
			evolution_offered[p[0]] = true
	pool = pool.filter(func(p): return not offers.has(p))
	while offers.size()<3 and not pool.is_empty():
		var pick = rng.randi_range(0,pool.size()-1)
		offers.append(pool.pop_at(pick))
	if source == "combat" and combat_level == 2 and combat_slots.size() == 1:
		offers = PERKS.filter(func(p): return p[0] in ["knife","pan","pepper"])
	if offers.is_empty():
		button(modal,"TARİF TAMAMLANDI · DEVAM →",Vector2(480,430),Vector2(480,80),resume_after_upgrade)
	for i in range(offers.size()):
		var p = offers[i]
		var color = {"FARE":CORAL,"RESTORAN":MINT,"MÜŞTERİ":GOLD,"YOL":Color("a7b5e4"),"SAVAŞ":Color("bdacec")}[p[1]]
		var card = panel(modal,Vector2(155+i*383,317),Vector2(363,368),Color("224b4c"))
		label(card,p[1],Vector2(24,23),14,color)
		var icon = preload("res://scripts/item_icon.gd").new()
		card.add_child(icon)
		icon.position = Vector2(24,62)
		icon.size = Vector2(70,70)
		icon.icon_id = p[0]
		label(card,"EVRİM · TEK FIRSAT" if p[0] in ["robot","belt"] else ("YENİ" if not perks.has(p[0]) else "%d / 4" % (perks[p[0]]+1)),Vector2(112,85),17,color)
		label(card,p[2],Vector2(24,147),27,CREAM)
		label(card,p[3],Vector2(24,197),17,Color("c0d5c7"),317)
		button(card,"SEÇ    +",Vector2(24,290),Vector2(315,55),func(): choose_perk(i),TEAL)
	label(modal,"SEÇİM SIRASINDA ZAMAN DURUR.  /  YÜKSELTMELER BU KOŞU BOYUNCA KALIR.",Vector2(155,723),12,MINT)

func choose_perk(index):
	if not choosing or index < 0 or index >= offers.size(): return
	apply_perk(offers[index][0])
	toast(offers[index][2]+" tarifine eklendi!")
	tone(880,0.15,0.08)
	resume_after_upgrade()

func resume_after_upgrade():
	choosing = false
	modal.visible = false
	if next_wave_pending:
		wave += 1
		profile.record("wave",wave)
		wave_duration = 60.0 + (wave-1)*5
		wave_time = wave_duration
		spawn_timer = 1.0
		rep = minf(100,rep+10)
		next_wave_pending = false
	update_hud()

func apply_perk(id):
	if not perk_allowed(id): return
	var slots = combat_slots if PERKS.filter(func(p): return p[0] == id)[0][1] == "SAVAŞ" else kitchen_slots
	if id in ["robot","belt"]:
		var base = "clean" if id == "robot" else "capacity"
		slots[slots.find(base)] = id
	elif not slots.has(id): slots.append(id)
	perks[id] = perks.get(id,0)+1
	celebrate_power(id)
	match id:
		"speed": speed *= 1.18
		"range":
			service_range += 0.6
			aura.scale = Vector3.ONE*service_range/2.65
		"capacity": capacity += 1
		"dash": dash_cooldown *= 0.75
		"hands": work_rate *= 1.3
		"clean": clean_rate *= 1.35
		"oven": cook_rate *= 1.3
		"decor":
			patience_mult *= 1.25
			for g in guests:
				g.patience *= 1.25
				g.max_patience *= 1.25
			plant(Vector3(-10.3+perks[id]*0.7,0,-0.5))
			plant(Vector3(10.3-perks[id]*0.7,0,-0.5))
		"pressure": monsters.damage *= 1.3
		"reload": monsters.haste *= 1.25
		"knife", "pan", "pepper": monsters.upgrade_weapon(id)
		"reach": monsters.attack_range += 2
		"might": monsters.power *= 1.25
		"tips": tip_mult *= 1.3
		"boulevard", "express", "portal":
			build_roads()
			rebuild_navigation()
			for g in guests:
				if g.state == "walking": g.path = path_between(g.node.position,seat_position(tables[g.table]))
				elif g.state == "leaving": g.path = path_between(g.node.position,Vector3(0,0,8))

func toggle_pause():
	if not running or ended or choosing: return
	paused = not paused
	if not paused:
		modal.visible = false
		return
	clear_modal()
	veil(0.65)
	var p = panel(modal,Vector2(465,280),Vector2(510,320))
	label(p,"Minik bir mola.",Vector2(35,32),40)
	label(p,"Mutfak seni bekler.",Vector2(35,105),21,MINT)
	button(p,"SERVİSE DÖN   →",Vector2(35,174),Vector2(440,58),toggle_pause)
	button(p,"Karakter seçimine dön",Vector2(35,246),Vector2(440,48),restart)

func finish_run(won):
	if ended: return
	if won:
		profile.record("wins")
		if profile.difficulty>0: profile.record("hard_wins")
	profile.save_profile()
	ended = true
	running = false
	if money>best and not test_mode:
		best = money
		var save = ConfigFile.new()
		save.set_value("record","gold",best)
		save.save("user://mik_mik.cfg")
	clear_modal()
	veil(0.78)
	var p = panel(modal,Vector2(405,190),Vector2(630,500))
	label(p,"RESTORANIN HİKÂYESİ",Vector2(38,28),14,GOLD)
	label(p,"Şefin yıldızı parladı!" if won else "Bugünlük kepenkler indi.",Vector2(38,75),34)
	label(p,"Altı vardiyayı da tamamladın." if won else ("Şefin canı tükendi. Yeni koşu, yeni tarif." if health<=0 else "İtibar tükendi. Yeni koşu, yepyeni bir tarif."),Vector2(38,140),19,MINT)
	label(p,"%d" % money,Vector2(38,200),60,GOLD)
	label(p,"ALTIN",Vector2(40,272),13,MINT)
	label(p,"%d servis   /   %d kaçan müşteri\n%d yükseltme   /   Vardiya %d" % [served,missed,perks.values().reduce(func(a,b): return a+b,0),wave],Vector2(275,212),20,CREAM)
	button(p,"YENİ BİR TARİF DENE    →",Vector2(38,345),Vector2(554,66),restart,CORAL.darkened(0.18))
	label(p,"KALICI BAHŞİŞ: %d  ·  EN İYİ: %d ALTIN" % [profile.wallet,best],Vector2(38,438),13,MINT)

func restart():
	profile.save_profile()
	get_tree().reload_current_scene()

func load_best():
	if test_mode: return
	var save = ConfigFile.new()
	if save.load("user://mik_mik.cfg") == OK: best = int(save.get_value("record","gold",0))

func toast(value):
	toast_label.text = value
	toast_time = 4.5
	toast_label.modulate.a = 1

func puff(pos,color):
	var n = sphere(world,pos,Vector3.ONE*0.35,color)
	particles.append({"node":n,"life":0.6})

func floating_text(value,pos,color):
	var n = sign3d(world,value,pos,44,color)
	particles.append({"node":n,"life":1.3})

func tone(frequency,duration,volume):
	if muted or test_mode: return
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var bytes = PackedByteArray()
	bytes.resize(int(22050*duration)*2)
	for i in range(int(22050*duration)):
		var envelope = pow(1.0-float(i)/(22050*duration),2)
		var sample = sin(TAU*frequency*i/22050.0)*envelope*volume*32767
		bytes.encode_s16(i*2,int(sample))
	stream.data = bytes
	sound.stream = stream
	sound.play()

func build_audio():
	sound = AudioStreamPlayer.new()
	add_child(sound)
	music = AudioStreamPlayer.new()
	add_child(music)
	if test_mode: return
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var notes = [60,64,67,71,69,67,64,62,57,60,64,67,65,64,60,59,53,57,60,64,62,60,57,55,55,59,62,65,64,62,59,55]
	var beat = 0.27
	var samples = int(notes.size()*beat*22050)
	var bytes = PackedByteArray()
	bytes.resize(samples*2)
	for i in range(samples):
		var time = float(i)/22050
		var ni = int(time/beat)%notes.size()
		var local = fmod(time,beat)
		var f = 440*pow(2,(notes[ni]-69)/12.0)
		var v = (sin(TAU*f*local)+0.3*sin(TAU*f*2*local))*exp(-local*15)*0.065
		var bass = 440*pow(2,([48,45,41,43][int(ni/8)]-69)/12.0)
		v += sin(TAU*bass*time)*exp(-fmod(time,beat*2)*8)*0.055
		bytes.encode_s16(i*2,int(v*32767))
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	music.stream = stream
	music.volume_db = -9
	music.play()

func toggle_audio():
	muted = not muted
	music.stream_paused = muted
	toast("Ses kapalı" if muted else "Ses açık")

func smoke_test():
	start_run()
	set_process(false)
	await get_tree().physics_frame
	player.position = Vector3(-3,0,0)
	var start_x = player.position.x
	Input.action_press("right")
	for frame in range(15): await get_tree().physics_frame
	Input.action_release("right")
	assert(player.position.x > start_x+0.5,"D must move the mouse right")
	Input.action_press("dash")
	for frame in range(3): await get_tree().physics_frame
	Input.action_release("dash")
	assert(dash_left > 0 and dash_time > 0,"Space must trigger dash and cooldown")
	for frame in range(20): await get_tree().physics_frame
	player.position = TABLE_SPOTS[0]+Vector3(0,0,2.5)
	Input.action_press("up")
	for frame in range(40): await get_tree().physics_frame
	Input.action_release("up")
	assert(player.position.z > TABLE_SPOTS[0].z+1.35,"Mouse must collide with tables")
	player.position = Vector3(-20,0,5)
	Input.action_press("right")
	for frame in range(10): await get_tree().physics_frame
	Input.action_release("right")
	assert(player.position.x>-20 and player.position.x<-18,"WASD must work outside the former map bounds")
	set_physics_process(false)
	spawn_guest()
	var g = guests[0]
	assert(assign_table(g),"Customer must get a seat")
	assert(g.path.size()>0,"Customer must have a navigable route")
	for n in range(180): update_guests(0.1)
	assert(g.state == "seated","Customer must arrive at table")
	var t = tables[g.table]
	player.position = t.pos+Vector3(0,0,1.8)
	auto_service(0.8)
	assert(t.state == "cooking","Proximity takes order automatically")
	update_orders(5)
	assert(t.state == "ready","Kitchen must cook automatically")
	player.position = Vector3(0,0,-4)
	auto_service(0.1)
	assert(carried.size() == 1,"Kitchen proximity loads tray")
	player.position = t.pos+Vector3(0,0,1.8)
	auto_service(0.1)
	assert(t.state == "eating","Table proximity delivers food")
	update_tables(5)
	assert(served == 1 and money>0,"Eating grants gold and XP")
	auto_service(1)
	assert(t.state == "empty","Proximity cleans table")
	for p in PERKS: apply_perk(p[0])
	assert(speed>5 and capacity == 3 and service_range>2.65,"Character upgrades must apply")
	assert(path_between(Vector3(0,0,7),Vector3(0,0,-4)).size()>0,"Open boulevard must be navigable")
	for i in range(1,7):
		wave = i
		show_upgrades(i<6)
		assert(offers.size() == 3,"Upgrade choices must remain available")
		choose_perk(0)
	assert(not choosing,"Choosing an upgrade resumes simulation")
	spawn_guest()
	var impatient = guests[-1]
	impatient.patience = 0
	lose_guest(impatient)
	assert(missed == 1 and rep<100,"Lost guests reduce reputation")
	finish_run(false)
	assert(ended and not running,"Loss stops gameplay")
	print("SMOKE PASS: WASD movement, Space dash, table collision, navigation, automatic order/cook/pickup/serve/clean, rewards, all upgrades, waves, customer loss, game over")
	get_tree().quit()

func animate_waiting(g, delta):
	g["wait_age"] = g.get("wait_age",0.0)+delta
	var age = g.wait_age
	var impatience = clampf(1-g.patience/g.max_patience,0,1)
	var rig = g.model.get_meta("rig")
	rig.spoon.visible = false
	rig.head.rotation.y = sin(age*.8)*(.12+impatience*.28)
	rig.head.rotation.x = .07+impatience*.16
	rig.head.rotation.z = sin(age*1.1)*.06
	rig.arms[0].rotation.x = .6+impatience*.5
	rig.arms[1].rotation.x = 1.65+sin(age*(4+impatience*6))*.12
	for i in range(2): rig.feet[i].position.y = .12+maxf(0,sin(age*(5+impatience*8)+i*PI))*(.015+impatience*.11)
	g.model.rotation.z = sin(age*2)*impatience*.045
	var yawn = maxf(0,sin(clampf((fmod(age,9)-7)/2,0,1)*PI))
	rig.mouth.visible = yawn>.05
	rig.mouth.scale.y = .018+yawn*.13
	if yawn>.05:
		rig.head.rotation.x = -.15*yawn
		rig.arms[1].rotation.x = 2.0

func swing_chef(kind):
	strike_left = .24
	strike_kind = kind

func animate_strike(delta):
	if strike_left<=0: return
	strike_left = maxf(0,strike_left-delta)
	if action_pose != "" or gesture_left>0 or power_time>0: return
	var rig = mouse_model.get_meta("rig")
	rig.knife.visible = strike_kind == "knife"
	rig.soda.visible = strike_kind == "soda"
	var pulse = sin((1-strike_left/.24)*PI)
	rig.arms[1].rotation.x = pulse*(1.6 if strike_kind == "knife" else 1.1)
	rig.arms[1].rotation.z = -.45*pulse
	rig.head.rotation.z = .06*pulse
	if strike_left<=0: reset_animal_pose(mouse_model)
