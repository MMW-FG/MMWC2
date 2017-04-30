##########################################################
####### Single Starter/Generator electrical system #######
####################    Syd Adams    #####################
###### Based on Curtis Olson's nasal electrical code #####
##########################################################
#Only start fuel cell if battery switch is on at that time
setlistener("/controls/electric/fuel-cell", func {
if("/controls/electric/battery-switch", 1){
setprop("systems/electrical/fuel-cell", 1);
}
    }
(update_electrical,5);
    print("Electrical System ... ok");
});


update_bus1 = func(pwr){
    setprop("systems/electrical/outputs/lights/landing-lights[0]",pwr * getprop("controls/lighting/landing-lights"));
    setprop("systems/electrical/outputs/lights/taxi-lights",pwr * getprop("controls/lighting/taxi-lights"));
    setprop("systems/electrical/outputs/lights/nav-lights",pwr * getprop("controls/lighting/nav-lights"));
    setprop("systems/electrical/outputs/lights/instrument-lights",pwr * getprop("controls/lighting/instruments-norm"));
}

update_bus2 = func(pwr){
if(getprop("controls/electric/battery-switch") or getprop("systems/electrical/fuel-cell")){
    setprop("systems/electrical/outputs/comm",24);
    setprop("systems/electrical/outputs/comm[1]",24);
}
}



update_electrical = func {
    var pwr=24;
setprop("/power", pwr);
    var power=0;
    var load1=0.0;
    var load2=0.0;
    var volts=0;
    var AC=0;
    var invrtr=getprop("controls/electric/inverter-switch") or 0;
    if(getprop("controls/electric/battery-switch") or getprop("systems/electrical/fuel-cell")){power=1;volts=24;}
    setprop("systems/electrical/volts",volts);
    AC = 115 * (invrtr*power);
    setprop("systems/electrical/AC",AC);
    if(count==0)update_bus1(power);
    if(count==1)update_bus2(volts);
    count +=1;
    if(count>1)count=0;
settimer(update_electrical, 0);
}
