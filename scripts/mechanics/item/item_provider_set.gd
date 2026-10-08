extends Resource
class_name ItemProviderSet

@export var providers: Array[ItemProviderValue] = []
@export var ratio: ItemRatioSet = null

func _init(
	providers_: Array[ItemProviderValue] = [],
	ratio_: ItemRatioSet = null,
) -> void:
	providers = providers_
	ratio = ratio_
	
func reset() -> void:
	for provider_: ItemProviderValue in providers:
		provider_.reset()
		
	if ratio != null:
		ratio.reset()

func is_empty() -> bool:
	for provider_: ItemProviderValue in providers:
		if not provider_.is_empty():
			return false
	
	return true

func has_item_type(type_: Core.ItemType, subtype_: Variant) -> bool:
	for provider_: ItemProviderValue in providers:
		if provider_.has_item_of_type(type_, subtype_):
			return true
	
	return false

func get_item() -> ItemResource:
	if ratio != null:
		var item_type_: Dictionary = _get_next_item_type()
		
		if item_type_.is_empty():
			return null
			
		return _get_item_of_type(item_type_.type, item_type_.subtype)
	else:
		var indexes_: Array[int] = range(providers.size())
		indexes_.shuffle()
		
		for index_: int in indexes_:
			if providers[index_].is_empty():
				continue
				
			return providers[index_].get_item()
		
		return null
	
func get_items(count_: int) -> Array[ItemResource]:
	var result_: Array[ItemResource] = []
	
	var current_count_: int = count_
	
	while current_count_ > 0:
		var item_: ItemResource = get_item()
		
		# No more items to get
		if item_ == null:
			break
			
		result_.push_back(item_)
		
	return result_
	
func _get_next_item_type() -> Dictionary:
	if is_empty():
		return {}
	
	# If an ItemAliasProviderValue has alieases that do not match the types 
	# defined in the ItemRatioSet, we check a maximum of twice the size to 
	# allow repeating.
	var total_count_: int = ratio.size()
	total_count_ *= 2
	
	var current_count_: int = 0
	
	var item_type_: Dictionary = ratio.get_next_item_type()
	while not has_item_type(item_type_.type, item_type_.subtype):
		item_type_ = ratio.get_next_item_type()
		
		current_count_ += 1
		if current_count_ >= total_count_:
			return {}
		
	return item_type_
	
func _get_item_of_type(type: Core.ItemType, subtype: Variant) -> ItemResource:
	var indexes_: Array[int] = range(providers.size())
	indexes_.shuffle()
	
	for index_: int in indexes_:
		if providers[index_].is_empty():
			continue
			
		if not providers[index_].has_alias_of_type(type, subtype):
			continue
		
		return providers[index_].get_alias_of_type(type, subtype)
	
	return null
