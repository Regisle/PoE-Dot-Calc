extends ColorRect

var font1 = null
const BASE_GRID_HEIGHT = 80
const BASE_GRID_WIDTH = 35
const BASE_GRID_SPACE = 8

var GraphSize = Vector2.ZERO
var GRID_HEIGHT = 80
var GRID_WIDTH = 35
var GRID_SPACE = 8

var MaxVal = 0
var nBar = 0
var nBarText = 0
var graphData = []

var MaxValDivisor = 1

func _ready() -> void:
	var textGraph = Label.new()
	font1 = textGraph.get_font("")
	pass


func drawGraph(data) -> void:
	graphData = []
	GraphSize = rect_size
	
	var tempData = {}
	for i in range(data.size()):
		if tempData.has(data[i]):
			tempData[data[i]] += 1
		else:
			tempData[data[i]] = 1
	
	for dat in tempData:
		graphData.append(Vector2(dat, tempData[dat]))
	graphData.sort_custom(self, "sort_x_ascending")
	
	MaxValDivisor = int(graphData.size() / (GraphSize.x - 50) + 1)
	
	while graphData.size() > GraphSize.x - 50:
		tempData = []
		for i in range(graphData.size()):
			if i % MaxValDivisor == 0:
				tempData.append(Vector2(graphData[i].x,graphData[i].y))
			else:
				tempData[-1].y += graphData[i].y
		graphData = tempData
	
	#print(graphData)
	
	for val in graphData:
		MaxVal = max(MaxVal, val.y)
	nBar = max(graphData.size(), 1)
		
	
	#print(nBar)
	if nBar > 16:
		GRID_SPACE = 0
		nBarText = 16
	else:
		GRID_SPACE = 8
		nBarText = nBar
		
	GRID_WIDTH = max(1, min(35, (GraphSize.x - 60) * BASE_GRID_WIDTH / ((BASE_GRID_WIDTH + GRID_SPACE) * nBar)))
	#print(GRID_WIDTH)
	
	
	if MaxVal == 0:
		return
	
	update()
	pass


func _draw() -> void:
	if graphData.size() < 1:
		return
	#lines
	for i in range(6):
		#Scale 0 to max value on left
# warning-ignore:integer_division
		draw_string(font1, Vector2(15, (GraphSize.y - 15) - int(i*GRID_HEIGHT)), String(int(i * MaxVal / MaxValDivisor) / 5), Color("828282"))
		
		#Main line Axis X
		draw_line(Vector2(50, (GraphSize.y - 19) - int(i*GRID_HEIGHT)), Vector2(50 + (nBar * (GRID_WIDTH + GRID_SPACE) + GRID_SPACE), (GraphSize.y - 19) - int(i*GRID_HEIGHT)), Color("b4b4b4", 2, false))
		
		#Secondary line Axis X
		for j in range(3):
			draw_line(Vector2(50, (GraphSize.y - 40) - int(i*GRID_HEIGHT) + j * 20), Vector2(50 + (nBar * (GRID_WIDTH + GRID_SPACE) + GRID_SPACE), (GraphSize.y - 40) - int(i*GRID_HEIGHT) + j * 20), Color("dcdcdc", 1, false))
	
	#draw bars
	for i in range(nBar):
		draw_rect(Rect2(Vector2((50 + GRID_SPACE) + i*(GRID_WIDTH + GRID_SPACE), GraphSize.y - 20), Vector2(GRID_WIDTH, - (graphData[i].y * GRID_HEIGHT * 5 / MaxVal))), Color("1890F5"), true)
		
	#bar text
	for i in range(nBarText):
# warning-ignore:integer_division
		draw_string(font1, Vector2((40 + GRID_SPACE) + i*(BASE_GRID_WIDTH + BASE_GRID_SPACE) + BASE_GRID_WIDTH / 2, (GraphSize.y)), String(graphData[int(i * nBar/nBarText)].x), Color("1890F5"))
	pass


func sort_x_ascending(a, b) -> bool:
		if a.x < b.x:
			return true
		return false
