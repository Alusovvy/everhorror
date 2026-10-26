extends SceneTree
## Usage: godot --headless --path . --script res://tools/balance_sim.gd
## The balance bot (task_14, TECH-3; assumptions in the spec: 07_balans.md "Pomiar"). It "plays" the
## week without the world scene, on the game's own costs: the expedition graph and its hours
## (Expeditions), fatigue and the day's hours (GameState.advance_time), the quota (GameState.QUOTA),
## the blast (StoryDirector.BLAST_HOURS) and the talk minutes (VN.TALK_MINUTES). So a balance change in
## the game changes the bot's answer. Two styles ("żyły": tunnels all day; "rozmowy": talks every
## morning and the fire in the evening) in two variants (every story gate as in the table, or a
## day later), and for each run it prints
##   BALANCE[żyły, optymistyczny]: norma 12 → dzień 4, 15:20 (żyły po dniu 7: 21)
## or "norma 12 → nie osiągnięta (N żył po dniu 7)".
## It MEASURES, it does not grade: the pace never fails the test. What is checked are invariants
## (the bot is back by 22:00, fatigue stays within bounds, no vein twice, the logs agree with the
## count, the same answer twice). Left out on purpose, so the result is a rough upper bound on the
## pace rather than a prediction: the hero's health and sanity, the meetings with the Drudzy and
## Hrapek, the Dobrawa and Tekla plots; the dialogue chains behind the gates are replaced by the table
## below (printed with the result). The tour is greedy (the place with the most veins per hour, road and
## the way back included), not the best possible one.

const STYLE_VEINS := "żyły"
const STYLE_TALK := "rozmowy"
const STYLES: Array[String] = [STYLE_VEINS, STYLE_TALK]
## The index is the delay in days that is added to every gate.
const VARIANTS: Array[String] = ["optymistyczny", "opóźniony"]

## Veins under flowstone (gen_locations.gd hidden_vein): a pickaxe and 2 h instead of 1 h. data_lint
## checks this list against the generator.
const HIDDEN_VEINS: Array[String] = ["rzapie_2", "upadowa_2", "kaplica_2"]
const VEIN_HOURS := 1.0
const HIDDEN_VEIN_HOURS := 2.0

## The story gates, as in the spec table (07_balans.md "Pomiar"). Days are the first day the gate can
## be open in the optimistic variant; hours are what it costs, in the camp unless said otherwise.
const LINA_DAY := 1
const LINA_HOURS := 0.5
const OLEJ_DAY := 2
const OLEJ_HOURS := 0.5
const KAPLICA_DAY := 2
## Komora pomp: the pump is turned the day after the oil went to Nasir, 2 h at the crank.
const PUMP_HOURS := 2.0
## The old pick's head lies in Stare wyrobisko (0.5 h to find), goes to Wszebor (in the camp from day
## 2), and the pickaxe is ready the day after.
const OBUCH_HOURS := 0.5
const WSZEBOR_IN_CAMP_FROM := 2

## "rozmowy": every morning 3 options with everyone who is in the camp (5 min each); 4 people on
## day 1, about 10 later. The evening fire takes an hour and opens at 20:00.
const TALK_OPTIONS := 3
const PEOPLE_FIRST_DAY := 4
const PEOPLE_LATER := 10
const FIRE_HOURS := 1.0
const FIRE_FROM := 20.0
const EPS := 0.001

var gs
var vn
var Ex
var Story
var Report

var _checks := 0
var _problems: Array[String] = []

# State of the run in progress.
var _style := ""
var _delay := 0
var _first_east_day := 0
var _olej_day := 0
var _obuch_found := false
var _obuch_given_day := 0
var _quota_day := 0
var _quota_hour := 0.0
var _veins_day7 := -1
var _trace: Array[String] = []

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	vn = root.get_node("VN")
	Ex = load("res://script/expeditions.gd")
	Story = load("res://script/story_director.gd")
	Report = load("res://script/run_report.gd")

	print("--- Balance bot: the week without the world (TECH-3)")
	_print_assumptions()
	var results := {}
	for style in STYLES:
		for delay in VARIANTS.size():
			var key := "%s/%d" % [style, delay]
			var result := _play_week(style, delay)
			results[key] = result
			print("   trace %s, %s:" % [style, VARIANTS[delay]])
			for line in _trace:
				print("      " + line)
			if "--timeline" in OS.get_cmdline_user_args():
				_print_timeline()
			print(_result_line(style, delay, result))

	print("--- Invariants (the pace itself is never graded)")
	for message in _problems:
		print("   [FAIL] " + message)
		_failures_from_run += 1
	_check(_failures_from_run == 0, "the bot kept to its own rules in every run (%d slips)" % _failures_from_run)
	for style in STYLES:
		for delay in VARIANTS.size():
			var again := _play_week(style, delay)
			var first: Dictionary = results["%s/%d" % [style, delay]]
			_check(_same(first, again), "%s, %s: the same answer twice" % [style, VARIANTS[delay]])
			_check(int(first["veins_day7"]) <= int(first["vein_total"]) and int(first["veins_day7"]) >= 0, "%s, %s: veins after day 7 are within 0-%d (%d)" % [style, VARIANTS[delay], first["vein_total"], first["veins_day7"]])
	_check(_problems.size() == _failures_from_run, "the repeat runs broke no rule either")

	print("--- The run report reads the bot's week")
	_play_week(STYLE_VEINS, 0)
	_report_check()

	print("\nRESULT: %s (%d checks)" % ["ALL PASSED" if _failures == 0 else "%d FAILED" % _failures, _checks])
	quit(0 if _failures == 0 else 1)

var _failures := 0
var _failures_from_run := 0

#region One week

func _play_week(style: String, delay: int) -> Dictionary:
	gs.reset()
	_style = style
	_delay = delay
	_first_east_day = 0
	_olej_day = 0
	_obuch_found = false
	_obuch_given_day = 0
	_quota_day = 0
	_quota_hour = 0.0
	_veins_day7 = -1
	_trace = []
	var problems_before := _problems.size()
	for day in range(1, gs.QUOTA_DAY + 1):
		_play_day(day)
	# Day 8 has begun (the last night was slept).
	_expect(gs.day == gs.QUOTA_DAY + 1, "the week ends on day %d (%d)" % [gs.QUOTA_DAY + 1, gs.day])
	_expect(gs.vein_log.size() == gs.veins_mapped(), "the vein log has every vein marked (%d of %d)" % [gs.vein_log.size(), gs.veins_mapped()])
	var counted := true
	for i in gs.vein_log.size():
		counted = counted and int(gs.vein_log[i].get("n", 0)) == i + 1
	_expect(counted, "the vein log counts the veins on the map as they are marked (n = 1, 2, 3…)")
	if _quota_day > 0:
		# The vein that brought the count to the quota, found by its count, as the report does.
		var at_quota: Array = gs.vein_log.filter(func(entry): return int(entry.get("n", 0)) == gs.QUOTA)
		_expect(at_quota.size() == 1 and int(at_quota[0]["day"]) == _quota_day and is_equal_approx(float(at_quota[0]["at"]), _quota_hour), "the vein log agrees on when the quota was reached")
	return {
		"quota_day": _quota_day, "quota_hour": _quota_hour, "veins_day7": _veins_day7, "vein_total": gs.vein_total(),
		"new_problems": _problems.size() - problems_before,
	}

func _play_day(day: int) -> void:
	_expect(gs.day == day and is_equal_approx(gs.hour, gs.DAY_START_HOUR), "day %d starts at 06:00 (%s)" % [day, gs.clock_text()])
	var veins_before: int = gs.veins_mapped()
	if _style == STYLE_TALK:
		var people := PEOPLE_FIRST_DAY if day == 1 else PEOPLE_LATER
		_spend(people * TALK_OPTIONS * vn.TALK_MINUTES / 60.0, "Rozmowa z ekipą")
	_camp_gates()
	var trips := 0
	while true:
		var target := _best_target()
		if target == &"":
			break
		_tour(target)
		trips += 1
		_camp_gates()
	if _style == STYLE_TALK:
		_fire()
	_expect(not gs.is_away() and gs.expedition.is_empty(), "day %d ends in the camp" % day)
	_trace.append("dzień %d: żyły %d (+%d), wypraw: %d, w obozie %s, zmęczenie %d%%" % [day, gs.veins_mapped(), gs.veins_mapped() - veins_before, trips, gs.time_text(gs.hour), int(gs.player_fatigue)])
	gs.log_time(gs.hour, 0.0, "Sen")
	if day == gs.QUOTA_DAY:
		_veins_day7 = gs.veins_mapped()
	gs.start_next_day()

## One outing: leave the camp for `first`, mark what is worth marking, move on while something is
## worth it, come back.
func _tour(first: StringName) -> void:
	var target := first
	while target != &"":
		if target != gs.current_place():
			_travel(target)
		_mark_veins_here()
		target = _best_target()
	_return_home()

# Mirrors StoryDirector._arrive: the walk tires like the tunnels, half of it is the price of the way
# back, the first visit costs an extra hour of scouting.
func _travel(place: StringName) -> void:
	var here: StringName = gs.current_place()
	var route: Array[StringName] = Ex.path(here, place)
	_expect(not route.is_empty() and Ex.route_lock(route) == "", "the way to %s is open" % place)
	var hours: float = Ex.trip_hours(route)
	var walked: float = Ex.walk_hours(route)
	var reason := ("Wyprawa: %s" if here == Ex.CAMP else "Droga: %s") % Ex.display_name(place)
	if here == Ex.CAMP:
		gs.begin_expedition()
	gs.travelling = true
	_spend(hours, reason)
	gs.travelling = false
	gs.expedition["outbound_hours"] = float(gs.expedition.get("outbound_hours", 0.0)) + walked
	gs.set_flag("visited_%s" % place)
	gs.set_flag("location", String(place))
	gs.note_expedition_place(String(place))
	if place == &"east" and _first_east_day == 0:
		_first_east_day = gs.day
	_arrival_gates(place)

# Mirrors StoryDirector._return_to_camp: half of the way walked, never doubled, even late.
func _return_home() -> void:
	var hours: float = Ex.return_hours()
	gs.clear_flag("location")
	gs.travelling = true
	_spend(hours, "Powrót do obozu")
	gs.travelling = false
	gs.end_expedition()

func _mark_veins_here() -> void:
	var here: StringName = gs.current_place()
	for vein in _markable(here):
		var hours := _vein_hours(vein)
		if gs.hour + hours + Ex.return_hours() > _deadline() + EPS:
			break
		_spend(hours, "Odkuwanie nacieku" if hours > VEIN_HOURS else "Znaczenie żyły")
		_expect(not gs.has_flag("vein_" + vein), "vein %s is marked only once" % vein)
		gs.set_flag("vein_" + vein)
		if _quota_day == 0 and gs.quota_met():
			_quota_day = gs.day
			_quota_hour = gs.hour

func _fire() -> void:
	if gs.hour < FIRE_FROM:
		_spend(FIRE_FROM - gs.hour, "Czekanie na wieczór")
	_spend(FIRE_HOURS, "Wieczór przy ogniu")
	gs.rest_by_fire()

#endregion

#region The greedy choice

func _deadline() -> float:
	return gs.DAY_START_HOUR + gs.DAY_LENGTH_HOURS - (FIRE_HOURS if _style == STYLE_TALK else 0.0)

func _vein_hours(vein: String) -> float:
	return HIDDEN_VEIN_HOURS if vein in HIDDEN_VEINS else VEIN_HOURS

## The veins at a place the hero can mark right now (the hidden ones need the pickaxe), the cheap
## ones first.
func _markable(place: StringName) -> Array[String]:
	var result: Array[String] = []
	for vein in gs.LOCATIONS[place].veins:
		if gs.has_flag("vein_" + vein):
			continue
		if vein in HIDDEN_VEINS and not gs.has_item("kilof"):
			continue
		result.append(vein)
	result.sort_custom(_vein_before)
	return result

func _vein_before(a: String, b: String) -> bool:
	if _vein_hours(a) != _vein_hours(b):
		return _vein_hours(a) < _vein_hours(b)
	return a < b

## The way back from a place the hero reached after `walked` hours of walking since the camp, by
## the game's own rule.
func _return_after(walked: float) -> float:
	var saved: Dictionary = gs.expedition
	gs.expedition = {"outbound_hours": walked}
	var hours: float = Ex.return_hours()
	gs.expedition = saved
	return hours

## Hours of a gate that is dealt with on arriving at this place (the pump, the pick's head).
func _arrival_gate_hours(place: StringName) -> float:
	var hours := 0.0
	if place == &"pompy" and _pump_due():
		hours += PUMP_HOURS
	if place == &"wyrobisko" and not _obuch_found:
		hours += OBUCH_HOURS
	return hours

## What a visit to `place` would give: the veins that fit before the deadline, the hours, and veins
## per hour (the gates' hours are paid but not counted against the score). {} when there is nothing.
func _plan(place: StringName) -> Dictionary:
	var here: StringName = gs.current_place()
	var stay := place == here
	var travel := 0.0
	var walk := 0.0
	if not stay:
		var route: Array[StringName] = Ex.path(here, place)
		if route.is_empty() or Ex.route_lock(route) != "":
			return {}
		travel = Ex.trip_hours(route)
		walk = Ex.walk_hours(route)
	var out_now: float = 0.0 if here == Ex.CAMP else float(gs.expedition.get("outbound_hours", 0.0))
	var return_now: float = 0.0 if here == Ex.CAMP else Ex.return_hours()
	var return_after: float = return_now if stay else _return_after(out_now + walk)
	var gate_hours := 0.0 if stay else _arrival_gate_hours(place)
	var spent := 0.0
	var count := 0
	for vein in _markable(place):
		var hours := _vein_hours(vein)
		if gs.hour + travel + gate_hours + spent + hours + return_after > _deadline() + EPS:
			break
		spent += hours
		count += 1
	if count == 0:
		return {}
	var cost: float = travel + spent + (return_after - return_now)
	return {"place": place, "veins": count, "score": count / cost}

## From the camp every known place is a candidate (the map table); in the field the place itself
## and its neighbours (the field map). &"" = nothing is worth it, go home.
func _best_target() -> StringName:
	var here: StringName = gs.current_place()
	var candidates: Array[StringName] = []
	if here == Ex.CAMP:
		candidates = Ex.known_places()
	else:
		candidates.append(here)
		for id in Ex.neighbours(here):
			if id != Ex.CAMP:
				candidates.append(id)
	var best := &""
	var best_score := 0.0
	for id in candidates:
		var plan := _plan(id)
		if not plan.is_empty() and float(plan["score"]) > best_score + 1e-9:
			best = id
			best_score = float(plan["score"])
	return best

#endregion

#region The story gates (the spec table, 07_balans.md "Pomiar")

## Gates that conversation opens come a day earlier for the talking style (never before day 1).
func _talk_gate_day(base_day: int) -> int:
	return maxi(1, base_day + _delay - (1 if _style == STYLE_TALK else 0))

func _pump_due() -> bool:
	return not gs.has_flag("pump_running") and _olej_day > 0 and gs.day >= _olej_day + 1

## Everything the camp alone decides, done at the first chance on or after the gate's day.
func _camp_gates() -> void:
	var day: int = gs.day
	# The rubble: the fuses from Stara sztolnia to Mirosław, then the blast.
	if not gs.has_flag("west_blasted") and _first_east_day > 0 and day >= _first_east_day + _delay and _fits(Story.BLAST_HOURS):
		_spend(Story.BLAST_HOURS, "Mirosław wysadza zawał")
		gs.set_flag("west_blasted")
	if not gs.has_item("lina") and day >= _talk_gate_day(LINA_DAY) and _fits(LINA_HOURS):
		_spend(LINA_HOURS, "Rozmowa z Raciborem")
		gs.give_item("lina")
	if not gs.has_item("olej") and day >= _talk_gate_day(OLEJ_DAY) and _fits(OLEJ_HOURS):
		_spend(OLEJ_HOURS, "Rozmowa z Teklą")
		gs.give_item("olej")
		_olej_day = day
	# Nobody can tell the hero about the chapel on day 1 (Bolko offers it from day 2, Dobrawa comes
	# on day 2, the deciphering happens at night), so the talking style does not open this gate early.
	if not gs.has_flag("kaplica_known") and day >= maxi(KAPLICA_DAY, _talk_gate_day(KAPLICA_DAY)):
		gs.set_flag("kaplica_known")
	# The pick's head, once found, goes to Wszebor (in the camp from day 2); the pickaxe is ready
	# the day after (a delayed variant waits one more day).
	if _obuch_found and _obuch_given_day == 0 and day >= WSZEBOR_IN_CAMP_FROM:
		_obuch_given_day = day
	if not gs.has_item("kilof") and _obuch_given_day > 0 and day >= _obuch_given_day + 1 + _delay:
		gs.give_item("kilof")

## The gates that need the hero at a place.
func _arrival_gates(place: StringName) -> void:
	if place == &"pompy" and _pump_due():
		_spend(PUMP_HOURS, "Praca przy pompach")
		gs.set_flag("pump_running")
	if place == &"wyrobisko" and not _obuch_found:
		_spend(OBUCH_HOURS, "Szukanie obucha")
		_obuch_found = true

func _fits(hours: float) -> bool:
	return gs.hour + hours <= _deadline() + EPS

#endregion

#region Output and checks

func _print_assumptions() -> void:
	print("BALANCE założenia: dni 1-%d, po każdym dniu noc i poranek; powrót do obozu najpóźniej o 22:00 (styl rozmowy: o 21:00, bo wieczorem jest ognisko)" % gs.QUOTA_DAY)
	print("BALANCE założenia: cel zachłannie, najwięcej żył na godzinę razem z drogą i powrotem; koszty (drogi, zmęczenie, godziny, norma) z gry")
	print("BALANCE założenia: pominięte zdrowie i poczytalność bohatera, spotkania z Drugimi i Hrapkiem, wątki Dobrawy i Tekli; wynik to górna granica tempa, nie przewidywanie")
	print("BALANCE styl żyły: rozmawia tylko wtedy, gdy wymaga tego bramka; styl rozmowy: rano %d opcje z każdym w obozie (po %d min; %d osoby w dniu 1, potem %d), wieczorem ognisko (%s)" % [TALK_OPTIONS, vn.TALK_MINUTES, PEOPLE_FIRST_DAY, PEOPLE_LATER, gs.hours_text(FIRE_HOURS)])
	print("BALANCE bramki [optymistyczny]: zawał = po 1. wizycie w Starej sztolni, %s w obozie | lina = od dnia %d, %s w obozie | olej = od dnia %d, %s w obozie | pompy = dzień po oleju, %s w Komorze pomp | kilof = dzień po oddaniu obucha Wszeborowi (w obozie od dnia %d; obuch %s w Starym wyrobisku) | kaplica = od dnia %d" % [gs.hours_text(Story.BLAST_HOURS), LINA_DAY, gs.hours_text(LINA_HOURS), OLEJ_DAY, gs.hours_text(OLEJ_HOURS), gs.hours_text(PUMP_HOURS), WSZEBOR_IN_CAMP_FROM, gs.hours_text(OBUCH_HOURS), KAPLICA_DAY])
	print("BALANCE bramki [opóźniony]: każda bramka o dzień później; w stylu rozmowy bramki zależne od rozmów (lina, olej) o dzień wcześniej, nie wcześniej niż w dniu 1; wiedza o kaplicy w żadnym stylu nie jest wcześniejsza niż dzień %d" % KAPLICA_DAY)

func _result_line(style: String, delay: int, result: Dictionary) -> String:
	var head := "BALANCE[%s, %s]: norma %d → " % [style, VARIANTS[delay], gs.QUOTA]
	if int(result["quota_day"]) > 0:
		return head + "dzień %d, %s (żyły po dniu %d: %d)" % [result["quota_day"], gs.time_text(float(result["quota_hour"])), gs.QUOTA_DAY, result["veins_day7"]]
	return head + "nie osiągnięta (%d żył po dniu %d)" % [result["veins_day7"], gs.QUOTA_DAY]

## With `-- --timeline` after the script: every day of every run, line by line, as the notebook's
## "Czas" tab would show it (to see why a run came out as it did).
func _print_timeline() -> void:
	for day in range(1, gs.QUOTA_DAY + 1):
		for entry in gs.time_log.get(str(day), []):
			print("      %d %s · %s · %s" % [day, gs.time_text(float(entry["at"])), entry["why"], gs.duration_text(int(entry["min"]))])

func _same(a: Dictionary, b: Dictionary) -> bool:
	return int(a["quota_day"]) == int(b["quota_day"]) and is_equal_approx(float(a["quota_hour"]), float(b["quota_hour"])) and int(a["veins_day7"]) == int(b["veins_day7"])

## The week just played is the run report's input: its numbers must be the bot's.
func _report_check() -> void:
	var data: Dictionary = Report.collect(Report.ENDING_WEEK)
	var days: Array = data["days"]
	_check(days.size() == gs.QUOTA_DAY + 1, "the report has %d days (%d)" % [gs.QUOTA_DAY + 1, days.size()])
	var sums_ok := true
	var dawns_ok := true
	for day in days:
		if int(day["day"]) <= gs.QUOTA_DAY:
			var minutes := 0
			for category in Report.CATEGORIES:
				minutes += int(day["time"]["minutes"][category])
			sums_ok = sums_ok and minutes == int(day["time"]["total"]) and minutes == gs.logged_minutes(int(day["day"]))
			# The bot sleeps with the day over, however much of it was unused.
			sums_ok = sums_ok and day["time"]["unused_before_sleep_min"] != null
		dawns_ok = dawns_ok and day["dawn"] != null
	_check(sums_ok, "every day's categories add up to its time log")
	_check(dawns_ok, "every day has its dawn entry")
	_check(int(data["quota"]["veins"]) == gs.veins_mapped() and int(data["veins"].size()) == gs.veins_mapped(), "the report counts the bot's veins (%d)" % gs.veins_mapped())
	var reached: Variant = data["quota"]["reached_at"]
	_check(reached != null and int(reached["day"]) == _quota_day and is_equal_approx(float(reached["at"]), _quota_hour), "the report's quota time is the bot's")
	var first_dawn: Dictionary = days[0]["dawn"]
	_check(int(first_dawn["veins"]) == 0, "day 1 begins with no veins")
	_check(Report.to_markdown(data).contains("## Czas według kategorii"), "the report renders")

## Rules the bot has to keep; a slip is remembered and reported at the end.
func _expect(ok: bool, what: String) -> void:
	_checks += 1
	if not ok and not what in _problems:
		_problems.append(what)

func _spend(hours: float, why: String) -> void:
	if hours <= 0.0:
		return
	gs.advance_time(hours, why)
	_expect(gs.hour <= gs.DAY_START_HOUR + gs.DAY_LENGTH_HOURS + EPS, "the bot is never out past 22:00 (%s, after \"%s\")" % [gs.clock_text(), why])
	_expect(gs.player_fatigue >= 0.0 and gs.player_fatigue <= gs.FATIGUE_MAX, "fatigue stays within 0-100 (%.1f)" % gs.player_fatigue)

func _check(ok: bool, what: String) -> void:
	_checks += 1
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1

#endregion
