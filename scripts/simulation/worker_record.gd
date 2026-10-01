extends RefCounted
class_name WorkerRecord

## Simulation-only worker data. Animation and character nodes are kept in the presentation layer.
enum State { IDLE, WALKING, CLEARING, PLANTING, BUILDING, FERTILIZING, TREATING }

var id: String = "worker_01"
var worker_name: String = "Rafi"
var position: Vector3 = Vector3(-22.0, 0.0, 13.0)
var destination: Vector3 = position
var state: State = State.IDLE
var job_type: String = ""
var job_progress: float = 0.0
var energy: float = 100.0
var morale: float = 100.0
var experience: float = 0.0
var active_task = null
var task_queue: Array = []
var walk_speed: float = 3.5
var time_in_state: float = 0.0


func state_name() -> String:
	match state:
		State.IDLE:
			return "IDLE"
		State.WALKING:
			return "WALKING"
		State.CLEARING:
			return "CLEARING"
		State.PLANTING:
			return "PLANTING"
		State.BUILDING:
			return "BUILDING"
		State.FERTILIZING:
			return "FERTILIZING"
		State.TREATING:
			return "TREATING"
	return "IDLE"
