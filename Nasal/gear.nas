setlistener("/sim/signals/fdm-initialized", func {
    setprop("/controls/gear/blockF",1);
    setprop("/controls/gear/blockL",1);
    setprop("/controls/gear/blockR",1);
setprop("/controls/engines/engine/master-alt",0);
});
