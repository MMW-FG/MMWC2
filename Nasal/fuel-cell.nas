##########################################################
#######Electrical system for Xray#########
#basic setup
setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_fuelcell,5);
    print("Fuel Cell and Engine System ... ok");
});

#start fuel cell if battery switch and fuel cell switch are on.
setlistener("/controls/electric/fuel-cell", func {
if(getprop("/controls/electric/battery-switch") == 1){
setprop("systems/electrical/fuel-cell", 1);
}
    });


#engine master switch toggles starter till engine starts IF fuel cell is on
setlistener("/controls/engines/engine[0]/master-switch", func {
if(getprop("systems/electrical/fuel-cell") == 1){
setprop("/controls/engines/engine[0]/starter", 1);
}
    });


update_fuelcell = func {
if(getprop("/controls/electric/fuel-cell") == 0){
setprop("systems/electrical/fuel-cell", 0);
 }
if(getprop("systems/electrical/fuel-cell") == 0){
setprop("/controls/engines/engine[0]/starter", 0);
setprop("/controls/engines/engine[0]/magnetos", 0);
setprop("/controls/engines/engine[0]/master-switch", 0);
 }
if(getprop("/controls/engines/engine[0]/master-switch") == 0){
setprop("/controls/engines/engine[0]/starter", 0);
 }
settimer(update_fuelcell, 0);
}
