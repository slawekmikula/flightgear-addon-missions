var get = mission.get;

mission.addExtension("MissionObject", {
	type: "object-activation-action",

	new: func(n) {
		var m = {
			parents     : [me],
			name        : n.getValue("name"),
			_references : n.getNode("reference-list"),
			_state      : get(n, "object-state", 1),
		};

		return m;
	},

	start: func {
		if ( me._references == nil )
			return;
		mission.activate_object_group(me._references, me._state);
	},

	stop: func,

	del: func,
});