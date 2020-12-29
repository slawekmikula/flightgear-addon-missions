#
# Protocol KML addon
#
# Slawek Mikula, December 2019

var main = func( addon ) {
    var root = addon.basePath;
    var myAddonId  = addon.id;
    var mySettingsRootPath = "/addons/by-id/" ~ myAddonId;
    # setting root path to addon
    setprop("/sim/mission/root_path", root);

    # load scripts
    foreach(var f; ['mission.nas', 'extensions.nas', 'persistence.nas', 'gui.nas', 'utils.nas'] ) {
        io.load_nasal( root ~ "/Nasal/" ~ f, "mission" );
    }
}