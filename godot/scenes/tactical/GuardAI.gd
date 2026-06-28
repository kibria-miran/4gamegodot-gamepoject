extends RefCounted

enum GUARD_STATE { UNAWARE, SUSPICIOUS, ALERTED, COMBAT }

var id: String
var tile_position: Vector2i
var facing: Vector2i
var alert_meter: int = 0
var hp: int = 50
var max_hp: int = 50
var combat: int = 5
var state: int = GUARD_STATE.UNAWARE
