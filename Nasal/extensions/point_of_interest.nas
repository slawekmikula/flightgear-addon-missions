

mission.addExtension("MissionObject", {

	type: "point-of-interest",

	new: func(n) {
		var m = {
			parents        : [me],
			name           : n.getValue("name"),
			node           : props.getNode("/sim/mission/point-of-interest", 1).addChild("point-of-interest"),
			activated      : mission.get(n, "activated", 0),
			_active        : 0,
			target_name    : mission.get(n, "target-name", "---"),
			_wld_posN      : n.getNode("attached-world-position"),
			_obj_posN      : n.getNode("attached-world-object"),
			_coord         : nil,
			#_mdl_coord     : nil,
			_path          : "/Missions/Generic/Models/checkpoint-h50.xml",
			_model         : nil,
			_offsets       : [],
		};

		m.id = m.node.getIndex();

		return m;
	},

	init: func { #revise
		me._listeners = [
			setlistener(me.node.getNode("selected", 1), func me._select()),
		];
		if (me._wld_posN != nil) {
			me._coord = mission.get_coord(me._wld_posN);
			me._mdl_coord = geo.Coord.new(me._coord);
		} elsif (me._obj_posN != nil) {
			var name = me._obj_posN.getValue("object-reference");
			foreach (var obj; mission.mission_objects) {
				if (obj.name == name) {
					me._coord = mission.get_coord(obj.node.getNode("world-position"));
					break;
				}
			}
			me._mdl_coord = geo.Coord.new(me._coord);
			me._offsets = [
				mission.get(me._obj_posN, "x-offset-m", 0),
				mission.get(me._obj_posN, "y-offset-m", 0),
				mission.get(me._obj_posN, "z-offset-m", 0),
			];
			me._apply_offsets();
		}
		me._model = mission.put_model(getprop("/sim/fg-root") ~ me._path, me._mdl_coord);
		me.node.setValues({
			"latitude-deg"  : me._coord.lat(),
			"longitude-deg" : me._coord.lon(),
			"altitude-m"    : me._coord.alt(),
			"name"          : me.target_name,
		});
		if (me.activated)
			me.start();
		else
			me._hide();
	},

	_apply_offsets: func {
		var crs  = math.atan2(me._offsets[1], me._offsets[0]) * R2D;
		var dist = math.sqrt(me._offsets[0] * me._offsets[0] + me._offsets[1] * me._offsets[1]);

		me._mdl_coord.apply_course_distance(crs, dist);
		me._mdl_coord.set_alt(me._coord.alt() + me._offsets[2]);
	},

	start: func {
		!me._active or return;
		me._active = 1;
		me._show();
		me.node.setBoolValue("active", 1);
		setprop("/sim/mission/point-of-interest/current-POI", me.id); #?
		setprop("/sim/mission/point-of-interest/signals/POI-changed", 1);
	},

	stop: func {
		me._active = 0;
		me._hide();
		me.node.setBoolValue("active", 0);
		setprop("/sim/mission/point-of-interest/signals/POI-changed", 1);
	},

	del: func {
		me.stop();
		me._model.remove();
		me.node.remove();
		foreach(var l; me._listeners)
			removelistener(l);
		setsize(me._listeners, 0);
	},

	_select: func {
		if (!me._active)
			return;
		elsif (me._selected())
			me._show();
		else me._hide();
	},

	_selected: func mission.get(me.node, "selected", 0),

	_show: func {
		me._model.setValue("elevation-ft", me._mdl_coord.alt() * M2FT);
	},

	_hide: func {
		me._model.setValue("elevation-ft", -99999);
	},

}); #addExtension