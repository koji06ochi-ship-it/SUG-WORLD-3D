extends Node3D
class_name WorldValleyTerrain

@export var terrain_size := 150.0
@export var subdivisions := 90

func elevation(x: float, z: float) -> float:
    var side := maxf(0.0, (absf(x) - 12.0) / 22.0)
    var ridge := side * side * (7.0 + 2.0 * sin(z * 0.1 + x * 0.04))
    var hill := 0.28 * sin(x * 0.24) * cos(z * 0.17)
    if Vector2((x + 12.0) / 16.0, (z - 22.0) / 11.0).length() < 1.1:
        return 0.0
    return maxf(0.0, ridge + hill)

func _ready() -> void:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for zi in range(subdivisions):
        for xi in range(subdivisions):
            var x0 := (float(xi) / float(subdivisions) - 0.5) * terrain_size
            var x1 := (float(xi + 1) / float(subdivisions) - 0.5) * terrain_size
            var z0 := (float(zi) / float(subdivisions) - 0.5) * terrain_size
            var z1 := (float(zi + 1) / float(subdivisions) - 0.5) * terrain_size
            var a := Vector3(x0, elevation(x0,z0), z0)
            var b := Vector3(x1, elevation(x1,z0), z0)
            var c := Vector3(x0, elevation(x0,z1), z1)
            var d := Vector3(x1, elevation(x1,z1), z1)
            for p in [a,c,b,b,c,d]:
                tool.set_color(Color("#69985d").lerp(Color("#8d9288"),clampf(p.y/13.0,0.0,0.7)))
                tool.add_vertex(p)
    tool.generate_normals()
    var visual := MeshInstance3D.new()
    visual.mesh = tool.commit()
    var material := StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    visual.material_override = material
    add_child(visual)
    var ground := StaticBody3D.new()
    var collider := CollisionShape3D.new()
    collider.shape = visual.mesh.create_trimesh_shape()
    ground.add_child(collider)
    add_child(ground)
