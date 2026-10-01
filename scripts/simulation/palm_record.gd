extends RefCounted
class_name PalmRecord

## Pure simulation data; WorldBuilder owns the corresponding palm visual.
const CropModel = preload("res://scripts/simulation/crop_model.gd")
enum GrowthStage { SEEDLING, YOUNG, MATURE }
enum FruitState { NONE, DEVELOPING, READY, HARVESTED, RECOVERING }

var id: String = ""
var slot_index: int = -1
var cohort_id: String = ""
var planted_day: float = 0.0
## Field-age in accelerated model days since this palm was planted.
var age: float = 0.0
var growth_stage: GrowthStage = GrowthStage.SEEDLING
var health: float = 100.0
var fertilizer: float = 0.0
var pest_risk: float = 0.0
var position: Vector3 = Vector3.ZERO
var fruit_state: FruitState = FruitState.NONE
var harvest_ready: bool = false
var fruit_quantity: float = 0.0
var last_harvest: float = -1.0
var harvest_count: int = 0
## Accelerated game-days elapsed in this fruit/recovery cycle.
var fruit_cycle_days: float = 0.0


func stage_name() -> String:
	match growth_stage:
		GrowthStage.SEEDLING:
			return "Seedling"
		GrowthStage.YOUNG:
			return "Young palm"
		GrowthStage.MATURE:
			return "Mature palm"
	return "Seedling"


func fruit_state_name() -> String:
	match fruit_state:
		FruitState.NONE:
			return "MATURE" if growth_stage == GrowthStage.MATURE else "NO FRUIT"
		FruitState.DEVELOPING:
			return "FRUIT DEVELOPING"
		FruitState.READY:
			return "READY TO HARVEST"
		FruitState.HARVESTED:
			return "HARVESTED"
		FruitState.RECOVERING:
			return "RECOVERY / GROWING"
	return "MATURE"


func growth_to_next_stage() -> float:
	return CropModel.growth_progress_to_next_stage(age)
