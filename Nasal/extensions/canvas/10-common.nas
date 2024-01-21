
var Config = {
    new: func() return { parents: [Config] },

    redraw: func,

    customize: func(c) {
        foreach(var k; keys(c))
            if (contains(me.cfg, k))
                me.cfg[k] = c[k];
        me.redraw();
    },
};
