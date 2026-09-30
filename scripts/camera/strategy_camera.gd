extends Camera3D
class_name StrategyCamera

## Elevated miniature-world camera with smooth pan, zoom, and small optional rotation.
@export var minimum_zoom: float = 8.0
@export var maximum_zoom: float = 58.0
@export var zoom_step: float = 2.0
@export var pan_sensitivity: float = 0.0018
@export var smoothing: float = 12.0
@export var elevation_degrees: float = 48.0
@export var minimum_elevation: float = 34.0
@export var maximum_elevation: float = 62.0
@export var allow_rotation: bool = true
@export var world_min := Vector2(-43.0, -37.0)
@export var world_max := Vector2(43.0, 37.0)

var focus_point := Vector3(-7.0, 0.0, 6.0)
var desired_focus := Vector3(-7.0, 0.0, 6.0)
var zoom_distance: float = 32.0
var desired_zoom: float = 32.0
var desired_elevation: float = 48.0
var yaw: float = 0.0
var desired_yaw: float = 0.0

var _dragging := false
var _rotating := false
var _touching := false
var _dragged_this_gesture := false
var pointer_was_dragged := false
var _gesture_start := Vector2.ZERO
var _last_pointer := Vector2.ZERO


func _ready() -> void:
	current = true
	_apply_transform()


func _process(delta: float) -> void:
	var weight := 1.0 - exp(-smoothing * delta)
	focus_point = focus_point.lerp(desired_focus, weight)
	zoom_distance = lerpf(zoom_distance, desired_zoom, weight)
	yaw = lerp_angle(yaw, desired_yaw, weight)
	elevation_degrees = lerpf(elevation_degrees, desired_elevation, weight)
	_apply_transform()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMagnifyGesture:
		desired_zoom = clampf(desired_zoom / maxf(event.factor, 0.1), minimum_zoom, maximum_zoom)
	elif event is InputEventKey and event.pressed and allow_rotation:
		if event.keycode == KEY_Q:
			desired_yaw += 0.12
		elif event.keycode == KEY_E:
			desired_yaw -= 0.12


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		desired_zoom = maxf(minimum_zoom, desired_zoom - zoom_step)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		desired_zoom = minf(maximum_zoom, desired_zoom + zoom_step)
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _pointer_over_ui():
				_dragging = true
				_dragged_this_gesture = false
				_gesture_start = event.position
				_last_pointer = event.position
		else:
			if _dragging:
				pointer_was_dragged = _dragged_this_gesture
			_dragging = false
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and not _pointer_over_ui():
			_dragging = true
			_dragged_this_gesture = true
			_last_pointer = event.position
		elif not event.pressed:
			_dragging = false
	elif event.button_index == MOUSE_BUTTON_MIDDLE and allow_rotation:
		if event.pressed and not _pointer_over_ui():
			_rotating = true
			_last_pointer = event.position
		elif not event.pressed:
			_rotating = false


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _dragging:
		var displacement := event.position - _gesture_start
		if displacement.length() >= 6.0:
			_dragged_this_gesture = true
		var delta_pointer := event.position - _last_pointer
		_pan_by(delta_pointer)
		_last_pointer = event.position
	elif _rotating and allow_rotation:
		var delta_pointer := event.position - _last_pointer
		desired_yaw -= delta_pointer.x * 0.004
		desired_elevation = clampf(
			desired_elevation + delta_pointer.y * 0.035, minimum_elevation, maximum_elevation
		)
		_last_pointer = event.position


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if not _pointer_over_ui():
			_touching = true
			_dragging = true
			_dragged_this_gesture = false
			_gesture_start = event.position
			_last_pointer = event.position
	else:
		if _touching:
			pointer_was_dragged = _dragged_this_gesture
		_touching = false
		_dragging = false


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if _touching:
		if (event.position - _gesture_start).length() >= 6.0:
			_dragged_this_gesture = true
		_pan_by(event.relative)
		_last_pointer = event.position


func _pan_by(pointer_delta: Vector2) -> void:
	if pointer_delta.length_squared() < 0.001:
		return
	var right := global_transform.basis.x
	var forward := -global_transform.basis.z
	right.y = 0.0
	forward.y = 0.0
	right = right.normalized()
	forward = forward.normalized()
	var scale := zoom_distance * pan_sensitivity
	desired_focus += (-right * pointer_delta.x + forward * pointer_delta.y) * scale
	desired_focus.x = clampf(desired_focus.x, world_min.x, world_max.x)
	desired_focus.z = clampf(desired_focus.z, world_min.y, world_max.y)


func _apply_transform() -> void:
	var elevation := deg_to_rad(elevation_degrees)
	var offset := (
		Vector3(sin(yaw) * cos(elevation), sin(elevation), cos(yaw) * cos(elevation))
		* zoom_distance
	)
	global_position = focus_point + offset
	look_at(focus_point, Vector3.UP)


func _pointer_over_ui() -> bool:
	var hovered := get_viewport().gui_get_hovered_control()
	return hovered != null


func ground_point(screen_position: Vector2) -> Vector3:
	var origin := project_ray_origin(screen_position)
	var direction := project_ray_normal(screen_position)
	if absf(direction.y) < 0.0001:
		return Vector3(-9999.0, 0.0, -9999.0)
	var distance := -origin.y / direction.y
	if distance < 0.0:
		return Vector3(-9999.0, 0.0, -9999.0)
	return origin + direction * distance


func consume_drag_flag() -> bool:
	var was_dragged := pointer_was_dragged
	pointer_was_dragged = false
	return was_dragged


func set_focus(point: Vector3, zoom: float = -1.0) -> void:
	desired_focus = Vector3(point.x, 0.0, point.z)
	desired_focus.x = clampf(desired_focus.x, world_min.x, world_max.x)
	desired_focus.z = clampf(desired_focus.z, world_min.y, world_max.y)
	if zoom > 0.0:
		desired_zoom = clampf(zoom, minimum_zoom, maximum_zoom)


func reset_view() -> void:
	desired_yaw = 0.0
	desired_elevation = 48.0
	set_focus(Vector3(-7.0, 0.0, 6.0), 32.0)
