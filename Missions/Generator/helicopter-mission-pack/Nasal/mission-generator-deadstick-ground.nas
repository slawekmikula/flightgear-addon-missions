srand();

# Aircraft
var n1 = mission.object_by_name('Aircraft');

# Pilot
var n2 = mission.object_by_name('Pilot');

# Landing area
var n3 = mission.object_by_name('area_landing_site');

var lat = getprop('/sim/mission/generator/latitude-deg');
var lon = getprop('/sim/mission/generator/longitude-deg');

var c = geo.Coord.new().set_latlon(lat, lon);
var ac = geo.Coord.new(c);

# Pilot location
c.apply_course_distance(rand() * 360, 9.0);

# Aircraft heading
var hdg = rand() * 360;

n1.setDoubleValue('world-position/latitude-deg', lat);
n1.setDoubleValue('world-position/longitude-deg', lon);
n1.setDoubleValue('orientation/heading-deg', hdg - 90);

n2.setDoubleValue('world-position/latitude-deg', c.lat() );
n2.setDoubleValue('world-position/longitude-deg', c.lon() );
n2.setDoubleValue('orientation/heading-deg', hdg);

n3.setDoubleValue('attached-world-position/latitude-deg', c.lat() );
n3.setDoubleValue('attached-world-position/longitude-deg', c.lon() );
n3.setDoubleValue('orientation/heading-deg', hdg);


# Adjust aircraft model orientation
var lg  = [];
var alt = [,,,,];
var l1 = 6;
var l2 = 2.0;


for (var i = 0; i < 3; i += 1) append(lg, geo.Coord.new(ac));

lg[0].apply_course_distance(180 + hdg, l1);
lg[1].apply_course_distance(-90 + hdg, l2);
lg[2].apply_course_distance( 90 + hdg, l2);

alt[0] = geo.elevation(ac.lat(), ac.lon());
alt[1] = geo.elevation(lg[0].lat(), lg[0].lon());
alt[2] = geo.elevation(lg[1].lat(), lg[1].lon());
alt[3] = geo.elevation(lg[2].lat(), lg[2].lon());

var pitch = math.atan2(alt[1] - alt[0], l1) * R2D;
var roll = math.atan2(alt[2] - alt[3], l2) * R2D;

setprop('/sim/mission/generator/pitch-deg', -pitch);
setprop('/sim/mission/generator/roll-deg', roll);

#n2.setDoubleValue('world-position/latitude-deg', lg[2].lat() );
#n2.setDoubleValue('world-position/longitude-deg', lg[2].lon() );
#n2.setDoubleValue('orientation/heading-deg', hdg);
