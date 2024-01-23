var x_size = getprop("/sim/startup/xsize");
var y_size = getprop("/sim/startup/ysize");

var tmp = {
    new: func {
        var m = {parents: [tmp]};

        m.data = {};

        return m;
    },

    spawn: func(type, a1 = nil, a2 = nil, a3 = nil) {

        if (type == "button")
            me._newButton(a1, a2);

        elsif (type == "label")
            me._newLabel(a1);

        elsif (type == "missionObjective")
            me._newMissionObjective(a1, a2);

        elsif (type == "scrollArea")
            me._newScrollArea(a1, a2);

        else return;
    },

};

tmp._newLabel = func(txt = "Label", cfg = nil) {
    if (cfg == nil)
        cfg = {};
    var label = widgets.Label.new(me.root, me.data, txt, cfg);
    me.swallow(label);
    return label;
}

tmp._newButton = func(txt = "Button") {
    var b = widgets.Button.new(me.root, txt);
    me.swallow(b.button);
    return b;
}

tmp._newMissionObjective = func(n, cfg = nil) {
    if (cfg == nil)
        cfg = {};
    var obj = widgets.missionObjective.new(me.root, me.data, n, cfg);
    me.swallow(obj);
    return obj;
};

tmp._newScrollArea = func(cfg = nil) {
    if (cfg == nil)
        cfg = {};
    var scr = widgets.scrollArea.new(me.root, me.data, cfg);
    me.swallow(scr);
    return scr;
}

var layeredDialog = {
    new: func (wr = 0.4, hr = 0.5625) {
        var m = {parents:[layeredDialog, __mission.canvas.Config.new(), tmp.new()]};

        m.data.width = mission.sim.x_size() * wr;
        m.data.height = m.data.width * hr;
        m.layers = [];
        m.visible = nil;
        m._position = [,,];

        m.cfg = {
            bgColor: "#222222",
            datumPoint: [0.5, 0.5],
            widthRatio: wr,
            heightRatio: hr,
        };

        m.window = canvas.Window.new([m.data.width, m.data.height], "dialog");
#        m.window.set("resize", 1);
        m.window.hide();
        m.canvas = m.window.createCanvas();
        m.root = m.canvas.createGroup();

        m.move(0.5, 0.5); # center

        m.window.del = func ()
        {
            m.window.clearFocus();
            m.window.hide();
            m.visible = 0;
        }

        m.redraw(0);

        return m;
    },

    datumPoint: func {
        if (size(arg) < 2) return (me.cfg.datumPoint);
        me.cfg.datumPoint = [arg[0], arg[1]];
        me.move(me._position[0], me._position[1]);
        return me;
    },

    newLayer: func(cfg = nil) {
        var l = dialogLayer.new(me.canvas, me.data, cfg);
        append(me.layers, l);
        return l;
    },

    show: func(n = nil) {
        if (n != nil) {
            foreach(var l; me.layers)
                if (l.name == n) {
                    me.window.set("title", n);
                    l.show();
                } else l.hide();
        }

        me.window.show();
        me.window.setFocus();
        me.visible = 1;
    },

    move: func(xr, yr) {
        me.window.set("tf/t[0]", x_size * xr - me.data.width * me.cfg.datumPoint[0]);
        me.window.set("tf/t[1]", y_size * yr - me.data.height * me.cfg.datumPoint[1]);
        me._position = [xr, yr];
    },

    redraw: func(l = 1) {
        var f = [
            func me.canvas.set("background", me.cfg.bgColor),
            func {  # revise
                me.window.set("content-size[0]", me.data.width = me.cfg.widthRatio * 1920);
                me.window.set("content-size[1]", me.data.height = me.cfg.heightRatio * 1080); print("resizing window");
            },
        ];
        if ( l > (var s = size(f)) )
            l = s;
        for(var i = 0; i <= l; i += 1)
            f[i]();

        foreach(var l; me.layers)
            l.redraw();
        return me;
    },

    hide: func {
        me.window.hide();
    },

    del: func call(canvas.Window.del, [], me.window);

};

var dialogLayer = {
    new: func(c, d, cfg = nil) {
        var m = {parents: [dialogLayer, tmp.new(), Config.new()]};
        m.root = c.createGroup();
        m.data = d;
        m.d = d;
        m.data.root_layout = 1;
        m.name = "";
        m.cfg = {};
        m.img = m.root.createChild("image").setSize(m.data.width, m.data.height);

        if (cfg == nil) cfg = {};

        var c = canvas.Config.new(cfg);

        var default = {
            bgColor: "#222222",
            name: "Dialog Layer",
            bgImage: nil,
        };

        foreach(var k; keys(default)) m.cfg[k] = c.get(k, default[k]);

        m._el = [];
        m.redraw();
        return m;
    },

    swallow: func(el) {
        append(me._el, el);
        return me;
    },

    show: func {
#        me.root.getCanvas().setLayout(me.layout);
        me.root.show();
    },

    hide: func me.root.hide(),

    redraw: func {
        #var s = me.cfg;
        foreach(var e; me._el)
            e.redraw();
        #####
        me.name = me.cfg.name;
        if (me.cfg.bgImage != nil)
            me.img.setFile(me.cfg.bgImage);
        ####

    },

};
