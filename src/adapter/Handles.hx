package adapter;

@:jsRequire("vscode-debugadapter", "Handles")
extern class Handles<T> {
	function new():Void;
	function reset():Void;
	function create(value:T):Int;
	function get(handle:Int, ?dflt:T):T;
}
