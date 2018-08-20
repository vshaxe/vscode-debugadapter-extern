package adapter;

import protocol.debug.Types;

extern class ProtocolServer {
	function sendEvent<T>(event:Event<T>):Void;
	function sendResponse<T>(response:Response<T>):Void;
}
