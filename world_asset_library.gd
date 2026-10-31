extends RefCounted
class_name WorldAssetLibrary

# CC0 models from Kenney, redistributed in syuhei176/ai-game-assets.
# Asset files must exist in res://assets/kenney/ before enabling.
const TREE_PINE := "res://assets/kenney/tree_pine.glb"
const TREE_OAK := "res://assets/kenney/tree_oak.glb"
const ROCK := "res://assets/kenney/rock_large.glb"
const HOUSE := "res://assets/kenney/building_house.glb"

static func _spawn(parent: Node3D, path: String, at: Vector3, size: float) -> bool:
    if not ResourceLoader.exists(path):
        push_warning("Missing CC0 asset: " + path)
        return false
    var scene := load(path) as PackedScene
    if scene == null:
        return false
    var node := scene.instantiate() as Node3D
    if node == null:
        return false
    node.position = at
    node.scale = Vector3.ONE * size
    parent.add_child(node)
    return true

static func install(parent: Node3D) -> void:
    var root := Node3D.new()
    root.name = "KenneyCC0Models"
    parent.add_child(root)
    # Visible GLB showcase along the starting route, clear of the walkable corridor.
    _spawn(root, TREE_PINE, Vector3(5.8, 0, 10), 4.5)
    _spawn(root, TREE_OAK, Vector3(-6.5, 0, 16), 4.5)
    _spawn(root, ROCK, Vector3(5.8, 0, 15), 2.2)
    # Real mesh assets; leave gameplay paths and lake clear.
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261103
    for i in range(42):
        var x := rng.randf_range(-43.0, 43.0)
        var z := rng.randf_range(-39.0, 44.0)
        if absf(x) < 7.0 or Vector2(x + 12.0, z - 22.0).length() < 18.0 or Vector2(x - 8.0, z - 22.0).length() < 10.0:
            continue
        _spawn(root, TREE_PINE if i % 3 == 0 else TREE_OAK, Vector3(x, 0, z), rng.randf_range(3.5, 5.5))
    for i in range(16):
        var x := rng.randf_range(-42.0, 42.0)
        var z := rng.randf_range(-35.0, 42.0)
        if absf(x) < 6.0 or Vector2(x + 12.0, z - 22.0).length() < 16.0:
            continue
        _spawn(root, ROCK, Vector3(x, 0, z), rng.randf_range(1.5, 2.8))
    # House asset placed as a separate village building; preserve interactive cottage.
    _spawn(root, HOUSE, Vector3(19, 0, 32), 2.2)
