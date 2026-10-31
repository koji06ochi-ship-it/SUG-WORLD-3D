extends RefCounted
class_name WorldState

const SAVE_PATH := "user://world_save_v1.json"
var schema_version := 1
var world_position := Vector3(0, 0.8, 0)
var inventory := {"fish": 0, "key": 0, "seeds": 0, "coins": 0, "insight": 0}
var garden := {"planted": 0}
var quest_flags := {"lake": false, "gate": false}
var event_ids: Array[String] = []
var avatar_preset_id := ""
var consent_state := {"ai": false, "sharing": false}
var screen_id := "01"
var return_to := "01"

func to_dict() -> Dictionary:
    return {"schemaVersion": schema_version, "worldPosition": [world_position.x, world_position.y, world_position.z], "inventory": inventory.duplicate(true), "gardenState": garden.duplicate(true), "questFlags": quest_flags.duplicate(true), "npcEventIds": event_ids.duplicate(), "avatarPresetId": avatar_preset_id, "consentState": consent_state.duplicate(true), "screenId": screen_id, "returnTo": return_to}

func apply_dict(d: Dictionary) -> bool:
    if int(d.get("schemaVersion", -1)) != schema_version:
        return false
    var p: Array = d.get("worldPosition", [])
    if p.size() != 3:
        return false
    world_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
    inventory = d.get("inventory", inventory).duplicate(true)
    garden = d.get("gardenState", garden).duplicate(true)
    quest_flags = d.get("questFlags", quest_flags).duplicate(true)
    event_ids.assign(d.get("npcEventIds", []))
    avatar_preset_id = str(d.get("avatarPresetId", ""))
    consent_state = d.get("consentState", consent_state).duplicate(true)
    screen_id = str(d.get("screenId", "01"))
    return_to = str(d.get("returnTo", "01"))
    return true

func save() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(to_dict()))
    file.flush()
    return file.get_error() == OK

func load_save() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var data: Variant = JSON.parse_string(file.get_as_text())
    return data is Dictionary and apply_dict(data)

func award_once(event_id: String, item: String, amount: int) -> bool:
    if event_id.is_empty() or event_ids.has(event_id):
        return false
    event_ids.append(event_id)
    inventory[item] = int(inventory.get(item, 0)) + amount
    return true
