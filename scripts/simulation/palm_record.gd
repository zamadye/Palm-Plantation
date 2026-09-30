extends RefCounted
class_name PalmRecord

## Compact simulation record; the visible palm is a separate scene/model.
enum GrowthStage { SEEDLING, YOUNG, DEVELOPING, MATURE }

var id: String = ""
var slot_index: int = -1
var position: Vector3 = Vector3.ZERO
var planting_age_days: float = 0.0
var growth_stage: GrowthStage = GrowthStage.SEEDLING
var health: float = 100.0
var fertilizer_state: float = 0.0
var pest_state: float = 0.0
var inspected: bool = false
var last_inspected_day: int = 0


func stage_name() -> String:
	match growth_stage:
		GrowthStage.SEEDLING:
			return "Seedling"
		GrowthStage.YOUNG:
			return "Young palm"
		GrowthStage.DEVELOPING:
			return "Developing palm"
		GrowthStage.MATURE:
			return "Mature palm"
	return "Seedling"


func growth_to_next_stage() -> float:
	var limits := [8.0, 22.0, 45.0, 45.0]
	var stage_index := int(growth_stage)
	if stage_index >= 3:
		return 1.0
	var start_age := 0.0
	if stage_index == 1:
		start_age = 8.0
	elif stage_index == 2:
		start_age = 22.0
	return clampf((planting_age_days - start_age) / (limits[stage_index] - start_age), 0.0, 1.0)
