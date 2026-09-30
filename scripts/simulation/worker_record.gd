extends RefCounted
class_name WorkerRecord

## Simulation-only data for a visible worker. Rendering is owned by Main/VisualFactory.
enum State { IDLE, WALKING, CLEARING, PLANTING, BUILDING, FERTILIZING, INSPECTING, TREATING }

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
var active_job: Dictionary = {}
var job_queue: Array[Dictionary] = []
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
		State.INSPECTING:
			return "INSPECTING"
		State.TREATING:
			return "TREATING"
	return "IDLE"
