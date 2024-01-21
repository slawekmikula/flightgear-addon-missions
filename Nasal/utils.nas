var repair_str = func(s) {
	var r = "";
    var r2 = "";
	var skip = 0;
	s ~= "";
	for (var i = 0; i < size(s); i += 1) {
		var c = s[i];
		if (c == `\t`)
			r ~= ' ';
		elsif (c == `\n`)
			r ~= ' ';
        else
            r ~= chr(c);
	}
    for (var i = 0; i < size(r); i += 1) {
        var c = r[i];
        if (string.isspace(c))
            if (skip)
                r ~= '';
            else
                {r2 ~= ' '; skip = 1}
        else
            {r2 ~= chr(c); skip = 0}
    }
	return string.trim(r2);
}




var sound_library = {
    _playing: 0,

    "click": ["click.wav", 0.2, 0.0],
    "click2": ["appear-online.wav", 1.0, 0.3],
    "click4": ["click4.wav", 0.25, 0.18],
    "message1": ["ui/message1.wav", 1.0, 0.8],
};

var ui_sound = func (snd)
{
    !sound_library._playing or return;
    sound_library._playing = 1;
    mission.play_sound( sound_library[snd][0],
                        sound_library[snd][1]);
    settimer(func sound_library._playing = 0, sound_library[snd][2]);
}


var splash_screen = func {
	var s = getprop("sim/startup/splash-alpha");
	if (s == nil) s = 1;
	return s > 0 ? 1 : 0;
}
