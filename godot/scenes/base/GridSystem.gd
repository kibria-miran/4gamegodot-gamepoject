extends Node3D

const GRID_SIZE: int = 8
const TILE_SIZE: float = 4.0

var grid: Array = []
var selected_room_id: String = ""
var ghost_preview: MeshInstance3D = null

func _ready():
    _build_grid_visual()
    EventBus.room_built.connect(_on_room_built)

func _build_grid_visual():
    for z in range(GRID_SIZE):
        for x in range(GRID_SIZE):
            var tile = BoxMesh.new()
            tile.size = Vector3(3.8, 0.1, 3.8)
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.2, 0.22, 0.25)
            if (x + z) % 2 == 0:
                mat.albedo_color = Color(0.18, 0.2, 0.22)
            mat.transparency = 0.3
            var mi = MeshInstance3D.new()
            mi.mesh = tile
            mi.material_override = mat
            mi.position = Vector3(x * TILE_SIZE, -0.05, z * TILE_SIZE)
            add_child(mi)

func get_tile_from_mouse(event: InputEventMouseButton) -> Vector2i:
    if event.button_index != MOUSE_BUTTON_LEFT: return Vector2i(-1, -1)
    var space = get_viewport().get_camera_3d()
    if not space: return Vector2i(-1, -1)
    var from = space.project_ray_origin(event.position)
    var dir = space.project_ray_normal(event.position)
    var plane = Plane(Vector3(0, 1, 0), 0)
    var intersect = plane.intersects_ray(from, dir)
    if intersect == null: return Vector2i(-1, -1)
    var x = floori(intersect.x / TILE_SIZE + 0.5)
    var z = floori(intersect.z / TILE_SIZE + 0.5)
    if x < 0 or x >= GRID_SIZE or z < 0 or z >= GRID_SIZE: return Vector2i(-1, -1)
    return Vector2i(x, z)

func is_tile_occupied(tile: Vector2i) -> bool:
    for room in FacilityManager.get_all_rooms():
        if room.get("tile") == tile:
            return true
    return false

func place_room(room_id: String, tile: Vector2i) -> bool:
    if tile.x < 0 or tile.y < 0: return false
    if is_tile_occupied(tile): return false
    return FacilityManager.build_room(room_id, tile, 0)

func _on_room_built(room_id: String, tile: Vector2i):
    var room_data = RoomDatabase.get(room_id)
    if room_data.is_empty(): return
    var cube = BoxMesh.new()
    cube.size = Vector3(3.8, 2.0, 3.8)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.3, 0.35, 0.4)
    match room_id:
        "generator_room": mat.albedo_color = Color(0.8, 0.6, 0.1)
        "command_center": mat.albedo_color = Color(0.1, 0.4, 0.8)
        "barracks": mat.albedo_color = Color(0.2, 0.6, 0.3)
        "containment_cell": mat.albedo_color = Color(0.7, 0.2, 0.2)
        "armory": mat.albedo_color = Color(0.5, 0.3, 0.1)
    var mi = MeshInstance3D.new()
    mi.mesh = cube
    mi.material_override = mat
    mi.position = Vector3(tile.x * TILE_SIZE, 1.0, tile.y * TILE_SIZE)
    add_child(mi)
