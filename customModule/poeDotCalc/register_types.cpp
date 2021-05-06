#include "register_types.h"
#include "core/class_db.h"
#include "dotCalc.h"

void register_poeDotCalc_types(){
  ClassDB::register_class<DotCalc>();
}

void unregister_poeDotCalc_types(/* arguments */) {
  /* nothing to do here */
}
