

mission.extension_add("Handler", {
	init: func {
		me.timer = maketimer(0.1, func me._loop());
		me.timer.start();
		me.toggle_timer = maketimer(1, func me.toggle_compass());
		#me.toggle_timer.start();

		var w = 130;
		var h = 1.22*w;
		var bg_color = [0.2, 0.4, 0.7, 0.9];
		var line_color = [1, 1, 1, 0.8];

		me.window = canvas.Window.new([w,h]);
		me.window.set("visible", 0);
		me.canvas = me.window.createCanvas();
		me.canvas.setColorBackground(0,0,0,0);
		foreach (var k; ["Compass", "Pointer", "Aircraft", "Table"])
			me[k] = me.canvas.createGroup();
		#me.AircraftSVG = me.canvas.createGroup();
		#canvas.parsesvg(me.AircraftSVG, "Nasal/mission/drawing.svg");
		#me.AircraftSVG.setScale(1);

		var cw = 0.6 * w; #compass width (diameter)
		me.Compass.createChild("path")
			.moveTo(-cw/2, -cw/2 * 0)
			.arcSmallCWTo(cw/2, cw/2, 0, cw/2, 0)
			.arcSmallCWTo(cw/2, cw/2, 0, -cw/2, 0)
			.close()
			.setColor(line_color)
			.setColorFill(bg_color)
			.setStrokeLineWidth(2);

		for (var i = 0; i < 8; i += 1)
			me.Compass.createChild("path")
				.moveTo(0, -cw/2*0.95)
				.lineTo(0, -cw/2 * 0.8)
				.setColor(line_color)
				.setStrokeLineWidth(2)
				.setRotation(i * 45 * D2R);

		var font_size = 0.15 * cw;
		forindex (var i; var v = ["N", "E", "S", "W"]) {
			var a = i * 90 * D2R;
			var r = -cw / 2 * 0.7;
			me.Compass.createChild("text")
				.setTranslation(-math.sin(a) * r, math.cos(a) * r)
				.setText(v[i])
				.setAlignment("center-top")
				.setFontSize(font_size)
				.setFont("LiberationFonts/LiberationSans-Bold.ttf")
				.setColor(1,1,1)
				.setRotation(i * 90 * D2R);
		}
		me.Compass.setTranslation(w/2, w/2);

		var arrow_size = 0.12 * cw;
		var arrow_width = 0.15 * cw;
		var r = -cw/2 * 1.025;
		me.Pointer.createChild("path")
			.moveTo(0, r - arrow_size)
			.lineTo(arrow_width/2, r)
			.lineTo(-arrow_width/2, r)
			.close()
			.setColor(0,1,0,0.8)
			.setColorFill(1,1,0,0.98)
			.setStrokeLineWidth(0);
		me.Pointer.setTranslation(w/2, w/2);

		var fuselage_length = cw*0.38;
		var fuselage_width = 0.15 * fuselage_length;
		var wing_span = cw*0.35;
		var wing_chord = [0.37 * fuselage_length, 0.12 * fuselage_length];
		var wing_chord_dist = [0.3 * fuselage_length, 0.6 * fuselage_length];
		var tail_span = 0.5 * wing_span;
		var tail_chord = [0.18 * fuselage_length, 0.07 * fuselage_length];
		me.Aircraft.createChild("path")
			.moveTo(0, -fuselage_length/2)
			.lineTo(fuselage_width/2, -fuselage_length/2 + fuselage_width/2)
			.lineTo(fuselage_width/2, -fuselage_length/2 + wing_chord_dist[0])
			.lineTo(wing_span/2, -fuselage_length/2 + wing_chord_dist[1])
			.lineTo(wing_span/2, -fuselage_length/2 + wing_chord_dist[1] + wing_chord[1])
			.lineTo(fuselage_width/2, -fuselage_length/2 + wing_chord_dist[0] + wing_chord[0])
			.lineTo(fuselage_width/2, fuselage_length/2 - tail_chord[0])
			.lineTo(tail_span/2, fuselage_length/2 - tail_chord[1])
			.lineTo(tail_span/2, fuselage_length/2)  #
			.lineTo(-tail_span/2, fuselage_length/2) #
			.lineTo(-tail_span/2, fuselage_length/2 - tail_chord[1])
			.lineTo(-fuselage_width/2, fuselage_length/2 - tail_chord[0])
			.lineTo(-fuselage_width/2, -fuselage_length/2 + wing_chord_dist[0] + wing_chord[0])
			.lineTo(-wing_span/2, -fuselage_length/2 + wing_chord_dist[1] + wing_chord[1])
			.lineTo(-wing_span/2, -fuselage_length/2 + wing_chord_dist[1])
			.lineTo(-fuselage_width/2, -fuselage_length/2 + wing_chord_dist[0])
			.lineTo(-fuselage_width/2, -fuselage_length/2 + fuselage_width/2)
			.close()
			.setColor(line_color)
			.setStrokeLineWidth(2);
		me.Aircraft.setTranslation(w/2, w/2);

		var th = 0.45 * cw;
		var x_left = 0.05 * w;
		var x_right = w - x_left;
		var y_top = h - th - x_left;
		var y_bottom = h - x_left;
		me.Table.createChild("path")
			.moveTo(x_left, y_top)
			.horizTo(x_right)
			.vertTo(y_bottom)
			.horizTo(x_left)
			.close()
			.moveTo(x_left, y_bottom - th/2)
			.horizTo(x_right)
			#.moveTo((x_right - x_left)/2 + x_left, y_bottom - th/2)
			#.vertTo(y_top)
			.setColor(line_color)
			.setColorFill(bg_color)
			.setStrokeLineWidth(2);
		me.Pointer.setTranslation(w/2, w/2);

		var font_size = 0.7 * th/2;
		var _step = (x_right - x_left)/4;
		me.Dist = me.Table.createChild("text")
			.setTranslation(_step + x_left, y_top + th/4)
			.setText("...")
			.setAlignment("center-center")
			.setFontSize(font_size)
			.setFont("LiberationFonts/LiberationSans-Regular.ttf")
			.setColor(1,1,1);

		me.Alt = me.Table.createChild("text")
			.setTranslation(_step*3 + x_left, y_top + th/4)
			.setText("...")
			.setAlignment("center-center")
			.setFontSize(font_size)
			.setFont("LiberationFonts/LiberationSans-Regular.ttf")
			.setColor(1,1,1);

		me.Name = me.Table.createChild("text")
			.setTranslation((x_right - x_left)/2 + x_left, y_bottom - th/4)
			.setText("...")
			.setAlignment("center-center")
			.setFontSize(font_size)
			.setFont("LiberationFonts/LiberationSans-Regular.ttf")
			.setColor(1,1,1);

		# Draw arrows
		var offset = th/7;

		me.Arrow_L = me.Table.createChild("path")
			.moveTo(x_left + offset, y_bottom - th/4)
			.lineTo(x_left + th/2 * 0.6, y_bottom - offset)
			.vertTo(y_bottom - th/2 + offset)
			.close()
			.setColorFill(1,1,1,0.8)
			.setColor(1,1,1,0.8);
		me.Arrow_L.addEventListener("click", func setprop("/sim/mission/point-of-interest/signals/prev-POI", 1));

		me.Arrow_R = me.Table.createChild("path")
			.moveTo(x_right - offset, y_bottom - th/4)
			.lineTo(x_right - th/2 * 0.6, y_bottom - offset)
			.vertTo(y_bottom - th/2 + offset)
			.close()
			.setColorFill(1,1,1,0.8)
			.setColor(1,1,1,0.8);
		me.Arrow_R.addEventListener("click", func setprop("/sim/mission/point-of-interest/signals/next-POI", 1));


		me.listeners = [
			setlistener("/sim/mission/point-of-interest/POI-count", func me.toggle_compass()),
			setlistener("/sim/mission/point-of-interest/target-name", func me._update_name()),
			setlistener("/sim/mission/point-of-interest/altitude-m", func me._update_alt()),
			setlistener("/sim/menubar/visibility", func me._update_visibility()),
			setlistener(me.node.getNode("show-compass", 1), func me.show_compass()),
			setlistener(me.node.getNode("hide-compass", 1), func me.hide_compass()),
		];

		me._update_name = func me.Name.setText(__mission.POI.name);

		me._update_alt = func me.Alt.setText(int(__mission.POI.alt * M2FT) ~ " ft");

		me._update_visibility = func {
			if (!me._visible)
				return;
			if (getprop("/sim/menubar/visibility"))
				me.window.set("visible", 0); #me.window.hide();
			else me.window.set("visible", 1); #me.window.show();
		}

		me._visible = 0;

		me.show_compass = func {
			if (!me.node.getValue("show-compass"))
				return;
			#me.timer.start();
			me.window.set("visible", me._visible = 1);
			me.node.setValue("show-compass", 0);
			compass_visible(1);
		}

		me.hide_compass = func {
			if (!me.node.getValue("hide-compass"))
				return;
			#me.timer.stop();
			me.window.set("visible", me._visible = 0);
			me.node.setValue("hide-compass", 0);
			compass_visible(0);
		}

		me.show_arrows = func(show = 1) {
			if (show) {
				me.Arrow_L.show();
				me.Arrow_R.show();
			} else {
				me.Arrow_L.hide();
				me.Arrow_R.hide();
			}
		}

		me.toggle_compass = func {
			if (__mission.POI.count > 0)
				me.window.set("visible", me._visible = 1);
			else
				me.window.set("visible", me._visible = 0);
			if (__mission.POI.count > 1)
				me.show_arrows();
			else
				me.show_arrows(0);
		}
	},

	node: props.getNode("/sim/mission/compass", 1),

	obj_node: props.getNode("/sim/mission/current-object", 1),

	object_position: func {
		geo.Coord.new().set_latlon(
			getprop("/sim/mission/current-object/latitude-deg") or 0,
			getprop("/sim/mission/current-object/longitude-deg") or 0,
			getprop("/sim/mission/current-object/altitude-m") or 0
		);
	},

	_loop: func {
		var dist = poi_distance();
		me.Compass.setRotation(-getprop("/orientation/heading-deg") * D2R);
		me.Pointer.setRotation( poi_heading() );
		var _i = int(dist);                   #
		var _r = "." ~ int((dist - _i) * 10); #revise!
		me.Dist.setText(_i ~ _r ~ " NM");     #
	},

	stop: func {
		foreach(var l; me.listeners)
			removelistener(l);
		setsize(me.listeners, 0);

		me.timer.stop();
		me.toggle_timer.stop();
		me.node.remove();
		me.window.del();
	},
});

var poi_heading = func {
	(__mission.POI.hdg or 0) * D2R;
	#(getprop("/sim/mission/current-point-of-interest/heading-deg") or 0) * D2R;
}

var poi_distance = func {
	(__mission.POI.dist or 0) / 1852;
	#(getprop("/sim/mission/current-point-of-interest/distance-m") or 0) / 1852;
}

var compass_visible = func (v = 1) setprop("/sim/mission/compass/visible", v > 0 ? 1 : 0);