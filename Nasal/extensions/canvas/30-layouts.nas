var layouts = {};

layouts.boxLayout = {
    new: func(group, d, r = 0) {
        var m = {parents: [layouts.boxLayout, style.new(), tmp.new()]};

        m.root = group;
        m.data = d;

        m.d = {r: r, root_layout: 0, _size: [0, 0], trigger: func call(m.redraw, [])};
        m.sizeHint = [0, 0];
        m.spacing = 0;
        m.style = {
            spacing: 20,
            margin: 20,
        };

        m._tr = [0, 0];
#        m._bb = [[,,], [,,]];
        m._el = [];
        m._size = [,,];

        m.redraw = func {
            var r = m.data.r;

            m.d._size[r] = m.data._size[r];
            m.sizeHint[r] = m.d._size[r];
            if (m.data.root_layout) {
                m.d._size[!r] = m.data._size[!r];
                m.sizeHint[!r] = m.data._size[!r];
            }
            else
                m._updateWH();

            m._size[0] = m.d._size[0];
            m._size[1] = m.d._size[1];

            m._update();

        }

        m.redraw();
        return m;
    },

    debug_prnt: func {
        print(me.data._size[0] ~ " " ~ me.data._size[1]);
        print(me._size[0] ~ " " ~ me._size[1]);
    },

    _updateWH: func {
        var r = me.data.r; # parent rotation
        var rd = me.d.r;   # my rotation

        var wh = [0, 0];
        var WH = [0, 0];
        WH[r] = me.style.spacing; # ?

        var l = 0;
        var L = 0;
        foreach(var e; me._el) {
            wh[!r] = e.sizeHint[!r]; # width for hbox / height for vbox
            if (wh[!r] > WH[!r])
                WH[!r] = wh[!r];
            # next direction:
            WH[r] += e.sizeHint[r] + me.style.spacing; # height for hbox / width for vbox
        }
#        me._size[!r] = L;
        me.d._size[!r] = WH[!r];
        me.sizeHint[r] = WH[r];
        me.sizeHint[!r] = WH[!r];
    },

    swallow: func(e) {
        e.data = me.d;
        append(me._el, e);
#        me.sizeHint[!me.d.r] += e.sizeHint[!me.d.r];
        me.redraw();
        me.data.trigger();
    },

    move: func(x, y) {
        me._tr = [x, y];
        me.redraw();
    },

    _spacing: func(r) {
        var l = me.d._size[!r];
        var s = 0;
        var spacing = 0;

        foreach(var el; me._el) {
            s += el._size[!r];
        }
        spacing = (l - s) / (size(me._el) + 1);
#        print(spacing);
         me.spacing = spacing;
        return spacing;

    },
    _update: func {
        var r = me.d.r;
        var s = me._spacing(r);
        var xy = [0,0];
        xy[!r] = s;
        forindex(var i; me._el) {
            xy[r] = me.d._size[r] / 2 - me._el[i]._size[r]/2;
            me._el[i].move(me._tr[0] + xy[0], me._tr[1] + xy[1]);
            xy[!r] += me._el[i]._size[!r] + s;
        }
    },
};