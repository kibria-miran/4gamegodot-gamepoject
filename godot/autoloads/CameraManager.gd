extends Node

var current_rig: Node3D = null

func switch_to_base():
	print("CameraManager: switching to BaseCameraRig")

func switch_to_tactical():
	print("CameraManager: switching to TacticalCameraRig")

func smooth_pan_to(tile: Vector2i, duration: float = 0.3):
	pass
