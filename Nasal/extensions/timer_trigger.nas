
__mission.timer = {current_time: nil};

var dtN = props.getNode("/sim/time/delta-sec");

mission.extension_add("MissionObject", {
	type: "timer-trigger",

	new: func(n) {
		var m = {
			parents        : [me],
			name           : n.getValue("name"),
			current_time   : 0,
			_activated     : mission.get(n, "activated", 0),
			_single_shot   : mission.get(n, "single-shot", 1),
			_on_scr_timer  : mission.get(n, "on-screen-timer", 0),
			_start_t       : num(mission.get(n, "start-time", 0)),
			_stop_t        : num(mission.get(n, "stop-time", 0)),
			_stays_visible : mission.get(n, "stays-visible", 0),
			_actions       : n.getNode("actions", 0),
		};
		m._d = (m._stop_t >= m._start_t) ? 1 : -1;

		m.current_time = m._start_t;

		m.timer = maketimer(0, func m._loop());
		#m.timer.singleShot = m._single_shot;

		if (m._activated)
			m.start();

		return m;
	},

	start: func {
		me.timer.start();

		if (me._on_scr_timer)
			setprop("/sim/mission/timer/start-timer", 1);
	},

	restart: func me.current_time = me._start_t,

	adjust: func(t) me.current_time += t,

	stop: func {
		me.timer.stop();

		if (me._on_scr_timer) {
		    if (!me._stays_visible)
			    setprop("/sim/mission/timer/hide-timer", 1);
			setprop("/sim/mission/timer/stop-timer", 1);
            setprop("/sim/mission/timer/current-time", me.current_time);
        }
	},

	del: func me.stop(),

	_trigger: func {
		if (me._actions == nil)
			return;
		mission.activate_object_group(me._actions);
	},

	_loop: func {
		me.current_time += me._d * dtN.getValue();

		if (me._on_scr_timer)
			__mission.timer.current_time = me.current_time;

		if ((me.current_time >= math.max(me._start_t, me._stop_t)) or
			(me.current_time <= math.min(me._start_t, me._stop_t)) )
		{
			me._trigger();
			me.stop();
		}
	},
});
