
var mission_objects = [];
var mission_started = 0;
var mission_node    = props.getNode("/sim/mission/data", 1);
var mission_root    = "";
var mission_is_generated = 0;

var hasmember = view.hasmember;

var preferences_load = func() {
    foreach (var a; directory(mission_root)) {
        if (a == "mission-preferences.xml") {
            io.read_properties(mission_root ~ "/mission-preferences.xml", props.getNode(""));
            break;
        }
    }
	var f = mission_node.getChild("preferences-file");
	if (f != nil)
        io.read_properties(mission_root ~ "/" ~ f.getValue(), props.getNode(""));
}

var start_mission = func(path, filename = "mission.xml") {
    mission_root = path;
	if (mission_started) {
        return;
    }

    # FIXME - FIX ResourceLoader in FG Source
	#mission_root = resolvepath("/Aircraft/Missions/" ~ name);
	if (mission_root == "") {
        return;
    }
    # save mission root for repositioning (will reset addon)
    setprop("/sim/mission/current_mission/path", mission_root);
    setprop("/sim/mission/current_mission/file-name", filename);

	mission_node.removeAllChildren();
	io.read_properties(mission_root ~ "/" ~ filename, mission_node);

    # set flightgear main state (location, weather)
	var presets = mission_node.getChild("presets");
	if (presets != nil) {
		props.copy(presets, props.getNode("/sim/presets"));
		fgcommand("reposition");
	}

	var timeofday = mission_node.getChild("timeofday");
	if (timeofday != nil) {
		fgcommand("timeofday", props.Node.new({ "timeofday" : timeofday.getValue() }));
    }

    # wait for simulator restart & proceed
	settimer (func _start_mission(), 0);
}

var _start_mission = func {
    # wait for splash screen closing
	if (splash_screen()) {
		settimer(func _start_mission(), 2);
		return;
	}

    # reload data
    mission_root = getprop("/sim/mission/current_mission/path");
    var filename = getprop("/sim/mission/current_mission/file-name");
    if (filename == nil)
        filename = "mission.xml";
    print("mission root: " ~ mission_root);
    print("mission file: " ~ filename);

	mission_node.removeAllChildren();
	io.read_properties(mission_root ~ "/" ~ filename, mission_node);


    #
	var n = mission_node.getChild("nasal");
    globals.__mission_nasal = {};
	if (n != nil) {
        if ( (var f = n.getChild("file")) != nil )
            io.load_nasal(mission_root ~ "/" ~ f.getValue(), "__mission_nasal");
    }


	preferences_load();
	extensions_load();
	mission_objects_init();

	mission_started = 1;
}

var restart_mission = func {
	if (!mission_started)
        return;
    stop_mission();
    start_mission(getprop("/sim/mission/current_mission/path"));
}

var stop_mission = func {
	if (!mission_started) {
        return;
    }

	foreach(var obj; mission_objects) {
        obj.del();
        #print(id(obj));
        #settimer(func obj.parents = nil, 0);
    }
	setsize(mission_objects, 0);

    extensions_clear();
	delete(globals, "__mission");
	delete(globals, "__mission_nasal");

	mission_started = 0;
}


var object_by_name = func(name) {
    foreach(var obj; mission_node.getChildren("object"))
        if (obj.getValue("name") == name)
            return obj;
    nil
}


var activate_object = func(name, start = 1) {
	if (name == nil) {
		return;
    }

	foreach(var obj; mission_objects) {
		if (obj.name == name) {
			if (start) {
				obj.start();
			} else {
				obj.stop();
            }
		}
    }
}

var activate_object_group = func(group, start = 1) {
	foreach(var ref; group.getChildren("object-reference")) {
		activate_object(ref.getValue(), start);
    }
}

var get_coord = func(n) {
	geo.Coord.new().set_latlon (
		var lat = n.getValue("latitude-deg") or 0,
		var lon = n.getValue("longitude-deg") or 0,
		(n.getValue("altitude-m") or 0) + (geo.elevation(lat, lon) or 0) * get(n, "altitude-is-AGL", 1)
	);
}


var put_model = func(path, coord, heading = 0, pitch = 0, roll = 0) {
	var models = props.getNode("/models");
	var model = nil;

	for (var i = 0; 1; i += 1) {
		if (models.getChild("model", i, 0) == nil) {
			model = models.getChild("model", i, 1);
			break;
		}
    }

	var model_path = model.getPath();

	model.setValues({
		"path"               : path,
		"latitude-deg"       : coord.lat(),
		"latitude-deg-prop"  : model_path ~ "/latitude-deg",
		"longitude-deg"      : coord.lon(),
		"longitude-deg-prop" : model_path ~ "/longitude-deg",
		"elevation-ft"       : coord.alt() * M2FT,
		"elevation-ft-prop"  : model_path ~ "/elevation-ft",
		"heading-deg"        : heading,
		"heading-deg-prop"   : model_path ~ "/heading-deg",
		"pitch-deg"          : pitch,
		"pitch-deg-prop"     : model_path ~ "/pitch-deg",
		"roll-deg"           : roll,
		"roll-deg-prop"      : model_path ~ "/roll-deg",
	});

	model.getNode("load", 1).remove();

	return model;
}

var model = {
	new: func (path, coord, heading = 0, pitch = 0, roll = 0) {
		var m = {
			parents: [model],
			model: put_model(path, coord, heading, pitch, roll)
		};
	},
};

var get = func(node, path, default = nil) {
	if ( (var value = node.getValue(path)) == nil) {
		default;
    } else {
        value;
    }
}

var file_found = func(filename) {
    return call(io.readfile, [filename], nil, nil, var err=[]);
}

var play_sound = func (file, vol = 1.0) {

    var filepath = mission_root ~ "/Sounds/";
    if (!file_found(filepath ~ "/" ~ file)) {
        filepath = getprop("/sim/mission/root_path") ~ "/Missions/Generic/Sounds";
    }

	var sound = {
		path : filepath,
		file : file,
		volume : vol
	};
	fgcommand("play-audio-sample", props.Node.new(sound));
}

var speak = func (text) {
    setprop("/sim/sound/voices/atc", text);
}


var sim =
{

listeners: [
    setlistener("/sim/startup/xsize", func sim._update_xy_size()),
    setlistener("/sim/startup/ysize", func sim._update_xy_size()),
],


x_size: func ()
{
    me._x_size;
},


y_size: func ()
{
    me._y_size;
},


init: func ()
{
    me._update_xy_size();
},

_update_xy_size: func ()
{
    me._x_size = getprop("/sim/startup/xsize");
    me._y_size = getprop("/sim/startup/ysize");
    setprop("/sim/mission/signals/xy-size-updated", 1);
},

}; #sim

sim.init();


# Scaling for other resolutions
var scale = func (v, dim = "w")
{
    if ( dim == "w" ) {
        v/1920 * sim.x_size();
    } elsif ( dim == "h" ) {
        v/1080 * sim.y_size();
    }
}

print("Mission loaded");
