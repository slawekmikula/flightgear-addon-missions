
mission.addExtension("MissionObject", {
	type: "proximity-trigger",

	new: func(n) {
		var m = {
			parents           : [me],
			node              : n,
			name              : n.getValue("name"),
			_areas            : [],
			_activated        : (n.getValue("activated") or 0),
			_on_enter_actions : n.getNode("on-enter-actions"),
			_on_exit_actions  : n.getNode("on-exit-actions"),
		};

		m.timer = maketimer(0, func m._loop());

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
		var exit = 0;

		foreach(var a; me._areas) {
			if (a.entering())
				enter = 1;
			if (a.exiting())
				exit = 1;
		}

		if (me._on_enter_actions != nil)
			if (enter)
				mission.activate_object_group(me._on_enter_actions);

		if (me._on_exit_actions != nil)
			if (exit)
				mission.activate_object_group(me._on_exit_actions);
	},

	del: func me.stop(),
});