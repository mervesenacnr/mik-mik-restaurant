extends RefCounted
var game
var profile
var preview_root
var preview_model
var page = "crew"
func setup(g):
	game = g
	profile = g.profile
	return self
func show_page(next = "crew"):
	page = next
	game.clear_modal()
	game.hud.visible = false
	game.veil(.7)
	game.label(game.modal,"mik mik",Vector2(64,34),46,game.CREAM)
	game.label(game.modal,"%d  BAHŞİŞ" % profile.wallet,Vector2(1110,49),22,game.GOLD)
	for i in range(3):
		var id = ["crew","training","achievements"][i]
		var b = game.button(game.modal,["Fareler & stil","Başlangıç statları","Başarımlar"][i],Vector2(64+i*330,111),Vector2(310,48),func(): show_page(id),game.TEAL if page == id else game.INK)
		if page == id: b.add_theme_color_override("font_color",game.GOLD)
	if page == "crew": show_crew()
	elif page == "training": show_training()
	else: show_achievements()
	game.label(game.modal,"WASD / Yön tuşları     SPACE: dash",Vector2(65,818),17,game.MINT)
	game.button(game.modal,"BAŞLA   →",Vector2(1060,793),Vector2(310,65),game.start_run,game.CORAL.darkened(.2))

func show_crew():
	for i in range(profile.CHARACTERS.size()):
		var c = profile.CHARACTERS[i]
		var p = game.panel(game.modal,Vector2(64,184+i*140),Vector2(620,123),game.TEAL if profile.character == c[0] else game.INK)
		game.label(p,c[1],Vector2(20,13),27,game.CREAM)
		game.label(p,c[2],Vector2(20,55),16,game.MINT)
		var open = profile.is_open(c[3])
		var text = "SEÇİLİ" if profile.character == c[0] else "SEÇ" if open else "KİLİTLİ"
		var b = game.button(p,text,Vector2(448,18),Vector2(150,42),func():
			profile.select_character(c[0])
			show_page(),game.TEAL)
		b.disabled = not open or profile.character == c[0]
		if not open:
			var a = profile.ACHIEVEMENTS.filter(func(a): return a[0] == c[3])[0]
			game.label(p,"%s  ·  %d/%d" % [a[1],mini(profile.stats[a[2]],a[3]),a[3]],Vector2(20,89),13,game.GOLD)
	var p = game.panel(game.modal,Vector2(712,184),Vector2(658,565),game.INK)
	var viewport_box = SubViewportContainer.new()
	p.add_child(viewport_box)
	viewport_box.position = Vector2(15,10)
	viewport_box.size = Vector2(280,315)
	viewport_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vp = SubViewport.new()
	vp.size = Vector2i(280,315)
	vp.transparent_bg = true
	vp.own_world_3d = true
	viewport_box.add_child(vp)
	preview_root = Node3D.new()
	vp.add_child(preview_root)
	var camera = Camera3D.new()
	preview_root.add_child(camera)
	camera.position = Vector3(2,1.8,4)
	camera.look_at(Vector3(0,1.05,0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.8
	var light = DirectionalLight3D.new()
	preview_root.add_child(light)
	light.rotation_degrees = Vector3(-35,-25,0)
	light.light_energy = .9
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = .4
	preview_root.add_child(env)
	refresh_preview()
	game.label(p,"Tüy",Vector2(325,25),17,game.CREAM)
	palette_picker(p,Vector2(325,58),"fur")
	game.label(p,"Kıyafet rengi",Vector2(325,121),17,game.CREAM)
	palette_picker(p,Vector2(325,154),"cloth")
	game.label(p,"Göz şekli",Vector2(325,217),17,game.CREAM)
	for i in range(profile.EYES.size()):
		var eye = profile.EYES[i]
		var b = game.button(p,eye[1],Vector2(325+(i%2)*145,248+int(i/2)*42),Vector2(135,35),func():
			profile.select_eyes(eye[0])
			show_page(),game.TEAL if profile.eye_shape == eye[0] else game.INK)
		b.add_theme_font_size_override("font_size",16)
		for state in ["normal","hover","pressed"]:
			var compact = b.get_theme_stylebox(state).duplicate()
			compact.content_margin_top = 5
			compact.content_margin_bottom = 5
			compact.content_margin_left = 8
			compact.content_margin_right = 8
			b.add_theme_stylebox_override(state,compact)
	game.label(p,"Kıyafet",Vector2(22,337),16,game.MINT)
	for i in range(profile.COSTUMES.size()):
		var outfit = profile.COSTUMES[i]
		var b = game.button(p,outfit[1],Vector2(22+i*157,367),Vector2(146,44),func():
			profile.select_costume(outfit[0])
			show_page(),game.TEAL if profile.costume == outfit[0] else Color("345359"))
		b.disabled = not profile.is_open(outfit[2])
		if b.disabled: b.tooltip_text = profile.ACHIEVEMENTS.filter(func(a): return a[0] == outfit[2])[0][1]
	game.label(p,"Zorluk",Vector2(22,433),16,game.MINT)
	for i in range(3):
		var d = profile.DIFFICULTIES[i]
		var b = game.button(p,d[0],Vector2(22+i*210,461),Vector2(198,44),func():
			profile.select_difficulty(i)
			show_page(),game.CORAL.darkened(.35) if profile.difficulty == i else Color("345359"))
		b.disabled = not profile.difficulty_open(i)
		b.tooltip_text = "Önce bir koşu kazan" if b.disabled else "Düşman canı ×%.2f · hasar ×%.2f · hız ×%.2f" % [d[1],d[2],d[3]]
	var d = profile.DIFFICULTIES[profile.difficulty]
	game.label(p,"Can ×%.2f   Hasar ×%.2f   Hız ×%.2f   Akın +%d" % [d[1],d[2],d[3],d[4]],Vector2(22,524),14,game.GOLD)
func palette_picker(parent, pos, key):
	var palette = profile.FUR_PALETTE if key == "fur" else profile.CLOTH_PALETTE
	for i in range(4):
		var entry = palette[i]
		var selected = profile.get(key).is_equal_approx(entry[1])
		var b = game.button(parent,"✓" if selected else "",pos+Vector2(i*73,0),Vector2(62,43),func():
			profile.select_palette(key,i)
			show_page(),entry[1])
		b.tooltip_text = entry[0]
		b.add_theme_color_override("font_color",game.INK if entry[1].get_luminance()>.4 else game.CREAM)
func refresh_preview():
	if is_instance_valid(preview_model):
		preview_model.get_parent().remove_child(preview_model)
		preview_model.queue_free()
	preview_model = game.animal(preview_root,profile.fur,profile.cloth,true)
	profile.dress(preview_model)
	preview_model.rotation.y = PI+.3
	var idle = preview_model.create_tween().set_loops()
	idle.tween_property(preview_model,"position:y",.045,.8).set_trans(Tween.TRANS_SINE)
	idle.tween_property(preview_model,"position:y",0,.8).set_trans(Tween.TRANS_SINE)
func show_training():
	game.label(game.modal,"Servis: +1  ·  Her 10 düşman: +1  ·  Zafer: +30 kalıcı bahşiş",Vector2(65,189),20,game.MINT)
	for i in range(profile.TRAINING.size()):
		var t = profile.TRAINING[i]
		var lv = int(profile.training.get(t[0],0))
		var p = game.panel(game.modal,Vector2(65,244+i*99),Vector2(1305,84),game.INK)
		game.label(p,t[1],Vector2(22,19),24,game.CREAM)
		game.label(p,t[2]+" / kademe",Vector2(375,27),17,game.MINT)
		game.label(p,"%d / 5" % lv,Vector2(855,24),22,game.GOLD)
		var b = game.button(p,"TAMAM" if lv>=5 else "%d  BAHŞİŞ  +" % profile.price(t[0]),Vector2(1025,16),Vector2(255,52),func():
			profile.buy(t[0])
			show_page("training"))
		b.disabled = lv>=5 or profile.wallet<profile.price(t[0])
	game.label(game.modal,"Kalıcıdır. Yeni koşuda uygulanır; eşya slotlarını doldurmaz.",Vector2(65,760),17,game.GOLD)
func show_achievements():
	for i in range(profile.ACHIEVEMENTS.size()):
		var a = profile.ACHIEVEMENTS[i]
		var open = profile.unlocked.has(a[0])
		var p = game.panel(game.modal,Vector2(65+(i%2)*665,190+int(i/2)*193),Vector2(640,173),game.TEAL if open else game.INK)
		game.label(p,a[1]+("  ✓" if open else ""),Vector2(22,16),25,game.CREAM)
		var units = {"served":"servis","kills":"düşman","wave":"vardiya","wins":"zafer","hard_wins":"zor zafer"}
		game.label(p,"%d / %d %s" % [mini(profile.stats[a[2]],a[3]),a[3],units[a[2]]],Vector2(22,60),18,game.GOLD)
		game.label(p,a[4],Vector2(22,107),17,game.MINT)
		var progress = game.bar(p,Vector2(22,149),Vector2(595,5),game.GOLD)
		progress.value = clampf(float(profile.stats[a[2]])/a[3]*100,0,100)
