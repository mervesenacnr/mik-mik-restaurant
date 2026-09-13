extends SceneTree
var game
func _initialize(): call_deferred("run")
func shot(name):
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func run():
	game = load("res://scripts/game.gd").new()
	game.test_mode = true
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	DirAccess.make_dir_recursive_absolute("res://captures")
	await shot("fare-secimi")
	game.profile.record("served",50)
	game.profile.record("kills",75)
	game.profile.record("wave",4)
	game.profile.record("wins")
	for i in range(4):
		var id = game.profile.CHARACTERS[i][0]
		game.profile.select_character(id)
		game.profile.select_palette("fur",i)
		game.profile.select_palette("cloth",i)
		game.profile.select_eyes(game.profile.EYES[i][0])
		game.profile_menu.show_page("crew")
		await shot("fare-"+id)
	game.profile.select_character("nane")
	game.profile.select_costume("royal")
	game.profile.select_difficulty(2)
	game.profile.select_palette("cloth",3)
	game.profile.select_palette("fur",1)
	game.profile_menu.show_page("crew")
	await shot("fare-kostumleri")
	game.profile_menu.show_page("training")
	await shot("kalici-statlar")
	game.profile_menu.show_page("achievements")
	await shot("basarimlar")
	game.start_run()
	game.update_camera(4)
	await shot("kostum-oyunda")
	print("PROFILE PREVIEW: five screens rendered")
	quit()
