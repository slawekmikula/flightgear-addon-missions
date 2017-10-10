#
# Usage:
#
#	<object>
#		<name>...</name>
#		<type>random-action</type>
#		<probability-percent>...</probability-percent>
#		<actions>
#			<object-reference>...</object-reference>
#			...
#		</actions>
#	</object>
#


var rnd = func {
	srand(); #?
	rand();
}

var random_node = func (v) {
	var s = 1 / size(v);
	var r = rnd();
	forindex (var i; v)
		if ( ((i + 1) * s) >= r)
			return(v[i]);
	return nil; #?
}


var random_action = {
	type: "random-action",

	new: func(n) {
		var m = {
			parents       : [random_action],
			name          : n.getValue("name"),
			_probability  : mission.get(n, "probability-percent", 100) / 100,
			_actions      : n.getNode("actions", 1).getChildren("object-reference"),
		};
		return m;
	},

	start: func {
		size(me._actions) or return;
		if (rnd() > me._probability)
			return;
		mission.activate_object(random_node(me._actions).getValue());
	},

	stop: func,

	del: func,
};

mission.addExtension("MissionObject", random_action);