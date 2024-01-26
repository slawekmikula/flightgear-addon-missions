var path = getprop("/sim/mission/root_path"); # revise
#__mission.mission_stopped = 0;

var state_changed = 0;
var x_size = mission.sim.x_size();
var y_size = mission.sim.y_size();

var message =
{

init: func ()
{
    me.timer = maketimer(5, func me.hide() );
    me.timer.singleShot = 1;
    me.txt.hide();
},


hide: func ()
{
    me.txt.hide();
},

show: func (txt, t = 5)
{
    me.timer.restart(t);
    me.txt.setText(txt).show();
    mission.ui_sound("message1");
},

txt: canvas.getDesktop().createChild("text")
           .setFont("LiberationFonts/LiberationSans-Regular.ttf")
           .setFontSize(mission.scale(30, "h"), 1.0)
           .setColor(1,1,1,1)
           .set('stroke',  'rgb(0,0,0)')
           .setAlignment("center-center")
           .setTranslation(x_size/2, 80).setText(""),

}; # message

message.init();

mission.extension_add("Handler", {
	init: func ()
    {
		me.listeners = [
			setlistener( me.node.getNode("objective-status-changed", 1),
                         func me.update() ),
            setlistener( me.node.getNode("objective-status-message", 1),
                         func(n) message.show(n.getValue()) ),
		];
	},

	node: props.getNode("/sim/mission/objectives", 1),

	update: func ()
    {
		if (state_changed) return;
		state_changed = 1;
		settimer(func me.check_objectives(), 0);
	},

	check_objectives: func ()
    {
        #setprop("/sim/mission/signals/objectives-changed", 1);
        print(size(__mission.objectives));
		var failed = 0;
		var completed = 0;
		#var objectives = me.node.getChildren("objective");
		foreach (var g; __mission.objectives)
			if ((var state = g.status()) == "failed")
				failed += 1;
			elsif (state == "completed") # or "hidden" -- ?
				completed += 1;
		if (failed)
			mission_completed(0);
		elsif (completed == size(__mission.objectives))
			mission_completed(1);
		state_changed = 0;
        settimer(func setprop("/sim/mission/signals/objectives-changed", 1), 1);
        #print(completed ~ "    " ~ size(objectives));
	},

	stop: func ()
    {
		foreach(var l; me.listeners)
			removelistener(l);
		setsize(me.listeners, 0);
		me.node.remove();
        message.txt.del();
	},
});


#var create_objectives = func{}

var mission_summary_layer = __mission.mission_dialog.newLayer({
    name:     "Mission Summary",
    bgImage:  path ~ "/GUI/fgbg4.png",
});


var draw_title = func(n)
{
    mission_summary_layer.spawn("label", {
        text:           n,
        color:          "#e0e0b5",
        fontSize:       mission.scale(35, "h"),
        font:           "LiberationFonts/LiberationSerif-Regular.ttf",
        datumPoint:     [0.5, 0],
        movement:       [0.5, 0.08],
    });
}


# Buttons

var mission_summary_b_objectives = mission_summary_layer.spawn("label", {
    text:                "Objectives",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            mission.scale(25, "h"),
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func __mission.mission_dialog.show("Mission Objectives"),
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    movement:            [0.315, 1-0.06],
    debug:               0,
});


var mission_summary_b_done = mission_summary_layer.spawn("label", {
    text:                "Done",
    font:                "LiberationFonts/LiberationSerif-Regular.ttf",
    fontSize:            mission.scale(25, "h"),
    color:               "#5b625a",
    mouseoverColor:      "#bbc2cf",
    clickable:           1,
    clickedFunc:         func {
                             mission.stop_mission();
#                             objectives_mode();
                         },
    datumPoint:          [0.5, 0.5],
    clickArea:           [1/4.5, 1/12],
    clickAreaDatumPoint: [0.5, 0.5],
    movement:            [1-0.315, 1-0.06],
    rotation:            0,
    debug:               0,
});


var show_mission_summary = func ()
{
    __mission.mission_dialog.show("Mission Summary");
    __mission.mission_stopped = 1;
}


mission_completed = func (c = 1)
{
    var m = (c < 1 ? "Mission Failed" : "Mission Completed");
    draw_title(m);
    settimer(show_mission_summary, 3);
}