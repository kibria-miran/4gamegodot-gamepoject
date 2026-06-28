extends Node

func has_line_of_sight(from_tile: Vector2i, to_tile: Vector2i) -> bool:
    var from_pos = tile_to_world(from_tile) + Vector3(0, 1.0, 0)
    var to_pos = tile_to_world(to_tile) + Vector3(0, 1.0, 0)
    var space = get_tree().root.get_world_3d().direct_space_state
    if not space: return true
    var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
    query.collision_mask = 0b0010
    var result = space.intersect_ray(query)
    return result.is_empty()

func tile_to_world(tile: Vector2i) -> Vector3:
    return Vector3(tile.x * 4.0, 0.0, tile.y * 4.0)
