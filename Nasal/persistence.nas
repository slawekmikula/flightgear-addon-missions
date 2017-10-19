
var save_data = func {
	var path = getprop("/sim/fg-home") ~ "/Export/state.xml";

	var fdm_node      = props.getNode("fdm");
	var engines_node  = props.getNode("engines");
	var rotors_node   = props.getNode("rotors");
	var systems_node  = props.getNode("systems");
	var controls_node = props.getNode("controls");

	var data = props.Node.new();

	props.copy(fdm_node, data.getNode("fdm", 1));
	props.copy(engines_node, data.getNode("engines", 1));
	props.copy(rotors_node, data.getNode("rotors", 1));
	props.copy(systems_node, data.getNode("systems", 1));
	props.copy(controls_node, data.getNode("controls", 1));

	io.write_properties(path, data);
	data.remove();
}

var load_data = func {
	var path = getprop("/sim/fg-home") ~ "/Export/state.xml";
	io.read_properties(path, "/");
}
