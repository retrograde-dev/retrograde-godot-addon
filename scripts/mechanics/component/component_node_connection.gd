class_name ComponentNodeConnection

var edge: Core.Edge # Edge of the node this connection starts from
var end_edge: Core.Edge # Edge of the node connected to
var end_coords: Vector2i # Coords of connected component or end
var path_coords: Array[Vector2i] # Coords of components in between

func _init(
	edge_: Core.Edge,
	end_edge_: Core.Edge,
	end_coords_: Vector2i, 
	path_coords_: Array[Vector2i] = []
) -> void:
	edge = edge_
	end_edge = end_edge_
	end_coords = end_coords_
	path_coords = path_coords_
