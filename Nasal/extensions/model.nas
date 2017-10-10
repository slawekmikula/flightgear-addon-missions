
mission.addExtension("MissionObject", {
	type: "model",

	new: func(n) {
		var m = {
			parents     : [me],
			node        : n,
			name        : n.getValue("name"),
			_activated  : (n.getValue("activated") or 0),
			_path       : n.getValue("path"),
			_coord      : mission.get_coord(n.getNode("world-position")),
			_heading    : (n.getValue("orientation/heading-deg") or 0),
			_pitch      : (n.getValue("orientation/pitch-deg") or 0),
			_roll       : (n.getValue("orientation/roll-deg") or 0),
		};

		#m.object_N = props.getNode("/sim/mission/objects", 1).addChild("model");
		#m.position_N = n.getNode("world-position");

		m.model = mission.put_model(m._path, m._coord, m._heading, m._pitch, m._roll);

		if (!m._activated)
			m._hide();

		return m;
	},

	start: func me._show(),

	stop: func me._hide(),

	del: func me.model.remove(),

	_show: func {
		me.model.setValue("elevation-ft", me._coord.alt() * M2FT);
	},

	_hide: func {
		me.model.setValue("elevation-ft", -99999);
	},
});