var x_size = getprop("/sim/startup/xsize"); # revise: update globally
var y_size = getprop("/sim/startup/ysize");


var state_changed = 0;
var initialized   = 0;
var counters = [];
var w = 0.1 * x_size;
var w1 = w/8 * 6;
var h = 0.14 * w;
var bg_color = [0.2, 0.4, 0.7, 0.9];
var line_color = [1, 1, 1, 0.8];


#var text = func (root, cfg)
#{
#    root.createChild("text")
#        .setFont("LiberationFonts/LiberationSans-Regular.ttf")
#        .setFontSize(h*0.6, 1.0)
#        .setColor(1,1,1,1)
#        .setAlignment(cfg.alignment);
#}

var counter =
{

new: func (n)
{
    var m = {
        parents  : [counter],
        node     : n,
        visible  : n.getValue("visible"),
        listener : setlistener( n.getNode("counter-updated", 1),
                                func m.update() ),
    };
    m.root = canvas.getDesktop().createChild("group");
    m.root.setTranslation(x_size - 1.6 * w, 1.6 * h);
    m.root.createChild("path")
          .rect(0, 0, w, h, {"border-top-radius":h/2.5, "border-bottom-radius": h/2.5})
          .setColor(line_color)
          .setColorFill(bg_color)
          .setStrokeLineWidth(1);
    m.root.createChild("path")
          .moveTo(w1, 0)
          .lineTo(w1, h)
          .setColor(line_color)
          .setStrokeLineWidth(2).hide();# remove
    m.label = m.root.createChild("text")
               .setFont("LiberationFonts/LiberationSans-Regular.ttf")
               .setFontSize(h*0.6, 1.0)
               .setColor(1,1,1,1)
               .setAlignment("left-center")
               .setTranslation(w/10, h/2)
               .setText(m.node.getValue("text"));

    m.value = m.root.createChild("text")
               .setFont("LiberationFonts/LiberationSans-Bold.ttf")
               .setFontSize(h*0.6*1.2, 1.0)
               .setColor(1,1,1,1)
               #.set('stroke',  'rgb(0,0,0)')
               .setAlignment("center-center")
               .setTranslation(w/8 * 7, h/2)
               .setText(m.node.getValue("counter"));

    return m;
},


update: func ()
{
    me.value.setText(me.node.getValue("counter"));
},


show: func ()
{
    me.root.show();
},


hide: func ()
{
    me.root.hide();
},


setTranslation: func (x, y)
{
    me.root.setTranslation(x, y);
},


del: func ()
{
    removelistener(me.listener);
    me.root.del();
},

}; #counter


var counter_handler =
{

node: props.getNode("/sim/mission/counters", 1),


init: func ()
{
    me.listeners = [
        setlistener(me.node.getNode("counters-updated", 1), func me.update()),
    ];
    me.counters = [];
    settimer(func me.load_counters(), 0);
},


load_counters: func ()
{
    foreach(var c; me.node.getChildren("counter")) {
        append(me.counters, counter.new(c));
    }
    me.redraw();
    #settimer(func me.redraw(), 0);
    initialized = 1;
},


update: func ()
{
    initialized or return;
	!state_changed or return;
    state_changed = 1;
	settimer(func me.redraw(), 0);
},


redraw: func ()
{
    var x = x_size - 1.3 * w;
    var y = 1.6 * h;
    foreach(var c; me.counters) {
        if (c.visible) {
            c.setTranslation(x, y);
            y += 1.5 * h;
        } else {
            c.hide();
        }
    }
},


stop: func ()
{
	foreach(var l; me.listeners)
		removelistener(l);
	setsize(me.listeners, 0);

    foreach(var c; me.counters)
        c.del();
    setsize(me.counters, 0);

},

}; #counter_handler


mission.extension_add("Handler", counter_handler);