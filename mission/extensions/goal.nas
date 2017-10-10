
mission.addExtension("MissionObject", {
	type: "goal",

	new: func(n) {
		var m = {
			parents     : [me],
			name        : n.getValue("name"),
			_text       : mission.get(n, "text", "---"),
			_state      : mission.get(n, "goal-state", "pending"),
			_order      : mission.get(n, "order", 0),
			_activated  : mission.get(n, "activated", 0),
			_error      : 0,
		};

		return m;
	},


	init: func {
		var N = props.getNode("/sim/mission/goals", 1);
		me.node = N.getChild("goal", me._order, 0);

		if (me.node != nil) {
			me._error = 1;
			return;
		}

		me.node = N.getChild("goal", me._order, 1);

		me.node.setValues({
			"text"       : me._text,
			"goal-state" : me._state,
		});
	},


	status: func(status) {
		if (me._error) return;
		me.node.setValue("goal-state", status);
		setprop("/sim/mission/goals/goal-state-changed", 1);
	},


	stop: func,


	del: func,

});