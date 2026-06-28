extends Node


signal day_started(day: int)
signal phase_changed(phase: String)
signal room_built(room_id: String, tile: Vector2i)
signal room_demolished(tile: Vector2i)
signal resource_changed(type: String, value: float)
signal event_fired(event: Dictionary)
signal game_over(reason: String)
signal mission_started(mission_id: String)
signal mission_completed(success: bool, result: Dictionary)
signal moral_threshold_crossed(threshold: String)
signal objective_secured()
