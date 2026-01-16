extends BaseCanvasLayer
class_name HUDController

var available_space: Vector2

var _data: Dictionary

func _init() -> void:
	if FileAccess.file_exists("res://data/hud.json"):
		var _file: HUDDataFile = HUDDataFile.new("res://data/hud.json")
		_file.load()
		_data = _file.data
	else:
		_data = {
			&"enabled": [],
			&"huds": [],
			&"default": {}
		}
	
func _ready() -> void:
	super._ready()
	
	get_viewport().connect(&"size_changed", _on_viewport_size_changed)
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if reset_type_ == Core.ResetType.START:
		for hud_: StringName in _data.enabled:
			assert(_data.huds.has(hud_), "HUD not found. (" + hud_ + ")")
			
			if not _data.huds.has(hud_):
				continue
			
			var hud_resource_: Resource = load(_data.huds[hud_])
			
			assert(hud_resource_ != null, "HUD not found. (" + hud_ + ": " + _data.huds[hud_] + ")")
			
			var hud_node_: BaseHUD = hud_resource_.instantiate()

			if _data.default.has(hud_):
				hud_node_.visible = _data.default[hud_].visible
				hud_node_.hud_alignment = _data.default[hud_].alignment
				hud_node_.hud_offset = _data.default[hud_].offset
			else:
				hud_node_.visible = false
				
			hud_node_.rect_changed.connect(_on_hud_rect_changed)
				
			add_child(hud_node_)
		
		_update_available_space()
		_reposition()
	elif reset_type_ == Core.ResetType.REFRESH:
		_reposition()

func get_hud(alias_: StringName) -> BaseHUD:
	for child_: Node in get_children():
		if child_ is BaseHUD and child_.alias == alias_:
			return child_
		
	return null
	
func has_visible_huds() -> bool:
	for child_: Node in get_children():
		if child_ is BaseHUD and child_.visible:
			return true
		
	return false

func is_hud_visible(alias_: StringName) -> bool:
	var hud_: BaseHUD = get_hud(alias_)
	
	if hud_ != null and hud_.visible == true:
		return true
		
	return false

func hide_huds() -> void:
	for child_: Node in get_children():
		if child_ is BaseHUD:
			child_.hide()

func hide_hud(alias_: StringName) -> void:
	var hud_: BaseHUD = get_hud(alias_)
	if hud_ != null:
		hud_.hide()
			
func show_hud(alias_: StringName) -> void:
	var hud_: BaseHUD = get_hud(alias_)
	
	if hud_ != null:
		hud_.show()
		_reposition_hud(hud_)
		
func _on_viewport_size_changed() -> void:
	_update_available_space()
	_reposition()
	
func _update_available_space() -> void:
	available_space = Vector2(get_viewport().get_visible_rect().size) / scale

func _reposition(force: bool = false) -> void:
	for child_: Node in get_children():
		if child_ is BaseHUD:
			_reposition_hud(child_)
	
func _reposition_hud(hud_: BaseHUD) -> void:
	var rect_: Rect2 = hud_.get_scale_rect()

	var offset_: Vector2 = Core.get_align_offset(rect_, hud_.alignment)
	
	var position_: Vector2 = Vector2.ZERO
	
	match hud_.hud_alignment:
		Core.Alignment.TOP_CENTER, \
		Core.Alignment.CENTER_CENTER, \
		Core.Alignment.BOTTOM_CENTER:
			position_.x = (available_space.x - rect_.size.x) * 0.5
		Core.Alignment.TOP_RIGHT, \
		Core.Alignment.CENTER_RIGHT, \
		Core.Alignment.BOTTOM_RIGHT:
			position_.x = available_space.x - rect_.size.x
	
	match hud_.hud_alignment:
		Core.Alignment.CENTER_LEFT, \
		Core.Alignment.CENTER_CENTER, \
		Core.Alignment.CENTER_RIGHT:
			position_.y = (available_space.y - rect_.size.y) * 0.5
		Core.Alignment.BOTTOM_LEFT, \
		Core.Alignment.BOTTOM_CENTER, \
		Core.Alignment.BOTTOM_RIGHT:
			position_.y = available_space.y - rect_.size.y
	
	hud_.position = position_ + offset_ + hud_.hud_offset

func _on_hud_rect_changed(hud_: BaseHUD) -> void:
	_reposition_hud(hud_)
