extends RefCounted
class_name WorldLandscape

# Decorative landscape only; does not alter the existing collision ground or game logic.
static func _mat(hex: String, transparent: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(hex)
    m.roughness = 0.8
    if transparent:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.albedo_color.a = 0.82
    return m

static func _shape(parent: Node3D, name: String, mesh: Mesh, at: Vector3, hex: String) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name
    n.mesh = mesh
    n.position = at
    n.material_override = _mat(hex)
    parent.add_child(n)
    return n

static func install(scene: Node3D) -> void:
    var root := Node3D.new()
    root.name = "WorldLandscape01"
    scene.add_child(root)
    # Low-poly ridge peaks: taper into the horizon, no large flat wall.
    var ridge_rng := RandomNumberGenerator.new()
    ridge_rng.seed = 20261102
    for row in range(3):
        for i in range(13):
            var x := -84.0 + float(i) * 14.0 + ridge_rng.randf_range(-3.0, 3.0)
            var z := 105.0 + float(row) * 21.0 + ridge_rng.randf_range(-4.0, 4.0)
            var peak_height := ridge_rng.randf_range(13.0, 29.0) * (1.0 + float(row) * 0.15)
            var mountain := CylinderMesh.new()
            mountain.top_radius = 0.0
            mountain.bottom_radius = ridge_rng.randf_range(12.0, 19.0)
            mountain.height = peak_height
            mountain.radial_segments = 7
            var color := "#708c7f" if row == 0 else ("#879b99" if row == 1 else "#a0adad")
            _shape(root, "RidgePeak", mountain, Vector3(x, peak_height * 0.5 - 2.0, z), color)
            if row > 0 and peak_height > 25.0:
                var cap := CylinderMesh.new()
                cap.top_radius = 0.0
                cap.bottom_radius = mountain.bottom_radius * 0.22
                cap.height = peak_height * 0.24
                cap.radial_segments = 7
                _shape(root, "SnowCap", cap, Vector3(x, peak_height * 0.88 - 2.0, z), "#e2e9e4")
    # Water surface is kept inside the existing lake footprint.
    var water := PlaneMesh.new()
    water.size = Vector2(19.6, 11.6)
    var lake := _shape(root, "LakeSurface", water, Vector3(-12, 0.14, 22), "#45a4b6")
    lake.material_override = _mat("#4aaabb", true)
    # Pebbled banks on the north and south sides.
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261101
    for i in range(46):
        var a := rng.randf_range(0.0, TAU)
        var x := -12.0 + cos(a) * rng.randf_range(10.4, 11.8)
        var z := 22.0 + sin(a) * rng.randf_range(6.4, 7.5)
        if absf(x) < 4.0:
            continue
        var pebble := SphereMesh.new()
        pebble.radius = rng.randf_range(0.12, 0.36)
        pebble.height = pebble.radius * 1.1
        _shape(root, "LakePebble", pebble, Vector3(x, 0.16, z), "#b1ab92")
    # Foreground flowers: keep path and interactions clear.
    for i in range(85):
        var x := rng.randf_range(-38.0, 38.0)
        var z := rng.randf_range(-25.0, 44.0)
        if absf(x) < 5.0 or Vector2(x + 12.0, z - 22.0).length() < 16.0:
            continue
        var bloom := SphereMesh.new()
        bloom.radius = 0.12
        bloom.height = 0.24
        var palette := ["#f5d985", "#f4b2ab", "#d3c0f0"]
        _shape(root, "Wildflower", bloom, Vector3(x, 0.18, z), palette[i % 3])
