extends RefCounted
class_name LandZoneRecord

## Data-only plantation block / clearing-zone state. Its mesh and tree instances are view-only.
enum State { FOREST, CLEARING, CLEARED, PREPARING, PREPARED }

var id: String = "block_01"
var position: Vector3 = Vector3(8.0, 0.0, 10.0)
var size: Vector2 = Vector2(24.0, 18.0)
var grid_origin: Vector2i = Vector2i.ZERO
var state: State = State.FOREST
var clearing_progress: float = 0.0
var preparation_progress: float = 0.0


func contains(point: Vector3) -> bool:
	return absf(point.x - position.x) <= size.x * 0.5 and absf(point.z - position.z) <= size.y * 0.5
