extends Node
## Permanent progression is separate from all run XP and item slots.
const FUR_PALETTE = [["Kül",Color("999a9f")],["Bisküvi",Color("bc9873")],["Krem",Color("e0d1b5")],["Kakao",Color("79635d")]]
const CLOTH_PALETTE = [["Kiremit",Color("cc735b")],["Adaçayı",Color("6e9988")],["Gece",Color("526783")],["Mürdüm",Color("896680")]]
const EYES = [["round","Yuvarlak"],["sharp","Keskin"],["sleepy","Uykulu"],["oval","Oval"]]
const FILE = "user://mik_profile.cfg"
const CHARACTERS = [
	["mik","Mik","Dengeli şef","",Color("a8a5a0")],
	["zip","Zıp","+%15 hız · +1 tabak","service",Color("c9ad83")],
	["tok","Tok","+24 can · +%15 hasar · −%8 hız","hunter",Color("777789")],
	["nane","Nane","+%25 pişirme · +%20 temizlik","host",Color("d2c6bc")],
]
const COSTUMES = [["chef","Şef",""],["scarf","Gezgin","service"],["armor","Muhafız","hunter"],["royal","Kraliyet","victory"]]
const ACHIEVEMENTS = [
	["service","İlk müdavimler","served",10,"Zıp + Gezgin kıyafeti"],
	["hunter","Mutfak muhafızı","kills",75,"Tok + Muhafız kıyafeti"],
	["host","Evin lezzeti","served",50,"Nane"],
	["survivor","Akşam mesaisi","wave",4,"20 kalıcı bahşiş"],
	["victory","Usta şef","wins",1,"Kraliyet + Kâbus zorluğu"],
	["hard_win","Demir mutfak","hard_wins",1,"50 kalıcı bahşiş"],
]
const TRAINING = [["health","Dayanıklılık","+8 can"],["speed","Çeviklik","+%3 hız"],["damage","Kuvvet","+%5 silah hasarı"],["cook","Mutfak eğitimi","+%5 pişirme"],["clean","Temizlik eğitimi","+%5 temizlik"]]
const DIFFICULTIES = [["Öğle",1.0,1.0,1.0,0],["Yoğun mesai",1.35,1.25,1.15,2],["Kâbus",1.8,1.6,1.3,4]]
var game
var wallet = 0
var stats: Dictionary = {"served":0,"kills":0,"wave":0,"wins":0,"hard_wins":0}
var unlocked: Dictionary = {}
var training: Dictionary = {"health":0,"speed":0,"damage":0,"cook":0,"clean":0}
var character = "mik"
var costume = "chef"
var eye_shape = "round"
var fur = FUR_PALETTE[0][1]
var cloth = CLOTH_PALETTE[0][1]
var difficulty = 0
var dirty = false
var save_timer = 0.0
var notices: Array = []

func setup(g):
	game = g
	if not game.test_mode: read_save()
	return self

func _process(delta):
	save_timer += delta
	if dirty and save_timer>=3: save_profile()

func is_open(requirement): return requirement == "" or unlocked.has(requirement)
func difficulty_open(index): return index>=0 and index<3 and (index<2 or unlocked.has("victory"))
func selected_character(): return CHARACTERS.filter(func(c): return c[0] == character)[0]
func price(id): return 10+int(training.get(id,0))*10
func buy(id):
	if game.running or TRAINING.filter(func(t): return t[0] == id).is_empty(): return false
	if training.get(id,0)>=5 or wallet<price(id): return false
	wallet -= price(id)
	training[id] = int(training.get(id,0))+1
	dirty = true
	save_profile()
	return true
func select_character(id):
	if game.running: return false
	var found = CHARACTERS.filter(func(c): return c[0] == id)
	if found.is_empty() or not is_open(found[0][3]): return false
	character = id
	dirty = true
	return true
func select_costume(id):
	if game.running: return false
	var found = COSTUMES.filter(func(c): return c[0] == id)
	if found.is_empty() or not is_open(found[0][2]): return false
	costume = id
	dirty = true
	return true
func select_palette(key, index):
	if game.running or key not in ["fur","cloth"] or index<0 or index>=4: return false
	set(key,(FUR_PALETTE if key == "fur" else CLOTH_PALETTE)[index][1])
	dirty = true
	return true
func select_eyes(id):
	if game.running or not EYES.any(func(e): return e[0] == id): return false
	eye_shape = id
	dirty = true
	return true
func nearest_palette(value, palette):
	var best = palette[0][1]
	var distance = INF
	for entry in palette:
		var c = entry[1]
		var d = pow(value.r-c.r,2)+pow(value.g-c.g,2)+pow(value.b-c.b,2)
		if d<distance:
			distance = d
			best = c
	return best
func select_difficulty(index):
	if game.running or not difficulty_open(index): return false
	difficulty = index
	dirty = true
	return true
func record(event, amount = 1):
	if not stats.has(event): return
	if event == "wave": stats[event] = maxi(stats[event],amount)
	else: stats[event] += amount
	if event == "served": wallet += amount
	if event == "kills": wallet += int(stats.kills/10)-int((stats.kills-amount)/10)
	if event == "wins": wallet += 30
	for a in ACHIEVEMENTS:
		if not unlocked.has(a[0]) and stats[a[2]]>=a[3]:
			unlocked[a[0]] = true
			notices.append(a[1])
			if a[0] == "survivor": wallet += 20
			if a[0] == "hard_win": wallet += 50
	dirty = true
func save_profile(path = FILE):
	if game.test_mode and path == FILE: return OK
	var cfg = ConfigFile.new()
	for key in ["wallet","stats","unlocked","training","character","costume","fur","cloth","difficulty","eye_shape"]: cfg.set_value("profile",key,get(key))
	var error = cfg.save(path)
	if error == OK:
		dirty = false
		save_timer = 0
	else: push_warning("Kalıcı ilerleme kaydedilemedi: %s" % error)
	return error
func read_save(path = FILE):
	var cfg = ConfigFile.new()
	if cfg.load(path) != OK: return
	wallet = maxi(0,int(cfg.get_value("profile","wallet",0)))
	var saved_stats = cfg.get_value("profile","stats",{})
	if saved_stats is Dictionary:
		for key in stats: stats[key] = maxi(0,int(saved_stats.get(key,0)))
	var saved_training = cfg.get_value("profile","training",{})
	if saved_training is Dictionary:
		for t in TRAINING: training[t[0]] = clampi(int(saved_training.get(t[0],0)),0,5)
	# Unlocks are reconstructed from recorded milestones, rather than trusting stale selection data.
	for a in ACHIEVEMENTS:
		if stats[a[2]]>=a[3]: unlocked[a[0]] = true
	for key in ["character","costume"]:
		var choice = str(cfg.get_value("profile",key,get(key)))
		if key == "character": select_character(choice)
		else: select_costume(choice)
	for key in ["fur","cloth"]:
		var value = cfg.get_value("profile",key,get(key))
		if value is Color: set(key,nearest_palette(value,FUR_PALETTE if key == "fur" else CLOTH_PALETTE))
	select_eyes(str(cfg.get_value("profile","eye_shape","round")))
	var selected = clampi(int(cfg.get_value("profile","difficulty",0)),0,2)
	if difficulty_open(selected): difficulty = selected
	dirty = false

func dress(model):
	var rig = model.get_meta("rig")
	if costume != "chef" or character != "mik":
		for part in model.get_meta("chef_hat",[]): part.visible = false
	game.ArtDetail.face(game,model,fur,eye_shape)
	var art = game.ArtDetail.root_at(model)
	art.name = "CharacterSignature"
	var hat = game.ArtDetail.root_at(rig.head)
	hat.name = "SignatureHeadwear"
	var leather = Color("73543e")
	var brass = Color("cda66b")
	match character:
		"mik":
			# Double-breasted chef, neckerchief and a utensil holster.
			for x in [-.13,.13]:
				for y in [.57,.75,.92]: game.sphere(art,Vector3(x,y,-.38),Vector3.ONE*.055,brass)
			game.box(art,Vector3(.42,.54,0),Vector3(.18,.3,.2),leather)
			for z in [-.05,.05]: game.ArtDetail.rod(game,art,Vector3(.42,.63,z),Vector3(.42,.95,z),.022,game.CREAM)
		"zip":
			model.get_child(0).scale *= Vector3(.84,1.12,.88)
			rig.head.scale = Vector3(.92,1.08,.94)
			for foot in rig.feet: foot.scale *= Vector3(1,1,1.5)
			if costume != "royal":
				game.sphere(hat,Vector3(0,.43,.02),Vector3(.83,.28,.66),cloth)
				game.sphere(hat,Vector3(0,.42,-.36),Vector3(.8,.075,.4),cloth.darkened(.3))
				for x in [-.19,.19]:
					game.sphere(hat,Vector3(x,.53,-.26),Vector3(.26,.19,.06),brass)
					game.sphere(hat,Vector3(x,.54,-.3),Vector3(.19,.13,.025),Color("6b8d92"))
			game.ArtDetail.rod(game,art,Vector3(-.33,1.05,-.31),Vector3(.35,.4,-.32),.045,leather)
			game.sphere(art,Vector3(.43,.54,.06),Vector3(.48,.5,.3),leather)
			game.box(art,Vector3(.47,.66,-.1),Vector3(.35,.19,.07),brass)
			game.box(art,Vector3(.47,.61,-.15),Vector3(.08,.12,.025),game.GOLD)
			for x in [-.2,.2]: game.sphere(art,Vector3(x,.13,-.17),Vector3(.31,.19,.59),cloth.darkened(.35))
		"tok":
			model.get_child(0).scale *= Vector3(1.55,1.1,1.35)
			rig.head.scale = Vector3(1.12,.94,1.08)
			for arm in rig.arms:
				arm.position.x *= 1.35
				game.sphere(arm,Vector3(0,-.27,-.025),Vector3(.32,.33,.29),leather)
			for foot in rig.feet: foot.scale *= Vector3(1.3,1.25,1.2)
			for x in [-.53,.53]:
				game.sphere(art,Vector3(x,.97,0),Vector3(.44,.3,.51),cloth.darkened(.25))
				for z in [-.15,0,.15]: game.sphere(art,Vector3(x,1.12,z),Vector3.ONE*.07,brass)
			game.sphere(art,Vector3(0,.43,0),Vector3(1.13,.17,.87),leather)
			game.box(art,Vector3(0,.44,-.44),Vector3(.2,.17,.065),brass)
			for i in range(3): game.ArtDetail.rod(game,hat,Vector3(.29+i*.04,.02,-.41),Vector3(.25+i*.04,-.06,-.43),.011,Color("d09887"))
			if costume != "royal":
				game.sphere(hat,Vector3(0,.43,.05),Vector3(.77,.12,.63),cloth)
				game.box(hat,Vector3(.35,.45,.12),Vector3(.18,.12,.32),cloth)
		"nane":
			model.get_child(0).scale *= Vector3(1.12,.94,1.13)
			rig.head.scale = Vector3(.96,1.06,.97)
			game.sphere(art,Vector3(0,.42,0),Vector3(1,.29,.8),cloth)
			game.sphere(art,Vector3(0,.73,.45),Vector3(.66,.65,.38),leather)
			for i in range(7):
				var x = -.3+i*.1
				var leaf = game.sphere(hat,Vector3(x,.55+sin(i)*.07,.02),Vector3(.19,.48,.12),Color("63917b") if i%2 == 0 else Color("9cbb87"))
				leaf.rotation.z = x*1.9
				game.sphere(art,Vector3(x,.97+i%2*.08,.47),Vector3(.1,.43,.08),Color("63917b"))
			for x in [-.39,.39]:
				game.sphere(hat,Vector3(x,.39,-.18),Vector3.ONE*.14,Color("e6ba79"))
				game.sphere(art,Vector3(x,.62,-.24),Vector3(.19,.23,.18),Color("adc1ae"))
	if costume == "scarf":
		game.sphere(art,Vector3(0,1.05,0),Vector3(.76,.2,.63),cloth.lightened(.25))
		var flap = game.box(art,Vector3(.28,.81,-.39),Vector3(.20,.43,.07),cloth.lightened(.25))
		flap.rotation.z = -.18
	elif costume == "armor":
		game.sphere(art,Vector3(0,.73,-.14),Vector3(.82,.7,.57),cloth.darkened(.25))
		for x in [-.31,.31]:
			for y in [.57,.82]: game.sphere(art,Vector3(x,y,-.36),Vector3.ONE*.055,brass)
		game.box(art,Vector3(0,.78,-.44),Vector3(.16,.3,.05),game.GOLD)
	elif costume == "royal":
		game.sphere(art,Vector3(0,.72,.3),Vector3(.98,1,.22),cloth)
		for i in range(7): game.sphere(art,Vector3(-.42+i*.14,.27,.33),Vector3(.17,.12,.17),game.CREAM)
		game.cylinder(hat,Vector3(0,.57,0),.34,.16,game.GOLD)
		for x in [-.23,0,.23]:
			game.box(hat,Vector3(x,.74,0),Vector3(.10,.24,.20),game.GOLD)
			game.sphere(hat,Vector3(x,.87,0),Vector3.ONE*.09,game.GOLD)
		game.sphere(hat,Vector3(0,.63,-.34),Vector3(.12,.16,.07),game.CORAL)
	game.ArtDetail.bake(art)
	game.ArtDetail.bake(hat)
	model.set_meta("character_style",character)
