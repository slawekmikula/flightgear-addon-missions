
var scr_x = func getprop("/sim/startup/xsize");
var scr_y = func getprop("/sim/startup/ysize");

var init_gui = func {
	# do not reinit gui
	foreach(var menu; props.getNode("/sim/menubar/default").getChildren("menu")) {
		if (menu.getValue("label") == "Missions") {
			return;
        }
    }

	gui.Dialog.new("/sim/gui/dialogs/mission-browser/dialog",
        getprop("/sim/mission/root_path") ~ "/GUI/mission_browser.xml");

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

var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);

    setprop("/sim/sound/chatter/enabled", 1);
	setprop("/sim/sound/chatter/volume", 1.0);

    init_gui();

    print("Mission initalized");
});

