extends CanvasLayer
class_name PlantationGameUI

## Mobile-first strategy HUD. UI sends intent to Main; simulation never owns UI nodes.
const PalmData = preload("res://scripts/simulation/palm_record.gd")
const CropModel = preload("res://scripts/simulation/crop_model.gd")
const SEASON_SHORT_NAMES := ["WET", "SHIFT", "DRY", "SHIFT"]
const ACTION_ICONS := {
	"BUILD": preload("res://assets/ui/icons/build.svg"),
	"LAND": preload("res://assets/ui/icons/land.svg"),
	"PLANT": preload("res://assets/ui/icons/plant.svg"),
	"WORKERS": preload("res://assets/ui/icons/workers.svg"),
	"MANAGEMENT": preload("res://assets/ui/icons/management.svg")
}

signal action_selected(action: String)
signal speed_selected(speed: float)
signal maintenance_requested(action: String, palm_id: String)
signal land_clear_requested
signal harvest_requested(palm_id: String)
signal harvest_block_requested
signal sell_requested
signal selection_closed

var simulation
var main_controller
var screen: Control
var action_buttons: Dictionary = {}
var resource_labels: Dictionary = {}
var speed_buttons: Dictionary = {}
var objective_title: Label
var objective_hint: Label
var objective_progress: Label
var objective_bar: ProgressBar
var day_label: Label
var speed_label: Label
var details_panel: PanelContainer
var details_content: VBoxContainer
var details_title: Label
var toast_panel: PanelContainer
var toast_label: Label
var _toast_tween: Tween
enum LandState { FOREST, CLEARING, PREPARED }

var active_action: String = ""
var selected_kind: String = ""
var selected_id: String = ""
var _last_detail_signature: String = ""
var _toast_serial: int = 0
var _time_since_hud_refresh: float = 0.0


func _ready() -> void:
	layer = 10
	_build_ui()


func setup(state, controller) -> void:
	simulation = state
	main_controller = controller
	if not simulation.toast.is_connected(show_toast):
		simulation.toast.connect(show_toast)
	if not simulation.phase_changed.is_connected(_on_state_changed):
		simulation.phase_changed.connect(_on_state_changed)
	if not simulation.land_changed.is_connected(_on_state_changed):
		simulation.land_changed.connect(_on_state_changed)
	if not simulation.job_changed.is_connected(_on_state_changed):
		simulation.job_changed.connect(_on_state_changed)
	if not simulation.collection_changed.is_connected(_on_state_changed):
		simulation.collection_changed.connect(_on_state_changed)
	_refresh_hud()


func _process(delta: float) -> void:
	if simulation == null:
		return
	_time_since_hud_refresh += delta
	if _time_since_hud_refresh >= 0.12:
		_time_since_hud_refresh = 0.0
		_refresh_hud()
		if selected_kind == "worker":
			_update_worker_detail_values()
		elif selected_kind == "palm":
			var palm = simulation.get_palm(selected_id)
			if palm != null:
				_render_palm_details(palm)
		elif selected_kind == "land":
			_render_land_details()
		elif selected_kind == "shelter":
			_render_shelter_details()
		elif selected_kind == "collection":
			_render_collection_details()


func _build_ui() -> void:
	screen = Control.new()
	screen.name = "HUD"
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen)
	_build_status_card()
	_build_resources_card()
	_build_time_controls()
	_build_objective_card()
	_build_action_bar()
	_build_details_panel()
	_build_toast()
	get_viewport().size_changed.connect(_update_responsive_layout)
	_update_responsive_layout()


func _build_status_card() -> void:
	var panel := _make_panel("StatusCard", 0.0, 0.0, 0.0, 0.0, 18, 16, 248, 81)
	panel.custom_minimum_size = Vector2(230, 65)
	var margin := _add_margin(panel, 12, 9, 12, 9)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 3)
	margin.add_child(rows)
	var eyebrow := _label("PALM ESTATE   /   PROTOTYPE 0.2", 9, Color(0.69, 0.76, 0.63), true)
	rows.add_child(eyebrow)
	var title := _label("Kampung Baru", 19, Color(0.94, 0.93, 0.84), true)
	rows.add_child(title)


func _build_resources_card() -> void:
	var panel := _make_panel("Resources", 0.5, 0.0, 0.5, 0.0, -225, 16, 225, 81)
	var margin := _add_margin(panel, 11, 7, 11, 7)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 17)
	margin.add_child(row)
	var entries := [
		["money", "FUNDS", "$"],
		["wood", "TIMBER", ""],
		["seedlings", "SEEDLINGS", ""],
		["fertilizer", "FERTILIZER", ""],
		["pesticide", "TREATMENT", ""],
		["harvested_ffb_kg", "FFB KG", ""]
	]
	for entry in entries:
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 1)
		var amount := _label("—", 14, Color(0.93, 0.91, 0.80), true)
		amount.name = "Amount_%s" % entry[0]
		resource_labels[entry[0]] = amount
		var caption := _label(entry[1], 8, Color(0.63, 0.70, 0.60), true)
		column.add_child(amount)
		column.add_child(caption)
		row.add_child(column)


func _build_time_controls() -> void:
	var panel := _make_panel("TimeAndSpeed", 1.0, 0.0, 1.0, 0.0, -290, 16, -18, 81)
	var margin := _add_margin(panel, 11, 7, 11, 7)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)
	var clock := VBoxContainer.new()
	clock.add_theme_constant_override("separation", 1)
	day_label = _label("DAY 01", 13, Color(0.94, 0.92, 0.82), true)
	speed_label = _label("GAME TIME", 8, Color(0.63, 0.70, 0.60), true)
	clock.add_child(day_label)
	clock.add_child(speed_label)
	row.add_child(clock)
	var separator := ColorRect.new()
	separator.color = Color(0.8, 0.82, 0.7, 0.15)
	separator.custom_minimum_size = Vector2(1, 35)
	row.add_child(separator)
	var speeds := HBoxContainer.new()
	speeds.add_theme_constant_override("separation", 3)
	for speed in [1.0, 2.0, 4.0, 6.0]:
		var button := Button.new()
		button.text = "%dx" % int(speed)
		button.custom_minimum_size = Vector2(39, 34)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		_style_button(button, true)
		button.pressed.connect(_on_speed_pressed.bind(speed))
		speed_buttons[speed] = button
		speeds.add_child(button)
	row.add_child(speeds)


func _build_objective_card() -> void:
	var panel := _make_panel("Objective", 0.0, 1.0, 0.0, 1.0, 18, -208, 322, -112)
	var margin := _add_margin(panel, 15, 11, 15, 11)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)
	objective_title = _label("01  ·  ESTABLISH A BASE", 11, Color(0.78, 0.78, 0.58), true)
	objective_hint = _label(
		"Choose a shelter site in the camp clearing.", 12, Color(0.89, 0.90, 0.82)
	)
	objective_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_progress = _label("WAITING FOR A BUILD SITE", 9, Color(0.66, 0.72, 0.62), true)
	objective_bar = ProgressBar.new()
	objective_bar.custom_minimum_size = Vector2(0, 6)
	objective_bar.max_value = 100.0
	objective_bar.show_percentage = false
	objective_bar.add_theme_stylebox_override("background", _progress_background())
	objective_bar.add_theme_stylebox_override("fill", _progress_fill())
	column.add_child(objective_title)
	column.add_child(objective_hint)
	column.add_child(objective_progress)
	column.add_child(objective_bar)


func _build_action_bar() -> void:
	var panel := _make_panel("ActionBar", 0.5, 1.0, 0.5, 1.0, -251, -95, 251, -14)
	var margin := _add_margin(panel, 9, 8, 9, 8)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)
	var actions := ["BUILD", "LAND", "PLANT", "WORKERS", "MANAGEMENT"]
	for action_value in actions:
		var action := str(action_value)
		var button := Button.new()
		button.name = "Action_%s" % action
		button.custom_minimum_size = Vector2(82, 58)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = action.capitalize()
		button.add_theme_font_size_override("font_size", 10)
		_style_button(button, false)
		var icon_content := VBoxContainer.new()
		icon_content.name = "IconContent"
		icon_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_content.alignment = BoxContainer.ALIGNMENT_CENTER
		icon_content.add_theme_constant_override("separation", 1)
		icon_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		icon.name = "ActionIcon"
		icon.texture = ACTION_ICONS[action]
		icon.custom_minimum_size = Vector2(24, 24)
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var caption_text := "MANAGE" if action == "MANAGEMENT" else action
		var caption := _label(caption_text, 9, Color(0.91, 0.91, 0.82), true)
		caption.name = "ActionCaption"
		caption.tooltip_text = action.capitalize()
		caption.custom_minimum_size = Vector2(0, 11)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_content.add_child(icon)
		icon_content.add_child(caption)
		button.add_child(icon_content)
		button.pressed.connect(_on_action_pressed.bind(action))
		action_buttons[action] = button
		row.add_child(button)


func _build_details_panel() -> void:
	details_panel = _make_panel("DetailsPanel", 1.0, 0.5, 1.0, 0.5, -300, -122, -18, 142)
	details_panel.custom_minimum_size = Vector2(270, 264)
	details_panel.visible = false
	var margin := _add_margin(details_panel, 15, 12, 15, 13)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)
	details_content = VBoxContainer.new()
	details_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_content.add_theme_constant_override("separation", 8)
	scroll.add_child(details_content)
	var header := HBoxContainer.new()
	details_title = _label("DETAILS", 14, Color(0.94, 0.93, 0.84), true)
	details_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "×"
	close.custom_minimum_size = Vector2(30, 28)
	close.focus_mode = Control.FOCUS_NONE
	_style_button(close, true)
	close.pressed.connect(close_details)
	header.add_child(details_title)
	header.add_child(close)
	details_content.add_child(header)
	var divider := ColorRect.new()
	divider.color = Color(0.82, 0.83, 0.75, 0.14)
	divider.custom_minimum_size = Vector2(0, 1)
	details_content.add_child(divider)


func _build_toast() -> void:
	toast_panel = _make_panel("Toast", 0.5, 0.73, 0.5, 0.73, -200, 0, 200, 54)
	toast_panel.visible = false
	var margin := _add_margin(toast_panel, 14, 8, 14, 8)
	toast_label = _label("", 12, Color(0.94, 0.93, 0.84), true)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(toast_label)


func _make_panel(
	node_name: String,
	left: float,
	top: float,
	right: float,
	bottom: float,
	offset_l: float,
	offset_t: float,
	offset_r: float,
	offset_b: float
) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.anchor_left = left
	panel.anchor_top = top
	panel.anchor_right = right
	panel.anchor_bottom = bottom
	panel.offset_left = offset_l
	panel.offset_top = offset_t
	panel.offset_right = offset_r
	panel.offset_bottom = offset_b
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _panel_style())
	screen.add_child(panel)
	return panel


func _add_margin(parent: Control, left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)
	parent.add_child(margin)
	return margin


func _label(text_value: String, size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.34))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.075, 0.061, 0.91)
	style.border_color = Color(0.79, 0.79, 0.65, 0.15)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	style.shadow_size = 8
	return style


func _style_button(button: Button, compact: bool) -> void:
	button.add_theme_stylebox_override("normal", _button_style(Color(0.11, 0.15, 0.12, 0.92)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.17, 0.23, 0.17, 0.97)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.24, 0.34, 0.23, 1.0)))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.07, 0.09, 0.075, 0.72)))
	button.add_theme_color_override("font_color", Color(0.88, 0.90, 0.81))
	button.add_theme_color_override("font_hover_color", Color(0.97, 0.97, 0.87))
	button.add_theme_color_override("font_pressed_color", Color(0.97, 0.97, 0.87))
	button.add_theme_color_override("font_disabled_color", Color(0.45, 0.49, 0.42))
	button.add_theme_font_size_override("font_size", 10 if compact else 11)


func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.82, 0.83, 0.69, 0.12)
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	return style


func _progress_background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.13, 0.10, 0.95)
	style.set_corner_radius_all(3)
	return style


func _progress_fill() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.59, 0.68, 0.36)
	style.set_corner_radius_all(3)
	return style


func _on_action_pressed(action: String) -> void:
	active_action = action
	_update_button_states()
	action_selected.emit(action)


func _on_speed_pressed(speed: float) -> void:
	for value in speed_buttons:
		(speed_buttons[value] as Button).set_pressed_no_signal(is_equal_approx(float(value), speed))
	speed_selected.emit(speed)


func set_active_action(action: String) -> void:
	active_action = action
	_update_button_states()


func _update_button_states() -> void:
	for action in action_buttons:
		(action_buttons[action] as Button).set_pressed_no_signal(action == active_action)


func _refresh_hud() -> void:
	if simulation == null:
		return
	for key in resource_labels:
		var value: Variant = simulation.resources.get(key, 0)
		var prefix := "$" if key == "money" else ""
		(resource_labels[key] as Label).text = prefix + str(int(value))
	day_label.text = simulation.get_calendar_label()
	var season_index := clampi(simulation.get_current_season_index(), 0, SEASON_SHORT_NAMES.size() - 1)
	var season_label: String = str(SEASON_SHORT_NAMES[season_index])
	speed_label.text = "%s  ·  x%.0f" % [season_label, simulation.game_speed]
	objective_title.text = simulation.get_phase_title()
	objective_hint.text = simulation.get_instruction()
	objective_progress.text = simulation.get_progress_text()
	var progress := 0.0
	if simulation.shelter != null and not simulation.shelter.is_complete:
		progress = simulation.shelter.construction_progress * 100.0
	elif simulation.land_state == LandState.CLEARING:
		progress = simulation.land_progress * 100.0
	elif simulation.worker != null:
		progress = simulation.worker.job_progress * 100.0
	objective_bar.value = 100.0 if progress >= 100.0 else float(int(floor(progress / 25.0)) * 25)
	for value in speed_buttons:
		(speed_buttons[value] as Button).set_pressed_no_signal(
			is_equal_approx(float(value), simulation.game_speed)
		)
	_update_action_availability()
	if details_panel.visible and selected_kind == "management":
		_update_management_values()


func _update_action_availability() -> void:
	var build: Button = action_buttons.BUILD
	build.disabled = simulation.shelter != null
	var land: Button = action_buttons.LAND
	var plant: Button = action_buttons.PLANT
	var shelter_ready: bool = simulation.shelter != null and simulation.shelter.is_complete
	land.disabled = not shelter_ready or simulation.land_state == LandState.CLEARING
	plant.disabled = simulation.land_state != LandState.PREPARED


func _on_state_changed() -> void:
	_refresh_hud()
	if details_panel.visible and selected_kind == "worker":
		_update_worker_detail_values()
	elif details_panel.visible and selected_kind == "shelter":
		_render_shelter_details()
	elif details_panel.visible and selected_kind == "land":
		_render_land_details()
	elif details_panel.visible and selected_kind == "collection":
		_render_collection_details()


func set_selected_worker() -> void:
	selected_kind = "worker"
	selected_id = simulation.worker.id
	_last_detail_signature = ""
	details_panel.visible = true
	_render_worker_details()


func show_palm_detail(palm) -> void:
	selected_kind = "palm"
	selected_id = palm.id
	_last_detail_signature = ""
	details_panel.visible = true
	_render_palm_details(palm)


func show_shelter_detail() -> void:
	selected_kind = "shelter"
	selected_id = "starter_shelter"
	_last_detail_signature = ""
	details_panel.visible = true
	_render_shelter_details()


func show_land_detail() -> void:
	selected_kind = "land"
	selected_id = simulation.land_zone.id
	_last_detail_signature = ""
	details_panel.visible = true
	_render_land_details()


func show_collection_detail() -> void:
	selected_kind = "collection"
	selected_id = simulation.collection_point.id
	_last_detail_signature = ""
	details_panel.visible = true
	_render_collection_details()


func show_management() -> void:
	selected_kind = "management"
	selected_id = ""
	_last_detail_signature = ""
	details_panel.visible = true
	_render_management_details()


func close_details() -> void:
	dismiss_details()
	selection_closed.emit()


func dismiss_details() -> void:
	details_panel.visible = false
	selected_kind = ""
	selected_id = ""
	_last_detail_signature = ""


func refresh_hud() -> void:
	_refresh_hud()


func _clear_detail_rows() -> void:
	for index in range(details_content.get_child_count() - 1, 1, -1):
		details_content.get_child(index).queue_free()


func _add_detail_label(
	text_value: String, color: Color = Color(0.77, 0.80, 0.72), font_size: int = 12
) -> Label:
	var label := _label(text_value, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_content.add_child(label)
	return label


func _add_detail_row(caption: String, value: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := _label(caption, 11, Color(0.62, 0.69, 0.60))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var amount := _label(value, 11, Color(0.92, 0.92, 0.82), true)
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(label)
	row.add_child(amount)
	details_content.add_child(row)


func _render_worker_details() -> void:
	if simulation == null:
		return
	var active_task = simulation.worker.current_task
	var task_id: String = "—" if active_task == null else str(active_task.id)
	var task_status := "Available" if active_task == null else "%s · %s" % [active_task.task_type, active_task.status_name()]
	var task_progress := 0 if active_task == null else int(round(active_task.progress * 100.0))
	var signature := "%s|%s|%s|%d|%d|%d|%.0f|%.1f" % [
		simulation.worker.name,
		simulation.worker.state_name(),
		task_id + task_status,
		task_progress,
		simulation.worker.task_queue.size(),
		int(simulation.worker.experience),
		simulation.worker.energy,
		simulation.worker.carried_ffb_kg
	]
	if signature == _last_detail_signature:
		return
	_last_detail_signature = signature
	_clear_detail_rows()
	details_title.text = simulation.worker.name.to_upper()
	_add_detail_row("ROLE", simulation.worker.role)
	_add_detail_row("CURRENT STATE", simulation.worker.state_name())
	_add_detail_row("ACTIVE TASK", task_status)
	_add_detail_row("TASK PROGRESS", "%d%%" % task_progress)
	_add_detail_row("QUEUED TASKS", str(simulation.worker.task_queue.size()))
	_add_detail_row("PRODUCTIVITY", "%.0f%%" % (simulation.worker.productivity * 100.0))
	if simulation.worker.carrying_ffb:
		_add_detail_row("CARRYING", "%d kg FFB" % int(round(simulation.worker.carried_ffb_kg)))
	_add_detail_row("EXPERIENCE", "%.0f" % simulation.worker.experience)
	_add_detail_label(
		"Worker routes to each job and performs the work in-world.", Color(0.68, 0.73, 0.63), 10
	)


func _update_worker_detail_values() -> void:
	if details_panel.visible and selected_kind == "worker":
		_render_worker_details()


func _render_palm_details(palm) -> void:
	var fertilizer_available: int = int(simulation._available_resource("fertilizer"))
	var pesticide_available: int = int(simulation._available_resource("pesticide"))
	var harvest_reserved: bool = simulation.harvest_reservations.has(palm.id)
	var days_to_window: float = CropModel.days_to_next_harvest_window(
		palm.age, palm.fruit_cycle_days, palm.harvest_count, palm.harvest_ready
	)
	var estimate_age := maxf(palm.age, CropModel.FIRST_COMMERCIAL_HARVEST_DAYS)
	var estimated_ffb := CropModel.estimate_harvest_lot_kg(
		estimate_age, palm.health, palm.pest_risk, palm.fertilizer
	)
	if palm.harvest_ready:
		estimated_ffb = int(round(palm.fruit_quantity))
	var next_window_text := "READY · %d kg" % estimated_ffb if palm.harvest_ready else "~%d kg · %.1f mo" % [estimated_ffb, days_to_window / CropModel.DAYS_PER_MONTH]
	var signature := "%s|%d|%d|%d|%d|%d|%d|%d|%s" % [
		palm.id,
		int(palm.growth_stage),
		int(palm.fruit_state),
		int(floor(palm.age)),
		int(round(palm.health)),
		int(round(palm.fertilizer)),
		int(round(palm.pest_risk)),
		simulation.get_current_season_index(),
		str(harvest_reserved)
	]
	if signature == _last_detail_signature:
		return
	_last_detail_signature = signature
	_clear_detail_rows()
	details_title.text = "PALM"
	_add_detail_row("STAGE", palm.stage_name().to_upper())
	_add_detail_row("AGE", "%.1f game years" % CropModel.game_days_to_years(palm.age))
	if int(palm.growth_stage) < int(PalmData.GrowthStage.MATURE):
		var next_stage := "YOUNG PALM" if int(palm.growth_stage) == int(PalmData.GrowthStage.SEEDLING) else "MATURE PALM"
		_add_detail_row("NEXT STAGE", "%s · %d%%" % [next_stage, int(round(palm.growth_to_next_stage() * 100.0))])
	_add_detail_row("HEALTH", "%.0f%%" % palm.health)
	_add_detail_row("FRUIT", palm.fruit_state_name())
	_add_detail_row("NEXT FFB WINDOW", next_window_text)
	if palm.last_harvest >= 0.0:
		_add_detail_row("LAST HARVEST", "%s · %d cycle(s)" % [CropModel.calendar_label(palm.last_harvest), palm.harvest_count])
	_add_detail_row("FERTILIZER", "%.0f%%" % palm.fertilizer)
	_add_detail_row("PEST INDEX", "%.0f / 100" % palm.pest_risk)
	if palm.harvest_ready:
		_add_harvest_button("HARVEST" if not harvest_reserved else "HARVEST ORDERED", palm.id, not harvest_reserved)
	_add_detail_button("FERTILIZE  ·  5", "FERTILIZE", palm.id, fertilizer_available >= 5)
	_add_detail_button("TREAT PESTS  ·  2", "TREAT", palm.id, pesticide_available >= 2)
	_add_detail_label("Accelerated scenario model; timing and input rates are not local prescriptions.", Color(0.68, 0.73, 0.63), 10)


func _add_harvest_button(text_value: String, palm_id: String, enabled: bool) -> void:
	var button := _create_detail_button(text_value)
	button.disabled = not enabled
	button.pressed.connect(func(): harvest_requested.emit(palm_id))
	details_content.add_child(button)


func refresh_palm_detail(palm) -> void:
	if details_panel.visible and selected_kind == "palm" and selected_id == palm.id:
		_render_palm_details(palm)


func _render_land_details() -> void:
	if simulation == null:
		return
	var state_label := _land_state_label()
	var progress_value := int(round(simulation.land_progress * 100.0))
	var available_seedlings: int = int(simulation._available_resource("seedlings"))
	var available_fertilizer: int = int(simulation._available_resource("fertilizer"))
	var available_pesticide: int = int(simulation._available_resource("pesticide"))
	var ready_harvest_count: int = int(simulation.get_ready_harvest_count())
	var signature := "%s|%d|%d|%d|%d|%d|%d|%d|%d" % [
		state_label,
		progress_value,
		simulation.palms.size(),
		simulation.reserved_slots.size(),
		available_seedlings,
		available_fertilizer,
		available_pesticide,
		int(simulation.shelter != null and simulation.shelter.is_complete),
		ready_harvest_count
	]
	if signature == _last_detail_signature:
		return
	_last_detail_signature = signature
	_clear_detail_rows()
	details_title.text = "BLOCK 01 · %s" % state_label.to_upper()
	_add_detail_row("LAND STATE", state_label)
	match simulation.land_state:
		LandState.FOREST:
			_add_detail_label("Select this surveyed block to clear it. Crew and equipment cost: $150.", Color(0.68, 0.73, 0.63), 10)
			var clear_button := _create_detail_button("CLEAR LAND  ·  $150")
			clear_button.disabled = simulation.shelter == null or not simulation.shelter.is_complete or int(simulation.resources.money) < 150
			clear_button.pressed.connect(func(): land_clear_requested.emit())
			details_content.add_child(clear_button)
		LandState.CLEARING:
			_add_detail_row("CLEARING", "%d%%" % progress_value)
			_add_detail_label("Rafi is removing vegetation. The 4 × 4 planting grid appears when clearing is complete.", Color(0.68, 0.73, 0.63), 10)
		LandState.PREPARED:
			_add_detail_row("PLANTING POSITIONS", "%d / 16 occupied or queued" % (simulation.palms.size() + simulation.reserved_slots.size()))
			_add_detail_label("Four orderly rows are ready. Choose PLANT and tap an open marker.", Color(0.68, 0.73, 0.63), 10)
			var plant_button := _create_detail_button("PLANT A SEEDLING")
			plant_button.disabled = available_seedlings < 1 or simulation.palms.size() + simulation.reserved_slots.size() >= simulation.planting_slots.size()
			plant_button.pressed.connect(func():
				active_action = "PLANT"
				_update_button_states()
				action_selected.emit("PLANT")
			)
			details_content.add_child(plant_button)
			if ready_harvest_count > 0:
				_add_detail_row("READY TO HARVEST", str(ready_harvest_count))
				var harvest_button := _create_detail_button("HARVEST READY PALMS  ·  %d" % ready_harvest_count)
				harvest_button.pressed.connect(func(): harvest_block_requested.emit())
				details_content.add_child(harvest_button)
			if not simulation.palms.is_empty():
				_add_detail_button("FERTILIZE BLOCK  ·  5", "FERTILIZE", simulation.land_zone.id, available_fertilizer >= 5)
				_add_detail_button("TREAT BLOCK  ·  2", "TREAT", simulation.land_zone.id, available_pesticide >= 2)


func _create_detail_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 34)
	button.focus_mode = Control.FOCUS_NONE
	_style_button(button, true)
	return button


func _render_collection_details() -> void:
	var latest_sale: Dictionary = simulation.latest_transaction
	var sale_signature := "none" if latest_sale.is_empty() else "%s|%d|%d|%d" % [
		str(latest_sale.get("id", "")),
		int(latest_sale.get("ffb_kg", 0)),
		int(latest_sale.get("revenue", 0)),
		int(latest_sale.get("funds_after", 0))
	]
	var signature := "%d|%s" % [simulation.harvested_ffb_kg, sale_signature]
	if signature == _last_detail_signature:
		return
	_last_detail_signature = signature
	_clear_detail_rows()
	details_title.text = "FFB COLLECTION"
	_add_detail_row("STORED FFB", "%d kg" % simulation.harvested_ffb_kg)
	_add_detail_row("PROTOTYPE PRICE", "$%.2f / kg" % simulation.PROTOTYPE_FFB_PRICE_PER_KG)
	_add_detail_label("Fresh fruit bunches are delivered here by the worker before sale.", Color(0.68, 0.73, 0.63), 10)
	var sell_button := _create_detail_button("SELL STORED FFB")
	sell_button.disabled = simulation.harvested_ffb_kg <= 0
	sell_button.pressed.connect(func(): sell_requested.emit())
	details_content.add_child(sell_button)
	if not latest_sale.is_empty():
		_add_detail_label("LAST TRANSACTION  ·  %s" % str(latest_sale.get("id", "")), Color(0.78, 0.78, 0.58), 10)
		_add_detail_row("SOLD", "%d kg FFB" % int(latest_sale.get("ffb_kg", 0)))
		_add_detail_row("REVENUE", "+$%d" % int(latest_sale.get("revenue", 0)))
		_add_detail_row("FUNDS AFTER SALE", "$%d" % int(latest_sale.get("funds_after", 0)))


func _render_shelter_details() -> void:
	var progress := 0 if simulation.shelter == null else int(round(simulation.shelter.construction_progress * 100.0))
	var signature := "shelter|%d|%s" % [progress, "complete" if simulation.shelter != null and simulation.shelter.is_complete else "building"]
	if signature == _last_detail_signature:
		return
	_last_detail_signature = signature
	_clear_detail_rows()
	details_title.text = "STARTER SHELTER"
	if simulation.shelter == null:
		_add_detail_label("No shelter constructed yet.")
	else:
		_add_detail_row("CONSTRUCTION", "%d%%" % progress)
		_add_detail_row("STATUS", "Complete" if simulation.shelter.is_complete else simulation.worker.state_name().capitalize())
		_add_detail_label(
			"A first base for the crew and plantation operations.", Color(0.68, 0.73, 0.63), 10
		)


func _render_management_details() -> void:
	_clear_detail_rows()
	details_title.text = "ESTATE OVERVIEW"
	_update_management_values()


func _update_management_values() -> void:
	if not details_panel.visible or selected_kind != "management":
		return
	var signature := (
		"%d|%d|%d|%d|%s"
		% [
			simulation.day_number,
			simulation.palms.size(),
			simulation.resources.seedlings,
			simulation.resources.money,
			simulation.worker.state_name()
		]
	)
	if signature == _last_detail_signature:
		return
	_last_detail_signature = signature
	_clear_detail_rows()
	details_title.text = "ESTATE OVERVIEW"
	_add_detail_row("MODEL CALENDAR", simulation.get_calendar_label())
	_add_detail_row("SCENARIO PERIOD", simulation.get_current_season_name().capitalize())
	_add_detail_row("LAND", _land_state_label())
	_add_detail_row("PALMS", str(simulation.palms.size()))
	_add_detail_row("WORKER", simulation.worker.state_name().capitalize())
	_add_detail_row("GAME SPEED", "x%.0f" % simulation.game_speed)
	var cohorts: Array[Dictionary] = simulation.get_cohort_summaries()
	if cohorts.is_empty():
		_add_detail_label("Plant seedlings to establish the first crop cohort.", Color(0.68, 0.73, 0.63), 10)
	else:
		_add_detail_label("PLANTING COHORTS", Color(0.78, 0.78, 0.58), 10)
		for cohort in cohorts:
			_add_detail_label(
				"%s · %d palms · %.1f game years"
				% [str(cohort.id), int(cohort.palm_count), float(cohort.average_age_years)],
				Color(0.90, 0.91, 0.83),
				11
			)
			_add_detail_row(
				"SEED / YOUNG / MATURE",
				"%d / %d / %d"
				% [int(cohort.seedling_count), int(cohort.young_count), int(cohort.mature_count)]
			)
			_add_detail_row("AVG HEALTH", "%.0f%%" % float(cohort.average_health_percent))
			_add_detail_row(
				"AVG FERTILIZER",
				"%.0f / 100" % float(cohort.average_fertilizer_reserve)
			)
			_add_detail_row("AVG PEST INDEX", "%.0f / 100" % float(cohort.average_pest_index))
			_add_detail_row(
				"READY NOW",
				"%d · %d kg" % [int(cohort.ready_count), int(cohort.ready_kg)]
			)
			_add_detail_row(
				"NEXT 30 MODEL DAYS",
				"%d · ~%d kg"
				% [int(cohort.within_model_month_count), int(cohort.within_model_month_kg)]
			)
			var earliest_days := float(cohort.earliest_window_days)
			var earliest_window := "—"
			if earliest_days >= 0.0:
				if earliest_days <= 0.000001:
					earliest_window = "Today"
				else:
					earliest_window = "%s · %.1f mo" % [
						str(cohort.earliest_window_calendar),
					earliest_days / CropModel.DAYS_PER_MONTH
					]
			_add_detail_row("EARLIEST WINDOW", earliest_window)
	var outlook_note := (
		"Next 30 model days exclude ready fruit; forecasts use age and modeled drift. "
		+ "Fertilizer is reserve; pest index is a scenario scale, not an infestation rate."
	)
	_add_detail_label(outlook_note, Color(0.68, 0.73, 0.63), 10)


func _land_state_label() -> String:
	match simulation.land_state:
		LandState.FOREST:
			return "Forest"
		LandState.CLEARING:
			return "Clearing"
		LandState.PREPARED:
			return "Prepared"
	return "—"


func _add_detail_button(text_value: String, action: String, palm_id: String, enabled: bool) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 34)
	button.disabled = not enabled
	button.focus_mode = Control.FOCUS_NONE
	_style_button(button, true)
	button.pressed.connect(func(): maintenance_requested.emit(action, palm_id))
	details_content.add_child(button)


func show_toast(message: String, kind: String = "info") -> void:
	if not is_instance_valid(toast_panel):
		return
	_toast_serial += 1
	var serial := _toast_serial
	toast_label.text = message
	var panel_style := _panel_style()
	match kind:
		"success":
			panel_style.border_color = Color(0.48, 0.69, 0.34, 0.64)
		"warning":
			panel_style.border_color = Color(0.82, 0.62, 0.24, 0.66)
		"error":
			panel_style.border_color = Color(0.76, 0.31, 0.24, 0.7)
		_:
			panel_style.border_color = Color(0.63, 0.71, 0.55, 0.42)
	toast_panel.add_theme_stylebox_override("panel", panel_style)
	toast_panel.modulate.a = 1.0
	toast_panel.visible = true
	if _toast_tween != null and _toast_tween.is_running():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.8)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(
		func():
			if serial == _toast_serial and is_instance_valid(toast_panel):
				toast_panel.visible = false
	)


func _refresh_action_button_state() -> void:
	_update_button_states()


func _update_responsive_layout() -> void:
	if screen == null:
		return
	var viewport_width := get_viewport().get_visible_rect().size.x
	var resource_panel := screen.get_node_or_null("Resources") as PanelContainer
	var status_panel := screen.get_node_or_null("StatusCard") as PanelContainer
	var time_panel := screen.get_node_or_null("TimeAndSpeed") as PanelContainer
	var action_panel := screen.get_node_or_null("ActionBar") as PanelContainer
	if viewport_width < 1000.0:
		resource_panel.anchor_left = 0.0
		resource_panel.anchor_right = 1.0
		resource_panel.offset_left = 18.0
		resource_panel.offset_right = -18.0
		resource_panel.offset_top = 88.0
		resource_panel.offset_bottom = 145.0
	else:
		resource_panel.anchor_left = 0.5
		resource_panel.anchor_right = 0.5
		resource_panel.offset_left = -225.0
		resource_panel.offset_right = 225.0
		resource_panel.offset_top = 16.0
		resource_panel.offset_bottom = 81.0
	if viewport_width < 620.0:
		status_panel.offset_left = 10.0
		status_panel.offset_right = 180.0
		status_panel.offset_top = 10.0
		status_panel.offset_bottom = 75.0
		time_panel.offset_left = -214.0
		time_panel.offset_right = -10.0
		time_panel.offset_top = 10.0
		time_panel.offset_bottom = 75.0
		for speed in speed_buttons:
			var speed_button := speed_buttons[speed] as Button
			speed_button.custom_minimum_size = Vector2(26, 30)
			speed_button.add_theme_font_size_override("font_size", 8)
		action_panel.offset_left = -viewport_width * 0.5 + 8.0
		action_panel.offset_right = viewport_width * 0.5 - 8.0
		action_panel.offset_top = -91.0
		action_panel.offset_bottom = -8.0
		for action in action_buttons:
			var button := action_buttons[action] as Button
			button.custom_minimum_size = Vector2(52, 56)
			button.add_theme_font_size_override("font_size", 8)
	elif viewport_width < 1000.0:
		status_panel.offset_left = 18.0
		status_panel.offset_right = 248.0
		time_panel.offset_left = -275.0
		time_panel.offset_right = -18.0
		action_panel.offset_left = -245.0
		action_panel.offset_right = 245.0
		action_panel.offset_top = -95.0
		action_panel.offset_bottom = -14.0
		for action in action_buttons:
			var button := action_buttons[action] as Button
			button.custom_minimum_size = Vector2(76, 58)
			button.add_theme_font_size_override("font_size", 9)
	else:
		status_panel.offset_left = 18.0
		status_panel.offset_right = 248.0
		time_panel.offset_left = -290.0
		time_panel.offset_right = -18.0
		action_panel.offset_left = -251.0
		action_panel.offset_right = 251.0
		action_panel.offset_top = -95.0
		action_panel.offset_bottom = -14.0
		for action in action_buttons:
			var button := action_buttons[action] as Button
			button.custom_minimum_size = Vector2(82, 58)
			button.add_theme_font_size_override("font_size", 10)
	if viewport_width >= 620.0:
		for speed in speed_buttons:
			var speed_button := speed_buttons[speed] as Button
			speed_button.custom_minimum_size = Vector2(39, 34)
			speed_button.add_theme_font_size_override("font_size", 10)
