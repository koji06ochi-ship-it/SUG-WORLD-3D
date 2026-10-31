extends Node3D
# Procedural 3D environment: no paid assets, no external network requests.
# All coordinates preserve existing fishing/house/gate gameplay locations.
const LAKE := Vector2(-12.0, 22.0)
const HOUSE := Vector2(8.0, 22.0)
var rng := RandomNumberGenerator.new()

func elevation(x: float, z: float) -> float:
    var ridge: float = pow(maxf(0.0, (absf(x) - 12.0) / 23.0), 2.0) * (8.0 + 2.0 * sin(z * 0.08))
    var undulation: float = 0.32 * sin(x * 0.25) * cos(z * 0.15)
    var lake_d: float = Vector2((x - LAKE.x) / 17.0, (z - LAKE.y) / 12.0).length()
    if lake_d < 1.0:
        return -0.4
    if absf(x) < 3.5 and z > -15.0 and z < 48.0:
        return 0.0
    return maxf(0.0, ridge + undulation)

func material(color: Color, metallic: float = 0.0, roughness: float = 0.9) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    return m

func box_item(name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    var shape := BoxMesh.new()
    shape.size = size
    node.mesh = shape
    node.position = pos
    node.material_override = material(color)
    add_child(node)
    return node

func _ready() -> void:
    rng.seed = 20261101
    var environment := WorldEnvironment.new()
    var sky := Environment.new()
    sky.background_mode = Environment.BG_COLOR
    sky.background_color = Color("#a6d7e9")
    sky.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    sky.ambient_light_color = Color("#d6e7e3")
    sky.ambient_light_energy = 0.85
    environment.environment = sky
    add_child(environment)
    var sunlight := DirectionalLight3D.new()
    sunlight.rotation_degrees = Vector3(-48, -32, 0)
    sunlight.light_energy = 1.55
    add_child(sunlight)
    _terrain()
    _water()
    _cottage()
    _forest()
    _gate()

func _terrain() -> void:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var n := 100
    var extent := 85.0
    for z in n:
        for x in n:
            var x0: float = (float(x) / n * 2.0 - 1.0) * extent
            var x1: float = (float(x + 1) / n * 2.0 - 1.0) * extent
            var z0: float = (float(z) / n * 2.0 - 1.0) * extent
            var z1: float = (float(z + 1) / n * 2.0 - 1.0) * extent
            for point in [Vector2(x0,z0),Vector2(x1,z0),Vector2(x1,z1),Vector2(x0,z0),Vector2(x1,z1),Vector2(x0,z1)]:
                var y := elevation(point.x, point.y)
                var c := Color("#719d63")
                if y > 5.0:
                    c = c.lerp(Color("#84968c"), clampf((y - 5.0) / 12.0, 0.0, 0.8))
                if absf(point.x) < 3.5 and point.y > -15.0 and point.y < 48.0:
                    c = Color("#c5b18a")
                st.set_color(c)
                st.add_vertex(Vector3(point.x, y, point.y))
    st.generate_normals()
    var mesh := MeshInstance3D.new()
    mesh.name = "Terrain_Valley"
    mesh.mesh = st.commit()
    var m := material(Color.WHITE)
    m.vertex_color_use_as_albedo = true
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    mesh.material_override = m
    add_child(mesh)
    # Gameplay collision uses a safe flat base until heightfield collision is tested.
    var floor := StaticBody3D.new()
    floor.position.y = -0.55
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(170, 1, 170)
    collider.shape = shape
    floor.add_child(collider)
    add_child(floor)

func _water() -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = "Lake"
    var surface := CylinderMesh.new()
    surface.top_radius = 1.0
    surface.bottom_radius = 1.0
    surface.height = 0.08
    mesh.mesh = surface
    mesh.scale = Vector3(15.0, 1.0, 9.0)
    mesh.position = Vector3(LAKE.x, -0.06, LAKE.y)
    var m := material(Color("#49a9b8"), 0.05, 0.23)
    mesh.material_override = m
    add_child(mesh)

func _cottage() -> void:
    box_item("Cottage", Vector3(HOUSE.x, 1.6, HOUSE.y), Vector3(5.5,3.2,4.8), Color("#e5c59a"))
    var left := box_item("RoofLeft", Vector3(HOUSE.x-1.35,3.65,HOUSE.y),Vector3(3.3,0.35,5.4),Color("#885344"))
    left.rotation.z = -0.48
    var right := box_item("RoofRight", Vector3(HOUSE.x+1.35,3.65,HOUSE.y),Vector3(3.3,0.35,5.4),Color("#885344"))
    right.rotation.z = 0.48
    box_item("Door",Vector3(HOUSE.x,1.05,HOUSE.y-2.47),Vector3(1.15,2.1,0.1),Color("#694a39"))
    for dx in [-1.8,1.8]:
        box_item("Window",Vector3(HOUSE.x+dx,2.0,HOUSE.y-2.47),Vector3(0.9,1.0,0.12),Color("#a6d3cf"))

func _forest() -> void:
    for i in 115:
        var x := rng.randf_range(-76.0,76.0)
        var z := rng.randf_range(-75.0,75.0)
        if absf(x) < 5.0 or Vector2((x-LAKE.x)/18.0,(z-LAKE.y)/13.0).length() < 1.0 or Vector2(x-HOUSE.x,z-HOUSE.y).length() < 8.0:
            continue
        var h := elevation(x,z)
        var scale_factor := rng.randf_range(0.75,1.4)
        var trunk := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.12 * scale_factor
        cylinder.bottom_radius = 0.23 * scale_factor
        cylinder.height = 2.2 * scale_factor
        trunk.mesh = cylinder
        trunk.position = Vector3(x,h+1.1*scale_factor,z)
        trunk.material_override = material(Color("#71513c"))
        add_child(trunk)
        var crown := MeshInstance3D.new()
        var foliage := SphereMesh.new()
        foliage.radius = 1.3 * scale_factor
        foliage.height = 2.4 * scale_factor
        crown.mesh = foliage
        crown.position = Vector3(x,h+2.8*scale_factor,z)
        crown.material_override = material(Color("#417c50") if i % 3 else Color("#598b56"))
        add_child(crown)

func _gate() -> void:
    for x in [-8.0,-5.0]:
        box_item("AncientGatePillar",Vector3(x,1.75,37),Vector3(0.8,3.5,0.8),Color("#8e8d85"))
    box_item("AncientGateLintel",Vector3(-6.5,3.7,37),Vector3(4.0,0.65,0.9),Color("#8e8d85"))
