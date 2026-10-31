extends RefCounted
class_name WorldImportedAssets

const BASE := "res://assets/kenney/nature/"
const MODEL_NAMES := ["tree-oak", "tree-pinedefaulta", "tree-detailed", "rock-largea", "rock-smallb", "flower-reda", "plant-bush", "canoe"]

static func _place(root: Node3D, model_name: String, at: Vector3, scale_value: float) -> bool:
    var path := BASE + model_name + ".glb"
    if not ResourceLoader.exists(path):
        push_warning("Missing Kenney GLB: " + path)
        return false
    var packed := load(path) as PackedScene
    if packed == null:
        push_warning("Invalid Kenney GLB: " + path)
        return false
    var node := packed.instantiate() as Node3D
    if node == null:
        return false
    node.name = "Kenney_" + model_name
    node.position = at
    node.scale = Vector3.ONE * scale_value
    root.add_child(node)
    return true

static func install(scene: Node3D) -> void:
    var root := Node3D.new()
    root.name = "ImportedKenneyCC0"
    scene.add_child(root)
    var positions := [
        ["tree-oak", Vector3(6.2, 0.0, 10), 5.0],
        ["tree-oak", Vector3(-7.5, 0.0, 11), 5.8],
        ["tree-pinedefaulta", Vector3(7.5, 0.0, 19), 6.0],
        ["tree-pinedefaulta", Vector3(-8.5, 0.0, 17), 5.5],
        ["tree-detailed", Vector3(9.0, 0.0, 8), 5.0],
        ["rock-largea", Vector3(-6.0, 0.0, 7), 3.0],
        ["rock-smallb", Vector3(6.0, 0.0, 8), 2.5],
        ["plant-bush", Vector3(5.8, 0.0, 15), 4.0],
        ["flower-reda", Vector3(5.5, 0.0, 6), 4.0],
        ["canoe", Vector3(-13, 0.2, 20), 4.0]
    ]
    var count := 0
    for item in positions:
        if _place(root, str(item[0]), item[1], float(item[2])):
            count += 1
    print("KENNEY_ASSETS_INSTANCED=", count)
