var gear = props.getNode("gear", 1).getChildren("gear");

var wow = func {
	var on_ground = 0;
	foreach (var g; gear)
		if (g.getValue("wow")) {
			on_ground = 1;
			break;
		}
	return on_ground;
}

var ground_speed = func getprop("/velocities/groundspeed-kt");

var full_stop = func math.abs(ground_speed()) <= 1;

mission.extension_add("MissionObject", {
	type: "airport-landing-trigger",

	new: func(n) {
		var m = {
			parents      : [me],
			name         : n.getValue("name"),
			airport      : n.getValue("airport-id"),
			runways      : n.getChildren("runway"),
			landing_type : n.getValue("landing-type"),
			_actions     : n.getNode("actions"),
			_coord       : geo.Coord.new(),
			_rwy         : [],
			_activated   : (n.getValue("activated") or 0),
			_frame_count : 0,
			_frame       : 0,
			_next_frame  : 0,
		};

		m.timer = maketimer(0, func m._loop());

		var info = airportinfo(m.airport);
		if (size(m.runways) == 0)
			foreach (var r; keys(info.runways))
				append(m._rwy, info.runways[r]);
		else
			foreach (var rwy; m.runways)
				foreach (var r; keys(info.runways))
					if ((rwy.getValue()) == r)
						append(m._rwy, info.runways[r]);

		m._frame_count = size(m._rwy);

		if (m.landing_type == "full stop")
			m._landing_type = 0;
		elsif (m.landing_type == "touchdown")
			m._landing_type = 1;



		return m;
	},

	init: func {
		if (me._activated)
			me.start();
	},

	start: func me.timer.start(),

	stop: func {
		me.timer.stop();
	},

	_loop: func {
		me._update();
	},

	_update: func {
		if (!me._frame_count) return;
		me._frame = me._next_frame;

		var ac_coord = geo.aircraft_position();
		var hdg = me._rwy[me._frame].heading * D2R;
		me._coord.set_latlon(me._rwy[me._frame].lat, me._rwy[me._frame].lon);
		var crs = me._coord.course_to(ac_coord);

		me._dist = me._coord.distance_to(ac_coord);
		me._h_dist = math.sin(hdg - crs * D2R) * me._dist;
		me._dist   = math.cos(hdg - crs * D2R) * me._dist;

		me._next_frame = me._frame + 1;
		if (me._next_frame > (me._frame_count - 1))
			me._next_frame = 0;

		if (me._dist < 0) return;
		if (me._dist > me._rwy[me._frame].length) return;
		if (math.abs(me._h_dist * 2) > me._rwy[me._frame].width) return;
		if ( math.abs(me._rwy[me._frame].heading - getprop("/orientation/heading-deg")) > 90 ) return;
		if (!wow()) return;
		if (me._landing_type == 0 and !full_stop()) return;

		mission.activate_object_group(me._actions);
		me.stop();
	},

	del: func me.stop(),


});