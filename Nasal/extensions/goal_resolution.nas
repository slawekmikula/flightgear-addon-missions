
var goal_status = func(name, status) {
	foreach(var obj; mission.mission_objects) {
		if (obj.type != "goal") continue;
		if (obj.name == name) obj.status(status);
	}
}

var goal_group_status = func (group, status) {
	if (group == nil) return;
	foreach(var ref; group.getChildren("object-reference"))
		goal_status(ref.getValue(), status);
}

mission.addExtension("MissionObject", {
	type: "goal-resolution-action",

	new: func(n) {
		return {
			parents     : [me],
			name        : n.getValue("name"),
			_status     : mission.get(n, "goal-resolution", "completed"),
			_goals      : n.getNode("goals"),
		};
	},

	start: func goal_group_status(me._goals, me._status),

	stop: func,

	del: func,
});