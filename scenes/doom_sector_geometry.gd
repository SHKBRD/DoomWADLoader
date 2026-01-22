class_name DoomSectorGeometry
extends Node3D

@export var ceilMesh: MeshInstance3D
@export var floorMesh: MeshInstance3D
@export var wallMesh: MeshInstance3D

var sectorId: int

var ceilHeight: float
var floorHeight: float
var lightLevel: int

var ceilTextureName: String
var floorTextureName: String

var sectorPoints: PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init_sector(rawSector: RawDoomMap.DoomSector, sectorId: int, sectorGeo: Array[PackedVector2Array]) -> void:
	ceilHeight = rawSector.ceilingHeight
	floorHeight = rawSector.floorHeight
	ceilTextureName = rawSector.ceilingTextureName
	floorTextureName = rawSector.floorTextureName
	lightLevel = rawSector.lightLevel
	build_sector_meshes(sectorGeo)

func build_sector_meshes(sectorGeo: Array[PackedVector2Array]) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
