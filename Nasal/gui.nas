
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

	gui.Dialog.new("/sim/gui/dialogs/mission-message-box/dialog",
        getprop("/sim/mission/root_path") ~ "/GUI/mission_message_box.xml");

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
			{ #2
				label: "Restart mission",
				binding: {
					command: "nasal",
					script: "mission.restart_mission()",
				},
			},
			{ #3
				label: "msgbox",
				binding: {
					command: "nasal",
					script: "gui.showDialog('mission-message-box')",
				},
			},
		],
	};
	props.getNode("/sim/menubar/default").addChild("menu").setValues(h);
	fgcommand("gui-redraw");
}


var show_msgbox = func(msg, type = "info") {
    setprop('/sim/mission/gui/msgbox-text', msg);
    setprop('/sim/mission/gui/msgbox-icon-path',
        getprop('/sim/mission/root_path') ~ '/GUI/Dialog-' ~ type ~ '.png');
    gui.showDialog('mission-message-box');
}


var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);

    setprop("/sim/sound/chatter/enabled", 1);
	setprop("/sim/sound/chatter/volume", 1.0);

    init_gui();

    print("Mission initialized");
});

