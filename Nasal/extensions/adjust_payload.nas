#
# Usage:
#
#	<object>
#		<name>...</name>
#		<type>adjust-payload-action</type>
#		<station-id>...</station-id>
#		<adjustment-type>...</adjustment-type> "set" or "add"; default: "set"
#		<weight>...</weight>
#		<units>kg</units>                      "kg" or "lb"; default: "lb"
#	</object>
#


var adjust_payload_action = {
	type: "adjust-payload-action",

	new: func(n) {
		var m = {
			parents     : [adjust_payload_action],
			name        : n.getValue("name"),
			_id         : int(n.getValue("station-id")),
			_type       : mission.get(n, "adjustment-type", "set"),
			_weight     : mission.get(n, "weight"),
			_units      : mission.get(n, "units", "lb"),
		};

		if (m._units == "kg")
			m._weight *= 2.2;

		return m;
	},

	start: func {
		if (me._id == nil)
			return;
		var w = props.getNode("sim").getChild("weight", me._id, 0);
		if (w == nil)
			return;
		if (me._type == "add")
			w.setValue(mission.get(w, "weight-lb", 0.0) + me._weight);
		else
			w.setValue("weight-lb", me._weight);
	},

	stop: func,

	del: func,
};

mission.extension_add("MissionObject", adjust_payload_action);