

var n1 = mission.object_by_name('Aircraft');
var n2 = mission.object_by_name('Pilot');
var n3 = mission.object_by_name('area_landing_site');

var lat = getprop('/sim/mission/generator/latitude-deg');
var lon = getprop('/sim/mission/generator/longitude-deg');

var lat1 = getprop('/sim/mission/generator/latitude-deg[1]');
var lon1 = getprop('/sim/mission/generator/longitude-deg[1]');

var hdg = rand() * 360;
n1.setDoubleValue('world-position/latitude-deg', lat);
n1.setDoubleValue('world-position/longitude-deg', lon);
n1.setDoubleValue('orientation/heading-deg', hdg);

n2.setDoubleValue('world-position/latitude-deg', lat1);
n2.setDoubleValue('world-position/longitude-deg', lon1);
n2.setDoubleValue('orientation/heading-deg', 0);

n3.setDoubleValue('attached-world-position/latitude-deg', lat);
n3.setDoubleValue('attached-world-position/longitude-deg', lon);
n3.setDoubleValue('orientation/heading-deg', hdg);
