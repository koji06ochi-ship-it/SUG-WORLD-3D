extends Node3D
# Independent engine feasibility prototype. No imported QUEST or paid assets.
var player: CharacterBody3D
var camera: Camera3D
var heading := 0.0
var lake_position := Vector3(-12, 0, 22)
var house_position := Vector3(8, 0, 22)
var state := WorldState.new()
var navigation := WorldNavigation.new()
var overlay: PanelContainer
var overlay_open := false
var fish_attempts := 0
var status: Label
var touch_forward := 0.0
var touch_turn := 0.0

func _ready() -> void:
    _create_environment()
    _create_player()
    _create_ui()
    if state.load_save():
        player.position = state.world_position
        fish_attempts = int(state.inventory.get("fish", 0))

func _make_box(name: String, pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = name
    body.position = pos
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    visual.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    visual.material_override = material
    body.add_child(visual)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)
    return body

func _create_environment() -> void:
    var env := WorldEnvironment.new()
    var settings := Environment.new()
    settings.background_mode = Environment.BG_COLOR
    settings.background_color = Color("#a4d7e8")
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color = Color("#d4e8e4")
    settings.ambient_light_energy = 0.9
    env.environment = settings
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50, -30, 0)
    sun.light_energy = 1.4
    add_child(sun)
    _make_box("Ground", Vector3(0, -0.3, 0), Vector3(100, 0.6, 100), Color("#78a968"))
    _make_box("Path", Vector3(0, 0.03, 17), Vector3(5, 0.06, 65), Color("#cbb589"))
    _make_box("Lake", Vector3(-12, 0.07, 22), Vector3(20, 0.08, 12), Color("#4cabb9"))
    _make_box("Cottage", Vector3(8, 1.6, 22), Vector3(5, 3.2, 4), Color("#e5c69b"))
    _make_box("Roof", Vector3(8, 3.5, 22), Vector3(6, 0.6, 5), Color("#9b624b"))
    _make_box("GateLeft", Vector3(-8, 1.6, 37), Vector3(0.8, 3.2, 0.8), Color("#85817a"))
    _make_box("GateRight", Vector3(-5, 1.6, 37), Vector3(0.8, 3.2, 0.8), Color("#85817a"))
    _make_box("GateTop", Vector3(-6.5, 3.4, 37), Vector3(4, 0.6, 0.8), Color("#85817a"))
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261101
    for i in 90:
        var x := rng.randf_range(-45, 45)
        var z := rng.randf_range(-45, 45)
        if abs(x) < 5 or Vector2(x + 12, z - 22).length() < 16:
            continue
        _make_box("TreeTrunk_%d" % i, Vector3(x, 1.1, z), Vector3(0.35, 2.2, 0.35), Color("#71523b"))
        var crown := MeshInstance3D.new()
        var sphere := SphereMesh.new()
        sphere.radius = 1.4
        sphere.height = 2.8
        crown.mesh = sphere
        crown.position = Vector3(x, 3.1, z)
        var leaves := StandardMaterial3D.new()
        leaves.albedo_color = Color("#448653")
        crown.material_override = leaves
        add_child(crown)

func _create_player() -> void:
    player = CharacterBody3D.new()
    player.name = "PlaceholderAvatar"
    player.position = Vector3(0, 0.8, 0)
    var visual := MeshInstance3D.new()
    var body := CapsuleMesh.new()
    body.radius = 0.42
    body.height = 1.6
    visual.mesh = body
    var outfit := StandardMaterial3D.new()
    outfit.albedo_color = Color("#397c61")
    visual.material_override = outfit
    player.add_child(visual)
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.6
    collision.shape = capsule
    player.add_child(collision)
    add_child(player)
    camera = Camera3D.new()
    camera.current = true
    camera.fov = 60
    add_child(camera)

func _create_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := VBoxContainer.new()
    panel.position = Vector2(18, 25)
    layer.add_child(panel)
    status = Label.new()
    status.text = "S.u.G WORLD | Godot experiment"
    panel.add_child(status)
    var buttons := HBoxContainer.new()
    panel.add_child(buttons)
    for action in ["Fish", "Search", "Garden", "Save", "SAFE"]:
        var button := Button.new()
        button.text = action
        button.pressed.connect(_action.bind(action))
        buttons.add_child(button)
    var touch_controls := HBoxContainer.new()
    touch_controls.position = Vector2(18, 340)
    layer.add_child(touch_controls)
    for spec in [["◀", -1.0, 0.0], ["▲", 0.0, 1.0], ["▼", 0.0, -1.0], ["▶", 1.0, 0.0]]:
        var key_button := Button.new()
        key_button.text = str(spec[0])
        key_button.custom_minimum_size = Vector2(72, 72)
        key_button.button_down.connect(_touch_down.bind(float(spec[1]), float(spec[2])))
        key_button.button_up.connect(_touch_up)
        touch_controls.add_child(key_button)
    overlay = PanelContainer.new()
    overlay.position = Vector2(20, 110)
    overlay.custom_minimum_size = Vector2(330, 130)
    overlay.visible = false
    layer.add_child(overlay)
    var content := VBoxContainer.new()
    overlay.add_child(content)
    var text := Label.new()
    text.text = "15 | SAFE\n緊急時：119／110\n通信・ログイン不要"
    content.add_child(text)
    var back := Button.new()
    back.text = "ゲームに戻る"
    back.pressed.connect(_close_overlay)
    content.add_child(back)

func _touch_down(turn_value: float, forward_value: float) -> void:
    touch_turn = turn_value
    touch_forward = forward_value

func _touch_up() -> void:
    touch_turn = 0.0
    touch_forward = 0.0

func _close_overlay() -> void:
    overlay.visible = false
    overlay_open = false
    navigation.back()
    player.position = state.world_position

func _action(action: String) -> void:
    if action == "Save":
        state.world_position = player.position
        status.text = "保存しました" if state.save() else "保存失敗"
        return
    if action == "SAFE":
        state.world_position = player.position
        navigation.open_screen("15", player.position)
        overlay.visible = true
        overlay_open = true
        return
    if overlay_open:
        return
    if action == "Fish":
        if player.position.distance_to(lake_position) > 15:
            status.text = "湖に近づこう"
        else:
            fish_attempts += 1
            state.award_once("fish_%d" % fish_attempts, "fish", 1)
            status.text = "魚が釣れた"
            if fish_attempts == 2 and state.award_once("lake_key_first", "key", 1):
                status.text = "古い鍵が釣れた！"
    elif action == "Search":
        status.text = "種を発見した" if state.award_once("seed_first", "seeds", 1) else "ここはもう調べた"
    elif action == "Garden":
        if player.position.distance_to(house_position) < 7 and int(state.inventory.get("seeds", 0)) > 0:
            state.inventory["seeds"] = int(state.inventory["seeds"]) - 1
            state.garden["planted"] = int(state.garden.get("planted", 0)) + 1
            status.text = "庭に種を植えた"
        else:
            status.text = "種を持って家に近づこう"

func _physics_process(delta: float) -> void:
    var forward := (1.0 if (Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) else 0.0) - (1.0 if (Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) else 0.0)
    var turn := (1.0 if (Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) else 0.0) - (1.0 if (Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)) else 0.0)
    forward = clampf(forward + touch_forward, -1.0, 1.0)
    turn = clampf(turn + touch_turn, -1.0, 1.0)
    if overlay_open:
        forward = 0.0
        turn = 0.0
    heading += turn * delta * 1.8
    player.rotation.y = heading
    var direction := Vector3(sin(heading), 0, cos(heading))
    player.velocity.x = direction.x * forward * 4.0
    player.velocity.z = direction.z * forward * 4.0
    player.velocity.y = 0
    player.move_and_slide()
    var target := player.global_position + Vector3(-sin(heading) * 7, 5, -cos(heading) * 8)
    camera.global_position = camera.global_position.lerp(target, min(1.0, delta * 6.0))
    camera.look_at(player.global_position + Vector3(0, 1, 2))
