
mission.extension_add("MissionObject", {
	type: "run-binding-action",

	new: func(n)
    {
		return {
			parents        : [me],
			name           : n.getValue("name"),
			_bindings      : n.getChildren("binding"),
		};
	},


    init: func,


	start: func
    {
        foreach (var b; me._bindings)
            props.runBinding(b);
	},


	stop: func,


	del: func,

});
