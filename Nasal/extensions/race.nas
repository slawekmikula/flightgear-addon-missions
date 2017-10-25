


var w          = 400;
var h          = 80;
var bg_color   = [0.2, 0.4, 0.7, 0.9];
var line_color = [1, 1, 1, 0.8];
var txt_h      = h / 10;
var txt2_h     = txt_h * 0.8;
var font       = "LiberationFonts/LiberationSans-Italic.ttf";
var font2      = "LiberationFonts/LiberationMono-Italic.ttf";
var offset     = 5;
var th         = h - offset * 2;     # table height
var x_left     = offset;             # table corners
var x_right    = w - x_left;         #
var y_top      = x_left;             #
var y_bottom   = th + x_left;        # /table corners
var margin     = 10;

var window = canvas.Window.new([w,h]);

var scr_x = func getprop("/sim/startup/xsize");
var scr_y = func getprop("/sim/startup/ysize");

window.set("tf/t[0]", scr_x() - w - 20);
window.set("tf/t[1]", scr_y() / 20);

var mycanvas = window.createCanvas();
mycanvas.setColorBackground(0,0,0,0);

var table = mycanvas.createGroup();
var cfg = {
	"border-top-radius": h/2.1,
	"border-bottom-radius": h/2.1,
};
table.createChild("path")
	.rect(offset, offset, w - 2*offset, h - 2*offset, cfg)
	.setColor(line_color)
	.setColorFill(bg_color)
	.setStrokeLineWidth(2);


var _data = [
	#       0      ,        1       ,        2           ,       3        ,  4   ,   5   ,      6        ,
	#              ,        x       ,        y           ,   Alignment    , Size , Font  ,    Text       ,
	["Lap"         , h/2            , h/2 + offset/2     , "left-center"  , h/4  , font  , "Lap"        ],
	["_Lap"        , w/4            , h/2                , "left-center"  , h/3  , font2 , "-/-"        ],
	["TotalTime"   , w/1.5          , (h - 2*offset)/3   , "right-bottom" , h/6  , font  , "Total Time" ],
	["_TotalTime"  , w/1.5 + offset , (h - 2*offset)/3   , "left-bottom"  , h/4  , font2 , "00:00.0"    ],
	["CurrentLap"  , w/1.5          , (h - 2*offset)/3*2 , "right-bottom" , h/6  , font  , "Current Lap"],
	["_CurrentLap" , w/1.5 + offset , (h - 2*offset)/3*2 , "left-bottom"  , h/4  , font2 , "00:00.0"    ],
	["LastLap"     , w/1.5          , (h - 2*offset)/3*3 , "right-bottom" , h/6  , font  , "Last Lap"   ],
	["_LastLap"    , w/1.5 + offset , (h - 2*offset)/3*3 , "left-bottom"  , h/4  , font2 , "00:00.0"    ],
];

var txt = {};
foreach (var a; _data) {
	txt[a[0]] = table.createChild("text");
	txt[a[0]]
		.setTranslation(a[1], a[2])
		.setText(a[6])
		.setAlignment(a[3])
		.setFontSize(a[4])
		.setFont(a[5])
		.setColor(1,1,1);
}


var time_str = func(t) {
	var t1 = int(math.mod(t / 60, 60));
	var t2 = int(math.mod(t, 60));
	var t3 = int(math.mod(t * 10, 10));
	sprintf("%02d:%02d.%d", t1, t2, t3);
}

var timer = {
	_tN      : props.getNode("/sim/time/elapsed-sec"),
	_timer   : maketimer(0.1, func timer._loop()),
	_time    : 0,
	_penalty : 0,
	_total   : 0,
	_current : 0,
	_last    : 0,


	start: func {
		me._start_time = me._tN.getValue();
		me._timer.start();
	},

	stop: func {
		me._timer.stop();
	},

	add_time: func(t) {
		me._penalty += t;
	}, 

	reset: func {
		me._total += me._time + me._penalty;
		me._last = me._time;
		me._start_time = me._tN.getValue();
		txt._LastLap.setText(time_str(me._last));
	},

	_loop: func {
		me._time = me._tN.getValue() - me._start_time;
		txt._TotalTime.setText(time_str(me._total + me._time + me._penalty));
		txt._CurrentLap.setText(time_str(me._time));
	},
};


var race = {
	type: "race",

	new: func(n) {
		var m = {
			parents        : [race],
			name           : n.getValue("name"),
			_num_of_laps   : mission.get(n, "number-of-laps", 1),
			_clock_start   : mission.get(n, "clock-start", "immediate"), #on-action, on-first-race-point, immediate
			_course        : n.getNode("race-course", 0),
			_race_points   : [],
			_current_point : 0,
			_lap           : 1,
			_next_lap      : 0,
		};
		return m;
	},

	init: func {
		me._listeners = [
			setlistener("/sim/mission/race/signals/next-race-point", func me._next_point()),
		];

		if (me._clock_start == "on-action")
			me._clock_start = 0;
		elsif (me._clock_start == "on-first-race-point")
			me._clock_start = 1;
		else me._clock_start = 2;


		if ( me._course != nil )
			foreach(var ref; me._course.getChildren("object-reference"))
				foreach(var obj; mission.mission_objects)
					if (ref.getValue() == obj.name)
						append(me._race_points, obj);

		me._points_count = size(me._race_points);
		txt._Lap.setText(1 ~ "/" ~ me._num_of_laps);
		me.start();
	},

	start: func {
		me._race_points[me._current_point].start();
	},

	stop: func {
		timer.stop();
		foreach(var a; me._race_points)
			a.stop();
	},

	del: func {
		window.del();
		me.stop();
		foreach(var l; me._listeners)
			removelistener(l);
		setsize(me._listeners, 0);
	},

	_next_point: func {
		if ((me._clock_start == 1) and (me._current_point == 0) and me._lap == 1)
			timer.start();

		if (me._next_lap) {
			me._next_lap = 0;
			me._lap += 1;
			if (me._lap > me._num_of_laps) {
				timer.reset();
				timer.stop();
				me.stop();
				txt._CurrentLap.setText("00:00.0");
				return;
			}
			timer.reset();
			txt._Lap.setText(me._lap ~ "/" ~ me._num_of_laps);
		}

		me._current_point += 1;
		if ( (me._current_point + 1) > me._points_count ) {
			me._current_point = 0;
			me._next_lap = 1;
		}

		me._race_points[me._current_point].start();
	},
};

mission.extension_add("MissionObject", race);