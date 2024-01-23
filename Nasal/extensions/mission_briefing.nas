__mission.mission_stopped = 0;
var path = getprop("/sim/mission/root_path"); # revise
var mission_briefing = nil;
var difficulty_label = nil;
var scroll_area = nil;
var skill_level = -1;

var objectivesN = props.getNode("/sim/mission/objectives", 1);
var _objectives = [];
var objectives = [];

var objectives_mode_enabled = 0;

var briefing_layer = __mission.mission_dialog.newLayer({
    name:     "Mission Briefing",
    bgImage:  path ~ "/GUI/fgbg4.png",
});


var draw_title = func(n) {
    briefing_layer.spawn("label", {
        text:           n,
        color:          "#e0e0b5",
        fontSize:       24,
        font:           "LiberationFonts/LiberationSerif-Regular.ttf",
        datumPoint:     [0.5, 0],
        movement:       [0.5, 0.08],
    });
}


var draw_difficulty = func(s) {
    difficulty_label = briefing_layer.spawn("label", {
        text:           s,
        color:          "#e0e0b5",
        font:           "LiberationFonts/LiberationSerif-Regular.ttf",
        fontSize:       24,
        datumPoint:     [0, 0],
        movement:       [0.075, 0.15],
    });
}

# Buttons

var briefing_b_difficulty = briefing_layer.spawn("label", {
    text:                "Difficulty",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            25,
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func cycle_difficulty(),
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    movement:            [0.315, 1-0.06],
    debug:               0,
});


var briefing_b_continue = briefing_layer.spawn("label", {
    text:                "Continue",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            25,
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func {
                             objectives_show_briefing(0);
                             objectives_mode();
                         },
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    clickAreaDatumPoint: [0.5, 0.5],
    movement:            [1-0.315, 1-0.06],
    rotation:            0,
    debug:               0,
});


# Arrows

var arrowDown = briefing_layer.spawn("label", {
    text:       "→",
    font:       "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:   70,
    color:      "#5b625a",
    mouseoverColor: "#bbc2cf",
    clickable:  1,
    clickedFunc: func print("Down arrow"),
    datumPoint: [0., 0.5],
    clickArea:  [1/6, 1/12],
    clickAreaDatumPoint: [0., 0.5],
    movement:   [1-0.07, 0.55],
    rotation:   90,
    debug:      0,
});

var arrowUp = briefing_layer.spawn("label", {
    text:           "→",
    font:           "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:       70,
    color:          "#5b625a",
#    strokeColor:    "#000000",
    mouseoverColor: "#bbc2cf",
    clickable:      1,
    clickedFunc:    func print("Up arrow"),
    datumPoint:     [0., 0.5],
    clickArea:      [1/6, 1/12],
    clickAreaDatumPoint: [0., 0.5],
    movement:       [1-0.07, 1-0.55],
    rotation:       -90,
    debug:          0,
});


var cycle_difficulty = func ()
{
    if ((skill_level += 1) >= size(mission_briefing.difficulty))
        skill_level = 0;
    difficulty_label.customize(
        {text: "Difficulty: " ~ mission_briefing.label[skill_level]}
    );
    filter_objectives(skill_level);
    scroll_area.update();
    if (size(mission_briefing.difficulty) < 2)
        difficulty_label.hide();
    #scroll_area.customize({items: objectives});
    __mission.skill_level = skill_level;
}



var create_objectives = func {
    foreach(var obj; objectivesN.getChildren("objective"))
        append (
            _objectives,
            briefing_layer.spawn("missionObjective", obj, {
                font: "LiberationFonts/LiberationSerif-Regular.ttf",
                fontSize: 24,
                showBriefing: 1,
                boxColor: "#e0c9b3",
                pendingTextColor: "#e0e0b5",
                widthRatio: 1,
            }) #spawn
        ); #append
}

var objectives_show_briefing = func(b = 1) {
    foreach(var obj; _objectives)
        obj.customize({showBriefing: b});
        scroll_area.redraw();
}


var activate_objects = func {
    if (!size(mission_briefing.actions))
        return;
    if (mission_briefing.actions[skill_level] == nil)
        return;
    mission.activate_object_group(mission_briefing.actions[skill_level]);
}


var objectives_mode = func {
    briefing_layer.customize({
        name: "Mission Objectives",
        bgImage: path ~ "/GUI/mission-objectives-bg.jpg",
    });
    briefing_b_difficulty.hide();
    briefing_b_continue.hide();
    obj_b_done();
    objectives_mode_enabled = 1;
    __mission.mission_dialog.show("Mission Objectives");
    activate_objects();
}

var show_objectives = func ()
{
    objectives_mode_enabled or return;
    if ( !__mission.mission_dialog.visible ) {
        __mission.mission_dialog.show("Mission Objectives");
    } else {
        __mission.mission_dialog.window.del();
    }
}

var filter_objectives = func(skill) {
    setsize(objectives, 0);
    foreach(var obj; _objectives) {
        #obj.status("hidden").hide();
        obj.hide();
        foreach(var a; mission_briefing.objectives[skill]) {
            if (obj.name == a) {
                #obj.status("pending");
                if (obj.status() != "hidden")
                    append(objectives, obj);
            }
        }
    }
}

var objective_update_status = func ()
{
    foreach(var obj; _objectives) {
        obj.update_status();
    }
}


var missionBriefing = {

	type: "mission-briefing-action",

	new: func(n) {
		var m = {
			parents    : [me], # missionBriefing ?
            node       : n,
			name       : n.getValue("name"),
            title      : mission.get(n, "mission-title", "FlightGear Mission"),
            difficulty : n.getChildren("difficulty"),
            label      : [],
            objectives : [],
			actions    : [],
           # current_difficulty: 0,
            _activated : 0,
		};

        print(size(m.difficulty));
        var i = 0;
        foreach(var d; m.difficulty) {
            append(m.label, mission.get(d, "difficulty-label", " " ~ i));
            var v = [];
            foreach(var o; d.getNode("objectives", 1).getChildren("object-reference"))
                append(v, o.getValue());
            append(m.objectives, v);
            append(m.actions, d.getNode("actions", 1));
            i += 1;
        }

		return m;
	},

	init: func {
        forindex(var i; me.label)
            me.label[i] = string.trim(me.label[i], 0, string.isxspace);

        me.listeners = [
            setlistener( "/sim/mission/signals/objectives-changed",
                         func objective_update_status() ),
            setlistener( "/sim/mission/signals/show-objectives",
                         func show_objectives() ),
		];

    },

	start: func {
#        if (me._activated)
        show_briefing(me);
	},

	del: func ()
    {
        foreach(var l; me.listeners)
        removelistener(l);
        setsize(me.listeners, 0);
    },

}; # missionBriefing




var obj_b_done = func briefing_layer.spawn("label", {
    text:                "Done",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            25,
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func ()
                         {
                            if ( __mission.mission_stopped )
                                __mission.mission_dialog.show("Mission Summary");
                            else
                                __mission.mission_dialog.window.del();
                         },
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    clickAreaDatumPoint: [0.5, 0.5],
    movement:            [0.808, 1-0.06],
    rotation:            0,
    debug:               0,
});

var obj_b_messages = func briefing_layer.spawn("label", {
    text:                "Messages",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            25,
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func __mission.mission_dialog.show("Mission Briefing"),
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    clickAreaDatumPoint: [0.5, 0.5],
    movement:            [0.5, 1-0.06],
    rotation:            0,
    debug:               0,
});

var obj_b_map = func briefing_layer.spawn("label", {
    text:                "Map",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            25,
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func __mission.mission_dialog.show("Mission Briefing"),
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    clickAreaDatumPoint: [0.5, 0.5],
    movement:            [1-0.808, 1-0.06],
    rotation:            0,
    debug:               0,
});




##
# Load briefing data and show Mission Briefing
#

var show_briefing = func(b) {
    mission_briefing = b;
    draw_title(b.title);
    draw_difficulty("Difficulty: Normal");

    create_objectives();

    scroll_area = briefing_layer.spawn("scrollArea", {
        debug: 0,
        scrollUpButton: arrowUp,
        scrollDownButton: arrowDown,
        scrollArea: [0.82, 0.62],
        movement:   [0.08, 0.22],
        items: objectives,
    });

    cycle_difficulty(mission_briefing.label);

    __mission.mission_dialog.show("Mission Briefing");

}


mission.extension_add("MissionObject", missionBriefing);