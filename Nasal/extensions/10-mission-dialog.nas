print("#######################################################");

var x_size = getprop("/sim/startup/xsize");
var y_size = getprop("/sim/startup/ysize");
var path = getprop("/sim/mission/root_path");

#var N = props.getNode("/sim/mission/objectives", 1);

__mission.mission_dialog = __mission.canvas.layeredDialog.new(0.4, 3/4);
#__mission.mission_dialog_loaded = 1;



mission.show_objectives = func {
    mission_dialog.show();
}


mission.extension_add("Handler", {
	init: func {
		me.listeners = [
#			setlistener(me.node.getNode("objective-state-changed", 1), func me.update()),
		];
	},

	node: props.getNode("/sim/mission/objectives", 1),

	update: func {
		if (state_changed) return;
		state_changed = 1;
		settimer(func me.update_mission_dialog(), 0);
	},

	update_mission_dialog: func {

	},

	stop: func {
		foreach(var l; me.listeners)
			removelistener(l);
		setsize(me.listeners, 0);
		me.node.remove();
        __mission.mission_dialog.del();
	},
});
