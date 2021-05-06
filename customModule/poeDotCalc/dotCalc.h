#ifndef DOTCALC_H
#define DOTCALC_H

#include "core/reference.h"

class DotCalc : public Reference {
	GDCLASS(DotCalc, Reference);

protected:
	static void _bind_methods();
	//float calcMaxX(std::vector<Vector2> &dotInstances, int X, float timeElapsed);
	
	//simulation variables
	float simulationDuration;

	//attack variables
	float attacktime;
	int critchance;
	float critmult;
	bool Ruthless;
	float Ruthlessmult;
	int multistrikerepeates;
	float multistrikemult1;
	float multistrikemult2;
	float multistrikemult3;

	// dot variables
	int dotChance;
	int DotBasemin;
	int DotBasemax;

	int maxStacks;
	float dotDuration;

	int MoreDotChance; //no longer valid 3.14+

public:
	int calcDotInstance(int attacknum);
	int calcDotSimulation();
	void setSimVar(float duration);
	void setAttackVar(float time, int critChance, int critMult, bool Ruth, float RuthMult);
	void setAttackVar2(int Multi, float Multi1, float Multi2, float Multi3);
	void setDotVar(int chance, int min, int max, int stacks, float duration);

	DotCalc();
};

#endif
