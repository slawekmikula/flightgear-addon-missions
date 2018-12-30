#
# Missions addon
#
# Started by Marius_A
# Started on November 2016
#
# Converted to a FlightGear addon by
# Slawek Mikula, October 2017

var main = func( addon ) {
    # setting root path to addon
    var root = addon.basePath;
    setprop("/sim/mission/root_path", root);

    # load scripts
    foreach(var f; ['mission.nas', 'extensions.nas', 'persistence.nas', 'gui.nas', 'utils.nas'] ) {
        io.load_nasal( root ~ "/Nasal/" ~ f, "mission" );
    }
}
