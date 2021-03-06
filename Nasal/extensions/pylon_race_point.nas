

mission.extension_add("MissionObject", {

	type: "pylon-race-point",

	new: func(n) {
		var m = {
			parents         : [me],
			name            : n.getValue("name"),
			activated       : mission.get(n, "activated", 0),
			heading         : mission.get(n, "orientation/heading-deg", 0),
			ignore_dist     : mission.get(n, "ignore-distance-m", 100),
			enter_actions   : n.getNode("on-enter-actions"),
			penalty_actions : n.getNode("on-penalty-actions"),
			inside_dir      : mission.get(n, "inside-direction", 0),
			coord           : mission.get_coord(n.getNode("world-position")),
			_direct_dist    : nil,
			_norm_dist      : 0,
			_h_dist         : nil,
			_v_dist         : nil,
			_prev_norm_dist : nil,
		};

		if (m.inside_dir == "right")
			m.inside_dir = -1;
		elsif (m.inside_dir == "left")
			m.inside_dir = 1;
		else m.inside_dir = 0;

		m.timer = maketimer(0.5, func m._loop());

		return m;
	},

#	init: func {
#		if (me.activated)
#			me.start();
#	},


	start: func {
		me.timer.start();
	},

	stop: func {
		me.timer.stop();
	},

	del: func {
		me.stop();
	},


	_loop: func {
		me._update();
	},

	_update: func {
		var ac_coord = geo.aircraft_position();

		me._direct_dist = me.coord.direct_distance_to(ac_coord);
		if (me._direct_dist >= me.ignore_dist)
			return;

		var hdg = me.heading * D2R;
		var crs = me.coord.course_to(ac_coord) * D2R;


		me._v_dist = ac_coord.alt() - me.coord.alt();

		var d = math.sqrt(me._direct_dist * me._direct_dist - me._v_dist * me._v_dist);
		me._prev_norm_dist = me._norm_dist;
		me._norm_dist = math.cos(hdg - crs) * d;

		if (me._prev_norm_dist >= 0)
			return;

		if (me._norm_dist < 0)
			return;

		me._h_dist = math.sin(hdg - crs) * d;

		#if (math.sgn(me._h_dist) != me.inside_dir) {
			if (me.enter_actions != nil)
				mission.activate_object_group(me.enter_actions);
		#}


		me.stop();
		setprop("/sim/mission/race/signals/next-race-point", 1);

	},


}); #extension_add
