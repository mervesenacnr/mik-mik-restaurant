extends Control
var icon_id = "pan"
func _draw(): paint(self,icon_id,size/2,22,Color("f8eed9"))

static func paint(c, id, p, r, ink):
	var gold = Color("f1c56c")
	match id:
		"pan", "might":
			c.draw_circle(p-Vector2(r*0.2,0),r*0.65,ink,false,3)
			c.draw_line(p+Vector2(r*0.4,0),p+Vector2(r,0),ink,5)
		"knife", "reach":
			c.draw_colored_polygon(PackedVector2Array([p+Vector2(-r,r),p+Vector2(r,-r),p+Vector2(r*0.35,r*0.2)]),ink)
			c.draw_line(p+Vector2(-r,r),p+Vector2(-r*0.3,r*0.3),gold,5)
		"pressure", "reload":
			c.draw_style_box(style(Color("76bfc0")),Rect2(p-Vector2(r*0.5,r*0.7),Vector2(r,r*1.5)))
			c.draw_rect(Rect2(p-Vector2(r*0.22,r),Vector2(r*0.44,r*0.4)),ink)
			c.draw_circle(p,r*0.2,gold)
		"pepper":
			c.draw_arc(p-Vector2(r*0.4,r*0.3),r,0,PI*0.6,16,Color("e87958"),r*0.65)
			c.draw_line(p+Vector2(r*0.5,-r*0.3),p+Vector2(r*0.35,-r),Color("93c8ac"),4)
		"order", "hands":
			c.draw_rect(Rect2(p-Vector2(r*0.65,r),Vector2(r*1.3,r*1.8)),ink,false,2)
			for y in [-0.5,0,0.5]: c.draw_line(p+Vector2(-r*0.35,y*r),p+Vector2(r*0.35,y*r),gold,2)
		"dirty", "clean", "robot":
			c.draw_style_box(style(Color("93c8ac")),Rect2(p-Vector2(r*0.8,r*0.2),Vector2(r*1.6,r*0.8)))
			for v in [Vector2(-0.4,-0.7),Vector2(0.3,-0.9),Vector2(0.7,-0.4)]: c.draw_circle(p+v*r,r*0.16,ink,false,2)
		"eating":
			c.draw_line(p+Vector2(-r*0.45,-r),p+Vector2(-r*0.45,r),ink,3)
			for x in [-0.75,-0.45,-0.15]: c.draw_line(p+Vector2(x*r,-r),p+Vector2(x*r,-r*0.4),ink,2)
			c.draw_circle(p+Vector2(r*0.5,-r*0.6),r*0.35,ink)
			c.draw_line(p+Vector2(r*0.5,-r*0.4),p+Vector2(r*0.5,r),ink,3)
		"ready", "capacity", "belt":
			c.draw_arc(p,r*0.8,PI,TAU,20,ink,3)
			c.draw_line(p-Vector2(r,r*-0.1),p+Vector2(r,r*0.1),ink,3)
			c.draw_circle(p-Vector2(0,r),r*0.12,gold)
		"oven", "cooking":
			c.draw_rect(Rect2(p-Vector2(r,r*0.75),Vector2(r*2,r*1.5)),ink,false,3)
			c.draw_circle(p,r*0.4,gold,false,3)
		"speed", "dash", "express":
			c.draw_polyline(PackedVector2Array([p+Vector2(0,-r),p+Vector2(-r*0.6,r*0.1),p+Vector2(r*0.5,-r*0.1),p+Vector2(0,r)]),gold,4)
		"health":
			c.draw_line(p-Vector2(r*0.7,0),p+Vector2(r*0.7,0),ink,6)
			c.draw_line(p-Vector2(0,r*0.7),p+Vector2(0,r*0.7),ink,6)
		"vip", "tips":
			c.draw_circle(p,r*0.8,gold,false,3)
			c.draw_line(p-Vector2(0,r*0.5),p+Vector2(0,r*0.5),gold,3)
		"range", "portal", "boulevard":
			c.draw_arc(p,r*0.8,0,TAU,24,ink,2)
			c.draw_line(p-Vector2(r,0),p+Vector2(r,0),gold,3)
		"bell":
			c.draw_arc(p,r*0.7,PI,TAU,16,gold,4)
			c.draw_line(p-Vector2(r,0),p+Vector2(r,0),gold,3)
			c.draw_circle(p+Vector2(0,r*0.3),r*0.2,ink)
		_:
			portrait(c,p,r,id)

static func portrait(c,p,r,kind):
	var fur = Color("bd947a")
	if kind == "vip": fur = Color("f1c56c")
	if kind == "student": fur = Color("9facdf")
	if kind == "regular": fur = Color("93c8ac")
	for x in [-0.65,0.65]:
		c.draw_circle(p+Vector2(x,-0.5)*r,r*0.4,fur)
		c.draw_circle(p+Vector2(x,-0.5)*r,r*0.22,Color("e9b5a0"))
	c.draw_circle(p+Vector2(0,r*0.12),r*0.69,fur)
	for x in [-0.25,0.25]: c.draw_circle(p+Vector2(x,0)*r,r*0.09,Color("163d42"))
	c.draw_circle(p+Vector2(0,r*0.35),r*0.13,Color("163d42"))

static func style(color):
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(8)
	return s
