extends Control
const Icons = preload("res://scripts/item_icon.gd")
const CARD = Vector2(64,64)
var game
var entries: Array = []
var placed: Array = []
var markers: Array = []
func setup(g):
	game = g
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self
func project(pos):
	return game.camera.unproject_position(pos)*size/get_viewport().get_visible_rect().size
func refresh():
	entries.clear()
	placed.clear()
	markers.clear()
	if not game.running:
		queue_redraw()
		return
	var safe = Rect2(Vector2(64,172),size-Vector2(128,258))
	for i in range(game.tables.size()):
		var t = game.tables[i]
		if t.state == "empty": continue
		var ratio = clampf(t.guest.patience/t.guest.max_patience,0,1) if t.guest != null else 1.0
		var e = {"title":"M%02d" % (i+1),"screen":project(t.pos+Vector3(0,2.7,0)),"ratio":ratio,"seconds":ceili(t.guest.patience) if t.guest != null else -1,"kind":t.guest.kind if t.guest != null else "normal","action":t.state,"dish":t.dish,"color":game.MINT if ratio>0.5 else game.GOLD if ratio>0.25 else game.RED,"progress":clampf(t.progress/(0.85 if t.state == "dirty" else 0.65),0,1),"urgent":ratio}
		if safe.has_point(e.screen): markers.append(e)
		else: entries.append(e)
	var kitchen = project(Vector3(0,2.5,-5.8))
	var ready = game.orders.filter(func(o): return o.remaining<=0 and not game.carried.has(o.table)).size()
	var k = {"title":"MUTFAK","screen":kitchen,"ratio":1.0,"seconds":-1,"kind":"kitchen","action":"ready" if ready>0 else "oven","dish":-1,"color":game.GOLD,"progress":0.0,"urgent":0.0 if ready>0 else 2.0}
	if safe.has_point(kitchen): markers.append(k)
	else: entries.append(k)
	for guest in game.guests:
		if guest.state != "queue": continue
		var screen = project(guest.node.position+Vector3(0,2.5,0))
		if safe.has_point(screen): continue
		var ratio = clampf(guest.patience/guest.max_patience,0,1)
		entries.append({"title":"GİRİŞ","screen":screen,"ratio":ratio,"seconds":ceili(guest.patience),"kind":guest.kind,"action":"order","dish":guest.dish,"color":game.CORAL,"progress":0.0,"urgent":ratio})
	entries.sort_custom(func(a,b): return a.urgent<b.urgent)
	# Choose closest free point along the perimeter, leaving the HUD unobstructed.
	var anchors: Array = []
	for y in range(205,int(size.y)-100,76):
		anchors.append(Vector2(38,y))
		anchors.append(Vector2(size.x-38,y))
	for x in range(450,int(size.x)-95,76): anchors.append(Vector2(x,112))
	for x in range(100,int(size.x)-90,76): anchors.append(Vector2(x,size.y-95))
	for e in entries:
		if anchors.is_empty(): break
		var bearing = (e.screen-size/2).normalized()
		var best = 0
		var score = -2.0
		for i in range(anchors.size()):
			var dot = (anchors[i]-size/2).normalized().dot(bearing)
			if dot>score:
				score = dot
				best = i
		e["at"] = anchors.pop_at(best)-CARD/2
		e["bearing"] = bearing
		placed.append(e)
	queue_redraw()
func _draw():
	if game == null: return
	for e in markers:
		var p = e.screen+Vector2(0,sin(game.elapsed*3)*2)
		draw_circle(p,20,Color("163d42e8"))
		Icons.paint(self,e.action,p,12,e.color)
		if e.action in ["order","dirty"] and e.progress>0: draw_arc(p,23,-PI/2,-PI/2+TAU*maxf(.001,e.progress),24,game.GOLD,3)
	for e in placed:
		var p = e.at+CARD/2
		draw_circle(p,27,Color("163d42ef"))
		draw_arc(p,28,-PI/2,-PI/2+TAU*maxf(.001,e.ratio),32,e.color,3)
		if e.kind == "kitchen": Icons.paint(self,"oven",p,16,e.color)
		else: Icons.portrait(self,p,22,e.kind)
		var dir = e.bearing
		var n = Vector2(-dir.y,dir.x)
		draw_colored_polygon(PackedVector2Array([p+dir*41,p+dir*32+n*5,p+dir*32-n*5]),e.color)
		var badge = p+Vector2(20,20)
		draw_circle(badge,13,Color("244c50"))
		Icons.paint(self,e.action,badge,8,e.color)
		if e.dish>=0 and e.action in ["order","cooking","ready","eating"]:
			var food = p+Vector2(-21,19)
			draw_circle(food,10,Color("f8eed9"))
			var colors = [Color("be7742"),Color("edbb54"),Color("d96e45"),Color("f3d276")]
			draw_circle(food,7,colors[e.dish%4])
			if e.dish == 1: draw_line(food-Vector2(5,0),food+Vector2(5,0),game.CORAL,2)
			elif e.dish == 3:
				for v in [Vector2(-3,2),Vector2(3,-2)]: draw_circle(food+v,2,game.GOLD.darkened(.2))
