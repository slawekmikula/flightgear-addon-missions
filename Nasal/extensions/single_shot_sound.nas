
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

#	_play_sound: func {
#		var sound = {
#			path : me._sound_path,
#			file : me._sound_file, #file,
#			volume : 1
#		};
#		fgcommand("play-audio-sample", props.Node.new(sound));
#	},

	start: func mission.play_sound(me._sound_file),

	stop: func,

	del: func,
});