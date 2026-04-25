class_name AliasProviderSet

var providers: Array[AliasProviderValue]

func _init(providers_: Array[AliasProviderValue]) -> void:
	providers = providers_
	
func reset() -> void:
	for provider_: AliasProviderValue in providers:
		provider_.reset()

func is_empty() -> bool:
	for provider_: AliasProviderValue in providers:
		if not provider_.is_empty():
			return false
	
	return true

func get_alias() -> StringName:
	var indexes_: Array[int] = range(providers.size())
	indexes_.shuffle()
	
	for index_: int in indexes_:
		if providers[index_].is_empty():
			continue
			
		return providers[index_].get_alias()
	
	return &""

func get_aliases(count_: int) -> Array[StringName]:
	var result_: Array[StringName] = []
	
	var current_count_: int = count_
	
	while current_count_ > 0:
		var alias_: StringName = get_alias()
		
		# No more aliases to get
		if alias_ == &"":
			break
			
		result_.push_back(alias_)
		
	return result_
