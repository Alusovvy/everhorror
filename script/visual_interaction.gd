extends Control

@onready var dialogContainer: VBoxContainer = $ScrollContainer/DialogOptionContainer
@onready var scroll: ScrollContainer = $ScrollContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	build_options()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup() -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	dialogContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL	


func build_options() -> void:
	var sampleText1 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
	var sampleText2 = "This is a simulation"
	var sampleText3 = "Why shouldn't I keep it? It's mine. I found it. It came to me. - His fierce attachment and use of the phrase - my precious"
	var sampleText4 = "RUN JUST RUN"
	var sampleText5 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
	
	add_button(sampleText1)
	add_button(sampleText2)
	add_button(sampleText3)
	add_button(sampleText4)
	add_button(sampleText5)

func add_button(text: String) -> void:
	var btn: Button = Button.new()
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.text = text

	dialogContainer.add_child(btn)
