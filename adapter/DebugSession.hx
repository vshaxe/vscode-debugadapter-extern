package adapter;

import protocol.debug.Types;
import protocol.debug.Types.Source as TSource;

@:jsRequire("vscode-debugadapter","DebugSession")
extern class DebugSession extends ProtocolServer {
    public static function run(debugSession:Class<DebugSession>):Void;

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
    function customRequest<T>(command:String, response:Response<T>, args:Dynamic):Void;
    function convertClientLineToDebugger(lisne:Int):Int;
    function convertDebuggerLineToClient(line:Int):Int;
    function convertClientColumnToDebugger(line:Int):Int;
    function convertDebuggerColumnToClient(line:Int):Int;
    function convertClientPathToDebugger(clientPath:String):String;
    function convertDebuggerPathToClient(debugPath:String):String;
}

@:jsRequire("vscode-debugadapter", "Message")
extern class Message {
    var seq:Int;
    var type:protocol.debug.MessageType;

    function new(type:String):Void;
}

@:jsRequire("vscode-debugadapter", "Response")
extern class Response<T> extends Message {
    var request_seq:Int;
    var success:Bool;
    var command:String;

    function new(request:Request<T>, ?message:String):Void;
}

@:jsRequire("vscode-debugadapter", "Event")
extern class Event<T> extends Message  {
    var event: String;
    var body:T;

    function new(event:String, ?body:T);
}

@:jsRequire("vscode-debugadapter", "Source")
extern class Source {
    var name: String;
    var path: String;
    var sourceReference: Int;

    function new (name:String, path:String, id:Int = 0, ?origin:String, ?data:Dynamic):Void;
}

@:jsRequire("vscode-debugadapter", "Scope")
extern class Scope {
    var name:String;
    var variablesReference:Int;
    var namedVariables:Int;
    var indexedVariables:Int;
    var expensive:Bool;

    function new(name:String, reference:Int, expensive:Bool = false):Void;
}

@:jsRequire("vscode-debugadapter", "StackFrame")
extern class StackFrame  {
    var pid: Int;
    var source: Source;
    var line: Int;
    var column: Int;
    var name: String;

    function new (i: Int, nm:String, ?src:Source, ln:Int = 0, col:Int = 0):Void;
}

@:jsRequire("vscode-debugadapter", "Thread")
extern class Thread {
    var id: Int;
    var name: String;

    function new (id: Int, name: String):Void;
}

@:jsRequire("vscode-debugadapter", "Variable")
extern class Variable {
    var name: String;
    var value: String;
    var variablesReference: Int;

    function new (name: String, value: String, ref: Int = 0, ?indexedVariables: Int, ?namedVariables: Int):Void;
}

@:jsRequire("vscode-debugadapter", "Breakpoint")
extern class Breakpoint {
    var id:Int;
    var verified:Bool;
    var message:String;
    var source:TSource;
    var line:Int;
    var column:Int;
    var endLine:Int;
    var endColumn:Int;

    function new (verified:Bool, ?line: Int, ?column: Int, ?source: Source);
}

@:jsRequire("vscode-debugadapter", "Module")
extern class Module {
    var id:haxe.extern.EitherType<Int, String>;
    var name: String;

    function new (id:haxe.extern.EitherType<Int, String>, name:String):Void;
}

@:jsRequire("vscode-debugadapter", "CompletionItem")
extern class CompletionItem {
    var label: String;
    var start: Int;
    var length: Int;

    function new (label: String, start: Int, length: Int = 0):Void;
}


@:jsRequire("vscode-debugadapter", "StoppedEvent")
extern class StoppedEvent extends Event<TStoppedEvent> {
    var reason: String;
    var threadId: Int;
    var text: String;
    var allThreadsStopped: Bool;

    function new(reason:String, threadId:Int, ?exception_text:String):Void;
}

@:jsRequire("vscode-debugadapter", "ContinuedEvent")
extern class ContinuedEvent extends Event<TContinuedEvent> {
    function new (threadId:Int, ?allThreadsContinued:Bool):Void;
}

@:jsRequire("vscode-debugadapter", "InitializedEvent")
extern class InitializedEvent extends Event<{}> {
    function new():Void;
}

@:jsRequire("vscode-debugadapter", "TerminatedEvent")
extern class TerminatedEvent extends Event<TTerminatedEvent> {
    function new(?restart:Bool):Void;
}

@:jsRequire("vscode-debugadapter", "OutputEvent")
extern class OutputEvent extends Event<TOutputEvent> {
    function new (output: String, category:OutputEventCategory = "console"):Void;
}

@:jsRequire("vscode-debugadapter", "ThreadEvent")
extern class ThreadEvent extends Event<TThreadEvent> {
    function new (reason: String, threadId: Int):Void;
}

@:jsRequire("vscode-debugadapter", "BreakpointEvent")
extern class BreakpointEvent extends Event<TBreakpointEvent> {
    function new (reason: BreakpointEventReason, breakpoint: Breakpoint):Void;
}

@:jsRequire("vscode-debugadapter", "ModuleEvent")
extern class ModuleEvent extends Event<TModuleEvent> {
    function new (reason:ModuleEventReason, module: Module):Void;
}
