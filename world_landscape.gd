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
    # Irregular distant ridgeline built as a continuous faceted mesh, not a wall of cones.
    var ridge_rng := RandomNumberGenerator.new()
    ridge_rng.seed = 20261102
    for row in range(3):
        var verts := PackedVector3Array()
        var indices := PackedInt32Array()
        var cols := PackedColorArray()
        var distance := 95.0 + float(row) * 23.0
        for i in range(35):
            var x := -105.0 + float(i) * 6.0
            var height := 9.0 + 7.0 * absf(sin(float(i) * 0.37 + float(row))) + ridge_rng.randf_range(0.0, 8.0)
            height *= 1.0 + float(row) * 0.16
            verts.append(Vector3(x, -2.0, distance))
            verts.append(Vector3(x, height, distance + ridge_rng.randf_range(-2.0, 2.0)))
            var col := Color("#6c897c") if row == 0 else (Color("#8a9e9d") if row == 1 else Color("#a9b7b4"))
            cols.append(col.darkened(0.12))
            cols.append(col)
        for i in range(34):
            var k := i * 2
            indices.append_array(PackedInt32Array([k, k + 1, k + 2, k + 1, k + 3, k + 2]))
        var arrays := []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = verts
        arrays[Mesh.ARRAY_COLOR] = cols
        arrays[Mesh.ARRAY_INDEX] = indices
        var ridge_mesh := ArrayMesh.new()
        ridge_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        var ridge := _shape(root, "ContinuousRidge", ridge_mesh, Vector3.ZERO, "#ffffff")
        var ridge_material := StandardMaterial3D.new()
        ridge_material.vertex_color_use_as_albedo = true
        ridge_material.cull_mode = BaseMaterial3D.CULL_DISABLED
        ridge.material_override = ridge_material
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
