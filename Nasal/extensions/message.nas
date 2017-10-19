
#var play_sound = func(file) {
#	var sound = {
#		path : mission.mission_root ~ "/Sounds",
#		file : file,
#		volume : 1
#	};
#	fgcommand("play-audio-sample", props.Node.new(sound));
#}

var show_message = func (m, delay, speak = nil, snd = nil) {
	setprop("/sim/mission/message/current-message", m);
	setprop("/sim/mission/message/message-delay", delay);
	setprop("/sim/mission/message/show-message", 1);

    if (speak != nil) {
        mission.speak(m);
    }

	if (snd != nil) {
		mission.play_sound(snd);
    }
}

mission.extension_add("MissionObject", {
	type: "dialog-action",

	new: func(n) {
		var m = {
			parents     : [me],
			node        : n,
			name        : n.getValue("name"),
			_message    : n.getValue("text"),
            _speak      : n.getValue("speak"),
			_sound_file : n.getValue("sound-file"),
			_delay      : (n.getValue("delay-sec") or 5),
		};

		return m;
	},

	start: func show_message(me._message, me._delay, me._speak, me._sound_file),

	stop: func,

	del: func,
});