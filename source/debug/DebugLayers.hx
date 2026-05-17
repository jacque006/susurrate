package debug;

// The different layers that have buttons to be toggled in the UI. Adjust/Add/Remove
// as needed
enum abstract DebugLayers(String) from String to String {
	var GENERAL = "General";
	var RAYCAST = "Raycast";
	var AUDIO = "Audio";
	var SQUARE_GRID = "Square Grid";
	var ISO_GRID = "Iso Grid";
	var ISO_SPACE = "Iso Space";
	var GRID_SPACE = "Grid Space";
	var GRAPH = "Graph";
}