extends RefCounted
class_name PlantationTask

## Reusable simulation task record. Workers and world visuals reference this data; tasks do not own nodes.
enum Status { QUEUED, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED }

var id: String = ""
var task_type: String = ""
var target: Vector3 = Vector3.ZERO
var assigned_worker: String = ""
var duration: float = 0.0
var progress: float = 0.0
var status: Status = Status.QUEUED
var elapsed: float = 0.0
var payload: Dictionary = {}


func status_name() -> String:
	return str(Status.keys()[int(status)])
