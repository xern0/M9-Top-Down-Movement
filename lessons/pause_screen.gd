@tool
extends Control

@onready var ui_panel_container: PanelContainer = $UIPanelContainer

var is_currently_opening := false

@export_range(0.1, 10.0, 0.01, "or_greater") var animation_duration := 2.3

var tween: Tween

@onready var resume_button: Button = $UIPanelContainer/VBoxContainer/CenterContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $UIPanelContainer/VBoxContainer/CenterContainer/VBoxContainer/QuitButton
@onready var blur_color_rect: ColorRect = $BlurColorRect


@export_range(0, 1.0) var menu_opened_amount := 0.0:
	set = set_menu_opened_amount

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	menu_opened_amount = 0.0

	resume_button.pressed.connect(toggle)
	quit_button.pressed.connect(get_tree().quit)

func set_menu_opened_amount(amount: float) -> void:
	menu_opened_amount = amount
	visible = amount > 0
	
	if ui_panel_container == null or blur_color_rect == null:
		return
	
	blur_color_rect.material.set_shader_parameter("blur_amount", lerp(0.0, 1.5, amount))
	blur_color_rect.material.set_shader_parameter("saturation", lerp(1.0, 0.3, amount))
	blur_color_rect.material.set_shader_parameter("tint_strength", lerp(0.0, 0.2, amount))
	ui_panel_container.modulate.a = amount
	if not Engine.is_editor_hint():
		get_tree().paused = amount > 0.3

func toggle() -> void:
	# Switch the flag to the opposite value
	is_currently_opening = not is_currently_opening

	var duration := animation_duration
	# If there's a tween, and it is animating, we want to kill it.
	# This stops the previous animation.
	if tween != null:
		if not is_currently_opening:
			# If the previous tween was animating, we want to animate back
			# from the current point in the animation.
			duration = tween.get_total_elapsed_time()
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)

	var target_amount := 1.0 if is_currently_opening else 0.0
	tween.tween_property(self, "menu_opened_amount", target_amount, duration)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()
