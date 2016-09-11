package adapter;

@:jsRequire("vscode-debugadapter","Handles")
extern class Handles<T>
{
    public function new():Void;
    public function reset():Void;
	public function create(value:T):Int;
	public function get(handle:Int, ?dflt: T):T;
}