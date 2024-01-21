
var counter_trigger = {
    type: "counter-trigger",

    new: func (n) {
        return {
            parents    : [counter_trigger],
            node       : nil,
            name       : n.getValue("name"),
            text       : n.getValue("text"),
            stopCount  : n.getValue("stop-count"),
            _counter   : n.getValue("start-count"),
            _activated : n.getValue("activated") or 0,
            _actions   : n.getNode("actions"),
            _on_screen : 0,
        };
    },


    init: func {
        #var N = props.getNode("/sim/mission/counters", 1);
        me.node = props.getNode("/sim/mission/counters", 1).addChild("counter");
        me.node.setValues({
            "on-screen" : (me._on_screen = (me.text != nil)),
            "text"      : me.text,
            "visible"   : me._activated,
            "counter"   : me._counter,
            "updated"   : 1,
        });
        if ( me._activated )
            me.start();
    },


    start: func {
        me._activated = 1;
        if ( me._on_screen ) {
            me.node.setBoolValue("visible", 1);
            me._update();
        }
    },


    count: func (c) {
        me._activated or return;
        me._counter += c;
        if (me._counter == me.stopCount)
            me._trigger();
        me.node.setIntValue("counter", me._counter);
        me._update();
    },


    stop: func {
        me._activated = 0;
        if ( me._on_screen ) {
            me.node.setBoolValue("visible", 0);
            me._update();
        }
    },


    del: func me.node.remove(),


    _update: func {
        me.node.setBoolValue("counter-updated", 1);
        #setprop("/sim/mission/counters/counters-updated", 1);
    },


    _trigger: func {
        if ( me._actions == nil )
            return;
        mission.activate_object_group(me._actions);
    },

};

mission.extension_add("MissionObject", counter_trigger);