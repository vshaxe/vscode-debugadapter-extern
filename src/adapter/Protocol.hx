package adapter;

import protocol.debug.Types;

@:jsRequire("vscode-debugadapter", "ProtocolServer")
extern class ProtocolServer {
	function sendEvent<T>(event:Event<T>):Void;
	function sendResponse<T>(response:Response<T>):Void;
	function sendRequest<T>(command:String, args:Dynamic, timeout:Float, cb:(response:Response<T>) -> Void):Void;
}
