#
# Usage:
#
#	<object>
#		<name>...</name>
#		<type>menu-prompt-trigger</type>
#		<activated>...</activated>
#		<text>...</text>
#		<menu-item>
#			<text>...</text>
#			<actions>...</actions>
#		</menu-item>
#		<menu-item>...</menu-item>
#	</object>
#

var w          = 450;
var h          = 200;
var bg_color   = [0.2, 0.4, 0.7, 0.5];
var line_color = [1, 1, 1, 0.8];
var txt_h      = h / 10;
var txt2_h     = txt_h * 0.8;
var font       = "LiberationFonts/LiberationSans-Bold.ttf";
var offset     = 5;
var th         = h - offset * 2;     # table height
var x_left     = offset;             # table corners
var x_right    = w - x_left;         #
var y_top      = x_left;             #
var y_bottom   = th + x_left;        # /table corners
var margin     = 10;

var menu_item = {
	new: func(group, x, y, txt, actions, p) {
		var m = {
			parents : [menu_item, p],
			text    : txt,
			actions : actions,
		};

		m.item = group.createChild("text")
			.setTranslation(x, y)
			.setText(txt)
			.setAlignment("left-center")
			.setFontSize(txt_h * 0.8)
			.setFont(font)
			.setColor(1,1,1,1);
		m.item.set("blend-source-alpha", "one");
		m.item.set("blend-destination-alpha", "zero");
		m.item.addEventListener("click", func m.action());

		return m;
	},

	action: func {
		#print(me.text);
		mission.activate_object_group(me.actions);
		me.stop();
	},
};


var menu_prompt_trigger = {
	type: "menu-prompt-trigger",

	new: func(n) {
		var m = {
			parents     : [menu_prompt_trigger],
			name        : n.getValue("name"),
			_activated  : mission.get(n, "activated", 0),
			_text       : mission.get(n, "text", ""),
			_items      : n.getChildren("menu-item"),
			_references : n.getNode("actions"),
		};

		m._window = canvas.Window.new([w,h]);

		m._window.set("tf/t[0]", mission.scr_x() / 2 - w / 2);
		m._window.set("tf/t[1]", mission.scr_y() / 2 - h / 2);
		m._window.set("visible", 0);

		m._canvas = m._window.createCanvas();
		m._canvas.setColorBackground(0,0,0,0);

		m._MsgBox = m._canvas.createGroup();

		m._MsgBox.createChild("path")
			.moveTo(x_left, y_top)
			.horizTo(x_right)
			.vertTo(y_bottom)
			.horizTo(x_left)
			.close()
			.setColor(line_color)
			.setColorFill(bg_color)
			.setStrokeLineWidth(2);

		m._txt1 = m._MsgBox.createChild("text")
			.setTranslation(margin, txt_h * 1.5) #revise
			.setText(m._text)
			.setAlignment("left-center")
			.setFontSize(txt_h)
			.setFont(font)
			.setColor(1,1,1,1);
		m._txt1.set("blend-source-alpha", "one");
		m._txt1.set("blend-destination-alpha", "zero");

		for (var i = 0; i < size(m._items); i += 1) {
			var x = margin * 2;
			var y = txt_h * 3.5 + i * txt2_h * 1.5;
			var txt = i + 1 ~ " - " ~ mission.get(m._items[i], "text", "");
			menu_item.new(m._MsgBox, x, y, txt, m._items[i].getNode("actions"), m);
		}


		return m;
	},

	init: func if (me._activated) me.start(),

	start: func {
		me._window.set("visible", 1);
		me._window.setFocus();
	},

	stop: func {
		me._window.set("visible", 0);
		#me._window.setFocus();
	},

	del: func me._window.del(),
};

mission.extension_add("MissionObject", menu_prompt_trigger);