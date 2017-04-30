###############################################################################
##
##  Nasal for DR400
##
##  Clément de l'Hamaide - PAF Team
##  This file is licensed under the GPL license version 2 or later.
##
## Updated for GIT : Helijah April 2013
##
###############################################################################

# Do terrain modelling ourselves.
setprop("sim/fdm/surface/override-level", 1);


#####################################
# Dialogs (please comment the version)
#####################################

var checklists_dialog = gui.Dialog.new("/sim/gui/dialogs/dr400/checklists/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/checklist/checklists.xml");
var config_dlg = gui.Dialog.new("/sim/gui/dialogs/config/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/config.xml");
fgcommand("loadxml", props.Node.new({filename: getprop("/sim/aircraft-dir")~"/Dialogs/checklist/checklists-text.xml", targetnode: "/sim/gui/dialogs/dr400/checklists-list"}));

#####################################
#Fuel pressure
#####################################

var Fuel_press=func {
  var fuel_level = getprop("consumables/fuel/tank/level-lbs");
  var engine_run = getprop("/engines/engine/running");
  var tank_selector = getprop("controls/fuel/tank/to_engine");
  var pump_on = (getprop("/systems/electrical/outputs/fuel-pump") > 20) ? 1 : 0;

  if (fuel_level > 0.1) {
    if (tank_selector==1){
      if (pump_on==1){
          interpolate("/engines/engine/fuel-pressure-psi", 4, 1); #300 mbar
      }else{
        if(engine_run==1){
          interpolate("/engines/engine/fuel-pressure-psi", 4, 1); #300 mbar
        }else{
          interpolate("/engines/engine/fuel-pressure-psi", 0, 1);
        }
      }
    }else{
      interpolate("/engines/engine/fuel-pressure-psi", 0, 1);
    }
  }else{
    interpolate("/engines/engine/fuel-pressure-psi", 0, 1);
  }

  #if(getprop("/engines/engine/fuel-pressure-psi") < 0.5){
  #  setprop("fdm/jsbsim/propulsion/tank/priority", 0);
  #}else{
  #  setprop("fdm/jsbsim/propulsion/tank/priority", 1);
  #}
#  settimer(Fuel_press,0);
}

##############################################
############### ENGINE SYSTEM ################
##############################################

#Engine sensors class 
# ie: var Eng = Engine.new(engine number);
var Engine = {
    new : func(eng_num){
        m =               { parents : [Engine]};
	m.air_temp =      props.globals.initNode("environment/temperature-degc");
	m.oat =           m.air_temp.getValue() or 0;
        m.eng =           props.globals.initNode("engines/engine["~eng_num~"]");
        m.running =       0;
        m.ot_target =     90;
	m.mp =            m.eng.initNode("mp-inhg");
        m.cutoff =        props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff");
        m.mixture =       props.globals.initNode("engines/engine["~eng_num~"]/mixture");
        m.mixture_lever = props.globals.initNode("controls/engines/engine["~eng_num~"]/mixture",1,"DOUBLE");
        m.rpm =           m.eng.initNode("rpm",1);
        m.oil_temp =      m.eng.initNode("oil-temp-c",m.oat,"DOUBLE");
        m.cyl_temp =      m.eng.initNode("cyl-temp",m.oat,"DOUBLE");
        m.carb_heat =     m.eng.initNode("carb-heat",0,"DOUBLE");
	m.carb_temp =     m.eng.initNode("carb-temp-degc",m.oat,"DOUBLE");
        m.oil_psi =       m.eng.initNode("oil-pressure-psi",0.0,"DOUBLE");
        m.fuel_psi =      m.eng.initNode("fuel-psi-norm",0,"DOUBLE");
        m.fuel_out =      m.eng.initNode("out-of-fuel",0,"BOOL");
        m.fuel_switch =   props.globals.initNode("controls/fuel/switch-position",-1,"INT");
        m.hpump =         props.globals.initNode("systems/hydraulics/pump-psi["~eng_num~"]",0,"DOUBLE");
	m.Lrunning =      setlistener("engines/engine["~eng_num~"]/running",func (rn){m.running=rn.getValue()},0,0);
	return m;
    },
#### update ####
    update : func(eng_num){
        var rpm =     me.rpm.getValue();
	var mp =      me.mp.getValue();
	var OT =      me.oil_temp.getValue();
        var mx =      me.mixture_lever.getValue();
	var ctemp =   me.air_temp.getValue();
        var cyltemp = me.cyl_temp.getValue();
        var cheat =   me.carb_heat.getValue();
	var cooling = (getprop("velocities/airspeed-kt") * 0.1) *2;
        ###################################
        ######### OIL TEMPERATURE #########
        ###################################
	cooling += (mx * 5);
	var tgt  = me.ot_target + mp;
	var tgt -= cooling;
	if(me.running){
		if(OT < tgt) OT += rpm * 0.00001;
		if(OT > tgt) OT -= cooling * 0.001;
		}else{
		if(OT > me.air_temp.getValue()) OT-=0.001; 
	}
        me.oil_temp.setValue(OT);
        ###################################
        ##### CARBURATOR TEMPERATURE ######
        ###################################
	var et0 = getprop("/environment/temperature-degc");
	# var cbt = et0 + 0.85 * mp; #carb temperature
        if(props.globals.getNode("systems/electrical/outputs/carb-heat").getValue() > 24){
          cheat += 0.01;
          if(cheat > 15) cheat = 15;
          setprop("engines/engine["~eng_num~"]/carb-heat", cheat);
          # cbt += cheat;
        }else{
          cheat -= 0.05;
          if(cheat < 0) cheat = 0;
          setprop("engines/engine["~eng_num~"]/carb-heat", cheat);
          # cbt += cheat;
        }
	ctemp = (rpm * 0.0029);
	me.carb_temp.setValue(et0 - ctemp + cheat);
    },
};

EngineMain = Engine.new(0);

##########################################
# Mixture/Throttle controlled by mouse
##########################################

var mousex =0;
var msx = 0;
var msxa = 0;
var mousey = 0;
var msy = 0;
var msya=0;

var mouse_accel=func{
  msx=getprop("devices/status/mice/mouse/x") or 0;
  mousex=msx-msxa;
  mousex*=0.5;
  msxa=msx;
  msy=getprop("devices/status/mice/mouse/y") or 0;
  mousey=msya-msy;
  mousey*=0.5;
  msya=msy;
#  settimer(mouse_accel, 0);
}

var set_levers = func(type,num,min,max){
  var ctrl=[];
  var cpld=-1;
  if(type == "throttle"){
    ctrl = ["controls/engines/engine[0]/throttle","controls/engines/engine[1]/throttle"];
    cpld = "controls/throttle-coupled";
  }elsif(type == "prop"){
    ctrl = ["controls/engines/engine[0]/propeller-pitch","controls/engines/engine[1]/propeller-pitch"];
    cpld = "controls/prop-coupled";
  }elsif(type == "mixture"){
    ctrl = ["controls/engines/engine[0]/mixture","controls/engines/engine[1]/mixture"];
    cpld ="controls/mixture-coupled";
  }

  var amnt =mousey* getprop("controls/movement-scale");
  var ttl = getprop(ctrl[num]) + amnt;
  if(ttl > max) ttl = max;
  if(ttl<min)ttl=min;
  setprop(ctrl[num],ttl);
  if(getprop(cpld))setprop(ctrl[1-num],ttl);
}

##########################################
# Ground Detection
##########################################

var terrain_survol = func {
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");

  var info = geodinfo(lat, lon);
  if (info != nil) {
    if (info[1] != nil){
      if (info[1].solid !=nil)
        setprop("/environment/terrain-type",info[1].solid);
      if (info[1].load_resistance !=nil)
        setprop("/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
        setprop("/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
        setprop("/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
        setprop("/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
        setprop("/environment/terrain-names",info[1].names[0]);
    }         
  }else{
    setprop("/environment/terrain",1);
    setprop("/environment/terrain-load-resistance",1e+30);
    setprop("/environment/terrain-friction-factor",1.05);
    setprop("/environment/terrain-bumpiness",0);
    setprop("/environment/terrain-rolling-friction",0.02);
  }

  if(!getprop("sim/freeze/replay-state") and !getprop("/environment/terrain-type") and getprop("/position/gear-agl-m") < 0.5){
    setprop("sim/messages/copilot", "You are on water !");
    setprop("sim/freeze/clock", 1);
    setprop("sim/freeze/master", 1);
    setprop("sim/crashed", 1);
  }
#  settimer(terrain_survol, 0);
}

##############################################
######### AUTOSTART / AUTOSHUTDOWN ###########
##############################################

setlistener("/sim/model/start-idling", func(idle){
    var run= idle.getBoolValue();
    if(run){
    Startup();
    }else{
    Shutdown();
    }
},0,0);

var Startup = func{
  setprop("controls/fuel/tank/to_engine", 1);
  setprop("controls/fuel/tank/boost-pump", 1);
  setprop("controls/engines/engine[0]/master-alt",1);
  setprop("/controls/engines/engine[0]/magnetos",3);
  setprop("controls/engines/engine[0]/mixture",1);
  setprop("/controls/gear/brake-parking",1);
  setprop("/controls/lighting/instruments-norm",1);
  setprop("/instrumentation/comm[0]/power-btn",1);
  setprop("/instrumentation/comm[0]/volume",1);
  setprop("/instrumentation/nav[0]/power-btn",1);  
  setprop("/instrumentation/nav[0]/volume",1);
  setprop("/instrumentation/adf[0]/power-btn",1);
  setprop("/instrumentation/adf[0]/volume",1);
  setprop("/instrumentation/adf[0]/volume-norm",1);
  setprop("controls/electric/battery-switch",1);
  setprop("sim/messages/copilot", "Now press \"s\" to start engine");
}

var Shutdown = func{
  setprop("controls/fuel/tank/to_engine", 0);
  setprop("controls/engines/engine[0]/master-alt",0);
  setprop("/controls/engines/engine[0]/magnetos",0);
  setprop("controls/engines/engine[0]/mixture",1);
  setprop("/engines/engine[0]/rpm",0);
  setprop("/engines/engine[0]/running",0);
  setprop("/controls/gear/brake-parking",1);
  setprop("/controls/lighting/instruments-norm",0);
  setprop("/instrumentation/comm[0]/power-btn",0);
  setprop("/instrumentation/comm[0]/volume",0);
  setprop("/instrumentation/nav[0]/power-btn",0);
  setprop("/instrumentation/nav[0]/volume",0);
  setprop("/instrumentation/adf[0]/power-btn",0);
  setprop("/instrumentation/adf[0]/volume",0);
  setprop("/instrumentation/adf[0]/volume-norm",0);
  setprop("controls/electric/battery-switch",0);
  setprop("controls/fuel/tank/boost-pump", 0);
  setprop("sim/messages/copilot", "Engine is stopped");
}


############################################
# ELT System from Cessna337
# Authors: Pavel Cueto, with A LOT of collaboration from Thorsten and AndersG
# Adaptation by Clément de l'Hamaide and Daniel Dubreuil for DR400 or regent
############################################

var eltmsg = func {
  var lat = getprop("/position/latitude-string");
  var lon = getprop("/position/longitude-string");
  var aircraft = getprop("/sim/description");
  var callsign = getprop("/sim/multiplay/callsign");

  if(getprop("/sim/damaged")){
     if(getprop("/instrumentation/elt/armed")) {
        var help_string = "" ~ aircraft ~ " " ~ callsign ~ "  DAMAGED, requesting SAR service";
        screen.log.write(help_string);
      }
    }
  ;
  
    if(getprop("/sim/crashed")){
      if(getprop("/instrumentation/elt/armed")) {
        var help_string = "ELT AutoMessage: " ~ aircraft ~ " " ~ callsign ~ " at " ~lat~" LAT "~lon~" LON, *** CRASHED ***";
        setprop("/sim/multiplay/chat", help_string);
        setprop("/sim/freeze/clock", 1);
        setprop("/sim/freeze/master", 1);
        screen.log.write("Press p to resume");
      }
    }
  ;

  settimer(eltmsg, 0);  
};

  setlistener("/instrumentation/elt/on", func(n) {
    if(n.getBoolValue()){
       var lat = getprop("/position/latitude-string");
       var lon = getprop("/position/longitude-string");
       var aircraft = getprop("/sim/description");
       var callsign = getprop("/sim/multiplay/callsign");
       var help_string = "ELT AutoMessage: " ~ aircraft ~ " " ~ callsign ~ " at " ~lat~" LAT "~lon~" LON, MAYDAY, MAYDAY, MAYDAY";
       setprop("/sim/multiplay/chat", help_string);
      }
    }
  );
  
 setlistener("/instrumentation/elt/test", func(n) {
    if(n.getBoolValue()){
       var lat = getprop("/position/latitude-string");
       var lon = getprop("/position/longitude-string");
       var aircraft = getprop("/sim/description");
       var callsign = getprop("/sim/multiplay/callsign");
       var help_string = "Testing ELT: " ~ aircraft ~ " " ~ callsign ~ " at " ~lat~" LAT "~lon~" LON";
       screen.log.write(help_string);
      }
    }
  );

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
global_system = func{

  if(getprop("/systems/electrical/outputs/starter") > 18){
    setprop("/controls/engines/engine[0]/starter",1);
  }else{
    setprop("/controls/engines/engine[0]/starter",0);
  }

  if(getprop("/systems/electrical/volts") > 6){
    setprop("/instrumentation/attitude-indicator/spin",10);
  }else{
    setprop("/instrumentation/attitude-indicator/spin",0);
  }

  Fuel_press();
  mouse_accel();
  terrain_survol();
  EngineMain.update(0);

  settimer(global_system, 0);

}

##########################################
# SetListerner must be at the end of this file
##########################################
setlistener("/sim/signals/fdm-initialized", func{
  setprop("/environment/terrain-type",1);
  setprop("/environment/terrain-load-resistance",1e+30);
  setprop("/environment/terrain-friction-factor",1.05);
  setprop("/environment/terrain-bumpiness",0);
  setprop("/environment/terrain-rolling-friction",0.02);
  setprop("/instrumentation/nav[0]/power-btn",0); #force OFF
  setprop("/instrumentation/adf[0]/power-btn",0);
  setprop("/instrumentation/adf[0]/volume",0);
  setprop("/instrumentation/adf[0]/volume-norm",0);
  setprop("/controls/lighting/nav-lights", 0);
  setprop("/controls/lighting/landing-lights", 0);
  setprop("/controls/electric/battery-switch", 0);
});

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{

  settimer(eltmsg, 2);
  print('Emergency Locator Transmitter (ELT) loaded');

  setlistener("controls/engines/engine[0]/throttle", func(throttle){
    interpolate("controls/engines/engine[0]/throttle-hand", 0.2, 0.5);
    setprop("controls/engines/engine[0]/throttle-hand", throttle.getValue()-0.06);
    settimer(func { interpolate("controls/engines/engine[0]/throttle-hand", 0, 0.4); }, 3);
  });

  settimer(global_system, 2);
  removelistener(nasalInit);
});
