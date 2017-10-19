#
# Usage:
#
#	<object>
#		<name>...</name>
#		<type>refuel-action</type>
#		<tank-id>...</tank-id>
#		<fuel-fraction>...</fuel-fraction>
#	</object>
#


var refuel_action = {
	type: "refuel-action",

	new: func(n) {
		var m = {
			parents     : [refuel_action],
			name        : n.getValue("name"),
			_id         : int(n.getValue("tank-id")),
			_fraction   : n.getValue("fuel-fraction"),
		};
		return m;
	},

	start: func {
		if (me._id == nil)
			return;
		var tank = props.getNode("consumables/fuel").getChild("tank", me._id, 0);
		if (tank == nil)
			return;
		tank.setValue("level-norm", me._fraction);
	},

	stop: func,

	del: func,
};

mission.extension_add("MissionObject", refuel_action);