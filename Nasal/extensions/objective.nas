
mission.extension_add("MissionObject", {
	type: "objective",

	new: func(n) {
		var m = {
			parents     : [me],
			name        : n.getValue("name"),
			text        : mission.repair_str(mission.get(n, "text", "---")),
            briefing    : mission.repair_str(mission.get(n, "briefing", "")),
            optional    : mission.get(n, "optional", 0),
            _status     : mission.get(n, "status", "pending"),
			_activated  : mission.get(n, "activated", 0),

		};

        if (m.briefing == "")
            m.briefing = m.text;

        var s = m.optional ? " (Optional)" : "";

        m.text ~= s; m.briefing ~= s;

		return m;
	},


	init: func {
		var N = props.getNode("/sim/mission/objectives", 1);
		me.node = N.addChild("objective");

		me.node.setValues({
			"text"            : me.text,
            "briefing"        : me.briefing,
			"status"          : me._status,
            "optional"        : me.optional,
            "name"            : me.name,
		});
	},


	status: func(status) {
		me.node.setValue("status", status);
		setprop("/sim/mission/objectives/objective-status-changed", 1);
	},


	stop: func,


	del: func,

});