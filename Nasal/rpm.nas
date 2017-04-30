# ***********************************************
# **** Forcer les rpm à 0 si moteur arrêté   ****
# **** BARANGER Emmanuel                2012 ****
# ****                                       ****
# ***********************************************
var running = props.globals.getNode("/engines/engine[0]/running",1);
var starter = props.globals.getNode("/controls/engines/engine[0]/starter",1);
var enginerpm = props.globals.getNode("/engines/engine[0]/rpm");

var update_rpm = func 
{
  if (!(running.getBoolValue()) and !(starter.getBoolValue())) {
    enginerpm.setValue(0);
  }
}

var main_loop = func {
  update_rpm();
  settimer(main_loop, 0);
}

setlistener("/sim/signals/fdm-initialized", func {
  main_loop();
});

