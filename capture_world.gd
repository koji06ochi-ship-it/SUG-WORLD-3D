extends SceneTree

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var scene: PackedScene = load("res://main.tscn")
    if scene == null:
        push_error("main.tscn missing")
        quit(2)
        return
    var root_node := scene.instantiate()
    root.add_child(root_node)
    await process_frame
    await process_frame
    await process_frame
    await process_frame
    var image := root.get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        push_error("viewport image empty")
        quit(3)
        return
    var error := image.save_png("res://world_actual_render.png")
    if error != OK:
        push_error("PNG save failed: %d" % error)
        quit(4)
        return
    print("WORLD_RENDER_SAVED ", image.get_width(), "x", image.get_height())
    quit()
