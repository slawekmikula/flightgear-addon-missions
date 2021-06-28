var r_min = 1000;
var r_max = 2000;

var n1 = mission.mission_node.getChild('object', 2);

srand();

var c = geo.aircraft_position().apply_course_distance(rand() * 360, r_min + rand() * (r_max - r_min));

var info = geodinfo(c.lat(), c.lon());

if (info != nil and info[1] != nil)
    if (info[1].solid == 1)
        n1.setValue('mission-file', 'mission-deadstick-ground.xml');
    else
        n1.setValue('mission-file', 'mission-deadstick-water.xml');


setprop('/sim/mission/generator/latitude-deg',  c.lat());
setprop('/sim/mission/generator/longitude-deg', c.lon());

setprop('/sim/mission/generator/latitude-deg[1]',  c.lat());
setprop('/sim/mission/generator/longitude-deg[1]', c.lon());

setprop('/sim/mission/generator/mode', info[1].solid);

