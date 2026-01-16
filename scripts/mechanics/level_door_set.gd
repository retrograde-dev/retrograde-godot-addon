class_name LevelDoorSet

var doors: Array[LevelDoorValue]

func _init(level_: BaseLevel) -> void:
	for area_file_: AreaDataFile in level_.data.areas.files:
		var area_: Dictionary = area_file_.data
		
		if not area_.has(&"doors"):
			continue
			
		for door_: Dictionary in area_.doors:
			if not door_.has(&"area"):
				continue
			
			if not door_.area_.has(&"alias"):
				continue
			
			doors.push_back(LevelDoorValue.new(
				door_.alias,
				door_.area.alias,
				door_.area.position if door_.area.has(&"position") else Vector2i.ZERO,
				door_.area.mode if door_.area.has(&"mode") else Core.UnitMode.NORMAL,
				door_.meta if door_.has(&"meta") else {},
			))
			
func get_door(alias_: StringName) -> LevelDoorValue:
	for door_: LevelDoorValue in doors:
		if door_.alias == alias_:
			return door_
			
	return null
	
func get_doors() -> Array[LevelDoorValue]:
	return doors
