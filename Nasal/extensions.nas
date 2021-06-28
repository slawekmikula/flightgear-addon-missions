
var objects         = [];
var handlers        = [];
var exclude_list    = [];

var extensions_load = func {

    globals["__mission"] = {};

    var i = 0;
	var k = "";

    #load mission extension
	foreach(var script; mission_node.getChildren("include")) {
		globals["__mission"][k = "__" ~ i] = {};
		_load_nasal(mission_root ~ "/Nasal/extensions/" ~ script.getValue(), k);
		i += 1;
	}

    #load core extensions
	foreach(var script; extension_list()) {
		globals["__mission"][k = "__" ~ i] = {};
		_load_nasal(getprop("/sim/mission/root_path") ~ "/Nasal/extensions/" ~ script, k);
		i += 1;
	}
}

var extensions_clear = func {
	setsize(objects, 0);

	foreach (var h; handlers) {
		if (hasmember(h, "stop")) {
			h.stop();
        }
    }
	setsize(handlers, 0);
}

var extension_add = func (type, h) {
	if (type == "MissionObject") {
		append (objects, h);
	} elsif (type == "Handler") {
		append (handlers, h);
    }
}

var extension_list = func {
	var v = [];
	var path = getprop("/sim/mission/root_path") ~ "/Nasal/extensions";
	if((var dir = directory(path)) == nil) {
        return;
    }

	foreach(var file; sort(dir, cmp)) {
		if(size(file) > 4) {
			if (substr(file, -4) == ".nas") {
				append(v, file);
            }
        }
    }

	return v;
}

var mission_objects_init = func() {
    foreach (var h; handlers) {
		if( hasmember(h, "init") ) {
			h.init();
        }
    }

	foreach(var c; mission_node.getChildren("object")) {
		foreach(var obj; objects) {
			if (c.getValue("type") == obj.type) {
				append(mission_objects, obj.new(c));
            }
        }
    }

	foreach(var obj; mission_objects) {
		if( hasmember(obj, "init") ) {
			obj.init();
        }
    }
}

var _load_nasal = func(file, module) {    # (copy-paste from io.nas)
	var code = call(func compile(io.readfile(file), file), nil, var err = []);
	if (size(err)) {
		if (substr(err[0], 0, 12) == "Parse error:") { # hack around Nasal feature
			var e = split(" at line ", err[0]);
			if (size(e) == 2) {
				err[0] = string.join("", [e[0], "\n  at ", file, ", line ", e[1], "\n "]);
            }
		}
		for (var i = 1; (var c = caller(i)) != nil; i += 1) {
			err ~= subvec(c, 2, 2);
        }
		debug.printerror(err);
		return 0;
	}
	call(bind(code, globals), nil, nil, globals.__mission[module], err);
	debug.printerror(err);
}
