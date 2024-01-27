#
# Usage:
#
#   <object>
#       <name>...</name>
#       <type>menu-prompt-trigger</type>
#       <activated>...</activated>
#       <text>...</text>
#       <menu-item>
#           <text>...</text>
#           <actions>...</actions>
#       </menu-item>
#       <menu-item>...</menu-item>
#   </object>
#

var w          = mission.scale(450, "w");
var h          = mission.scale(200, "h");
var bg_color   = [0.2, 0.4, 0.7, 0.7];
var line_color = [1, 1, 1, 0.8];
var txt_h      = h / 10;
var txt2_h     = txt_h * 0.8;
var font       = "LiberationFonts/LiberationSans-Bold.ttf";
var offset     = h / 40;
var th         = h - offset * 2;     # table height
var x_left     = offset;             # table corners
var x_right    = w - x_left;         #
var y_top      = x_left;             #
var y_bottom   = th + x_left;        # /table corners
var margin     = h / 20;

var window_color = "#282c34aa";

var bg_cfg = {
    "border-top-radius":    w/40,
    "border-bottom-radius": w/40,
};

var hl_cfg = {
    "border-top-radius":    w/50,
    "border-bottom-radius": w/50,
};




var menu_item =
{

new: func (group, x, y, txt, actions, p)
{
    var m = {
        parents : [menu_item, p],
        text    : txt,
        actions : actions,
    };

    m._hl = group.createChild("path")
        .rect(0, -0.5 * txt_h, w - txt_h, txt_h )
        .setColorFill(bg_color)
        .set("blend-source-alpha", "one")
        .setTranslation(txt_h/2, y).hide();

    m.item = group.createChild("text")
        .setTranslation(x, y)
        .setText(txt)
        .setAlignment("left-center")
        .setFontSize(txt_h * 0.8)
        .setFont(font)
        .setColor(1,1,1,1);
    m.item.set("blend-source-alpha", "one");
    #m.item.set("blend-destination-alpha", "zero");

    m._area = group.createChild("path")
        .rect(0, -0.5 * txt_h, w, txt_h )
        #.setColor("red")
        .setTranslation(0, y);


    m._area.addEventListener("click",     func m.action() );
    m._area.addEventListener("mouseover", func m.highlight() );
    m._area.addEventListener("mouseout",  func m.highlight(0) );

    return m;
},


action: func ()
{
    #print(me.text);
    mission.activate_object_group(me.actions);
    mission.ui_sound("click2");
    me.stop();
},


highlight: func (hl = 1)
{
    if (hl > 0) {
        me.item.setColor("#ffff00");
        me._hl.show();
        mission.ui_sound("click");
    } else {
        me.item.setColor("#ffffff");
        me._hl.hide();
    }
},

}; # menu_item


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
            .rect(1, 1, w-2, h-2, bg_cfg)
            .setColor("#282c34ff")
            .setColorFill(window_color)
            .setStrokeLineWidth(1);

        m._txt1 = m._MsgBox.createChild("text")
            .setTranslation(margin, txt_h * 1.5) #revise
            .setText(m._text)
            .setAlignment("left-center")
            .set("blend-source-alpha", "one")
            #.set('stroke',  'rgb(0,0,0)')
            .setFontSize(txt_h)
            .setFont(font)
            .setColor(1,1,1,1);

        #m._txt1.set("blend-destination-alpha", "zero");

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