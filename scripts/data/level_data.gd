extends BaseData
class_name LevelData

var level_alias: StringName

var level: LevelDataFile
var areas: AreaDataLoader
var items: ItemDataLoader
var objects: ObjectDataLoader

func _init(level_alias_: StringName) -> void:
	level_alias = level_alias_
	
	level = LevelDataFile.new("res://data/level/" + level_alias_ + "/level.json")
	level.load()
	
	areas = AreaDataLoader.new("res://data/level/" + level_alias_ + "/area")
	areas.load()
	
	items = ItemDataLoader.new("res://data/level/" + level_alias_ + "/item")
	items.load()
	
	objects = ObjectDataLoader.new("res://data/level/" + level_alias_ + "/object")
	objects.load()
