package adapter;
import protocol.debug.Types;

extern class ProtocolServer
{
    public function sendEvent<T>(event:Event<T>):Void;
    public function sendResponse<T>(response: Response<T>):Void;
}