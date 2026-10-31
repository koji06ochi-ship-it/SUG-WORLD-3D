extends RefCounted
class_name WorldJourney

# A deterministic, offline-first 10-minute play sequence. Not an AI service.
const STAGES := [
 {"id":"arrival","title":"谷に到着","hint":"道を歩き、周囲を調べよう","seconds":0},
 {"id":"discover","title":"最初の発見","hint":"探索で種を見つけよう","seconds":60},
 {"id":"lake","title":"湖の時間","hint":"湖へ向かい、釣りをしてみよう","seconds":180},
 {"id":"garden","title":"小さな庭","hint":"家の庭に種を植えてみよう","seconds":360},
 {"id":"gate","title":"秘密の門","hint":"古い鍵を持って門を探そう","seconds":480},
 {"id":"reflect","title":"今日の発見","hint":"発見を振り返って記録しよう","seconds":600}
]
var seconds := 0.0
var discovered := false
var fished := false
var planted := false
var gate_seen := false

func progress(delta: float) -> void:
    seconds += maxf(0.0, delta)

func mark(action: String) -> void:
    match action:
        "Search": discovered = true
        "Fish": fished = true
        "Garden": planted = true
        "Gate": gate_seen = true

func stage_index() -> int:
    if not discovered:
        return 0
    if not fished:
        return 1
    if not planted:
        return 2
    if not gate_seen:
        return 3
    return 4 if seconds < 600.0 else 5

func hint() -> String:
    var index := stage_index()
    return str(STAGES[index]["hint"])

func to_dict() -> Dictionary:
    return {"seconds":seconds,"discovered":discovered,"fished":fished,"planted":planted,"gateSeen":gate_seen}

func apply_dict(d: Dictionary) -> void:
    seconds = maxf(0.0,float(d.get("seconds",0.0)))
    discovered = bool(d.get("discovered",false))
    fished = bool(d.get("fished",false))
    planted = bool(d.get("planted",false))
    gate_seen = bool(d.get("gateSeen",false))
