
mission.extension_add("MissionObject", {
	type: "count-action",

	new: func(n) {
		var m = {
			parents        : [me],
			name           : n.getValue("name"),
			node           : n,
            count          : n.getValue("count"),
			_triggers      : [],
		};


		return m;
	},

	init: func {
		if ( (var triggers_node = me.node.getNode("triggers")) != nil )
			foreach(var ref; triggers_node.getChildren("object-reference"))
				foreach(var obj; mission.mission_objects)
					if (ref.getValue() == obj.name)
                        if (obj.type == "counter-trigger")
						    append(me._triggers, obj);

	},

	start: func {
        foreach (var t; me._triggers)
            t.count(me.count);
	},

	stop: func,

	del: func,

});
