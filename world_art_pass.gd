extends RefCounted
class_name WorldArtPass

# First environment art pass; procedural geometry, no external asset licensing.
static func _material(color: String, metallic: float = 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(color)
    m.roughness = 0.82
    m.metallic = metallic
    return m

static func _mesh(parent: Node3D, name: String, mesh: Mesh, position: Vector3, color: String) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = mesh
    node.position = position
    node.material_override = _material(color)
    parent.add_child(node)
    return node

static func _box(parent: Node3D, name: String, size: Vector3, position: Vector3, color: String) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    return _mesh(parent, name, mesh, position, color)

static func _tree(parent: Node3D, x: float, z: float, scale_value: float, variant: int) -> void:
    var trunk := CylinderMesh.new()
    trunk.top_radius = 0.12 * scale_value
    trunk.bottom_radius = 0.24 * scale_value
    trunk.height = 2.0 * scale_value
    _mesh(parent, "Trunk", trunk, Vector3(x, scale_value, z), "#73533d")
    if variant == 0:
        for tier in range(3):
            var crown := CylinderMesh.new()
            crown.top_radius = 0.0
            crown.bottom_radius = (1.35 - float(tier) * 0.22) * scale_value
            crown.height = 2.0 * scale_value
            _mesh(parent, "PineCrown", crown, Vector3(x, (2.0 + float(tier) * 0.75) * scale_value, z), "#396e50")
    else:
        for tier in range(2):
            var crown := SphereMesh.new()
            crown.radius = (1.1 - float(tier) * 0.15) * scale_value
            crown.height = crown.radius * 2.0
            _mesh(parent, "BroadleafCrown", crown, Vector3(x + float(tier) * 0.35, (2.45 + float(tier) * 0.38) * scale_value, z), "#548f56")

static func install(scene: Node3D) -> void:
    var root := Node3D.new()
    root.name = "WorldArtPass01"
    scene.add_child(root)
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261101
    # Keep the path, house and fishing lake clear.
    for i in range(65):
        var x := rng.randf_range(-44.0, 44.0)
        var z := rng.randf_range(-42.0, 46.0)
        if absf(x) < 6.0 or Vector2(x + 12.0, z - 22.0).length() < 17.0:
            continue
        if Vector2(x - 8.0, z - 22.0).length() < 9.0:
            continue
        _tree(root, x, z, rng.randf_range(0.7, 1.3), i % 3)
    # Cottage detail: front windows, doorway and a pitched roof silhouette.
    _box(root, "CottageDoor", Vector3(1.2, 2.1, 0.12), Vector3(8.0, 1.05, 19.94), "#664d3b")
    for x in [6.25, 9.75]:
        _box(root, "Window", Vector3(0.85, 0.95, 0.12), Vector3(x, 2.15, 19.92), "#9ed2cc")
        _box(root, "WindowBar", Vector3(0.09, 1.0, 0.16), Vector3(x, 2.15, 19.84), "#6c4937")
    for x in [5.3, 10.7]:
        _box(root, "CottageBeam", Vector3(0.18, 3.3, 0.2), Vector3(x, 1.65, 19.9), "#74503b")
    # Roof trim, chimney and front step.
    _box(root, "RoofTrim", Vector3(6.25, 0.16, 5.2), Vector3(8, 3.84, 22), "#684437")
    _box(root, "Chimney", Vector3(0.72, 1.6, 0.72), Vector3(9.5, 4.35, 23.1), "#8c5a49")
    _box(root, "FrontStep", Vector3(2.2, 0.18, 1.1), Vector3(8, 0.12, 19.1), "#aa9d86")
    for i in range(5):
        _box(root, "FencePost", Vector3(0.15, 0.8, 0.15), Vector3(5.6 + float(i) * 1.4, 0.4, 8.4), "#9d7854")
    _box(root, "FenceRail", Vector3(6.0, 0.12, 0.12), Vector3(8.4, 0.58, 8.4), "#a98760")
    # Garden beds and low fencing placed to the side of the path.
    for bed in range(3):
        var z := 11.0 + float(bed) * 2.6
        _box(root, "GardenSoil", Vector3(2.2, 0.18, 1.65), Vector3(8.5, 0.15, z), "#6a4b35")
        for seedling in range(3):
            var plant := SphereMesh.new()
            plant.radius = 0.22
            plant.height = 0.44
            _mesh(root, "GardenPlant", plant, Vector3(7.75 + float(seedling) * 0.75, 0.42, z), "#4b9951")
    # Decorative rocks away from walkable corridor.
    for i in range(28):
        var x := rng.randf_range(-44.0, 44.0)
        var z := rng.randf_range(-40.0, 45.0)
        if absf(x) < 5.5 or Vector2(x + 12.0, z - 22.0).length() < 16.0:
            continue
        var rock := SphereMesh.new()
        rock.radius = rng.randf_range(0.22, 0.65)
        rock.height = rock.radius * 1.2
        _mesh(root, "Stone", rock, Vector3(x, rock.height * 0.32, z), "#9a9b89")
