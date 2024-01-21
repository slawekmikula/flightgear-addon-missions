print("missionObjective widget");
widgets.missionObjective = {
    new: func(group, data, dataN, cfg = nil) {
        var m = {parents: [widgets.missionObjective, Config.new(), tmp.new() ]};

        m.root = group.createChild("group");
        m.node = dataN;
        m.name = m.node.getValue("name");
        m.data = data;
        m.cfg = {};

        m.optional = m.node.getValue("optional");
        #m._status = m.node.getValue("status");
        m.translation = [0, 0];

        if (cfg == nil) cfg = {};

        var c = canvas.Config.new(cfg);
        var default = {
            font: "LiberationFonts/LiberationSans-Regular.ttf",
            fontSize:              25,
            boxStrokeLineWidth:    2,
            checkStrokeLineWidth:  4,
            cancelStrokeLineWidth: 4,
            pendingTextColor:      "#ffffff",
            canceledTextColor:     "#555555",
            boxColor:              "#ffffff",
            checkColor:            "#00bb00",
            cancelColor:           "#ff0000",
            failedColor:           "#ff0000",
            widthRatio:            1.0,
            movement:              [0, 0],
            showBriefing:          1,
        };

        foreach(var k; keys(default)) m.cfg[k] = c.get(k, default[k]);

        m._h = 20; # checkbox height

        var h = m._h;
        m.symbols = {
            box:    canvas.draw.rectangle(m.root, h, h, 0, 0),
            check:  m.root.createChild("path").moveTo(-h/2, -h/2)
                                              .lineTo(0, 0)
                                              .lineTo(h, -h)
                                              .setTranslation(math.ceil(h/5*2), math.ceil(h/5*3)),

            cancel: canvas.draw.circle(m.root, h/2, 0, 0).moveTo(-h/2, 0)
                                                         .lineTo(h/2, 0)
                                                         .setRotation(-45 * D2R)
                                                         .setTranslation(h/2, h/2),
            failed: m.root.createChild("path"),
        };
        m.text = m.root.createChild("text").setAlignment("left-top");

        m.redraw();

        return m;

    },
    status: func(s = nil) {
        if (s == nil)
            return (me.node.getValue("status"));
        me.node.setValue("status", s);
        me.redraw();
    },

    cancel: func {
        me.text.setColor(me.cfg.canceledTextColor);
        me.symbols.check.hide();
        me.symbols.cancel.show();
    },

    setTranslation: func(x, y) {
        me.translation = [x, y];
        me.root.setTranslation(me.translation[0], me.translation[1]);
        return me;
    },

    pending: func {
        me.symbols.cancel.hide();
        me.symbols.check.hide();
    },

    complete: func {
        me.symbols.cancel.hide();
        me.symbols.check.show();
    },


hide: func ()
{
    me.root.hide();
},


show: func ()
{
    me.root.show();
},


update_status: func ()
{
    var s = me.node.getValue("status");

    if (s == "pending")
        me.pending();
    elsif (s == "canceled")
        me.cancel();
    elsif (s == "completed")
        me.complete();
    elsif (s == "hidden")
        me.hide();
},


    redraw: func {
        me.symbols.box.setColor(me.cfg.boxColor)
                      .setStrokeLineWidth(me.cfg.boxStrokeLineWidth);

        me.symbols.check.setColor(me.cfg.checkColor)
                        .setStrokeLineWidth(me.cfg.checkStrokeLineWidth);

        me.symbols.cancel.setColor(me.cfg.cancelColor)
                         .setStrokeLineWidth(me.cfg.cancelStrokeLineWidth);

        me.text.setMaxWidth(me.data.width * me.cfg.widthRatio - 2 * me._h)
               .setColor(me.cfg.pendingTextColor)
               .setFont(me.cfg.font)
               .setFontSize(me.cfg.fontSize)
               .setTranslation(1.5 * me._h, 0)
               .setText(me.node.getValue(me.cfg.showBriefing ? "briefing" : "text"));
        me.root.setTranslation(me.data.width  * me.cfg.movement[0] + me.translation[0],
                               me.data.height * me.cfg.movement[1] + me.translation[1]);

        me.update_status();

        var h = me.text.getBoundingBox()[3];
        if (h < me._h)
            h = me._h;
        me.height = h + me._h;

        return me;
    },

    del: func me.node = nil, # .remove() ?
};