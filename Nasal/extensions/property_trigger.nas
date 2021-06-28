#
# Usage:
#
#	<object>
#		<name>...</name>
#		<type>property-trigger</type>
#		<activated>...</activated>
#		<condition>...</condition>
#		<actions>...</actions>
#	</object>
#

mission.extension_add("MissionObject", {

	type: "property-trigger",

	new: func(n) {
		var m = {
			parents     : [me],
			name        : n.getValue("name"),
			activated   : mission.get(n, "activated", 0),
			_condition  : n.getNode("condition"),
			_references : n.getNode("actions"),
		};

		m._timer = maketimer(0, func m._loop());

		return m;
	},

	init: func if (me.activated) me.start(),

	start: func {
		if ( (me._references == nil) or (me._condition == nil) )
			return;
		me._timer.start();
	},

	_loop: func {
		if ( props.condition(me._condition) ) {
			mission.activate_object_group(me._references);
			me.stop();
		}
	},

	stop: func me._timer.stop(),

	del: func me.stop(),

});
