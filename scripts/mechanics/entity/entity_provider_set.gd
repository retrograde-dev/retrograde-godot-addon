extends Resource
class_name EntityProviderSet

@export var providers: Array[EntityProviderValue] = []

func _init(providers_: Array[EntityProviderValue] = []) -> void:
	providers = providers_
	
func reset() -> void:
	for provider_: EntityProviderValue in providers:
		provider_.reset()

func is_empty() -> bool:
	for provider_: EntityProviderValue in providers:
		if not provider_.is_empty():
			return false
	
	return true

func get_entity() -> EntityResource:
	var indexes_: Array[int] = range(providers.size())
	indexes_.shuffle()
	
	for index_: int in indexes_:
		if providers[index_].is_empty():
			continue
			
		return providers[index_].get_entity()
	
	return null

func get_entities(count_: int) -> Array[EntityResource]:
	var result_: Array[EntityResource] = []
	
	var current_count_: int = count_
	
	while current_count_ > 0:
		var entity_: EntityResource = get_entity()
		
		# No more entities to get
		if entity_ == null:
			break
			
		result_.push_back(entity_)
		
	return result_
