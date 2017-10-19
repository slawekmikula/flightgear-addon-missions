
mission.extension_add("MissionObject", {
	type: "rectangle-area",

	new: func(n) {
		var m = {
			parents      : [me],
			node         : n,
			coord        : mission.get_coord(n.getNode("attached-world-position")), #revise: static position
			name         : n.getValue("name"),
			_direct_dist : nil,
			_norm_dist   : nil,
			_h_dist      : nil,
			_v_dist      : nil,
			_height      : (n.getValue("height") or 9999) / 2,
			_width       : (n.getValue("width") or 9999) / 2,
			_length      : (n.getValue("length") or 9999) / 2,
			_heading     : (n.getValue("orientation/heading-deg") or 0),
			_in_the_box  : 0,
		};

		m.timer = maketimer(0, func m._loop());
		#m.timer.start(); #remove
		#print("w:" ~ m._width ~ " h:" ~ m._height);


		#m.model = mission.put_model(getprop("/sim/fg-root") ~ "/Missions/Generic/Models/bounding_box.xml", m.coord, m._heading);
		setprop("/bbox/height", m._height * 2);
		setprop("/bbox/width", m._width * 2);
		setprop("/bbox/length", m._length * 2);
		return m;
	},

	start: func me.timer.start(),

	stop: func {
		me.timer.stop();
		me.entering();
		me.exiting();
		#me.model.remove();
	},

	entering: func {
		var a = me._entering;
		me._entering = 0;
		return a;
	},

	exiting: func {
		var a = me._exiting;
		me._exiting = 0;
		return a;
	},

	_exiting: 0,

	_entering: 0,

	_loop: func {
		me._update();
	},

	_update: func {
		var ac_coord = geo.aircraft_position();
		var hdg = me._heading * D2R;
		var crs = me.coord.course_to(ac_coord) * D2R;

		me._direct_dist = me.coord.direct_distance_to(ac_coord);
		me._v_dist = me.coord.alt() - ac_coord.alt();

		var d = math.sqrt(me._direct_dist * me._direct_dist - me._v_dist * me._v_dist);
		me._norm_dist = math.cos(hdg - crs) * d;
		me._h_dist = math.sin(hdg - crs) * d;


		var v = me._in_the_box;
		if ((math.abs(me._h_dist) <= me._width) and
			(math.abs(me._v_dist) <= me._height) and
			(math.abs(me._norm_dist) <= me._length ))
			me._in_the_box = 1;
		else me._in_the_box = 0;

		#setprop("/aaa/in-the-box", me._in_the_box);
		if (me._in_the_box == v)
			return;

		if (me._in_the_box) {
			me._entering = (me._entering ? 0 : 1);
			me._exiting = 0;
		} else {
			me._exiting = (me._exiting ? 0 : 1);
			me._entering = 0;
		}

		#setprop("/aaa/exiting", me._exiting);
		#setprop("/aaa/entering", me._entering);

	},

	del: func me.stop(),


});