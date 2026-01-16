extends BaseSpeech

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		%SpeechLabel.text = ""

func refresh_bubble() -> void:
	super.refresh_bubble()
	
	var bubble_size: Vector2 = Vector2(0, 768)
	var tile_size: Vector2i = Vector2i(0, 3)
	var horizontal_center_offset: int = 0
	var offset: int = 0

	var tile_set_source_id: int = %SpeechBubble.tile_set.get_source_id(0)
	
	match speech_style:
		Core.SpeechStyle.THINK:
			offset = 0 # Only one style atm
		
	match speech_size:
		Core.SpeechSize.SMALL:
			bubble_size.x = 768.0
			tile_size.x = 3
			horizontal_center_offset = 1
			
			for i: int in 3:
				%SpeechBubble.set_cell(Vector2i(0, i), tile_set_source_id, Vector2i(offset + 0, i))
				%SpeechBubble.set_cell(Vector2i(1, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(2, i), tile_set_source_id, Vector2i(offset + 2, i))
				%SpeechBubble.set_cell(Vector2i(3, i))
				%SpeechBubble.set_cell(Vector2i(4, i))
				%SpeechBubble.set_cell(Vector2i(5, i))
				%SpeechBubble.set_cell(Vector2i(6, i))
				
			%SpeechLabel.size.x = 300.0
		Core.SpeechSize.MEDIUM:
			bubble_size.x = 1280.0
			tile_size.x = 5
			horizontal_center_offset = 2
			
			for i: int in 3:
				%SpeechBubble.set_cell(Vector2i(0, i), tile_set_source_id, Vector2i(offset + 0, i))
				%SpeechBubble.set_cell(Vector2i(1, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(2, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(3, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(4, i), tile_set_source_id, Vector2i(offset + 2, i))
				%SpeechBubble.set_cell(Vector2i(5, i))
				%SpeechBubble.set_cell(Vector2i(6, i))
				
			%SpeechLabel.size.x = 812.0
		Core.SpeechSize.LARGE:
			bubble_size.x = 1792.0
			tile_size.x = 7
			horizontal_center_offset = 3
			
			for i: int in 3:
				%SpeechBubble.set_cell(Vector2i(0, i), tile_set_source_id, Vector2i(offset + 0, i))
				%SpeechBubble.set_cell(Vector2i(1, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(2, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(3, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(4, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(5, i), tile_set_source_id, Vector2i(offset + 1, i))
				%SpeechBubble.set_cell(Vector2i(6, i), tile_set_source_id, Vector2i(offset + 2, i))
			
			%SpeechLabel.size.x = 1324.0
	
	match speech_alignment:
		Core.Alignment.TOP_LEFT:
			if speech_orientation == Core.Orientation.VERTICAL:
				%SpeechBubble.set_cell(Vector2i(0, 0), tile_set_source_id, Vector2i(offset + 0, 3))
			else:
				%SpeechBubble.set_cell(Vector2i(0, 0), tile_set_source_id, Vector2i(offset + 0, 5))
			
			%SpeechBubble.position = Vector2(0.0, 0.0)
		Core.Alignment.TOP_RIGHT:
			if speech_orientation == Core.Orientation.VERTICAL:
				%SpeechBubble.set_cell(Vector2i(tile_size.x - 1, 0), tile_set_source_id, Vector2i(offset + 2, 3))
			else:
				%SpeechBubble.set_cell(Vector2i(tile_size.x - 1, 0), tile_set_source_id, Vector2i(offset + 1, 5))
			
			%SpeechBubble.position = Vector2(-bubble_size.x, 0.0)
		Core.Alignment.TOP_CENTER:
			%SpeechBubble.set_cell(Vector2i(horizontal_center_offset, 0), tile_set_source_id, Vector2i(offset + 1, 3))
			
			%SpeechBubble.position = Vector2(-bubble_size.x / 2.0, 0.0)
		Core.Alignment.BOTTOM_LEFT:
			if speech_orientation == Core.Orientation.VERTICAL:
				%SpeechBubble.set_cell(Vector2i(0, tile_size.y - 1), tile_set_source_id, Vector2i(offset + 0, 4))
			else:
				%SpeechBubble.set_cell(Vector2i(0, tile_size.y - 1), tile_set_source_id, Vector2i(offset + 0, 7))
			
			%SpeechBubble.position = Vector2(0.0, -bubble_size.y)
		Core.Alignment.BOTTOM_RIGHT:
			if speech_orientation == Core.Orientation.VERTICAL:
				%SpeechBubble.set_cell(Vector2i(tile_size.x - 1, tile_size.y - 1), tile_set_source_id, Vector2i(offset + 2, 4))
			else:
				%SpeechBubble.set_cell(Vector2i(tile_size.x - 1, tile_size.y - 1), tile_set_source_id, Vector2i(offset + 1, 7))
			
			%SpeechBubble.position = Vector2(-bubble_size.x, -bubble_size.y)
		Core.Alignment.BOTTOM_CENTER:
			%SpeechBubble.set_cell(Vector2i(horizontal_center_offset, tile_size.y - 1), tile_set_source_id, Vector2i(offset + 1, 4))
			
			%SpeechBubble.position = Vector2(-bubble_size.x / 2.0, -bubble_size.y)
		Core.Alignment.CENTER_LEFT:
			%SpeechBubble.set_cell(Vector2i(0, 1), tile_set_source_id, Vector2i(offset + 0, 6))
			
			%SpeechBubble.position = Vector2(0, -bubble_size.y / 2.0)
		Core.Alignment.CENTER_RIGHT:
			%SpeechBubble.set_cell(Vector2i(tile_size.x - 1, 1), tile_set_source_id, Vector2i(offset + 1, 6))
			
			%SpeechBubble.position = Vector2(-bubble_size.x, -bubble_size.y / 2.0)
		Core.Alignment.CENTER_CENTER:
			%SpeechBubble.position = Vector2(-bubble_size.x / 2.0, -bubble_size.y / 2.0)
		
func refresh_lines() -> void:
	super.refresh_lines()
	
	%SpeechLabel.text = speech_line
