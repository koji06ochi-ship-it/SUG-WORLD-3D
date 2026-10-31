extends RefCounted
class_name WorldNavigation

const SCREENS := {
 "01": "WORLD HOME", "02": "MY AVATAR", "03": "MY STORY",
 "04": "MIND PATH", "05": "MEMORY ITEMS", "06": "PEOPLE",
 "07": "FEELING", "08": "BABY STEP", "09": "CHALLENGE",
 "10": "REFRAME", "11": "CAN / CANNOT", "12": "SELF CARE",
 "13": "AI PARTNER", "14": "COMMUNITY", "15": "SAFE",
 "16": "SETTINGS"
}
var current := "01"
var return_to := "01"
var world_position := Vector3.ZERO

func open_screen(id: String, player_position: Vector3) -> bool:
    if not SCREENS.has(id):
        return false
    if current != id:
        return_to = current
    world_position = player_position
    current = id
    return true

func back() -> String:
    current = return_to
    return current
