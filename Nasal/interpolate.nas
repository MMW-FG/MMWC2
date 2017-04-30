###############################################################################
##
##  Nasal for DR400
##
##  Clément de l'Hamaide - http://www.clemaez.fr/
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

setlistener("/controls/electric/battery-switch", func(v) {
  if(v.getValue()){
    interpolate("/controls/electric/battery-switch-pos", 1, 0.25);
  }else{
    interpolate("/controls/electric/battery-switch-pos", 0, 0.25);
  }
});

setlistener("/controls/engines/engine/master-alt", func(v) {
  if(v.getValue()){
    interpolate("/controls/engines/engine/master-alt-pos", 1, 0.25);
  }else{
    interpolate("/controls/engines/engine/master-alt-pos", 0, 0.25);
  }
});

setlistener("/controls/engines/engine/starter_cmd", func(v) {
  if(v.getValue()){
    interpolate("/controls/engines/engine/starter_cmd-pos", 1, 0.25);
  }else{
    interpolate("/controls/engines/engine/starter_cmd-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/landing-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/landing-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/landing-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/tail-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/tail-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/tail-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/taxi-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/taxi-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/taxi-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/strobe-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/strobe-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/strobe-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/nav-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/nav-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/nav-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/gear/brake-parking", func(v) {
  if(v.getValue()){
    interpolate("/controls/gear/brake-parking-pos", 1, 0.25);
  }else{
    interpolate("/controls/gear/brake-parking-pos", 0, 0.25);
  }
});

setlistener("/controls/fuel/tank/to_engine", func(v) {
  if(v.getValue()){
    interpolate("/controls/fuel/tank/to_engine-pos", 1, 0.25);
  }else{
    interpolate("/controls/fuel/tank/to_engine-pos", 0, 0.25);
  }
});

setlistener("/controls/anti-ice/engine[0]/carb-heat", func(v) {
  if(v.getValue()){
    interpolate("/controls/anti-ice/engine[0]/carb-heat-pos", 1, 0.25);
  }else{
    interpolate("/controls/anti-ice/engine[0]/carb-heat-pos", 0, 0.25);
  }
});

setlistener("/controls/fuel/tank/boost-pump", func(v) {
  if(v.getValue()){
    interpolate("/controls/fuel/tank/boost-pump-pos", 1, 0.25);
  }else{
    interpolate("/controls/fuel/tank/boost-pump-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/warning-mode", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/warning-mode-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/warning-mode-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/warning-test", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/warning-test-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/warning-test-pos", 0, 0.25);
  }
});

setlistener("/controls/engines/engine/magnetos", func(v) {
    interpolate("/controls/engines/engine/magnetos-pos", v.getValue(), 0.25);
});
