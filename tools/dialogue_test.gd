extends SceneTree
## Usage: godot --headless --path . --script res://tools/dialogue_test.gd
## Plays the demo's dialogues without UI (picks responses by text) and checks the state:
## the dialect switch, Mirosław and Bolko (day 1), the new NPCs and their quests, the riddle
## wall, the crystal, the night texts and Racibor's announcement on day 3; task_05: the week,
## items and the new people (camp and Exitium), Racibor's reminder and reckoning; task_09: Hrapek
## (verse, running away after three questions, the fish, the body) and the fish quest.

var _failures := 0
var _requests: Array[String] = []
## Every line shown by _talk, as the player would read it.
var _seen: Array[String] = []
var gs
var dm

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	dm = root.get_node("DialogueManager")
	gs.action_requested.connect(func(a): _requests.append(a))
	var mir: Resource = load("res://dialogue/miroslaw.dialogue")
	var bolko: Resource = load("res://dialogue/bolko.dialogue")
	var system: Resource = load("res://dialogue/system.dialogue")
	var racibor: Resource = load("res://dialogue/racibor.dialogue")
	var tekla: Resource = load("res://dialogue/tekla.dialogue")
	var dobrawa: Resource = load("res://dialogue/dobrawa.dialogue")
	var wall: Resource = load("res://dialogue/sciana.dialogue")

	print("--- Silesian dialect switch")
	var settings = root.get_node("Settings")
	_check_gwara_coverage()
	settings.silesian_dialect = false
	settings.apply()
	var plain: String = await _first_line_of(mir, "Mirosław")
	gs.reset()  # the intro sets met_miroslaw
	settings.silesian_dialect = true
	settings.apply()
	var gwara: String = await _first_line_of(mir, "Mirosław")
	_check(plain == "Ty nowy? Siadaj, jak chcesz. Byle mi nad głową nie stać.", "original line with the dialect off (got '%s')" % plain)
	_check(gwara == "Ty nowy? Siadej, jak chcesz. Ino mi nad gowom niy stój.", "Silesian line with the dialect on (got '%s')" % gwara)
	gs.reset()

	print("--- Mirosław: first talk, ask about the collapse")
	await _talk(mir, "start", ["Co się stało z zachodnim chodnikiem?", "Muszę iść."])
	_check(gs.has_flag("met_miroslaw"), "met_miroslaw set")
	_check(gs.quest_state("lonty") == "active", "quest lonty started")

	print("--- Mirosław: deliver fuses, then ask to blast")
	gs.give_item("lonty")
	await _talk(mir, "start", ["Mam dla ciebie lonty", "Wysadź zawał na zachodzie. (4 h)"])
	_check(not gs.has_item("lonty"), "fuses taken")
	_check("Mirosław: Pokoż. No, gryfnie. Stare, ale suche. Ftoś je porządnie zawinął." in _seen, "Silesian line with [wait] resolves")
	_check(gs.has_flag("fuses_delivered"), "fuses_delivered set")
	_check(gs.rep("miroslaw") == 10, "Mirosław rep +10 (got %d)" % gs.rep("miroslaw"))
	_check("blast" in _requests, "blast requested")

	print("--- Mirosław: too late for blasting")
	gs.hour = 20.0
	_requests.clear()
	await _talk(mir, "start", ["Wysadź zawał na zachodzie. (4 h)", "Muszę iść."])
	_check(not ("blast" in _requests), "no blast when out of time")
	gs.hour = 8.0

	print("--- Bolko: cipher before trust, then after")
	gs.add_note(&"szyfr")
	await _talk(bolko, "start", ["Znalazłem kartkę zapisaną szyfrem dziadka.", "Pójdę już."])
	_check(not gs.has_flag("bolko_hint"), "no hint without trust")
	await _talk(bolko, "start", ["Jaki był mój dziadek?", "Pewnie miał swoje powody.", "Znalazłem kartkę zapisaną szyfrem dziadka.", "Pójdę już."])
	_check(gs.has_flag("bolko_hint"), "hint with trust (rep %d)" % gs.rep("bolko"))

	print("--- Racibor: the deposits quest, the rope permit")
	gs.set_flag("vein_rzapie")   # a vein marked before the quest is logged when it starts
	await _talk(racibor, "start", ["Znam mapy dziadka.", "Muszę iść."])
	_check(gs.quest_state("zloza") == "active", "quest zloza started")
	_check(gs.has_item("kwit"), "got Racibor's permit")
	_check("rzapie" in gs.quests[&"zloza"]["entries"], "earlier vein logged when the quest starts")
	await _talk(racibor, "start", ["Mam zaznaczone żyły.", "Muszę iść."])
	_check(gs.quest_state("zloza") == "active", "one vein is not enough")
	gs.set_flag("vein_upadowa")
	await _talk(racibor, "start", ["Mam zaznaczone żyły.", "Muszę iść."])
	_check(gs.has_flag("rac_first_report") and gs.has_note(&"raport_archiwum") and gs.quest_state("zloza") == "active", "first report accepted, archive note given, the quota goes on")
	_check(gs.has_flag("racibor_wants_upadowa"), "Racibor wants the decline")

	print("--- Tekla: the rope for the permit, the bundle, her father")
	await _talk(tekla, "start", ["Potrzebuję liny.", "Muszę iść."])
	_check(gs.has_item("lina") and not gs.has_item("kwit"), "rope for the permit")
	await _talk(tekla, "start", ["Masz dla mnie jakąś robotę?", "Dobrze, przyniosę.", "Muszę iść."])
	_check(gs.quest_state("towar") == "active", "quest towar started")
	# as the pickup in the sump does
	gs.set_flag("took_bundle")
	gs.give_item("tobolek")
	gs.add_note(&"list_konfraterni")
	await _talk(tekla, "start", ["Mam twój tobołek.", "Nikomu nie powiem.", "Znałaś może mojego dziadka?", "To był mój dziadek.", "Muszę iść."])
	_check(gs.quest_state("towar") == "done" and not gs.has_item("tobolek"), "bundle returned")
	_check(gs.has_flag("tekla_owes") and gs.rep("tekla") == 15, "Tekla owes you (rep %d)" % gs.rep("tekla"))
	_check("proch" in gs.quests[&"slady"]["entries"], "Tekla told about the gunpowder")

	print("--- Mirosław: the charge in the decline")
	gs.set_flag("met_racibor")
	gs.set_flag("saw_charge")
	var mir_sanity: int = gs.sanity(&"miroslaw")
	await _talk(mir, "start", ["Byłem na dnie upadowej.", "Dziadek miał trzy beczki prochu.", "Muszę iść."])
	_check("ladunek" in gs.quests[&"slady"]["entries"], "Mirosław recognised the charge")
	_check(gs.sanity(&"miroslaw") == mir_sanity - 3, "the talk costs him sanity")

	print("--- Day 2: Dobrawa, the chapel, the glossary")
	gs.start_next_day()
	await _talk(dobrawa, "start", ["Jesteś z Drugich?", "Czego tu właściwie szukasz?", "Pod jaskinią", "Muszę iść."])
	_check(gs.has_flag("kaplica_known") and gs.has_note(&"slowniczek"), "chapel known, glossary given")
	_check(gs.quest_state("sciana") == "active", "quest sciana started")

	print("--- The riddle wall: wrong answers cost time, then the right one")
	var hour_before: float = gs.hour
	await _talk(wall, "start", ["Gwiazda.", "Płomień.", "Oko.", "Spróbuję jeszcze raz.", "Gwiazda.", "Kamień.", "Zamknięte oko."])
	_check(is_equal_approx(gs.hour, hour_before + 1.0), "one wrong try costs 1 h (%.1f → %.1f)" % [hour_before, gs.hour])
	_check(gs.has_flag("wall_open"), "wall opened")
	_check("otwarta" in gs.quests[&"sciana"]["entries"], "quest entry for the open wall")
	_check("Ściana: Zeszliśmy z ___ i daliśmy wam oczy." in _seen, "translated inscription with the glossary")

	print("--- The crystal goes to Dobrawa")
	gs.give_item("krysztal")
	gs.add_note(&"list_dziadka")
	await _talk(dobrawa, "start", ["Znalazłem w kaplicy kryształ.", "Weź go.", "Muszę iść."])
	_check(gs.has_flag("dobrawa_leaving") and not gs.has_item("krysztal"), "Dobrawa takes the crystal and will leave")
	_check(gs.quest_state("sciana") == "done", "quest sciana done")

	print("--- Bolko: the chapel hint and the grandfather's fate")
	gs.set_flag("met_tekla")
	await _talk(bolko, "start", ["Dziadek sam zasypał upadową.", "Pójdę już."])
	_check(gs.has_flag("bolko_knows_fate"), "Bolko knows what happened")

	print("--- Night 2 dream, then Racibor's announcement on day 3")
	gs.set_flag("took_crystal")
	await _talk(system, "dream", [])
	_check(_seen.any(func(l): return l.contains("przycina lont")), "second-night dream with the crystal")
	gs.start_next_day()
	await _talk(racibor, "announcement", ["Dziadek sam zasypał upadową."])
	_check(gs.has_flag("plan_upadowa"), "Racibor plans to open the decline")
	_check(_seen.any(func(l): return l.begins_with("Bolko: Nad grobym")), "Bolko protests (in dialect)")

	print("--- Reporting Tekla instead (fresh state)")
	gs.reset()
	gs.set_flag("took_bundle")
	gs.give_item("tobolek")
	await _talk(racibor, "start", ["Tekla ukrywa coś przed tobą.", "Muszę iść."])
	_check(gs.has_flag("tekla_reported") and gs.has_item("lina"), "Tekla under watch, rope from Racibor")
	await _talk(tekla, "start", ["Kto teraz gotuje?"])
	_check(_seen.back().begins_with("Tekla: Bolko."), "Tekla talks from under watch")

	print("--- Bolko tells about the chapel on day 2")
	gs.reset()
	gs.change_rep("bolko", 5)
	gs.start_next_day()
	await _talk(bolko, "start", ["Była tu kiedyś jakaś kaplica?", "Pójdę już."])
	_check(gs.has_flag("kaplica_known"), "chapel known from Bolko")

	print("--- Sleep prompt")
	_requests.clear()
	await _talk(system, "sleep", ["Tak, idę spać"])
	_check("sleep" in _requests, "sleep requested")

	await _task05()
	await _task06()
	await _task09()
	await _task11()

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit()

## task_05: the week, items and the new people (camp and Exitium).
func _task05() -> void:
	var wszebor: Resource = load("res://dialogue/wszebor.dialogue")
	var nasir: Resource = load("res://dialogue/nasir.dialogue")
	var hagiwara: Resource = load("res://dialogue/hagiwara.dialogue")
	var sobek: Resource = load("res://dialogue/sobek.dialogue")
	var anzelm: Resource = load("res://dialogue/anzelm.dialogue")
	var sabina: Resource = load("res://dialogue/sabina.dialogue")
	var ottokar: Resource = load("res://dialogue/ottokar.dialogue")
	var hieronim: Resource = load("res://dialogue/hieronim.dialogue")
	var welf: Resource = load("res://dialogue/welf.dialogue")
	var drudzy: Resource = load("res://dialogue/drudzy.dialogue")
	var racibor: Resource = load("res://dialogue/racibor.dialogue")
	var tekla: Resource = load("res://dialogue/tekla.dialogue")
	var mir: Resource = load("res://dialogue/miroslaw.dialogue")
	var system: Resource = load("res://dialogue/system.dialogue")

	print("--- Wszebor: the pickaxe head, a new handle overnight")
	gs.reset()
	await _talk(wszebor, "start", ["Potrzebuję porządnego kilofa.", "Muszę iść."])
	_check(gs.quest_state("kilof") == "active", "quest kilof started")
	gs.give_item("obuch")
	await _talk(wszebor, "start", ["Mam obuch.", "Jak tam mój kilof?", "Muszę iść."])
	_check(not gs.has_item("kilof"), "no pickaxe the same day")
	gs.start_next_day()
	await _talk(wszebor, "start", ["Jak tam mój kilof?", "Muszę iść."])
	_check(gs.has_item("kilof") and gs.quest_state("kilof") == "done", "pickaxe the next day")

	print("--- Nasir: oil for the pumps, the crank, the fever and the medicine")
	gs.reset()
	await _talk(nasir, "start", ["Wiesz coś o pompach pod rząpiem?", "Muszę iść."])
	gs.give_item("olej")
	await _talk(nasir, "start", ["Mam olej do tłoków.", "Muszę iść."])
	_check(gs.has_flag("nasir_at_pumps") and not gs.has_item("olej"), "Nasir takes the oil")
	gs.start_next_day()
	gs.hour = 10.0
	gs.places[&"nasir"] = "teren"
	await _talk(nasir, "start", ["Pomogę ci przy korbie.", "Muszę iść."])
	_check(gs.has_flag("pump_running") and gs.quest_state("pompy") == "done", "the pumps run")
	gs.set_flag("fever_nasir")
	gs.set_flag("nasir_fever_started")
	gs.give_item("lekarstwo")
	await _talk(nasir, "start", ["Mam dla ciebie lekarstwo."])
	_check(not gs.has_fever(&"nasir") and gs.has_item("klejnot"), "Nasir cured, gives his jewel")
	_check(gs.quest_state("goraczka") == "done", "quest goraczka done")

	print("--- Anzelm: care, a medicine brewed from a mushroom")
	gs.reset()
	gs.player_health = 50
	await _talk(anzelm, "start", ["Opatrzysz mnie?", "Muszę iść."])
	_check(gs.player_health == 75, "Anzelm heals 25 (got %d)" % gs.player_health)
	# the mushroom goes to Anzelm for Nasir's fever (task_09: no greyed spoiler before the quest)
	gs.start_quest("goraczka")
	gs.give_item("grzyb")
	await _talk(anzelm, "start", ["Mam świecący grzyb.", "Uwarz lekarstwo.", "Muszę iść."])
	gs.start_next_day()
	await _talk(anzelm, "start", ["Lekarstwo gotowe?", "Muszę iść."])
	_check(gs.has_item("lekarstwo"), "medicine brewed overnight")

	print("--- Hagiwara: a poem for a mushroom, no forged ledger")
	gs.reset()
	await _talk(hagiwara, "start", ["Skąd jesteś?", "Nagate?", "Opowiedz o Cesarstwie.", "Co byś zapisał?", "Czego ci tu brakuje?", "Muszę iść."])
	gs.give_item("grzyb")
	await _talk(hagiwara, "start", ["Przyniosłem świecący grzyb.", "Muszę iść."])
	_check(gs.has_note(&"wiersz_hagiwary") and gs.has_item("lekarstwo"), "poem and medicine")
	gs.day = 6
	await _talk(hagiwara, "start", ["Mógłbyś dopisać", "Muszę iść."])
	_check(gs.veins_mapped() == 0 and gs.has_flag("hag_asked_lie"), "Hagiwara does not forge the ledger")

	print("--- Sobek: the bet")
	gs.reset()
	gs.start_quest("zloza")
	await _talk(sobek, "start", ["Załóżmy się", "Przyjmuję.", "Muszę iść."])
	for vein in ["east_1", "east_2", "west_1"]:
		gs.set_flag("vein_" + vein)
	await _talk(sobek, "start", ["Wygrałem zakład.", "Muszę iść."])
	_check(gs.quest_state("zaklad") == "done" and gs.has_item("nalewka"), "bet won, nalewka")

	print("--- Sabina and Anzelm: healing, the promise, peace; the shard")
	gs.reset()
	gs.set_flag("sabina_joined")
	gs.player_health = 40
	await _talk(sabina, "start", ["Możesz mnie uleczyć?", "Czujesz, gdzie są żyły?", "Muszę iść."])
	_check(gs.player_health == 85, "Sabina heals 45 (got %d)" % gs.player_health)
	await _talk(anzelm, "start", ["Dlaczego nie lubisz Sabiny?", "Muszę iść."])
	await _talk(sabina, "start", ["Brat Anzelm nie chce", "Obiecaj", "Muszę iść."])
	await _talk(anzelm, "start", ["Sabina obiecała", "Muszę iść."])
	_check(gs.has_flag("anzelm_sabina_peace") and gs.quest_state("pokoj") == "done", "peace between Anzelm and Sabina")
	gs.give_item("odlamek")
	await _talk(sabina, "start", ["Czego szukacie", "Co byś stąd chciała mieć?", "Mam dla ciebie odłamek", "Muszę iść."])
	_check(gs.quest_state("odlamek") == "done" and gs.has_item("lekarstwo"), "shard for Sabina, medicine")

	print("--- The Exitium meeting, Ottokar's offer, Hieronim, Welf")
	gs.reset()
	gs.give_item("krysztal")
	await _talk(drudzy, "meeting", ["Czego tu szukacie?", "Jaką cenę?"])
	_check(gs.has_flag("ottokar_knows_crystal"), "Ottokar notices the crystal")
	await _talk(ottokar, "start", ["W sprawie twojej oferty.", "Zaznacz mi te żyły."])
	_check(not gs.has_item("krysztal") and gs.veins_mapped() == 2, "crystal for two veins (got %d)" % gs.veins_mapped())
	await _talk(hieronim, "start", ["Kto oddycha?", "Znałeś mojego dziadka?"])
	await _talk(hieronim, "start", ["Co wiesz o błękicie?"])
	await _talk(hieronim, "start", ["Wstawaj"])
	_check(gs.has_item("swieca") and gs.has_item("bandaze"), "Hieronim gives a candle, then a bandage")
	gs.set_flag("welf_wounded")
	await _talk(welf, "start", ["Mam bandaże."])
	_check(gs.has_flag("welf_helped") and not gs.has_item("bandaze"), "Welf bandaged")
	await _talk(welf, "start", [])
	_check(gs.has_item("lekarstwo"), "Welf pays his debt")

	print("--- Tekla's stall, Mirosław by the fire")
	gs.reset()
	gs.set_flag("tekla_owes")
	await _talk(tekla, "start", ["Daj mi świecę.", "Potrzebuję oleju", "Muszę iść."])
	_check(gs.has_item("swieca") and gs.has_item("olej"), "candle and oil from Tekla")
	gs.places[&"miroslaw"] = "ognisko"
	gs.set_flag("met_miroslaw")
	gs.give_item("nalewka")
	var mir_before: int = gs.sanity(&"miroslaw")
	await _talk(mir, "start", ["Posiedzę z tobą przy ogniu.", "Napij się.", "Muszę iść."])
	_check(gs.done_today("mir_company") and gs.sanity(&"miroslaw") > mir_before, "company and a drink for Mirosław")

	print("--- Racibor: the reminder, the reckoning; the ending without the quota")
	gs.reset()
	gs.day = 5
	gs.set_flag("vein_east_1")
	gs.set_flag("vein_east_2")
	await _talk(racibor, "reminder", ["Znajdę je."])
	_check(_seen.any(func(l): return l.contains("mam 2 żyły. Brakuje 10")), "reminder counts the missing veins")
	for vein in gs.vein_ids().slice(0, 12):
		gs.set_flag("vein_" + vein)
	_check(gs.quota_met() and "norma" in gs.quests[&"zloza"]["entries"], "quota met is logged")
	await _talk(racibor, "reckoning", [])
	_check(gs.quest_state("zloza") == "done", "zloza done at the reckoning")
	await _talk(system, "left_behind", [])
	_check(_seen.back().contains("stuka w skałę"), "left alone ending text")

## task_06: day greetings, the campfire evenings, the fourteenth, the last-chance letter.
func _task06() -> void:
	var wszebor: Resource = load("res://dialogue/wszebor.dialogue")
	var dobrawa: Resource = load("res://dialogue/dobrawa.dialogue")
	var bolko: Resource = load("res://dialogue/bolko.dialogue")
	var ognisko: Resource = load("res://dialogue/ognisko.dialogue")
	var racibor: Resource = load("res://dialogue/racibor.dialogue")
	var system: Resource = load("res://dialogue/system.dialogue")

	print("--- Day greetings: once a day")
	gs.reset()
	gs.set_flag("met_wszebor")
	gs.day = 4
	await _talk(wszebor, "start", ["Muszę iść."])
	_check(gs.done_today("wsz_hello"), "Wszebor greets once a day")

	print("--- The farewell tag parses ([#leave])")
	gs.reset()
	gs.set_flag("met_wszebor")
	var walk = await dm.get_next_dialogue_line(wszebor, "start")
	var walk_guard := 0
	while walk != null and walk.responses.is_empty() and walk_guard < 20:
		walk_guard += 1
		walk = await dm.get_next_dialogue_line(wszebor, walk.next_id)
	var leave = null
	for r in walk.responses:
		if r.text.begins_with("Muszę iść"):
			leave = r
	_check(leave != null and leave.tags.has("leave") and not leave.text.contains("#"), "farewell has the leave tag, text stays clean")

	print("--- The campfire: tales, the song, after the tremor, the last evening")
	gs.reset()
	gs.day = 2
	gs.player_sanity = 50
	await _talk(ognisko, "start", [])
	_check(gs.player_sanity == 55 and gs.done_today("campfire"), "tales give +5, once a day")
	_check(gs.done_today("mir_company"), "Mirosław sat at the fire")
	gs.reset()
	gs.day = 5
	gs.player_sanity = 50
	await _talk(ognisko, "start", [])
	_check(_seen.any(func(l): return l.contains("Wultany")), "night 5: the Long Night song")
	_check(gs.player_sanity == 56, "the song gives +6")
	gs.reset()
	gs.day = 6
	gs.add_note(&"wiersz_hagiwary")
	await _talk(ognisko, "start", [])
	_check(_seen.any(func(l): return l.contains("boimy się razem")), "day 6: Hagiwara reads the poem")
	gs.reset()
	gs.day = 7
	await _talk(ognisko, "start", [])
	_check(_seen.any(func(l): return l.contains("Milczenie siedzi przy ogniu")), "day 7 without the quota")

	print("--- Bolko about the tremor")
	gs.reset()
	gs.set_flag("tremor_seen")
	await _talk(bolko, "start", ["W nocy ziemia drżała.", "Pójdę już."])
	_check(gs.has_flag("bolko_tremor"), "Bolko remembers the last tremor")

	print("--- The fourteenth: the clues, the counting dream, the lamp when left alone")
	gs.reset()
	gs.quest_log(&"czternasty", "kreski_rzapie")
	_check(gs.quest_state("czternasty") == "active", "the tally starts the quest")
	for f in ["saw_marks_rzapie", "saw_marks_pillar", "opened_grabiec_cache", "saw_bread"]:
		gs.set_flag(f)
	_check(gs.fourteenth_clues() == 4, "four clues counted")
	gs.day = 6
	await _talk(system, "dream", [])
	_check(_seen.any(func(l): return l.contains("Dochodzi do czternastu")), "the counting dream")
	_seen.clear()
	gs.day = 7
	await _talk(system, "dream", [])
	_check(_seen.any(func(l): return l.contains("czy policzyłeś")) and _seen.any(func(l): return l.contains("Dochodzi do czternastu")), "task_13: the counting in the last dream too")

	print("--- task_13: the deciphered letter ends the dream of whatever night it happens")
	for night in [3, 5, 7]:
		gs.reset()
		gs.day = night
		gs.add_note(&"odszyfrowana")
		_seen.clear()
		await _talk(system, "dream", [])
		_check(_seen.any(func(l): return l.contains("Twoim pismem")) and gs.has_flag("dream_decipher_seen"), "letter after night %d" % night)
		_seen.clear()
		await _talk(system, "dream", [])
		_check(not _seen.any(func(l): return l.contains("Twoim pismem")), "only once (night %d)" % night)
	gs.set_flag("fourteenth_gift")
	await _talk(system, "left_behind", [])
	_check(_seen.any(func(l): return l.contains("znakiem dziadka")), "the lamp in the left-alone ending")

	print("--- The reckoning: the last chance to show the letter")
	gs.reset()
	for vein in gs.vein_ids().slice(0, 12):
		gs.set_flag("vein_" + vein)
	gs.set_flag("plan_upadowa")
	gs.add_note(&"list_dziadka")
	await _talk(racibor, "reckoning", ["Przeczytaj to, zanim ją otworzysz."])
	_check(gs.has_flag("racibor_doubts"), "the letter stops the decline plan")

	print("--- The two Drugie in the evening")
	gs.reset()
	gs.day = 4
	gs.hour = 20.0
	gs.set_flag("sabina_joined")
	gs.give_item("krysztal")
	await _talk(dobrawa, "start", ["Stoicie tu z Sabiną co wieczór i milczycie.", "Muszę iść."])
	_check(gs.has_flag("dwie_drugie"), "the scene plays once")
	_check(_seen.any(func(l): return l.contains("czajnik")), "they feel the crystal")

## Runs a conversation, choosing responses whose text starts with the given strings, in order.
## task_09: Hrapek and "Ryba dla Hrapka", the [#free] tags.
func _task09() -> void:
	var hrapek: Resource = load("res://dialogue/hrapek.dialogue")
	var tekla: Resource = load("res://dialogue/tekla.dialogue")
	var wszebor: Resource = load("res://dialogue/wszebor.dialogue")
	var mir: Resource = load("res://dialogue/miroslaw.dialogue")

	print("--- Hrapek: the first meeting, three questions in a row and he runs")
	gs.reset()
	gs.day = 3
	gs.set_flag("hrapek_meetings", 1)
	gs.set_flag("hrapek_q", 0)
	var hour_before: float = gs.hour
	await _talk(hrapek, "meet", ["Co tu robisz?", "Kim jest ten Cesarz?", "Kim byłeś"])
	_check(gs.quest_state("ryba") == "active", "he is hungry: quest ryba started")
	_check(_seen.any(func(l): return l.contains("CO TYLE PYTA?")), "the third question: he runs")
	_check(not gs.has_flag("hrapek_told_past"), "the third question gets no answer")
	_check(is_equal_approx(gs.hour, hour_before), "talking to Hrapek costs no time")
	_check(gs.sanity(&"hrapek") == 20, "his sanity stays at 20")

	print("--- Hrapek: next meeting, two questions and a goodbye")
	gs.set_flag("hrapek_meetings", 2)
	gs.set_flag("hrapek_q", 0)
	await _talk(hrapek, "meet", ["Kim byłeś", "Znałeś mojego dziadka?", "Muszę iść."])
	_check(_seen.any(func(l): return l.begins_with("Hrapek: Górnikiem")), "Górnikiem... a nie, rybakiem")
	_check(gs.has_flag("hrapek_told_grandfather"), "two questions answered, no running")

	print("--- The fish: Tekla gives one only after the bundle")
	await _talk(tekla, "start", ["Masz może jakąś rybę?", "Muszę iść."])
	_check(not gs.has_item("ryba"), "no bundle, no fish")
	gs.set_flag("tekla_owes")
	await _talk(tekla, "start", ["Masz może jakąś rybę?", "Muszę iść."])
	_check(gs.has_item("ryba") and "od_tekli" in gs.quests[&"ryba"]["entries"], "fish from Tekla")

	print("--- Hrapek eats the fish: HE and the grandfather")
	gs.set_flag("hrapek_q", 2)
	await _talk(hrapek, "meet", ["Mam dla ciebie rybę.", "Gdzie jest twój pałac?", "Muszę iść."])
	_check(gs.quest_state("ryba") == "done" and not gs.has_item("ryba"), "fish eaten, quest done")
	_check(_seen.any(func(l): return l.contains("ON cię już raz dopadł")), "he tells about HIM")
	_check(_seen.any(func(l): return l.contains("broda siwa")), "he takes you for the grandfather")
	_check(gs.has_flag("hrapek_told_palace"), "the fish resets the question count")
	_check(gs.rep(&"hrapek") == 10, "trust +10")

	print("--- task_13: the pond is under water until the pumps run; the bandage for Wszebor")
	gs.reset()
	gs.start_quest("ryba")
	gs.hour = 9.0
	await _talk(mir, "hub", ["Chodź ze mną na ryby", "Muszę iść."])
	_check(not gs.has_item("ryba") and is_equal_approx(gs.hour, 9.0), "Mirosław: the pond is flooded, no fishing")
	_check(_seen.any(func(l): return l.contains("woda stoi po sam strop")), "Mirosław says why")
	await _talk(wszebor, "start", ["Chodź ze mną na ryby", "Muszę iść."])
	_check(not gs.has_item("ryba") and gs.has_flag("wsz_fish_offer"), "Wszebor: flooded, but offers the bandage deal")
	gs.give_item("bandaze")
	await _talk(wszebor, "start", ["Masz, bandaż na rękę", "Jak tam ryba z rząpia", "Muszę iść."])
	_check(not gs.has_item("bandaze") and gs.get_flag("wsz_fish_day") == gs.day, "the bandage taken, the fish promised")
	_check("wymiana" in gs.quests[&"ryba"]["entries"], "notebook: the deal")
	_check(not gs.has_item("ryba") and _seen.any(func(l): return l.contains("Rano, mówiłem")), "same day: not yet")
	gs.day += 1
	await _talk(wszebor, "start", ["Jak tam ryba z rząpia", "Muszę iść."])
	_check(gs.has_item("ryba") and "od_wszebora" in gs.quests[&"ryba"]["entries"], "next morning: a fish from the sump")

	print("--- Fishing with Wszebor (4 h) and Mirosław, the pumps running")
	gs.reset()
	gs.start_quest("ryba")
	gs.set_flag("pump_running")
	gs.hour = 20.0
	await _talk(wszebor, "start", ["Chodź ze mną na ryby", "Muszę iść."])
	_check(not gs.has_item("ryba") and is_equal_approx(gs.hour, 20.0), "too late: tomorrow")
	gs.hour = 9.0
	await _talk(wszebor, "start", ["Chodź ze mną na ryby", "Muszę iść."])
	_check(gs.has_item("ryba") and is_equal_approx(gs.hour, 13.0), "4 h at the pond, a fish (%s)" % gs.clock_text())
	gs.take_item("ryba")
	gs.day = 2
	gs.hour = 9.0
	await _talk(mir, "hub", ["Chodź ze mną na ryby", "Muszę iść."])
	_check(gs.has_item("ryba") and "zlowiona" in gs.quests[&"ryba"]["entries"], "a fish with Mirosław")
	_check(gs.done_today("mir_company"), "fishing counts as company for Mirosław")

	print("--- Hrapek's body: the ring, the fish too late")
	gs.reset()
	gs.start_quest("ryba")
	await _talk(hrapek, "body", ["Zabierz pierścień."])
	_check(gs.has_item("pierscien") and gs.has_flag("hrapek_found"), "the ring taken")
	_check(gs.quest_state("ryba") == "failed" and "za_pozno" in gs.quests[&"ryba"]["entries"], "the fish came too late")
	_check(gs.npc_status(&"hrapek") == "dead", "Hrapek is dead in the notebook")

	print("--- [#free] hand-overs and [#leave] farewells are tagged")
	gs.reset()
	gs.give_item("lonty")
	gs.set_flag("mir_asked_collapse")
	var hub_line = await dm.get_next_dialogue_line(mir, "hub")
	var tags := {}
	for r in hub_line.responses:
		tags[r.text] = r.tags
	_check(tags.get("Mam dla ciebie lonty. Suche.", PackedStringArray()).has("free"), "handing over the fuses is free")
	_check(tags.get("Muszę iść.", PackedStringArray()).has("leave"), "the farewell is tagged leave")
	_check(not tags.get("Skąd jesteś?", PackedStringArray(["free"])).has("free"), "an ordinary question is not free")

## task_11: the first meeting of each of the five in each first-level room on day 1 has the
## room line, and nowhere the camp greeting; on day 2 in the camp there is no shift line.
func _task11() -> void:
	print("--- task_11: first meetings on the day-1 shift, one line per room")
	var room_lines := {
		"wszebor": {"east": "Stemple stoją", "rzapie": "Woda mi po kostki", "west": "na wydechu"},
		"nasir": {"east": "Tu jest sucho", "rzapie": "Woda gada", "west": "stoi jak w misce"},
		"hagiwara": {"east": "znaczyła stemple", "rzapie": "Wilgoć niszczy papier", "west": "Przejście było niegodne"},
		"sobek": {"east": "jest prosto", "rzapie": "Nie lubię wody", "west": "Miecz przeszedł pierwszy"},
		"anzelm": {"east": "mech, który tamuje", "rzapie": "do picia się nie nadaje", "west": "powietrze jest ciężkie"},
	}
	for who in room_lines:
		var res: Resource = load("res://dialogue/%s.dialogue" % who)
		for room in room_lines[who]:
			gs.reset()
			gs.set_flag("location", room)
			gs.places[StringName(who)] = "teren"
			_seen.clear()
			await _talk(res, "start", ["Muszę iść."])
			var line: String = room_lines[who][room]
			var hit := _seen.any(func(t): return t.contains(line))
			var gap := _seen.any(func(t): return t.contains("szparę pod stropem"))
			_check(hit and gap == (room == "west"), "%s met first in %s: the room line%s" % [who, room, ", the gap under the roof" if room == "west" else ""])
	for who in room_lines:
		var res: Resource = load("res://dialogue/%s.dialogue" % who)
		gs.reset()
		gs.start_next_day()
		gs.places[StringName(who)] = "stol"
		_seen.clear()
		await _talk(res, "start", ["Muszę iść."])
		var shift_line := _seen.any(func(t): return t.contains("jutro") or t.contains("szycht"))
		_check(not shift_line, "%s met first in the camp on day 2: no shift line" % who)

	print("--- task_11: first meetings the coverage review found without a greeting")
	gs.reset()
	gs.start_next_day()
	gs.places[&"miroslaw"] = "kat"
	_seen.clear()
	await _talk(load("res://dialogue/miroslaw.dialogue"), "start", ["Muszę iść."])
	_check(_seen.any(func(t): return t.contains("W ciemnym kącie")), "Mirosław met first in his dark corner: the corner, not the fire")
	gs.reset()
	gs.start_next_day()
	_seen.clear()
	await _talk(load("res://dialogue/bolko.dialogue"), "start", ["Pójdę już."])
	_check(gs.has_flag("met_bolko") and _seen.any(func(t): return t.contains("wnuk")), "Bolko met first on day 2 still introduces himself")
	gs.reset()
	gs.day = 4
	gs.set_flag("fever_nasir")
	gs.set_flag("nasir_fever_started")
	_seen.clear()
	await _talk(load("res://dialogue/nasir.dialogue"), "start", ["Trzymaj się."])
	_check(gs.has_flag("met_nasir") and _seen.any(func(t): return t.contains("pompiarz z Sułtanatu")), "Nasir met first in his fever: Anzelm says who he is")

func _talk(resource: Resource, cue: String, choices: Array) -> void:
	var line = await dm.get_next_dialogue_line(resource, cue)
	var guard := 0
	while line != null and guard < 80:
		guard += 1
		var shown := "%s%s" % ["%s: " % line.character if line.character != "" else "", _strip_bbcode(line.text)]
		_seen.append(shown)
		print("   " + shown)
		if line.responses.size() > 0:
			var allowed: Array = line.responses.filter(func(r): return r.is_allowed)
			var pick = null
			if choices.size() > 0:
				for r in allowed:
					if r.text.begins_with(choices[0]):
						pick = r
						break
			if pick == null:
				print("   !! no allowed response matching %s among %s" % [choices.slice(0, 1), allowed.map(func(r): return r.text)])
				_failures += 1
				return
			choices.pop_front()
			print("   > %s" % pick.text)
			line = await dm.get_next_dialogue_line(resource, pick.next_id)
		else:
			line = await dm.get_next_dialogue_line(resource, line.next_id)

func _strip_bbcode(text: String) -> String:
	var re := RegEx.create_from_string("\\[/?[a-z]+[^\\]]*\\]")
	return re.sub(text, "", true)

## Text of the first line spoken by the given character from the "start" cue.
func _first_line_of(resource: Resource, character: String) -> String:
	var line = await dm.get_next_dialogue_line(resource, "start")
	var guard := 0
	while line != null and guard < 20:
		guard += 1
		if line.character == character:
			return line.text
		if line.responses.size() > 0:
			return ""
		line = await dm.get_next_dialogue_line(resource, line.next_id)
	return ""

## Every miner line in the .dialogue files has a Silesian version and every Silesian key still
## matches a line (a changed original silently falls back to the standard Polish text).
func _check_gwara_coverage() -> void:
	var gwara: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://dialogue/gwara_slaska.json"))
	var lines := {}
	for file in DirAccess.get_files_at("res://dialogue"):
		if not file.ends_with(".dialogue"):
			continue
		for raw in FileAccess.get_file_as_string("res://dialogue/" + file).split("\n"):
			var s: String = raw.strip_edges()
			for who in ["Mirosław: ", "Bolko: "]:
				if s.begins_with(who):
					lines[s.substr(who.length())] = true
	var missing: Array = lines.keys().filter(func(l): return not gwara.has(l))
	var unknown: Array = gwara.keys().filter(func(k): return not lines.has(k))
	_check(missing.is_empty(), "every miner line has a Silesian version %s" % [missing])
	_check(unknown.is_empty(), "every Silesian key matches a dialogue line %s" % [unknown])

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
