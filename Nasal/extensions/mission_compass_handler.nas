var x_size = getprop("/sim/startup/xsize"); # revise: update globally
var y_size = getprop("/sim/startup/ysize");


mission.extension_add("Handler", {
	init: func {
		me.timer = maketimer(0.1, func me._loop());
		me.timer.start();
		me.toggle_timer = maketimer(1, func me.toggle_compass());
		#me.toggle_timer.start();

		var w = 0.078 * x_size; #130;
		var h = 1.4*w; #1.22*w;
        var m = w/20;
        var window_color = "#282c34aa";
		var bg_color = [0.2, 0.4, 0.7, 0.8];
		var line_color = [1, 1, 1, 0.75];

		me.window = canvas.Window.new([w,h]);
		me.window.set("visible", 0);
		me.canvas = me.window.createCanvas();
		me.canvas.setColorBackground(0,0,0,0);
		foreach (var k; ["bg", "Table", "Compass", "Pointer", "Aircraft"])
			me[k] = me.canvas.createGroup();


        var bg_cfg = {
            "border-top-radius":    w/10,
            "border-bottom-radius": w/10,
        };

        me.bg.createChild("path")
          .rect(1, 1, w-2, h-2, bg_cfg)
          .setColor("#282c34ff")
          .setColorFill(window_color)
          .setStrokeLineWidth(1);




		var cw = 0.7 * w; #compass width (diameter)
		me.Compass.createChild("path")
			.moveTo(-cw/2, -cw/2 * 0)
			.arcSmallCWTo(cw/2, cw/2, 0, cw/2, 0)
			.arcSmallCWTo(cw/2, cw/2, 0, -cw/2, 0)
			.close()
			.setColor(line_color)
			.setColorFill(bg_color)
			.setStrokeLineWidth(1);


		for (var i = 0; i < 8; i += 1)
			me.Compass.createChild("path")
				.moveTo(0, -cw/2*0.95)
				.lineTo(0, -cw/2 * 0.85)
				.setColor("#ffffffff")
                .set("blend-source-alpha", "one")
                #.set("blend-destination-alpha", "zero")
				.setStrokeLineWidth(2)
				.setRotation(i * 45 * D2R);

		var font_size = 0.15 * cw;
		#forindex (var i; var v = ["N", "•", "E", "•", "S", "•", "W", "•"]) {
        forindex (var i; var v = ["N", "", "E", "", "S", "", "W", ""]) {#FIX
			var a = i * 45 * D2R;
			var r = -cw / 2 * 0.7;
			me.Compass.createChild("text")
				.setTranslation(-math.sin(a) * r, math.cos(a) * r)
				.setText(v[i])
				.setAlignment("center-top")
				.setFontSize(font_size * 1.0)
                #.set('stroke',  'rgb(0,0,0)')
				.setFont("LiberationFonts/LiberationSans-Bold.ttf")
                .set("blend-source-alpha", "one")
				.setColor(1,1,1)
				.setRotation(i * 45 * D2R);
		}
		me.Compass.setTranslation(w/2, h/2);

		var arrow_size = 0.12 * cw;
		var arrow_width = 0.15 * cw;
		var r = -cw/2 * 0.95;
		me.Pointer.createChild("text")
   				.setTranslation(0, r - arrow_size)
				.setText("") #.setText("ˆ")
				.setAlignment("center-center")
				.setFontSize(arrow_size * 2.5)
                #.set('stroke',  'rgb(0,0,0)')
                .set("blend-source-alpha", "one")
				.setFont("mononokiBoldItalic.ttf")
				.setColor(1,1,0,0.9)
				.setRotation(0 * D2R);
		me.Pointer.setTranslation(w/2, h/2);

		me.Aircraft.createChild("text")
			.setText("") #.setText("↑")
			.setAlignment("center-center")
			.setFontSize(font_size * 2.)
            #.set('stroke',  'rgb(0,0,0)')
            .set("blend-source-alpha", "one")
			.setFont("mononokiBoldItalic.ttf")
			.setColor(line_color)
			.setRotation(0 * D2R);
		me.Aircraft.setTranslation(w/2, h/2);

		var th = 0.45 * cw;
		var x_left = 0.05 * w;
		var x_right = w - x_left;
		var y_top = h - th - x_left;
		var y_bottom = h - x_left;

        #var m = 1;
        var row_h = 0.21 * cw;
        var row_spacing = row_h * 0.4;
        var row_w = (w - row_spacing - 2 * m) / 2;


        var x1 = m;
        var x2 = m + row_w + row_spacing;
        var y1 = m; #h - 2 * row_h - row_spacing - m;
        var y2 = h - row_h - m; #y1 + row_h + row_spacing;



        var table_cfg = {
            "border-top-radius":    row_h/2.5,
            "border-bottom-radius": row_h/2.5,
        };


		me.Table.createChild("path")
          .rect(x1, y1, row_w, row_h, table_cfg)
          .setColor(line_color)
          .setColorFill(bg_color)
          .set("blend-source-alpha", "one")
          .setStrokeLineWidth(1).hide();

		me.Table.createChild("path")
          .rect(x2, y1, row_w, row_h, table_cfg)
          .setColor(line_color)
          .setColorFill(bg_color)
          .set("blend-source-alpha", "one")
          .setStrokeLineWidth(1).hide();

		me.Table.createChild("path")
          .rect(x1, y2, w - 2*m, row_h, table_cfg)
          .setColor(line_color)
          .setColorFill(bg_color)
          .set("blend-source-alpha", "one")
          .setStrokeLineWidth(1);


		me.Table.createChild("path")
          .rect(x1, y1+row_h+row_spacing, w - 2*m, y2-row_h-2*row_spacing-m, table_cfg)
          .setColor(line_color)
          .setColorFill(bg_color)
          .set("blend-source-alpha", "one")
          .setStrokeLineWidth(1).hide();


		var font_size = 0.7 * row_h;
		var _step = (x_right - x_left)/4;
		me.Dist = me.Table.createChild("text")
			.setTranslation(m + row_w/2, y1 + row_h/2)
			.setText("...")
			.setAlignment("center-center")
			.setFontSize(font_size)
            .set('stroke',  'rgb(0,0,0)')
            .set("blend-source-alpha", "one")
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(1,1,1);

		me.Alt = me.Table.createChild("text")
			.setTranslation(x1 + 1.5*row_w + row_spacing, y1 + row_h/2)
			.setText("...")
			.setAlignment("center-center")
			.setFontSize(font_size)
            .set('stroke',  'rgb(0,0,0)')
            .set("blend-source-alpha", "one")
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
			.setColor(1,1,1);

		me.Name = me.Table.createChild("text")
			.setTranslation(w/2, y2 + row_h/2)
			.setText("...")
			.setAlignment("center-center")
			.setFontSize(0.7 * row_h)
            #.set('stroke',  'rgb(0,0,0)')
            .set("blend-source-alpha", "one")
			.setFont("LiberationFonts/LiberationSans-Bold.ttf")
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
            #me.window.clearFocus();
		}

		me.hide_compass = func {
			if (!me.node.getValue("hide-compass"))
				return;
			#me.timer.stop();
			me.window.set("visible", me._visible = 0);
			me.node.setValue("hide-compass", 0);
			compass_visible(0);
            #me.window.clearFocus();
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