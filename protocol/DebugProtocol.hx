'use strict';
package DebugProtocol;

abstract MessageType(String) from String
{
    var TYPE_REQUEST  = "request";
    var TYPE_RESPONSE = "response";
    var TYPE_EVENT    = "event";
}

/** 
    Base class of requests, responses, and events. 
**/
typedef ProtocolMessage = {
    /** 
        Sequence number 
    **/
    var seq:Int;
    var type:MessageType;
}

/** 
    Client-initiated request 
**/
typedef Request<T> = {
    > ProtocolMessage,

    /** 
        The command to execute 
    **/
    var command:String;

    /** 
        Object containing arguments for the command 
    **/
    @:optional var arguments:T;
}

/** 
    Server-initiated event 
**/
typedef Event<T> = {
    > ProtocolMessage,

    /** 
        Type of event 
    **/
    var event:String;

    /** 
        Event-specific information 
    **/
    @:optional var body:T;
}

/** 
    Server-initiated response to client request 
**/
typedef Response<T> = {
    > ProtocolMessage,

    /** 
        Sequence number of the corresponding request 
    **/
    var request_seq:Int;

    /** 
        Outcome of the request 
    **/
    var success:Bool;

    /** 
        The command requested
    **/
    var command:String;

    /** 
        Contains error message if success == false. 
    **/
    @:optional var message:String;

    /** 
        Contains request result if success is true and optional error details if success is false. 
    **/
    @:optional var body:T;
}

//---- Events

/** Event message for "initialized" event type.
    This event indicates that the debug adapter is ready to accept configuration requests (e.g. SetBreakpointsRequest, SetExceptionBreakpointsRequest).
    A debug adapter is expected to send this event when it is ready to accept configuration requests (but not before the InitializeRequest has finished).
    The sequence of events/requests is as follows:
    - adapters sends InitializedEvent (after the InitializeRequest has returned)
    - frontend sends zero or more SetBreakpointsRequest
    - frontend sends one SetFunctionBreakpointsRequest
    - frontend sends a SetExceptionBreakpointsRequest if one or more exceptionBreakpointFilters have been defined (or if supportsConfigurationDoneRequest is not defined or false)
    - frontend sends other future configuration requests
    - frontend sends one ConfigurationDoneRequest to indicate the end of the configuration
**/
typedef InitializedEvent = Event<Dynamic>;

typedef StoppedEvent = Event<{
    /** 
        The reason for the event (such as: 'step', 'breakpoint', 'exception', 'pause'). This string is shown in the UI. 
    **/
    var reason: String;

    /** 
        The thread which was stopped. 
    **/
    @:optional var threadId: Int;
        
    /** 
        Additional information. E.g. if reason is 'exception', text contains the exception name. This string is shown in the UI. 
    **/
    @:optional var text: String;

    /** If allThreadsStopped is true, a debug adapter can announce that all threads have stopped.
    *   The client should use this information to enable that all threads can be expanded to access their stacktraces.
    *   If the attribute is missing or false, only the thread with the given threadId can be expanded.
    **/
    @:optional var allThreadsStopped: Bool;
}>;

/** Event message for "continued" event type.
	The event indicates that the execution of the debuggee has continued.
	Please note: a debug adapter is not expected to send this event in response to a request that implies that execution continues, e.g. 'launch' or 'continue'.
	It is only necessary to send a ContinuedEvent if there was no previous request that implied this.
**/
typedef ContinuedEvent = Event<{
    /** 
        The thread which was continued. 
    **/
	var threadId: Int;
	/** 
        If allThreadsContinued is true, a debug adapter can announce that all threads have continued. 
    **/
	@:optional var allThreadsContinued: Bool;
}>;

/** Event message for "exited" event type.
	The event indicates that the debuggee has exited.
**/
typedef ExitedEvent = Event<{
    {
    /** 
        The exit code returned from the debuggee. 
    **/
	var exitCode: Int;
	};
}>;

/** Event message for "terminated" event types.
	The event indicates that debugging of the debuggee has terminated.
**/
typedef TerminatedEvent = Event<{
    /** 
        A debug adapter may set 'restart' to true to request that the front end restarts the session. 
    **/
    @:optional var restart:Bool;
}>;

/** Event message for "thread" event type.
	The event indicates that a thread has started or exited.
**/
typedef ThreadEvent = Event<{

    /** 
        The reason for the event (such as: 'started', 'exited'). 
    **/
	var reason: String;

	/** 
        The identifier of the thread. 
    **/
	var threadId: Int;
}>;

/** Event message for "output" event type.
	The event indicates that the target has produced output.
**/
typedef OutputEvent = Event<{
    /** 
        The category of output (such as: 'console', 'stdout', 'stderr', 'telemetry'). If not specified, 'console' is assumed. 
    **/
	@:optional var category: String;

	/** 
        The output to report. 
    **/
	var output: string;

	/** 
        Optional data to report. For the 'telemetry' category the data will be sent to telemetry, for the other categories the data is shown in JSON format. 
    **/
	var data: Dynamic;
}>;

/** 
    The reason for the breakpoint event. 
**/
@:enum
abstract BreakpointEventReason(String)
{
    var CHANGED = "changed";
    var NEW = "new";
}

/** Event message for "breakpoint" event type.
	The event indicates that some information about a breakpoint has changed.
**/
typedef BreakpointEvent = Event<{
    
	var reason:BreakpointEventReason;

	/** 
        The breakpoint. 
    **/
	var breakpoint: Breakpoint;
}>;

/** 
    The reason for the module event. 
**/
@:enum
abstract ModuleEventReason(String)
{
    var NEW = "new";
    var CHANGED = "changed";
    var REMOVED = "removed";
}

/** Event message for "module" event type.
	The event indicates that some information about a module has changed.
**/
typedef ModuleEvent = Event<{
    var reason:ModuleEventReason;

    /** 
        The new, changed, or removed module. In case of 'removed' only the module id is used. 
    **/
    var module: Module;
}>

//---- Frontend Requests

/** 
    runInTerminal request; value of command field is "runInTerminal".
	With this request a debug adapter can run a command in a terminal.
**/
typedef RunInTerminalRequest = Request<RunInTerminalRequestArguments>;

@:enum
abstract RunInTerminalArgumentsKind(String)
{
    var INTEGRATED = "integrated";
    var EXTERNAL = "external";
}

/** 
    Arguments for "runInTerminal" request. 
**/
typedef RunInTerminalRequestArguments = {
    /**
         What kind of terminal to launch. 
    **/
    @:optional var kind:RunInTerminalArgumentsKind;

    /** 
        Optional title of the terminal. 
    **/
    @:optional var title:String;

    /** 
        Working directory of the command. 
    **/
    var cwd:String;

    /** 
        List of arguments. The first argument is the command to run. 
    **/
    var args:Array<String>;

    /** 
        Environment key-value pairs that are added to the default environment. 
    **/
    @:optional var env:haxe.ds.DynamicAccess<String>;
};

/** 
    Response to Initialize request. 
**/
typedef RunInTerminalResponse = Response<{
    /** 
        The process ID 
    **/
    @:optional var processId:Int;
}>

//---- Debug Adapter Requests

/** 
    On error that is whenever 'success' is false, the body can provide more details.
**/
typedef ErrorResponse = Response<{
    /** 
        An optional, structured error message. 
    **/
	@:optional var error: Message;
}>;

/*
typedef InitializeRequest extends Request {
    public var arguments:InitializeRequestArguments;
}

typedef InitializeRequestArguments {
    public var adapterID:String;
    public var linesStartAt1?:Bool;
    public var columnsStartAt1?:Bool;
    public var pathFormat?:String;
    public var supportsVariableType?:Bool;
    public var supportsVariablePaging?:Bool;
    public var supportsRunInTerminalRequest?:Bool;
}

typedef InitializeResponse extends Response {
    public var body?:Capabilites;
}

typedef ConfigurationDoneRequest extends Request {
    public var arguments?:ConfigurationDoneArguments;
}

typedef ConfigurationDoneArguments {
}

typedef ConfigurationDoneResponse extends Response {
}

typedef LaunchRequest extends Request {
    public var arguments:LaunchRequestArguments;
}

typedef LaunchRequestArguments {
    public var noDebug?:Bool;
}

typedef LaunchResponse extends Response {
}

typedef AttachRequest extends Request {
    public var arguments:AttachRequestArguments;
}

typedef AttachRequestArguments {
}

typedef AttachResponse extends Response {
}

typedef DisconnectRequest extends Request {
    public var arguments?:DisconnectArguments;
}

typedef DisconnectArguments {
}

typedef DisconnectResponse extends Response {
}

typedef SetBreakpointsRequest extends Request {
    public var arguments:SetBreakpointsArguments;
}

typedef SetBreakpointsArguments {
    public var source:Source;
    public var breakpoints?:Dynamic;
    public var lines?:Dynamic;
    public var sourceModified?:Bool;
}

typedef SetBreakpointsResponse extends Response {
    public var body:Dynamic;
}

typedef SetFunctionBreakpointsRequest extends Request {
    public var arguments:SetFunctionBreakpointsArguments;
}

typedef SetFunctionBreakpointsArguments {
    public var breakpoints:Dynamic;
}

typedef SetFunctionBreakpointsResponse extends Response {
    public var body:Dynamic;
}

typedef SetExceptionBreakpointsRequest extends Request {
    public var arguments:SetExceptionBreakpointsArguments;
}

typedef SetExceptionBreakpointsArguments {
    public var filters:Dynamic;
}

typedef SetExceptionBreakpointsResponse extends Response {
}

typedef ContinueRequest extends Request {
    public var arguments:ContinueArguments;
}

typedef ContinueArguments {
    public var threadId:Float;
}

typedef ContinueResponse extends Response {
    public var body:Dynamic;
}

typedef NextRequest extends Request {
    public var arguments:NextArguments;
}

typedef NextArguments {
    public var threadId:Float;
}

typedef NextResponse extends Response {
}

typedef StepInRequest extends Request {
    public var arguments:StepInArguments;
}

typedef StepInArguments {
    public var threadId:Float;
    public var targetId?:Float;
}

typedef StepInResponse extends Response {
}

typedef StepOutRequest extends Request {
    public var arguments:StepOutArguments;
}

typedef StepOutArguments {
    public var threadId:Float;
}

typedef StepOutResponse extends Response {
}

typedef StepBackRequest extends Request {
    public var arguments:StepBackArguments;
}

typedef StepBackArguments {
    public var threadId:Float;
}

typedef StepBackResponse extends Response {
}

typedef RestartFrameRequest extends Request {
    public var arguments:RestartFrameArguments;
}

typedef RestartFrameArguments {
    public var frameId:Float;
}

typedef RestartFrameResponse extends Response {
}

typedef GotoRequest extends Request {
    public var arguments:GotoArguments;
}

typedef GotoArguments {
    public var threadId:Float;
    public var targetId:Float;
}

typedef GotoResponse extends Response {
}

typedef PauseRequest extends Request {
    public var arguments:PauseArguments;
}

typedef PauseArguments {
    public var threadId:Float;
}

typedef PauseResponse extends Response {
}

typedef StackTraceRequest extends Request {
    public var arguments:StackTraceArguments;
}

typedef StackTraceArguments {
    public var threadId:Float;
    public var startFrame?:Float;
    public var levels?:Float;
}

typedef StackTraceResponse extends Response {
    public var body:Dynamic;
}

typedef ScopesRequest extends Request {
    public var arguments:ScopesArguments;
}

typedef ScopesArguments {
    public var frameId:Float;
}

typedef ScopesResponse extends Response {
    public var body:Dynamic;
}

typedef VariablesRequest extends Request {
    public var arguments:VariablesArguments;
}

typedef VariablesArguments {
    public var variablesReference:Float;
    public var filter?:Dynamic;
    public var null;
    public var "named";
    public var start?:Float;
    public var count?:Float;
}

typedef VariablesResponse extends Response {
    public var body:Dynamic;
}

typedef SetVariableRequest extends Request {
    public var arguments:SetVariableArguments;
}

typedef SetVariableArguments {
    public var variablesReference:Float;
    public var name:String;
    public var value:String;
}

typedef SetVariableResponse extends Response {
    public var body:Dynamic;
}

typedef SourceRequest extends Request {
    public var arguments:SourceArguments;
}

typedef SourceArguments {
    public var sourceReference:Float;
}

typedef SourceResponse extends Response {
    public var body:Dynamic;
}

typedef ThreadsRequest extends Request {
}

typedef ThreadsResponse extends Response {
    public var body:Dynamic;
}

typedef ModulesRequest extends Request {
    public var arguments:ModulesArguments;
}

typedef ModulesArguments {
    public var startModule?:Float;
    public var moduleCount?:Float;
}

typedef ModulesResponse extends Response {
    public var body:Dynamic;
}

typedef EvaluateRequest extends Request {
    public var arguments:EvaluateArguments;
}

typedef EvaluateArguments {
    public var expression:String;
    public var frameId?:Float;
    public var context?:String;
}

typedef EvaluateResponse extends Response {
    public var body:Dynamic;
}

typedef StepInTargetsRequest extends Request {
    public var arguments:StepInTargetsArguments;
}

typedef StepInTargetsArguments {
    public var frameId:Float;
}

typedef StepInTargetsResponse extends Response {
    public var body:Dynamic;
}

typedef GotoTargetsRequest extends Request {
    public var arguments:GotoTargetsArguments;
}

typedef GotoTargetsArguments {
    public var source:Source;
    public var line:Float;
    public var column?:Float;
}

typedef GotoTargetsResponse extends Response {
    public var body:Dynamic;
}

typedef CompletionsRequest extends Request {
    public var arguments:CompletionsArguments;
}

typedef CompletionsArguments {
    public var frameId?:Float;
    public var text:String;
    public var column:Float;
    public var line?:Float;
}

typedef CompletionsResponse extends Response {
    public var body:Dynamic;
}

typedef CompletionItem {
    public var label:String;
    public var text?:String;
    public var start?:Float;
    public var length?:Float;
}

typedef Capabilites {
    public var supportsConfigurationDoneRequest?:Bool;
    public var supportsFunctionBreakpoints?:Bool;
    public var supportsConditionalBreakpoints?:Bool;
    public var supportsEvaluateForHovers?:Bool;
    public var exceptionBreakpointFilters?:Dynamic;
    public var supportsStepBack?:Bool;
    public var supportsSetVariable?:Bool;
    public var supportsRestartFrame?:Bool;
    public var supportsGotoTargetsRequest?:Bool;
    public var supportsStepInTargetsRequest?:Bool;
    public var supportsCompletionsRequest?:Bool;
}

typedef ExceptionBreakpointsFilter {
    public var filter:String;
    public var label:String;
    public var null?:Bool;
}

typedef Message {
    public var id:Float;
    public var format:String;
    public var variables?:Dynamic;
    public var sendTelemetry?:Bool;
    public var showUser?:Bool;
    public var url?:String;
    public var urlLabel?:String;
}

typedef Module {
    public var id:Dynamic;
    public var null;
    public var name:String;
    public var path?:String;
    public var isOptimized?:Bool;
    public var isUserCode?:Bool;
    public var version?:String;
    public var symbolStatus?:String;
    public var symbolFilePath?:String;
    public var dateTimeStamp?:String;
    public var addressRange?:String;
}

typedef ColumnDescriptor {
    public var attributeName:String;
    public var label:String;
    public var format:String;
    public var width:Float;
}

typedef ModulesViewDescriptor {
    public var columns:Dynamic;
}

typedef Thread {
    public var id:Float;
    public var name:String;
}

typedef Source {
    public var name?:String;
    public var path?:String;
    public var sourceReference?:Float;
    public var origin?:String;
    public var adapterData?:Dynamic;
}

typedef StackFrame {
    public var id:Float;
    public var name:String;
    public var source?:Source;
    public var line:Float;
    public var column:Float;
    public var endLine?:Float;
    public var endColumn?:Float;
}

typedef Scope {
    public var name:String;
    public var variablesReference:Float;
    public var namedVariables?:Float;
    public var indexedVariables?:Float;
    public var expensive:Bool;
}

typedef Variable {
    public var name:String;
    public var type?:String;
    public var value:String;
    public var kind?:String;
    public var variablesReference:Float;
    public var namedVariables?:Float;
    public var indexedVariables?:Float;
}

typedef SourceBreakpoint {
    public var line:Float;
    public var column?:Float;
    public var condition?:String;
}

typedef FunctionBreakpoint {
    public var name:String;
    public var condition?:String;
}

typedef Breakpoint {
    public var id?:Float;
    public var verified:Bool;
    public var message?:String;
    public var source?:Source;
    public var line?:Float;
    public var column?:Float;
    public var endLine?:Float;
    public var endColumn?:Float;
}

typedef StepInTarget {
    public var id:Float;
    public var label:String;
}

typedef GotoTarget {
    public var id:Float;
    public var label:String;
    public var line:Float;
    public var column?:Float;
    public var endLine?:Float;
    public var endColumn?:Float;
}
*/