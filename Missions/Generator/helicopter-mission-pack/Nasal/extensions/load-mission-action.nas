var load_mission_action = {

    type: "load-mission-action",

    new: func(n) {
        var m = {
            parents : [load_mission_action],
            name    : n.getValue("name"),
            #_path   : n.getValue("mission-path"),
            _file   : n.getValue("mission-file"),
        };

        return m;
    },

    start: func {
        #me._path = getprop("/sim/mission/current_mission/path") ~ "/" ~ me._path;
        var path = getprop("/sim/mission/current_mission/path");
        setprop("/sim/mission/current_mission/file-name", me._file);
        settimer(func mission.start_mission(path, me._file), 1);
        mission.stop_mission();
    },

    stop: func,

    del: func, 

}; #load_mission_action

mission.extension_add("MissionObject", load_mission_action);
