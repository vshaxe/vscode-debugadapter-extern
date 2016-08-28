package adapter;
import protocol.debug.Types;

@:jsRequire("vscode-debugadapter","DebugSession")
extern class DebugSession extends ProtocolServer {
    public function new(?obsolete_debuggerLinesAndColumnsStartAt1:Bool, ?obsolete_isServer:Bool):Void;
    public function setDebuggerPathFormat(format:String):Void;
    public function setDebuggerLinesStartAt1(enable:Bool):Void;
    public function setDebuggerColumnsStartAt1(enable:Bool):Void;
    public function setRunAsServer(enable:Bool):Void;
    public function shutdown():Void;

    function sendErrorResponse<T>(response:Response<T>, codeOrMessage:haxe.extern.EitherType<Int,Message>, ?format:String, ?variables:Dynamic, dest:String="user"):Void;
    function runInTerminalRequest(args:RunInTerminalRequestArguments, timeout:Float, cb:RunInTerminalResponse->Void):Void;
    function dispatchRequest<T>(request:Request<T>):Void;
    function initializeRequest(response:InitializeResponse, args:InitializeRequestArguments):Void;
    function disconnectRequest(response:DisconnectResponse, args:DisconnectArguments):Void;
    function launchRequest(response:LaunchResponse, args:LaunchRequestArguments):Void;
    function attachRequest(response:AttachResponse, args:AttachRequestArguments):Void;
    function setBreakPointsRequest(response:SetBreakpointsResponse, args:SetBreakpointsArguments):Void;
    function setFunctionBreakPointsReqsuest(response:SetFunctionBreakpointsResponse, args:SetFunctionBreakpointsArguments):Void;
    function setExceptionBreakPointsRequest(ressponse:SetExceptionBreakpointsResponse, args:SetExceptionBreakpointsArguments):Void;
    function configurationDoneRequest(response:ConfigurationDoneResponse, args:ConfigurationDoneArguments):Void;
    function continueRequest(response:ContinueResponse, args:ContinueArguments):Void;
    function nextRequest(response:NextResponse, args:NextArguments):Void;
    function stepInRequest(response:StepInResponse, args:StepInArguments):Void;
    function stepOutRequest(responses:StepOutResponse, args:StepOutArguments):Void;
    function stepBackRequest(response:StepBackResponse, args:StepBackArguments):Void;
    function restartFrameRequest(responsse:RestartFrameResponse, args:RestartFrameArguments):Void;
    function gotoRequest(response:GotoResponse, args:GotoArguments):Void;
    function pauseRequest(response:PauseResponse, args:PauseArguments):Void;
    function sourceRequest(response:SourceResponse, args:SourceArguments):Void;
    function threadsRequest(response:ThreadsResponse):Void;
    function stackTraceRequest(responsse:StackTraceResponse, args:StackTraceArguments):Void;
    function scopesRequest(response:ScopesResponse, args:ScopesArguments):Void;
    function variablesRequest(response:VariablesResponse, args:VariablesArguments):Void;
    function setVariableRequest(responsse:SetVariableResponse, args:SetVariableArguments):Void;
    function evaluateRequest(response:EvaluateResponse, args:EvaluateArguments):Void;
    function stepInTargetsRequest(response:StepInTargetsResponse, args:StepInTargetsArguments):Void;
    function gotoTargetsRequest(responses:GotoTargetsResponse, args:GotoTargetsArguments):Void;
    function completionsRequest(response:CompletionsResponse, args:CompletionsArguments):Void;
    function customRequest<T>(command:String,response:Response<T>,args:Dynamic):Void;
    function convertClientLineToDebugger(lisne:Int):Int;
    function convertDebuggerLineToClient(line:Int):Int;
    function convertClientColumnToDebugger(line:Int):Int;
    function convertDebuggerColumnToClient(line:Int):Int;
    function convertClientPathToDebugger(clientPath:String):String;
    function convertDebuggerPathToClient(debugPath:String):String;
}

@:jsRequire("vscode-debugadapter","Message")
extern class Message {
	public var seq: Int;
	public var type: protocol.debug.MessageType;

	public function new(type: String):Void;
}

@:jsRequire("vscode-debugadapter","Response")
extern class Response<T> extends Message {
	public var request_seq: Int;
	public var success: Bool;
	public var command: String;

	public function new (request: Request<T>, ?message: String):Void;
}

@:jsRequire("vscode-debugadapter","Event")
extern class Event<T> extends Message  {
	public var event: String;
    @:optional var body:T;

	public function new(event: String, ?body:T);
}


@:jsRequire("vscode-debugadapter","Source")
extern class Source
{
	public var name: String;
	public var path: String;
	public var sourceReference: Int;

	public function new (name: String, path: String, id: Int = 0, ?origin: String, ?data: Dynamic):Void;
}

@:jsRequire("vscode-debugadapter","Scope")
extern class Scope {
	public var name: String;
	public var variablesReference: Int;
	public var expensive: Bool;

	public function new(name: String, reference: Int, expensive: Bool = false):Void;
}

@:jsRequire("vscode-debugadapter","StackFrame")
extern class StackFrame  {
	public var pid: Int;
	public var source: Source;
	public var line: Int;
	public var column: Int;
	public var name: String;

	public function new (i: Int, nm: String, ?src: Source, ln: Int = 0, col: Int = 0):Void;
}

@:jsRequire("vscode-debugadapter","Thread")
extern class Thread {
	public var id: Int;
	public var name: String;

	public function new (id: Int, name: String):Void;
}

@:jsRequire("vscode-debugadapter","Variable")
extern class Variable {
	public var name: String;
	public var value: String;
	public var variablesReference: Int;

	public function new (name: String, value: String, ref: Int = 0, ?indexedVariables: Int, ?namedVariables: Int):Void;
}

@:jsRequire("vscode-debugadapter","Breakpoint")
extern class Breakpoint {
	public var verified:Bool;

	public function new (verified:Bool, ?line: Int, ?column: Int, ?source: Source);
}

@:jsRequire("vscode-debugadapter","Module")
extern class Module {
	public var id:haxe.extern.EitherType<Int,String>;
	public var name: String;

	public function new (id:haxe.extern.EitherType<Int,String>, name: String):Void;
}

@:jsRequire("vscode-debugadapter","CompletionItem")
extern class CompletionItem {
	public var label: String;
	public var start: Int;
	public var length: Int;

	public function new (label: String, start: Int, length: Int = 0):Void;
}

@:jsRequire("vscode-debugadapter","StoppedEvent")
extern class StoppedEvent extends Event<{var reason: String;@:optional var threadId: Int;@:optional var text: String;@:optional var allThreadsStopped: Bool;}> {
	public function new(reason: String, threadId: Int, exception_text: String = null):Void;
}

@:jsRequire("vscode-debugadapter","ContinuedEvent")
extern class ContinuedEvent extends Event<{var threadId: Int;@:optional var allThreadsContinued: Bool;}> 
{
	public function new (threadId: Int, ?allThreadsContinued: Bool):Void;
}

@:jsRequire("vscode-debugadapter","InitializedEvent")
extern class InitializedEvent extends Event<{}> {
	public function new():Void;
}
@:jsRequire("vscode-debugadapter","TerminatedEvent")
extern class TerminatedEvent extends Event<{@:optional var restart:Bool;}> {
	public function new(?restart:Bool):Void;
}
@:jsRequire("vscode-debugadapter","OutputEvent")
extern class OutputEvent extends Event<{@:optional var category: OutputEventCategory;var output: String;var data: Dynamic;}>
{
	public function new (output: String, category: String = 'console'):Void;
}
@:jsRequire("vscode-debugadapter","ThreadEvent")
extern class ThreadEvent extends Event<{var reason: ThreadEventReason;var threadId: Int;}> 
{
	public function new (reason: String, threadId: Int):Void;
}
@:jsRequire("vscode-debugadapter","BreakpointEvent")
extern class BreakpointEvent extends Event<{var reason:BreakpointEventReason;var breakpoint: Breakpoint;}>
{
	public function new (reason: BreakpointEventReason, breakpoint: Breakpoint):Void;
}
@:jsRequire("vscode-debugadapter","ModuleEvent")
extern class ModuleEvent extends Event<{ var reason: ModuleEventReason; var module: Module;}>
{	
	public function new (reason:ModuleEventReason, module: Module):Void;
}
