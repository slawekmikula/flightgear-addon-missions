
var play_sound = nil;
var show_message = nil;

mission.addExtension("Handler", {
	init: func {
		#me.DELAY = 4;
		me.timer = maketimer(0, func me._hide_msg());
		me.timer.singleShot = 1;

		me._margin = 5;
		me._offset = 5;

		var w = 300;
		var h = 400;
		var bg_color = [0.1, 0.1, 0.1, 0.8];
		var line_color = [1, 1, 1, 0.8];

		me.window = canvas.Window.new([w,h]);

		me._scr_x = func getprop("/sim/startup/xsize");
		me._scr_y = func getprop("/sim/startup/ysize");

		me.window.set("tf/t[0]", 0);
		me.window.set("tf/t[1]", me._scr_y() / 2);

		me.canvas = me.window.createCanvas();
		me.canvas.setColorBackground(0,0,0,0);
		me.MsgBox = me.canvas.createGroup();

		var th = 30;
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
			.setColor(bg_color)
			.setColorFill(bg_color)
			.setStrokeLineWidth(1);

		me.Text = me.MsgBox.createChild("text")
			.setTranslation(me._margin + me._offset, me._margin + me._offset)
			.setText("Message box")
			.setAlignment("left-top")
			.setFontSize(14)
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setMaxWidth(w - 2 * (me._margin + me._offset))
			.setColor(1,1,1);


		me.listeners = [
			setlistener("/sim/mission/message/show-message", func me.show_message()),
		];

		me.show_message = func {
			if (!getprop("/sim/mission/message/show-message"))
				return;
			me._update_msg_box(getprop("/sim/mission/message/current-message"));
			me.window.set("visible", 1);
			me.timer.restart(getprop("/sim/mission/message/message-delay"));
			setprop("/sim/mission/message/show-message", 0);
		};

		me.timer.start();

		me._update_msg_box = func (txt) {
			#me.window.set("visible", 0);

			var text_bb = me.Text.setText(txt).update().getBoundingBox();
			var width = text_bb[2];
			var height = text_bb[3];
			me.MsgBox.set("path/coord[3]", height + me._offset + 2 * me._margin);
		};

	},

	node: props.getNode("/sim/mission/message", 1),

	_hide_msg: func {
		me.window.set("visible", 0);
	},

	stop: func {
		foreach(var l; me.listeners)
			removelistener(l);
		setsize(me.listeners, 0);

		me.timer.stop();
		me.node.remove();
		me.window.del();
	},
});