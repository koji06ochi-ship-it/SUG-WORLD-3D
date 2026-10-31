extends RefCounted
class_name WorldTerrain

# Mobile-friendly vertex terrain. Separate from the legacy flat test scene.
static func elevation(x: float, z: float) -> float:
    var edge: float = maxf(0.0, (absf(x) - 10.0) / 24.0)
    var ridge: float = edge * edge * (8.0 + 2.0 * sin(z * 0.09 + x * 0.04))
    var ripples: float = 0.22 * sin(x * 0.28) * cos(z * 0.18)
    var lake_distance: float = Vector2((x + 12.0) / 15.0, (z - 22.0) / 10.0).length()
    if lake_distance < 1.1:
        return 0.0
    if absf(x) < 3.5 and z > -15.0 and z < 46.0:
        return 0.0
    return maxf(0.0, ridge + ripples)

static func create(parent: Node3D) -> MeshInstance3D:
    var vertices := PackedVector3Array()
    var colors := PackedColorArray()
    var indices := PackedInt32Array()
    const COUNT := 64
    const SIZE := 140.0
    for z in range(COUNT + 1):
        for x in range(COUNT + 1):
            var px: float = (float(x) / COUNT - 0.5) * SIZE
            var pz: float = (float(z) / COUNT - 0.5) * SIZE
            var y := elevation(px, pz)
            vertices.append(Vector3(px, y, pz))
            var t: float = clampf(y / 13.0, 0.0, 1.0)
            var c := Color("#72a564").lerp(Color("#879184"), t)
            if absf(px) < 3.5 and pz > -15.0 and pz < 46.0:
                c = Color("#c9b88f")
            colors.append(c)
    for z in range(COUNT):
        for x in range(COUNT):
            var i: int = z * (COUNT + 1) + x
            indices.append_array(PackedInt32Array([i, i + COUNT + 1, i + 1, i + 1, i + COUNT + 1, i + COUNT + 2]))
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_COLOR] = colors
    arrays[Mesh.ARRAY_INDEX] = indices
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    var instance := MeshInstance3D.new()
    instance.name = "WORLD_Terrain"
    instance.mesh = mesh
    var material := StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.roughness = 0.94
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    instance.material_override = material
    parent.add_child(instance)
    return instance
