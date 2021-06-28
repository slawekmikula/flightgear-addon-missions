var state_changed = 0;

var w = 250;
var h = 60;

var window = canvas.Window.new([w, h],"dialog").set('title', "Mission Resolution");
window.hide();
window.set("fill", "rgba(255,255,255,0.9)");
window.del = func window.hide();

var _scr_x = func getprop("/sim/startup/xsize");
var _scr_y = func getprop("/sim/startup/ysize");

window.set("tf/t[0]", _scr_x() / 2 - w / 2);
window.set("tf/t[1]", _scr_y() / 5);

var myCanvas = window.createCanvas().setColorBackground(0.2, 0.4, 0.7, 0.9);

var myText = myCanvas.createGroup().createChild("text")
	.setTranslation(w/2, h/2)
	.setAlignment("center-center")
	.setFontSize(h/2)
	.setFont("LiberationFonts/LiberationSans-Bold.ttf")
;

#var draw_message = func (s = 1) {
#	var color = s ? [0,1,0] : [0,0,0];
#	var txt = s ? "Success!" : "Mission failed";
#	window.set("tf/t[0]", _scr_x() / 2 - w / 2);
#	window.set("tf/t[1]", _scr_y() / 5);
#	myText.setText(txt).setColor(color);
#	window.setFocus();
#	window.show();
#}
var draw_message = func (s = 1) {
    var txt = s ? "Mission completed!" : "Mission failed";
    var icon = s ? "info" : "error";
    mission.show_msgbox(txt, icon);
}

mission.extension_add("Handler", {
	init: func {
		me.listeners = [
			setlistener(me.node.getNode("goal-state-changed", 1), func me.update()),
		];
	},

	node: props.getNode("/sim/mission/goals", 1),

	update: func {
		if (state_changed) return;
		state_changed = 1;
		settimer(func me.check_goals(), 0);
	},

	check_goals: func {
		var failed = 0;
		var completed = 0;
		var goals = me.node.getChildren("goal");
		foreach (var g; goals)
			if ((var state = g.getValue("goal-state")) == "failed")
				failed += 1;
			elsif (state == "completed")
				completed += 1;
		if (failed)
			draw_message(0);
		elsif (completed == size(goals))
			draw_message(1);
		state_changed = 0;
	},

	stop: func {
		foreach(var l; me.listeners)
			removelistener(l);
		setsize(me.listeners, 0);
		me.node.remove();
		call(canvas.Window.del, [], window);
	},
});
