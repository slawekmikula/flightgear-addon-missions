
var gear = props.getNode("gear", 1).getChildren("gear");

var wow = func {
	var on_ground = 0;
	foreach (var g; gear)
		if (g.getValue("wow")) {
			on_ground = 1;
			break;
		}
	return on_ground;
}

var ground_speed = func getprop("/velocities/groundspeed-kt");

var full_stop = func math.abs(ground_speed()) <= 1;


mission.addExtension("MissionObject", {
	type: "area-landing-trigger",

	new: func(n) {
		var m = {
			parents           : [me],
			node              : n,
			name              : n.getValue("name"),
			landing_type      : n.getValue("landing-type"),
			_areas            : [],
			_activated        : (n.getValue("activated") or 0),
			_actions          : n.getNode("actions"),
		};

		m.timer = maketimer(0, func m._loop());

		if (m.landing_type == "full stop") #?
			m._landing_type = 0;           #?
		elsif (m.landing_type == "touchdown")
			m._landing_type = 1;


		return m;
	},

	init: func {
		if ( (var areas_node = me.node.getNode("areas")) != nil )
			foreach(var ref; areas_node.getChildren("object-reference"))
				foreach(var obj; mission.mission_objects)
					if (ref.getValue() == obj.name)
						append(me._areas, obj);

		if (me._activated)
			me.start();
	},

	activate_areas: func(activate = 1) {
		foreach(var a; me._areas)
			if (activate)
				a.start();
			else
				a.stop();
	},

	start: func {
		me.activate_areas();
		me.timer.start();
	},

	stop: func {
		me.timer.stop();
		me.activate_areas(0);
	},

	_loop: func {
		var enter = 0;
		#var exit = 0;

		foreach(var a; me._areas) {
			if (a._in_the_box)
				enter = 1;
		}

		if (me._actions == nil) return;
		#if (exit) return;
		if (!enter) return;
		if (!wow()) return;
		if (me._landing_type == 0 and !full_stop()) return;

		mission.activate_object_group(me._actions);

		me.stop();
	},

	del: func me.stop(),
});