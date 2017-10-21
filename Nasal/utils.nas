
var splash_screen = func {
	var s = getprop("sim/startup/splash-alpha");
	if (s == nil) s = 1;
	return s > 0 ? 1 : 0;
}
