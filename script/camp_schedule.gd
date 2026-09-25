extends RefCounted
class_name CampSchedule

## Where each NPC is in the camp at the current day and hour (docs_v2/systemy/npc.md).
## Returns {"place": id, "marker": marker name, "pose": animation}, or {} when the NPC is away
## (in the tunnels, not arrived yet, gone). The StoryDirector applies it; dialogues can ask
## GameState.npc_place(id) where someone is.
##
## Day rhythm: breakfast before 8 (Tekla cooks, the others eat), work 8–18 (everyone at their
## area), supper 18–20, then the evening. Story states (sanity, trust, choices) come first.

static func placement(npc_id: StringName) -> Dictionary:
	match npc_id:
		&"miroslaw":
			return _miroslaw()
		&"bolko":
			return _bolko()
		&"racibor":
			return _racibor()
		&"tekla":
			return _tekla()
		&"dobrawa":
			return _dobrawa()
	return {}

static func _at(place: String, marker: String, pose: StringName) -> Dictionary:
	return {"place": place, "marker": marker, "pose": pose}

static func _supper() -> bool:
	return GameState.hour < 20.0

static func _miroslaw() -> Dictionary:
	var band := GameState.sanity_band(&"miroslaw")
	if GameState.day >= 2 and band in ["na_krawedzi", "zalamany"]:
		return _at("kat", "MiroslawCorner", &"Crouch_Idle")
	if GameState.part_of_day() == "dzien":
		return _at("proch", "MiroslawPowder", &"Crouch_Idle")
	# He eats alone by the fire, as far from it as the log allows.
	return _at("ognisko", "MiroslawFire", &"Sitting_Idle")

static func _bolko() -> Dictionary:
	var trust := GameState.rep(&"bolko")
	if GameState.day >= 2 and trust < 0:
		return _at("odwrocony", "BolkoAway", &"Idle")
	match GameState.part_of_day():
		"rano":
			if GameState.day >= 2 and trust >= 10:
				return _at("poslanie", "BolkoBed", &"Idle")
			return _at("stol", "BolkoEat", &"Sitting_Idle")
		"dzien":
			return _at("magazyn", "BolkoStorage", &"Fixing_Kneeling")
	if _supper():
		return _at("stol", "BolkoEat", &"Sitting_Idle")
	return _at("legowisko", "BolkoEvening", &"Idle")

static func _racibor() -> Dictionary:
	match GameState.part_of_day():
		"rano":
			return _at("stol", "RaciborEat", &"Sitting_Idle")
		"dzien":
			return _at("dowodztwo", "RaciborTable", &"Idle")
	if _supper():
		return _at("stol", "RaciborEat", &"Sitting_Idle")
	return _at("dowodztwo", "RaciborTable", &"Idle")

static func _tekla() -> Dictionary:
	if GameState.has_flag("tekla_reported"):
		return _at("pod_straza", "TeklaGuarded", &"Sitting_Idle")
	match GameState.part_of_day():
		"rano":
			return _at("kuchnia", "TeklaCook", &"Interact")
		"dzien":
			return _at("lada", "TeklaCounter", &"Idle")
	if _supper():
		return _at("kuchnia", "TeklaCook", &"Interact")
	return _at("lada", "TeklaCounter", &"Idle")

static func _dobrawa() -> Dictionary:
	# She comes down the shaft during the first night.
	if GameState.day < 2 or GameState.has_flag("dobrawa_left"):
		return {}
	var hour := GameState.hour
	if hour < 9.0:
		return _at("dowodztwo", "DobrawaLeader", &"Idle")
	if GameState.day >= GameState.LAST_DAY or hour < 12.0:
		return _at("wozki", "DobrawaCarts", &"Spell_Simple_Idle")
	# Around noon she goes down on her own and comes back in the afternoon.
	if hour < 16.0:
		return {}
	return _at("na_uboczu", "DobrawaApart", &"Idle")
