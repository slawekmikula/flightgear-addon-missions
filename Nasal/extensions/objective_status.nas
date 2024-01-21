
var objective_status = func (name, status)
{
	foreach(var obj; mission.mission_objects) {
		if (obj.type != "objective") continue;
		if (obj.name == name) obj.status(status);
	}
}


var objective_group_status = func (group, status)
{
	if (group == nil) return;
	foreach(var ref; group.getChildren("object-reference"))
		objective_status(ref.getValue(), status);
}


mission.extension_add("MissionObject", {
	type: "objective-status-action",

	new: func (n)
    {
		return {
			parents     : [me],
			name        : n.getValue("name"),
			_status     : mission.get(n, "objective-status", "completed"),
			_objectives : n.getNode("objectives"),
		};
	},

	start: func ()
    {
        objective_group_status(me._objectives, me._status);
        if (me._status == "completed") {
            setprop( "/sim/mission/objectives/objective-status-message",
                     "Objective Completed");
        }
    },

	stop: func,

	del: func,
});