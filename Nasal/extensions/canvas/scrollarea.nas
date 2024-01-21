
var scrollArea = {
    new: func(root) {
        var m = {parents: [ scrollArea, __mission.canvas.style.new()]};

        m.style = {
            bgColor: "#222222",
        };

        m._d = {
            x:  30, y: 30,
            w: 600, h: 300,

            items: [],
        };

        return m;
    },
    hideItem: func(i) {},
    showItem: func(i) {},
    resize: func(x = nil, y = nil) {},
    scrollUp: func {},
    scrollDown: func {},
};