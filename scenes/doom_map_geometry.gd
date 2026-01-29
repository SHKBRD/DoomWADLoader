class_name DoomMapGeometry
extends Node3D


@export var sectorList: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func build_map_sectors(map: RawDoomMap) -> void:
	for sectorInd: int in map.sectors.size():
		var assembleSector: DoomSectorGeometry = Instantiate.scene(DoomSectorGeometry)
		assembleSector.name = "Sector"+str(sectorInd)
		sectorList.add_child(assembleSector)
		assembleSector.init_sector(map, map.sectors[sectorInd], sectorInd)
		

func initialize_geometry(map: RawDoomMap) -> void:
	build_map_sectors(map)
	var newSaveScene: PackedScene = PackedScene.new()
	print(get_child(0).get_child_count())
	newSaveScene.pack(self)
	var result: Error = ResourceSaver.save(newSaveScene, "res://test/sector_3d_test.tscn")
	if result == Error.OK:
		print("saved")
	else:
		print(result)
		print("wrong")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
