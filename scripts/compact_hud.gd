extends Control
const Icons = preload("res://scripts/item_icon.gd")
var game
var slot_rects: Array = []
var background = Icons.style(Color("163d42e8"))
func _ready(): mouse_filter = Control.MOUSE_FILTER_PASS
func _gui_input(_event):
	tooltip_text = ""
	for entry in slot_rects:
		if entry.rect.has_point(get_local_mouse_position()): tooltip_text = entry.tip
func _draw():
	if game == null: return
	slot_rects.clear()
	var font = ThemeDB.fallback_font
	for row in range(2):
		var slots = game.kitchen_slots if row == 0 else game.combat_slots
		var tint = game.MINT if row == 0 else Color("bdacec")
		var y = 24+row*72
		Icons.paint(self,"oven" if row == 0 else "knife",Vector2(42,y+25),14,tint)
		for i in range(game.SLOT_LIMIT):
			var rect = Rect2(66+i*55,y,49,49)
			draw_style_box(background,rect)
			if i<slots.size():
				var id = slots[i]
				Icons.paint(self,id,rect.get_center()-Vector2(0,3),14,tint)
				var data = game.PERKS.filter(func(p): return p[0] == id)[0]
				slot_rects.append({"rect":rect,"tip":data[2]+"\n"+data[3]})
				for j in range(4): draw_circle(rect.position+Vector2(10+j*10,42),2.5,tint if j<game.perks[id] or id in game.SINGLE_ITEMS else Color("456266"))
			else:
				draw_circle(rect.get_center(),2,Color("65817c"))
				slot_rects.append({"rect":rect,"tip":"Boş mutfak slotu" if row == 0 else "Boş savaş slotu"})
		var progress = float(game.xp)/game.next_xp if row == 0 else float(game.combat_xp)/game.next_combat_xp
		draw_rect(Rect2(66,y+55,324,3),Color("244c50"))
		draw_rect(Rect2(66,y+55,324*progress,3),tint)
	draw_style_box(background,Rect2(size.x-337,24,228,44))
	var top = Vector2(size.x/2-90,24)
	draw_style_box(background,Rect2(top,Vector2(180,49)))
	draw_string(font,top+Vector2(16,32),"%d / 6   %02d:%02d" % [game.wave,int(game.wave_time)/60,int(game.wave_time)%60],HORIZONTAL_ALIGNMENT_LEFT,-1,22,game.CREAM)
	var bottom = Vector2(size.x/2-190,size.y-61)
	draw_style_box(background,Rect2(bottom,Vector2(380,45)))
	Icons.paint(self,"health",bottom+Vector2(22,22),10,game.CORAL)
	draw_rect(Rect2(bottom+Vector2(42,18),Vector2(110,8)),Color("456266"))
	draw_rect(Rect2(bottom+Vector2(42,18),Vector2(110*game.health/game.max_health,8)),game.CORAL)
	Icons.paint(self,"capacity",bottom+Vector2(180,22),11,game.GOLD)
	draw_string(font,bottom+Vector2(202,28),"%d/%d" % [game.carried.size(),game.capacity],HORIZONTAL_ALIGNMENT_LEFT,-1,17,game.CREAM)
	Icons.paint(self,"dash",bottom+Vector2(275,22),12,game.GOLD)
	draw_arc(bottom+Vector2(275,22),18,-PI/2,-PI/2+TAU*maxf(0.001,1-game.dash_left/game.dash_cooldown),24,game.GOLD,2)
	draw_string(font,bottom+Vector2(303,28),"SPACE",HORIZONTAL_ALIGNMENT_LEFT,-1,13,game.CREAM)
	Icons.paint(self,"tips",Vector2(size.x-224,46),11,game.GOLD)
	draw_string(font,Vector2(size.x-205,52),str(game.money),HORIZONTAL_ALIGNMENT_LEFT,-1,17,game.GOLD)
	Icons.portrait(self,Vector2(size.x-310,46),12,"regular")
	draw_string(font,Vector2(size.x-291,52),str(int(game.rep)),HORIZONTAL_ALIGNMENT_LEFT,-1,17,game.MINT)
