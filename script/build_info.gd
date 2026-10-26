extends RefCounted
class_name BuildInfo

## Which build this is (task_14, UI-6 / TECH-1). The version lives in the project settings
## (application/config/version); the spec commit the game was built against is stamped into the
## constant below by tools/release/stamp_build.js just before every export and committed with the
## release, so between releases it still shows the last release's commit ("unknown" in a tree
## that was never stamped). The built game never calls git.
const SPEC_SHA := "8e46253"

static func version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "dev"))

## "0.5.3 · spec 8e46253", the label in the corner of the main menu.
static func label() -> String:
	return "%s · spec %s" % [version(), SPEC_SHA]
