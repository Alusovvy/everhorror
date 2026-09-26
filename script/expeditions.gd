extends RefCounted
class_name Expeditions

## The expedition map (docs_v2/systemy/eksploracja_kopalni.md): the graph of places from
## data/locations, shortest paths, what the hero knows and may enter, and what a trip costs.
## The camp is the node "oboz". Travel itself is done by the StoryDirector.

const CAMP := &"oboz"
## The first time you reach a place you have to look around before you can do anything.
const SCOUTING_HOURS := 1.0
## A badly hurt hero drags himself along: every leg takes longer.
const WOUNDED_EXTRA_HOURS := 1.0

static func place(id: StringName) -> LocationData:
	return GameState.LOCATIONS.get(id)

## Neighbour id → hours of travel.
static func neighbours(id: StringName) -> Dictionary:
	if id == CAMP:
		var result := {}
		for place_id in GameState.LOCATIONS:
			var data: LocationData = GameState.LOCATIONS[place_id]
			if data.links.has(String(CAMP)):
				result[place_id] = float(data.links[String(CAMP)])
		return result
	var links := {}
	var data := place(id)
	if data:
		for key in data.links:
			links[StringName(key)] = float(data.links[key])
	return links

## Shortest path by hours, from → … → to (both included); empty if there is none.
## It goes through places that are open now (the galeria by the pumps when the hero has no
## rope for the szyb, around the corridor Mirosław sealed). Only when every way is blocked
## does it return the shortest one, so route_lock() can say what stands in the way.
static func path(from: StringName, to: StringName) -> Array[StringName]:
	var route := _shortest(from, to, true)
	if route.is_empty():
		route = _shortest(from, to, false)
	return route

static func _shortest(from: StringName, to: StringName, open_ways_only: bool) -> Array[StringName]:
	var dist := {from: 0.0}
	var previous := {}
	var open: Array[StringName] = [from]
	while not open.is_empty():
		var best := 0
		for i in open.size():
			if dist[open[i]] < dist[open[best]]:
				best = i
		var current: StringName = open.pop_at(best)
		if current == to:
			break
		var links := neighbours(current)
		for next in links:
			# The destination may be locked itself: route_lock() then gives its own reason.
			if open_ways_only and next != to and own_lock(next) != "":
				continue
			var cost: float = dist[current] + links[next]
			if not dist.has(next) or cost < dist[next] - 0.001:
				dist[next] = cost
				previous[next] = current
				if not next in open:
					open.append(next)
	var result: Array[StringName] = []
	if not dist.has(to):
		return result
	var step := to
	result.append(step)
	while step != from:
		step = previous[step]
		result.push_front(step)
	return result

## Hours of walking along a path, with the wound penalty per leg (no scouting).
static func walk_hours(route: Array[StringName]) -> float:
	var hours := 0.0
	for i in range(1, route.size()):
		hours += float(neighbours(route[i - 1]).get(route[i], 0.0))
		if GameState.is_badly_hurt():
			hours += WOUNDED_EXTRA_HOURS
	return hours

## Walking plus scouting a place seen for the first time.
static func trip_hours(route: Array[StringName]) -> float:
	var hours := walk_hours(route)
	if not route.is_empty() and route.back() != CAMP and not is_visited(route.back()):
		hours += SCOUTING_HOURS
	return hours

## Names of the places walked through on the way (neither the start, the goal nor the camp),
## for the arrival card: "przez: Kaplica". Passing through doesn't count as a visit.
static func passed_through(route: Array[StringName]) -> Array[String]:
	var names: Array[String] = []
	for i in range(1, route.size() - 1):
		if route[i] != CAMP:
			names.append(display_name(route[i]))
	return names

static func is_visited(id: StringName) -> bool:
	return GameState.has_flag("visited_%s" % id)

## A place is on the hero's map once he has been next to it (it borders the camp or a visited
## place) or once someone told him about it (a "flag:" requirement that is already met).
static func is_known(id: StringName) -> bool:
	if is_visited(id):
		return true
	var data := place(id)
	if data == null:
		return false
	for key in data.links:
		if StringName(key) == CAMP or is_visited(StringName(key)):
			return true
	for requirement in data.requires:
		if requirement.begins_with("flag:") and GameState.has_flag(requirement.get_slice(":", 1)):
			return true
	return false

static func known_places() -> Array[StringName]:
	var result: Array[StringName] = []
	for id in GameState.LOCATIONS:
		if is_known(id):
			result.append(id)
	return result

## Why the place itself can't be entered ("" = it can). Requirements: "flag:<name>",
## "noflag:<name>" (closed for good once it is set) and "item:<id>".
static func own_lock(id: StringName) -> String:
	var data := place(id)
	if data == null:
		return ""
	for requirement in data.requires:
		var kind := requirement.get_slice(":", 0)
		var value := requirement.get_slice(":", 1)
		var ok := true
		match kind:
			"flag":
				ok = GameState.has_flag(value)
			"noflag":
				ok = not GameState.has_flag(value)
			"item":
				ok = GameState.has_item(value)
		if not ok:
			return String(data.locked.get(requirement, "Jeszcze nie."))
	return ""

## Why the route can't be walked: the first place on the way (after the start) that is locked.
static func route_lock(route: Array[StringName]) -> String:
	if route.is_empty():
		return "Nie ma tam drogi."
	for i in range(1, route.size()):
		var reason := own_lock(route[i])
		if reason != "":
			if i < route.size() - 1:
				return "Po drodze: %s. %s" % [display_name(route[i]), reason]
			return reason
	return ""

static func display_name(id: StringName) -> String:
	if id == CAMP:
		return "Obóz"
	var data := place(id)
	if data == null:
		return String(id)
	if data.unknown_name != "" and own_lock(id) != "":
		return data.unknown_name
	return data.display_name

static func veins_marked(id: StringName) -> int:
	var count := 0
	for vein in place(id).veins:
		if GameState.has_flag("vein_" + vein):
			count += 1
	return count

static func veins_total(id: StringName) -> int:
	return place(id).veins.size()

## "żyły: 1 z 2" once visited, "żyły: ?" before.
static func veins_text(id: StringName) -> String:
	if not is_visited(id):
		return "żyły: nie wiadomo"
	return "żyły: %d z %d zaznaczone" % [veins_marked(id), veins_total(id)]
