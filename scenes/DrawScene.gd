extends Node2D

@onready var doomWAD: DoomWAD = $DoomWAD

var map: RawDoomMap
var screenDims: Vector2

func _ready() -> void:
	map = doomWAD.get_map("E1M1")
	screenDims = get_viewport().size

func get_level_bounds(points: Array) -> Rect2:
	var minX: int = points[0].x
	var minY: int = points[0].y
	var maxX: int = points[0].x
	var maxY: int = points[0].y
	
	for point: Vector2i in points:
		minX = min(minX, point.x)
		minY = min(minY, point.y)
		maxX = max(maxX, point.x)
		maxY = max(maxY, point.y)
	
	var minVec: Vector2 = Vector2(minX, minY)
	var maxVec: Vector2 = Vector2(maxX, maxY)
	
	return Rect2i(minVec, maxVec-minVec)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_map(map)

func normalize_point(vertex: Vector2i, bounds: Rect2) -> Vector2:
	return ((Vector2(vertex)-bounds.position)/bounds.size)*bounds.size.normalized()

func draw_map(doomMap: RawDoomMap) -> void:
	var vertices: Array = doomMap.vertexes.map(func(v): return v*Vector2i(1,-1))
	var mapBounds: Rect2 = get_level_bounds(vertices)
	
	for vertex: Vector2i in vertices:
		var normalizedPos: Vector2 = normalize_point(vertex, mapBounds)
		
		draw_circle(normalizedPos*600, 1, Color.BLUE, true)
	
	var linedefs: Array[RawDoomMap.DoomLineDef] = doomMap.lineDefs
	for linedef: RawDoomMap.DoomLineDef in linedefs:
		var normalizedV1Pos: Vector2 = normalize_point(vertices[linedef.v1], mapBounds)
		var normalizedV2Pos: Vector2 = normalize_point(vertices[linedef.v2], mapBounds)
		draw_line(normalizedV1Pos*600, normalizedV2Pos*600, Color(0.5, 0.5, 0.75, 0.5), 2)
	
	var segments: Array[RawDoomMap.DoomSegment] = doomMap.segs
	for segment: RawDoomMap.DoomSegment in segments:
		var normalizedV1Pos: Vector2 = normalize_point(vertices[segment.v1], mapBounds)
		var normalizedV2Pos: Vector2 = normalize_point(vertices[segment.v2], mapBounds)
		draw_line(normalizedV1Pos*600, normalizedV2Pos*600, Color(0.75, 0.5, 0.5, 0.5), 2)
