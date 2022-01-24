extends Control

#refs

onready var label1 = $HBoxContainer/VBoxContainer/HBoxContainer/Label
onready var label2 = $HBoxContainer/VBoxContainer/HBoxContainer2/Label
onready var graph = $HBoxContainer/VBoxContainer/Graph

onready var calc : DotCalc = DotCalc.new()

#main variables
var toSim : int  = 0
var simRan : int = 0

var PoBEstimate : float = 0
var BetterPoBEstimate : float = 0
var totalDPS : float = 0

var toGraph : bool = true

#simulation variables
var simulations : int = 10000
var simulationSteps : int = 10000
var simulationDuration : float = 300
var dots = []

var singleAttack = false
var attacktime : float = 1.25

# dot variables
var dotChance : int = 100
var DotBase = {"min": 5000, "max": 10000}
var crit = {"chance": 20, "mult": 1.3}
#var MoreDotChance : int = 60 #no longer valid 3.14+
var Ruthless = {"active": false, "mult": 2.32}
var multistrike = {"repeates": 0, "mult1": 1.2, "mult2": 1.4, "mult3": 1.6}

var maxStacks : int = 1
var duration : float = 7


func _ready():
	$HBoxContainer/Inputs/simulations/HBoxContainer/VBoxContainer/SpinBox.value = simulations
	$HBoxContainer/Inputs/simulations/HBoxContainer/VBoxContainer2/SpinBox.value = simulationDuration
	$HBoxContainer/Inputs/simulations/HBoxContainer/VBoxContainer3/CheckButton.pressed = toGraph
	$HBoxContainer/Inputs/AttackTime/HBoxContainer/VBoxContainer/SpinBox.value = attacktime
	$HBoxContainer/Inputs/AttackTime/HBoxContainer/VBoxContainer2/CheckButton.pressed = singleAttack
	$HBoxContainer/Inputs/DoTBasics/HBoxContainer/VBoxContainer/SpinBox.value = dotChance
	$HBoxContainer/Inputs/DoTBasics/HBoxContainer/VBoxContainer2/SpinBox.value = duration
	$HBoxContainer/Inputs/DoTBasics/HBoxContainer/VBoxContainer3/SpinBox.value = maxStacks
	$HBoxContainer/Inputs/DotBase/HBoxContainer/VBoxContainer/SpinBox.value = DotBase.min
	$HBoxContainer/Inputs/DotBase/HBoxContainer/VBoxContainer2/SpinBox.value = DotBase.max
	$HBoxContainer/Inputs/Crit/HBoxContainer/VBoxContainer/SpinBox.value = crit.chance
	$HBoxContainer/Inputs/Crit/HBoxContainer/VBoxContainer2/SpinBox.value = crit.mult
#	$HBoxContainer/Inputs/MoreDot/SpinBox.value = MoreDotChance
	$HBoxContainer/Inputs/Ruthless/HBoxContainer/VBoxContainer/checkbox.pressed = Ruthless.active
	$HBoxContainer/Inputs/Ruthless/HBoxContainer/VBoxContainer2/SpinBox.value = Ruthless.mult
	$HBoxContainer/Inputs/Multistrike/HBoxContainer/VBoxContainer/SpinBox.value = multistrike.repeates
	$HBoxContainer/Inputs/Multistrike/HBoxContainer/VBoxContainer2/SpinBox.value = multistrike.mult1
	$HBoxContainer/Inputs/Multistrike/HBoxContainer/VBoxContainer3/SpinBox.value = multistrike.mult2
	$HBoxContainer/Inputs/Multistrike/HBoxContainer/VBoxContainer4/SpinBox.value = multistrike.mult3
	pass

# warning-ignore:unused_argument
func _process(delta) -> void:
	if toSim > 0:
		var temp = simRan
		for i in range(1, min(toSim, simulationSteps)):
			if singleAttack:
				dots.append(calc.calcDotInstance(i))
			else:
				dots.append(calc.calcDotSimulation())
			totalDPS += dots[-1]
		simRan += int(min(toSim, simulationSteps))
		toSim -= simulationSteps
		if toSim <= 0:
			toSim = 0
			$HBoxContainer/Inputs/RunSimulation.disabled = false
			$HBoxContainer/Inputs/RunSimulation.text = "Run Simulation"
		if dots.size() == 0:
			temp = 0
		else:
			temp = totalDPS / dots.size()
		if toGraph:
			graph.drawGraph(dots)
		label1.text = "simulations ran: " + String(simRan)
		label1.text += "     PoB estimated dps: " + String(PoBEstimate)
		label1.text += "     average dps: " + String(temp)
		label1.text += "     percent: " + String(PoBEstimate / temp * 100) + "%"
		label2.text = "Better PoB estimated dps: " + String(BetterPoBEstimate)
		label2.text += "     percent of PoB: " + String(BetterPoBEstimate / PoBEstimate * 100) + "%"
		label2.text += "     percent of Simulated: " + String(BetterPoBEstimate / temp * 100) + "%"
	pass

func calcDotSimulation() -> int:
	var timeElapsed = -attacktime
	var DotInstances = []
	DotInstances.append(Vector2(timeElapsed + duration, calcDotInstance(0)))
	var totalDotDamage = 0
	var attacknum = 0
	while timeElapsed < simulationDuration:
		totalDotDamage += calcMaxX(DotInstances, maxStacks, timeElapsed)
		timeElapsed += attacktime
		attacknum += 1
		var instance = Vector2(timeElapsed + duration, calcDotInstance(attacknum))
		DotInstances.insert(DotInstances.bsearch_custom(instance, self, "sort_dotval"),instance)
	return int(totalDotDamage / timeElapsed)
	pass


func calcDotInstance(attacknum : int) -> int:
	if rand_range(0, 100) > dotChance:
		return 0
	var DotRoll : int = int(rand_range(DotBase.min, DotBase.max + 1))
#	if rand_range(0, 100) <= MoreDotChance:
#		DotRoll = DotRoll * 2
	if rand_range(0, 100) <= crit.chance:
# warning-ignore:integer_division
		DotRoll = (DotRoll * int(crit.mult * 100)) / 100
	if multistrike.repeates > 1:
		match attacknum % (multistrike.repeates + 1):
			1:
# warning-ignore:integer_division
				DotRoll = (DotRoll * int(multistrike.mult1 * 100)) / 100
			2:
# warning-ignore:integer_division
				DotRoll = (DotRoll * int(multistrike.mult2 * 100)) / 100
			3:
# warning-ignore:integer_division
				DotRoll = (DotRoll * int(multistrike.mult3 * 100)) / 100
		if Ruthless.active and attacknum / (multistrike.repeates + 1) % 3 == 0:
# warning-ignore:integer_division
			DotRoll = (DotRoll * int(Ruthless.mult * 100)) / 100
	elif Ruthless.active and attacknum % 3 == 0:
# warning-ignore:integer_division
		DotRoll = (DotRoll * int(Ruthless.mult * 100)) / 100
	
	return DotRoll
	pass


func calcMaxX(dotInstances : Array, X : int, timeElapsed : float) -> float:
	var sum : float = 0
	var extraTime : float = 0
	var todel = []
	for i in range(dotInstances.size()):
		if dotInstances[i].x <= timeElapsed + extraTime:
			todel.append(dotInstances[i])
	for num in todel:
		dotInstances.erase(num)
	if dotInstances.size() < 0:
		return 0.0
	while extraTime + 0.0001 <= attacktime:
		#print(extraTime)
		#print(attacktime)
		var minTime : float = attacktime - extraTime
		var count : int = 0
		var dotVal : float = 0
		for dot in dotInstances:
			count += 1
			if count > X:
				break
			dotVal += dot.y
			minTime = min(minTime, dot.x - (timeElapsed + extraTime))
		extraTime += minTime
		sum += minTime * dotVal
		todel = []
		for i in range(dotInstances.size()):
			if dotInstances[i].x <= timeElapsed + extraTime:
				todel.append(dotInstances[i])
		for num in todel:
			dotInstances.erase(num)
		if minTime == 0:
			return sum
	return sum
	pass


func sort_dotval(a, b) -> bool:
	if a.y > b.y:
		return true
	return false
	pass


func _on_Simulation_pressed() -> void:
	toSim = simulations
	calc.setSimVar(simulationDuration)
	calc.setAttackVar(attacktime, crit.chance, crit.mult, Ruthless.active, Ruthless.mult)
	calc.setAttackVar2(multistrike.repeates, multistrike.mult1, multistrike.mult2, multistrike.mult3)
	calc.setDotVar(dotChance, DotBase.min, DotBase.max, maxStacks, duration)
	$HBoxContainer/Inputs/RunSimulation.disabled = true
	$HBoxContainer/Inputs/RunSimulation.text = "Simulating"
	var numstacks = duration / attacktime / maxStacks
	PoBEstimate = dotChance * (100 - crit.chance + crit.chance * crit.mult)  / (100 * 100)
	PoBEstimate = PoBEstimate * min(maxStacks, duration / attacktime)
	BetterPoBEstimate = PoBEstimate * (DotBase.min + (DotBase.max - DotBase.min) / pow(2, 1 / (numstacks + 1)))
	PoBEstimate = PoBEstimate * (DotBase.min + DotBase.max) / 2
	if Ruthless.active:
		 BetterPoBEstimate = BetterPoBEstimate * (1 + (Ruthless.mult - 1) / pow(3, 1 / (2 * (numstacks + 1))))
		 PoBEstimate = PoBEstimate * (1 + (Ruthless.mult - 1) / 3)
	pass


func _on_ResetSimulation_pressed() -> void:
	simRan = 0
	totalDPS = 0
	dots.clear()
	if toGraph:
		graph.drawGraph(dots)
	pass


func _on_Simulation_changed(value : int) -> void:
	simulations = value
	pass


func _on_Simulation_Duration_changed(value : float) -> void:
	simulationDuration = value
	simulationSteps = int(2500000 * attacktime / simulationDuration)
	pass


func _on_AttackTime_changed(value : float) -> void:
	attacktime = value
	simulationSteps = int(2500000 * attacktime / simulationDuration)
	pass


func _on_SingleAttack_toggled(button_pressed : bool) -> void:
	singleAttack = button_pressed
	pass


func _on_DotChance_changed(value : int) -> void:
	dotChance = value
	pass


func _on_DotDuration_changed(value : float) -> void:
	duration = value
	pass


func _on_DotStacks_changed(value : int) -> void:
	maxStacks = value
	pass


func _on_DotBase_Min_changed(value : int) -> void:
	DotBase.min = value
	pass


func _on_DotBase_Max_changed(value : int) -> void:
	DotBase.max = value
	pass


func _on_Crit_Chance_changed(value : int) -> void:
	crit.chance = value
	pass


func _on_Crit_Mult_changed(value : float) -> void:
	crit.mult = value
	pass


func _on_Ruthless_toggled(button_pressed : bool) -> void:
	Ruthless.active = button_pressed
	pass


func _on_Ruthless_Mult_changed(value : float) -> void:
	Ruthless.mult = value
	pass


func _on_Multistrike_Repeates_changed(value : int) -> void:
	multistrike.repeates = value
	pass


func _on_Multistrike_Mult1_changed(value : float) -> void:
	multistrike.mult1 = value
	pass


func _on_Multistrike_Mult2_changed(value : float) -> void:
	multistrike.mult2 = value
	pass


func _on_Multistrike_Mult3_changed(value : float) -> void:
	multistrike.mult3 = value
	pass


# warning-ignore:unused_argument
func _on_MoreBleed_changed(value : int) -> void:
#	MoreDotChance = int(new_text)
	pass


func _on_Graph_toggled(button_pressed : bool) -> void:
	toGraph = button_pressed
	pass
