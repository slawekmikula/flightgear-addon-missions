
mission.extension_add("MissionObject", {
	type: "reset-timer-action",

	new: func(n) {
		var m = {
			parents        : [me],
			name           : n.getValue("name"),
			node           : n,
			_triggers      : [],
		};


		return m;
	},

	init: func {
		if ( (var triggers_node = me.node.getNode("triggers")) != nil )
			foreach(var ref; triggers_node.getChildren("object-reference"))
				foreach(var obj; mission.mission_objects)
					if (ref.getValue() == obj.name)
                        if (obj.type == "timer-trigger")
						    append(me._triggers, obj);

	},

	start: func {
        foreach (var t; me._triggers)
            t.restart();
	},

	stop: func, 

	del: func,

});

