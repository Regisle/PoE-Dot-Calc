#include "dotCalc.h"
#include <vector>
#include <algorithm>

int rand_range(int start, int end){
	return (rand() % (end + 1 - start)) + start;
	
}

//helper function
int BinarySearch_Vector2Y_Left(std::vector<Vector2> arr, int value) {
    int low = 0;
    int high = arr.size() - 1;
    while (low <= high) {
        // invariants: value > A[i] for all i < low value <= A[i] for all i > high
        int mid = (low + high) / 2;
        if (arr[mid].y <= value)
            high = mid - 1;
        else
            low = mid + 1;
    }
    return low;
}


int DotCalc::calcDotInstance(int attacknum){
	if (rand_range(0, 100) > dotChance){
		return 0;
	}
	int DotRoll = rand_range(DotBasemin, DotBasemax + 1);
//	if rand_range(0, 100) <= MoreDotChance:
//		DotRoll = DotRoll * 2
	if (rand_range(0, 100) <= critchance){
		DotRoll = (DotRoll * int(critmult * 100)) / 100;
	}
	if (multistrikerepeates > 1){
		switch (attacknum % (multistrikerepeates + 1)){
			case 1:
				DotRoll = (DotRoll * int(multistrikemult1 * 100)) / 100;
				break;
			case 2:
				DotRoll = (DotRoll * int(multistrikemult2 * 100)) / 100;
				break;
			case 3:
				DotRoll = (DotRoll * int(multistrikemult3 * 100)) / 100;
				break;
		}
		if (Ruthless & (attacknum / (multistrikerepeates + 1) % 3 == 0)){
			DotRoll = (DotRoll * int(Ruthlessmult * 100)) / 100;
		}
	}
	else if (Ruthless & (attacknum % 3 == 0)){
		DotRoll = (DotRoll * int(Ruthlessmult * 100)) / 100;
	}

	return DotRoll;
}

//helper function
float calcMaxX(std::vector<Vector2> &dotInstances, int X, float timeElapsed, float attacktime){
	float sum = 0;
	float extraTime = 0;
	if (dotInstances.size() < 0){
		return 0.0;
	}
	for (unsigned int i = 0; i < dotInstances.size(); i++){
        if (dotInstances[i].x <= timeElapsed){
            dotInstances.erase(dotInstances.begin() + i);
            break;
        }
	}
	if (dotInstances.size() < 0){
		return 0.0;
	}
	while (extraTime + 0.0001 <= attacktime){
		float minTime = attacktime - extraTime;
		int count = 0;
		float dotVal = 0;
		for (unsigned int i = 0; i < dotInstances.size(); i++) {
			count += 1;
			if (count > X){
				break;
			}
			dotVal += dotInstances[i].y;
			minTime = std::min(minTime, dotInstances[i].x - (timeElapsed + extraTime));
		}
		extraTime += minTime;
		sum += minTime * dotVal;
        //clear expired dotInstances
        for (unsigned int i = 0; i < dotInstances.size(); i++){
            if (dotInstances[i].x <= (timeElapsed + extraTime)){
                dotInstances.erase(dotInstances.begin() + i);
                break;
            }
        }
		if (minTime <= 0){
            //std::cout << "Maxx Timer error" << std::endl;
			return sum;
		}
	}
	return sum;
}


int DotCalc::calcDotSimulation(){
	float timeElapsed = -attacktime;
	std::vector<Vector2> DotInstances = {};
	Vector2 instance;
	instance.x = timeElapsed + dotDuration;
	instance.y = float(calcDotInstance(0));
	DotInstances.push_back(instance);
	float totalDotDamage = 0;
	int attacknum = 0;
	while (timeElapsed < simulationDuration){
		totalDotDamage += calcMaxX(DotInstances, maxStacks, timeElapsed, attacktime);
		timeElapsed += attacktime;
		attacknum += 1;
		instance.x = timeElapsed + dotDuration;
		instance.y = float(calcDotInstance(attacknum));
		int pos = BinarySearch_Vector2Y_Left(DotInstances, instance.y);
        //std::cout << instance.y << " " << pos << std::endl;
		DotInstances.insert(DotInstances.begin() + pos,instance);
	}
	return int(totalDotDamage / timeElapsed);
}


void DotCalc::setSimVar(float duration) {
  simulationDuration = duration;
  //return 0;
}


void DotCalc::setAttackVar(float time, int critChance, int critMult, bool Ruth, float RuthMult) {
  attacktime = time;
  critchance = critChance;
  critmult = critMult;
  Ruthless = Ruth;
  Ruthlessmult = RuthMult;
  //return 0;
}


void DotCalc::setAttackVar2(int Multi, float Multi1, float Multi2, float Multi3) {
  multistrikerepeates = Multi;
  multistrikemult1 = Multi1;
  multistrikemult2 = Multi2;
  multistrikemult3 = Multi3;
  //return 0;
}


void DotCalc::setDotVar(int chance, int min, int max, int stacks, float duration) {
  dotChance = chance;
  DotBasemin = min;
  DotBasemax = max;
  maxStacks = stacks;
  dotDuration = duration;
  //return 0;
}


void DotCalc::_bind_methods(){
  ClassDB::bind_method(D_METHOD("calcDotInstance", "attacknum"), &DotCalc::calcDotInstance);
  ClassDB::bind_method(D_METHOD("calcDotSimulation"), &DotCalc::calcDotSimulation);
  ClassDB::bind_method(D_METHOD("setSimVar", "duration"), &DotCalc::setSimVar);
  ClassDB::bind_method(D_METHOD("setAttackVar", "time", "critChance", "critMult", "Ruth", "RuthMult"), &DotCalc::setAttackVar);
  ClassDB::bind_method(D_METHOD("setAttackVar2", "Multi", "Multi1", "Multi2", "Multi3"), &DotCalc::setAttackVar2);
  ClassDB::bind_method(D_METHOD("setDotVar", "chance", "min", "max", "stacks", "duration"), &DotCalc::setDotVar);
}


DotCalc::DotCalc(){}
