var POI_changed      = 0;
var listeners        = [];
var node             = props.getNode("/sim/mission/point-of-interest", 1);
var current_POI      = node.getNode("current-POI", 1);
var active_POI       = [];
var timer            = maketimer(0, func loop());

__mission.POI = {
	coord   : geo.Coord.new(),
	count   : 0,
	name    : "",
	alt     : 0,
	dist    : 0,
	crs     : 0,
	hdg     : 0,
	current : nil,
};

var poi = func (k, v = nil) {
	if (v == nil)
		return __mission.POI[k];
	__mission.POI[k] = v;
}

var compass_visible = func getprop("/sim/mission/compass/visible") or 0;

var show_compass = func !compass_visible() ? setprop("/sim/mission/compass/show-compass", 1) : return;

var hide_compass = func compass_visible() ? setprop("/sim/mission/compass/hide-compass", 1) : return;

var update = func {
	if (POI_changed) return;
	POI_changed = 1;
	settimer(func check_POI(), 0);
}

var check_POI = func {
	poi("count", var count = 0);
	setsize(active_POI, 0);
	foreach (var p; node.getChildren("point-of-interest"))
		if (p.getValue("active")) {
			poi("count", count += 1);
			append(active_POI, p);
		}
	if (poi("count"))
		select_POI();
	POI_changed = 0;
	setprop("/sim/mission/point-of-interest/POI-count", poi("count"));
}

var next_POI = func select_POI(poi("current") + 1);

var prev_POI = func select_POI(poi("current") - 1);

var select_POI = func(i = nil) {
	var s = size(active_POI) - 1;
	if (i == nil) i = 0;
	if (i < 0) i = s;
	if (i > s) i = 0;
	var p = node.getChild("point-of-interest", var index = active_POI[i].getIndex());
	__mission.POI.coord.set_latlon (
		p.getValue("latitude-deg"),
		p.getValue("longitude-deg"),
		p.getValue("altitude-m"),
	);
	poi("name", p.getValue("name"));
	poi("alt", p.getValue("altitude-m"));
	poi("current", i);
	setprop("/sim/mission/point-of-interest/target-name", poi("name"));
	setprop("/sim/mission/point-of-interest/altitude-m", poi("alt"));
	foreach (var p; active_POI)
		p.setValue("selected", p.getIndex() == index ? 1 : 0);
}

var loop = func {
	poi("count") or return;
	var ac_coord  = geo.aircraft_position();
	var crs       = ac_coord.course_to(poi("coord"));
	var dist      = ac_coord.distance_to(poi("coord"));
	poi("dist", dist);
	poi("crs", crs);
	poi("hdg", crs - getprop("/orientation/heading-deg"));
}

mission.extension_add("Handler", {
	init: func {
		listeners = [
			setlistener("/sim/mission/point-of-interest/signals/POI-changed", func update()),
			setlistener("/sim/mission/point-of-interest/signals/next-POI", func next_POI()),
			setlistener("/sim/mission/point-of-interest/signals/prev-POI", func prev_POI()),
		];
		timer.start();
	},

	stop: func {
		timer.stop();
		foreach(var l; listeners)
			removelistener(l);
		setsize(listeners, 0);
		node.remove();
	},
});