
mission.extension_add("Handler", {
	init: func {
		me.timer = maketimer(0.02, func me._loop());

		#me._margin = 5;
		me._offset = 5;

		var w = 200;
		var h = 33;
		var bg_color = [0.2, 0.4, 0.7, 0.9];
		var line_color = [1, 1, 1, 0.8];

		me.window = canvas.Window.new([w,h]);

		me._scr_x = func getprop("/sim/startup/xsize");
		me._scr_y = func getprop("/sim/startup/ysize");

		me.window.set("tf/t[0]", me._scr_x() / 2 - w / 2);
		me.window.set("tf/t[1]", me._scr_y() / 10);
		me.window.set("visible", 0);

		me.canvas = me.window.createCanvas();
		me.canvas.setColorBackground(0,0,0,0);
		me.MsgBox = me.canvas.createGroup();

		var th = h - me._offset * 2;
		var x_left = me._offset;
		var x_right = w - x_left;
		var y_top = x_left;
		var y_bottom = th + x_left;
		me.MsgBox.createChild("path")
			.moveTo(x_left, y_top)
			.horizTo(x_right)
			.vertTo(y_bottom)
			.horizTo(x_left)
			.close()
			.setColor(line_color)
			.setColorFill(bg_color)
			.setStrokeLineWidth(2);

		me.Text = me.MsgBox.createChild("text")
			.setTranslation(w/2, h/2)
			.setText("00:00:00.0")
			.setAlignment("center-center")
			.setFontSize(0.8 * th)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(1,1,1);

		me.elapsed_time = props.getNode("/sim/time/elapsed-sec");

		me.show = func(s) {
			var hours = s / 3600;
			var minutes = int(math.mod(s / 60, 60));
			var seconds = int(math.mod(s, 60));
			var msec = int(math.mod(s * 1000, 1000) / 100);
			var d = sprintf("%02d:%02d:%02d.%0d", hours, minutes, seconds, msec);
			me.Text.setText(d);
		}

		me._loop = func me.show(__mission.timer.current_time); #(me.elapsed_time.getValue() - me.start_time);

		me.listeners = [
			setlistener(me.node.getNode("start-timer", 1), func me.start_timer()),
			setlistener(me.node.getNode("stop-timer",  1), func me.stop_timer()),
		];

		me.start_timer = func {
			if (!me.node.getValue("start-timer"))
				return;
			me.start_time = me.elapsed_time.getValue();
			me.timer.start();
			me.window.set("visible", 1);
			me.node.setValue("start-timer", 0);
		}

		me.stop_timer = func {
			if (!me.node.getValue("stop-timer"))
				return;
			me.timer.stop();
			me.window.set("visible", 0);
			me.node.setValue("stop-timer", 0);
		}
		#me.timer.start();
	},

	node: props.getNode("/sim/mission/timer", 1),

	stop: func {
		foreach(var l; me.listeners)
			removelistener(l);
		setsize(me.listeners, 0);

		me.timer.stop();
		me.node.remove();
		me.window.del();
	},
});