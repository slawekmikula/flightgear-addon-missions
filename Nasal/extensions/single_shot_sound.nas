
mission.extension_add("MissionObject", {
	type: "single-shot-sound-action",

	new: func(n) {
		var m = {
			parents     : [me],
			node        : n,
			name        : n.getValue("name"),
			_sound_path : mission.mission_root ~ "/Sounds",
			_sound_file : n.getValue("sound-file"),
		};

		return m;
	},

	start: func mission.play_sound(me._sound_file),

	stop: func,

	del: func,
});