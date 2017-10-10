
#var play_sound = func(file) {
#	var sound = {
#		path : mission.mission_root ~ "/Sounds",
#		file : file,
#		volume : 1
#	};
#	fgcommand("play-audio-sample", props.Node.new(sound));
#}

var show_message = func (m, delay, snd = nil) {
	setprop("/sim/mission/message/current-message", m);
	setprop("/sim/mission/message/message-delay", delay);
	setprop("/sim/mission/message/show-message", 1);

	if (snd != nil)
		mission.play_sound(snd);
}

mission.addExtension("MissionObject", {
	type: "dialog-action",

	new: func(n) {
		var m = {
			parents     : [me],
			node        : n,
			name        : n.getValue("name"),
			_message    : n.getValue("text"),
			_sound_file : n.getValue("sound-file"),
			_delay      : (n.getValue("delay-sec") or 5),
		};

		return m;
	},

	start: func show_message(me._message, me._delay, me._sound_file),

	stop: func,

	del: func,
});