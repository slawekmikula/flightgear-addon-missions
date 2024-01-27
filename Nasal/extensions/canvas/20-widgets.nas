var widgets = {};


var busy = 0;

var sounds = {
    "click": ["click.wav", 0.2, 0.0],
    "click2": ["appear-online.wav", 1.0, 0.3],
    "click4": ["click4.wav", 0.25, 0.18],
};


var ui_sound = func (snd)
{
    !busy or return;
    busy = 1;
    mission.play_sound(sounds[snd][0], sounds[snd][1]);
    settimer(func busy = 0, sounds[snd][2]);
}


widgets.Label =
{

new: func(root, data, cfg = nil)
{
    var m = {parents: [widgets.Label, Config.new(), tmp.new()]};
    m.data = data;
    m.root = root.createChild("group");
    m.text = m.root.createChild("text");
    m.cfg = {};
    m.bb = [,,,,];
    m._size = [,,];
    m._clickable = 0;

    if (cfg == nil) cfg = {};

    var c = canvas.Config.new(cfg);
    var default = {
        color: "#ffffff",
        strokeColor: "#ffffff",
        mouseoverColor: "#ffffff",
        font: "LiberationFonts/LiberationSans-Regular.ttf",
        fontSize: 22,
        datumPoint: [0.5, 0.5],
        text: "Label",
        movement: [0, 0],
        rotation: 0,
        clickable: 0,
        clickedFunc: func,
        clickArea: [0.05, 0.05],
        clickAreaDatumPoint: [0.5, 0.5],
        debug: 0,
    };

    foreach(var k; keys(default))
        m.cfg[k] = c.get(k, default[k]);

    if (m.cfg.clickable) {
        var w = m.data.width  * m.cfg.clickArea[0];
        var h = m.data.height * m.cfg.clickArea[1];

        m.click_area = canvas.draw.rectangle( m.root, w, h,
                                             -w * m.cfg.clickAreaDatumPoint[0],
                                             -h * m.cfg.clickAreaDatumPoint[1] );

        if (m.cfg.debug)
            m.click_area.setColor("#ff0000");

        m.click_area.addEventListener("click",
            func ()
            {
                call(m.cfg.clickedFunc, []);
                mission.ui_sound("click2");
            }
        );

        m.click_area.addEventListener("mouseover",
            func ()
            {
                m.text.setColor(m.cfg.mouseoverColor);
                mission.ui_sound("click");
            }
        );

        m.click_area.addEventListener("mouseout",
            func ()
            {
                m.text.setColor(m.cfg.color);
            }
        );
    }

    return m.redraw();
}, # Label.new


redraw: func
{
    me.text.setText(me.cfg.text)
           .setFont(me.cfg.font)
           .setColor(me.cfg.color)
           .setAlignment("center-center")
           .setFontSize(me.cfg.fontSize);
    me.root.setRotation(me.cfg.rotation * D2R);
    me._updateBB();

    return me;
},


show: func ()
{
    me.root.show();
},


hide: func ()
{
    me.root.hide();
},


move: func(xr, yr)
{
    me.root.setTranslation( me.data.width * xr,
                            me.data.height * yr );

    me.text.setTranslation( -me.bb[0] - me._size[0] * me.cfg.datumPoint[0],
                            -me.bb[1] - me._size[1] * me.cfg.datumPoint[1] );

    me.cfg.movement[0] = xr;
    me.cfg.movement[1] = yr;

    return me;
},


setTranslation: func(x, y)
{
    me.text.setTranslation(x, y);
    return me;
},


_updateBB: func ()
{
    me.bb = me.text.getBoundingBox();

    me._size[0] = me.bb[2] - me.bb[0];
    me._size[1] = me.bb[3] - me.bb[1];

    me.move(me.cfg.movement[0], me.cfg.movement[1]);
},

}; # widgets.Label



widgets.scrollArea =
{

new: func (group, data, cfg = nil)
{
    var m = {parents: [widgets.scrollArea, Config.new(), tmp.new()]};

    m.root = group.createChild("group");
    m.data = data;
    m.translation = [0, 0];
    m.d = {};
    m.cfg = {};
    m.item_count = 0;
    m._id = [0, nil]; # first/last visible item id

    if (cfg == nil)
        cfg = {};

    var c = canvas.Config.new(cfg);
    var default = {
        movement:         [0, 0],
        datumPoint:       [0, 0],
        scrollArea:       [0.9, 0.9],
        scrollUpButton:   nil,
        scrollDownButton: nil,
        items:            [],
        movement:         [0, 0],
        debug:            0,
    };
    foreach(var k; keys(default)) m.cfg[k] = c.get(k, default[k]);

    m.d.width  = m.data.width  * m.cfg.scrollArea[0];
    m.d.height = m.data.height * m.cfg.scrollArea[1];

    m.translation[0] =  m.data.width * m.cfg.movement[0]
                      - m.d.width * m.cfg.datumPoint[0];
    m.translation[1] =  m.data.height * m.cfg.movement[1]
                      - m.d.width * m.cfg.datumPoint[1];

    m._scroll_fn = func (d = 0)
    {
        if (m.item_count < 1) return;
        (d < 1) ? m.scrollUp() : m.scrollDown();
    };

    if (m.cfg.scrollUpButton != nil)
        m.cfg.scrollUpButton.customize({
            clickedFunc: func call(m._scroll_fn, [0]),
        });

    if (m.cfg.scrollDownButton != nil)
        m.cfg.scrollDownButton.customize({
            clickedFunc: func call(m._scroll_fn, [1]),
        });

    if (m.cfg.debug)
        m.frame = canvas.draw.rectangle(
            m.root,
            m.d.width, m.d.height,
            m.translation[0], m.translation[1]
        ).setColor("#ff0000");

    m.redraw();

    return m;
}, # scrollArea.new

update: func ()
{
    me._id[0] = 0;
    me._id[1] = nil;
    me.show_button(me.cfg.scrollDownButton);
    me.show_button(me.cfg.scrollUpButton);
    me.redraw();
},

redraw: func ()
{
    me.item_count = size(me.cfg.items);

    foreach(var item; me.cfg.items) {
        item.data = me.d;
        item.customize({movement: [0, 0]});
    }

    var a = 0;
    if (me._id[1] == nil) {
        for(var i = me._id[0]; i < me.item_count; i += 1) {
            var item = me.cfg.items[i];
            a += item.height;
            if (a <= me.d.height)
                me._id[1] = i;
        }
    } elsif (me._id[0] == nil) {
        for (var i = me._id[1]; i > 0; i -= 1) {
            var item = me.cfg.items[i];
            a += item.height;
            if (a <= me.d.height)
                me._id[0] = i;
        }
    }
    a = 0;

    if (me._id[0] == 0)
        me.show_button(me.cfg.scrollUpButton, 0);
    if (me._id[1] == (me.item_count - 1))
        me.show_button(me.cfg.scrollDownButton, 0);

    for(var i = 0; i < me.item_count; i += 1) {
        var item = me.cfg.items[i];
        if ( (i < me._id[0]) or (i > me._id[1]) ) {
            item.hide();
            continue;
        } else {
            item.setTranslation(me.translation[0],
                                me.translation[1] + a)
                .show();
        }
        a += item.height;
    }

}, # redraw

scrollDown: func ()
{
    me.show_button(me.cfg.scrollUpButton);
    me._id[0] = nil;
    me._id[1] += 1;
    if (me._id[1] > (me.item_count - 1))
        me._id[1] = me.item_count - 1; # revise
    me.redraw();
},

scrollUp: func ()
{
    me.show_button(me.cfg.scrollDownButton);
    me._id[0] -= 1;
    me._id[1] = nil;
    if (me._id[0] < 0)
        me._id[0] = 0;
    me.redraw();
},

show_button: func (b, show = 1)
{ # fix: move to common functions
    if (b == nil)
        return;
    if (show < 1)
        b.hide();
    else
        b.show();
},

}; # scroll area