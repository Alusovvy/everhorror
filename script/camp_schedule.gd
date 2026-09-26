extends RefCounted
class_name CampSchedule

## Where each NPC is in the camp at the current day and hour (docs_v2/systemy/npc.md).
## Returns {"place": id, "marker": marker name, "pose": animation}, or {} when the NPC is away
## (in the tunnels, not arrived yet, gone). The StoryDirector applies it; dialogues can ask
## GameState.npc_place(id) where someone is.
##
## Day rhythm: breakfast before 8 (Tekla cooks, the others eat), work 8–18 (everyone at their
## area), supper 18–20, then the evening. Story states (sanity, trust, choices) come first.
## People who left or died (status "gone", "dead") are never in the camp; the Drudzy from
## Exitium are only met in the tunnels (FieldSchedule), except Sabina once she has joined.

static func placement(npc_id: StringName) -> Dictionary:
	if GameState.npcs.has(npc_id) and GameState.npc_status(npc_id) in ["gone", "dead"]:
		return {}
	# task_10: on day 1 five of them are on a shift in the first-level rooms (FieldSchedule).
	if GameState.away_first_day(npc_id):
		return {}
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
		&"wszebor":
			return _wszebor()
		&"nasir":
			return _nasir()
		&"hagiwara":
			return _hagiwara()
		&"sobek":
			return _sobek()
		&"anzelm":
			return _anzelm()
		&"sabina":
			return _sabina()
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

## Wszebor hews in the old working by day (FieldSchedule) and sings by the fire at night.
static func _wszebor() -> Dictionary:
	match GameState.part_of_day():
		"rano":
			return _at("stol", "WszeborEat", &"Sitting_Idle")
		"dzien":
			return {}
	return _at("ognisko", "WszeborFire", &"Sitting_Idle")

## Nasir sees to the camp's water; once he has oil he works at the pumps by day. The fever puts
## him on the box by Anzelm's sick bed.
static func _nasir() -> Dictionary:
	if GameState.has_fever(&"nasir"):
		return _at("chory", "NasirSick", &"Sitting_Idle")
	match GameState.part_of_day():
		"rano":
			return _at("stol", "NasirEat", &"Sitting_Idle")
		"dzien":
			if nasir_at_pumps():
				return {}
			return _at("woda", "NasirWater", &"Fixing_Kneeling")
	if _supper():
		return _at("stol", "NasirEat", &"Sitting_Idle")
	return _at("przy_wodzie", "NasirEvening", &"Crouch_Idle")

## From the day after he got the oil, Nasir spends his working hours at the pumps.
static func nasir_at_pumps() -> bool:
	return GameState.has_flag("nasir_at_pumps") and int(GameState.get_flag("nasir_at_pumps", 99)) < GameState.day

static func _hagiwara() -> Dictionary:
	match GameState.part_of_day():
		"rano":
			return _at("stol", "HagiwaraEat", &"Sitting_Idle")
		"dzien":
			return _at("ksiega", "HagiwaraLedger", &"Interact")
	if _supper():
		return _at("stol", "HagiwaraEat", &"Sitting_Idle")
	return _at("herbata", "HagiwaraTea", &"Sitting_Idle")

## Sobek guards the east exit day and night; at supper he plays dice at the common table.
static func _sobek() -> Dictionary:
	if GameState.part_of_day() == "wieczor" and _supper():
		return _at("kosci", "SobekDice", &"Sitting_Idle")
	return _at("straz", "SobekGuard", &"Idle")

static func _anzelm() -> Dictionary:
	if GameState.part_of_day() == "rano" and not GameState.has_fever(&"nasir"):
		return _at("modlitwa", "AnzelmPray", &"Fixing_Kneeling")
	return _at("izba", "AnzelmInfirmary", &"Interact")

## Sabina stays apart from the others; once Anzelm lets her, she helps with the sick.
static func _sabina() -> Dictionary:
	if not GameState.has_flag("sabina_joined"):
		return {}
	match GameState.part_of_day():
		"rano":
			return _at("z_boku", "SabinaApart", &"Idle_Torch")
		"dzien":
			if GameState.has_fever(&"nasir") and GameState.has_flag("anzelm_sabina_peace"):
				return _at("chorzy", "SabinaSick", &"Idle_Torch")
			return _at("wozek", "SabinaCart", &"Idle_Torch")
	return _at("wieczor", "SabinaEvening", &"Idle_Torch")
