
var mission_objects = [];
var mission_started = 0;
var mission_node    = props.getNode("/sim/mission/data", 1);
var mission_root    = "";
var objects         = [];
var handlers        = [];


var hasmember = view.hasmember;

var addExtension = func (type, h) {
	if (type == "MissionObject")
		append (objects, h);
	elsif (type == "Handler")
		append (handlers, h);
}

var extension_list = func {
	var v = [];
	var path = getprop("/sim/fg-root") ~ "/Nasal/mission/extensions";
	if((var dir = directory(path)) == nil) return;
	foreach(var file; sort(dir, cmp))
		if(size(file) > 4)
			if (substr(file, -4) == ".nas")
				append(v, file);
	return v;
}


var load_nasal = func(file, module) {    # (copy-paste from io.nas)
	var code = call(func compile(io.readfile(file), file), nil, var err = []);
	if (size(err)) {
		if (substr(err[0], 0, 12) == "Parse error:") { # hack around Nasal feature
			var e = split(" at line ", err[0]);
			if (size(e) == 2)
				err[0] = string.join("", [e[0], "\n  at ", file, ", line ", e[1], "\n "]);
		}
		for (var i = 1; (var c = caller(i)) != nil; i += 1)
			err ~= subvec(c, 2, 2);
		debug.printerror(err);
		return 0;
	}
	call(bind(code, globals), nil, nil, globals.__mission[module], err);
	debug.printerror(err);
}

var load_preferences = func() {
	foreach (var a; directory(mission_root))
		if (a == "preferences.xml") {
			io.read_properties(mission_root ~ "/preferences.xml", props.getNode(""));
			break;
		}
}

var start_mission = func(name) {
	if (mission_started) return;

	mission_root = resolvepath("Missions/" ~ name);
	if (mission_root == "") return;

	load_preferences();

	mission_node.removeAllChildren();
	io.read_properties(mission_root ~ "/mission.xml", mission_node);

	var presets = mission_node.getChild("presets");
	if (presets != nil) {
		props.copy(presets, props.getNode("/sim/presets"));
		fgcommand("reposition");
	}

	var timeofday = mission_node.getChild("timeofday");
	if (timeofday != nil)
		fgcommand("timeofday", props.Node.new({ "timeofday" : timeofday.getValue() }));


	globals["__mission"] = {};

	#load_extensions();

	var i = 0;
	var k = "";
	foreach(var script; mission_node.getChildren("include")) {
		globals["__mission"][k = "__" ~ i] = {};
		load_nasal(mission_root ~ "/extensions/" ~ script.getValue(), k);
		i += 1;
	}
	foreach(var script; extension_list()) {
		globals["__mission"][k = "__" ~ i] = {};
		load_nasal(getprop("/sim/fg-root") ~ "/Nasal/mission/extensions/" ~ script, k);
		i += 1;
	}

	settimer (func _start_mission(), 0);
}

var _start_mission = func {
	if (splash_screen()) {
		settimer(func _start_mission(), 2);
		return;
	}

	foreach (var h; handlers)
		if( hasmember(h, "init") )
			h.init();

	foreach(var c; mission_node.getChildren("object"))
		foreach(var obj; objects)
			if (c.getValue("type") == obj.type)
				append(mission_objects, obj.new(c));

	foreach(var obj; mission_objects)
		if( hasmember(obj, "init") )
			obj.init();

	mission_started = 1;
}

var splash_screen = func {
	var s = getprop("sim/startup/splash-alpha");
	if (s == nil) s = 1;
	return s > 0 ? 1 : 0;
}

var stop_mission = func {
	if (!mission_started) return;

	foreach(var obj; mission_objects) obj.del();

	setsize(mission_objects, 0);
	setsize(objects, 0);

	foreach (var h; handlers)
		if (hasmember(h, "stop"))
			h.stop();
	setsize(handlers, 0);

	delete(globals, "__mission");

	mission_started = 0;
}


var activate_object = func(name, start = 1) {
	if (name == nil)
		return;
	foreach(var obj; mission_objects)
		if (obj.name == name) {
			if (start)
				obj.start();
			else
				obj.stop();
		}
}


var activate_object_group = func(group, start = 1) {
	foreach(var ref; group.getChildren("object-reference"))
		activate_object(ref.getValue(), start);
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

	for (var i = 0; 1; i += 1)
		if (models.getChild("model", i, 0) == nil) {
			model = models.getChild("model", i, 1);
			break;
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
	if ( (var value = node.getValue(path)) == nil)
		default;
	else value;
}

var play_sound = func (file) {
	var sound = {
		path : mission_root ~ "/Sounds",
		file : file,
		volume : 1
	};
	fgcommand("play-audio-sample", props.Node.new(sound));
}

var scr_x = func getprop("/sim/startup/xsize");
var scr_y = func getprop("/sim/startup/ysize");

var init_gui = func {
	gui.Dialog.new("/sim/gui/dialogs/mission-browser/dialog", "Nasal/mission/GUI/mission_browser.xml");

	#reset handling
	foreach(var menu; props.getNode("/sim/menubar/default").getChildren("menu"))
		if (menu.getValue("label") == "Missions")
			return;
	#/reset handling

	var h = {
		label: "Missions",
		item: [
			{ #0
				label: "Mission browser",
				binding: {
					command: "nasal",
					script: "gui.showDialog('mission-browser')",
				},
			},
			{ #1
				label: "Toggle compass",
			},
			{ #2
				label: "Stop mission",
				binding: {
					command: "nasal",
					script: "mission.stop_mission()",
				},
			},
		],
	};
	props.getNode("/sim/menubar/default").addChild("menu").setValues(h);
	fgcommand("gui-redraw");
}

###
var save_data = func {
	var path = getprop("/sim/fg-home") ~ "/Export/state.xml";

	var fdm_node      = props.getNode("fdm");
	var engines_node  = props.getNode("engines");
	var rotors_node   = props.getNode("rotors");
	var systems_node  = props.getNode("systems");
	var controls_node = props.getNode("controls");

	var data = props.Node.new();

	props.copy(fdm_node, data.getNode("fdm", 1));
	props.copy(engines_node, data.getNode("engines", 1));
	props.copy(rotors_node, data.getNode("rotors", 1));
	props.copy(systems_node, data.getNode("systems", 1));
	props.copy(controls_node, data.getNode("controls", 1));

	io.write_properties(path, data);
	data.remove();
}

var load_data = func {
	var path = getprop("/sim/fg-home") ~ "/Export/state.xml";
	io.read_properties(path, "/");
}

###

_setlistener("/nasal/mission/loaded", func {
	setprop("/sim/sound/chatter/enabled", 1);
	setprop("/sim/sound/chatter/volume", 1.0);
	init_gui();
});