extends Node3D

var grid_size: Vector2i

func load_map(map_data: Dictionary):
    grid_size = Vector2i(map_data.width, map_data.height)

func tile_to_world(tile: Vector2i) -> Vector3:
    return Vector3(tile.x * 4.0, 0.0, tile.y * 4.0)

func world_to_tile(world: Vector3) -> Vector2i:
    return Vector2i(int(world.x / 4.0), int(world.z / 4.0))
