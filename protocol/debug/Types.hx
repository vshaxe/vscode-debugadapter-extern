package protocol.debug;

import haxe.extern.EitherType;

@:enum
abstract MessageType(String) from String {
    var request = "request";
    var response = "response";
    var event = "event";
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
    A client or server-initiated request.

    (type: request)
**/
typedef Request<T> = {
    >ProtocolMessage,

    /**
        The command to execute.
    **/
    var command:String;

    /**
        Object containing arguments for the command.
    **/
    @:optional var arguments:T;
}

/**
    Server-initiated event.

    (type: event)
**/
typedef Event<T> = {
    >ProtocolMessage,

    /**
        Type of event.
    **/
    var event:String;

    /**
        Event-specific information.
    **/
    @:optional var body:T;
}

/**
    Response to a request.
**/
typedef Response<T> = {
    >ProtocolMessage,

    /**
        Sequence number of the corresponding request.
    **/
    var request_seq:Int;

    /**
        Outcome of the request.
    **/
    var success:Bool;

    /**
        The command requested.
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

/** Event message for 'initialized' event type.
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

@:enum
abstract StopReason(String) to String {
    var step = "step";
    var breakpoint = "breakpoint";
    var exception = "exception";
    var pause = "pause";
    var entry = "entry";
}

typedef TStoppedEvent = {
    /**
        The reason for the event (such as: 'step', 'breakpoint', 'exception', 'pause', 'entry').
        For backward compatibility this string is shown in the UI if the 'description' attribute is missing (but it must not be translated).
    **/
    var reason: StopReason;

    /**
        The full reason for the event, e.g. 'Paused on exception'. This string is shown in the UI as is.
    **/
    @:optional var description:String;

    /**
        The thread which was stopped.
    **/
    @:optional var threadId:Int;

    /**
        Additional information. E.g. if reason is 'exception', text contains the exception name. This string is shown in the UI.
    **/
    @:optional var text:String;

    /**
        If allThreadsStopped is true, a debug adapter can announce that all threads have stopped.
        *  The client should use this information to enable that all threads can be expanded to access their stacktraces.
        *  If the attribute is missing or false, only the thread with the given threadId can be expanded.
    **/
    @:optional var allThreadsStopped:Bool;
}

/** Event message for 'stopped' event type.
    The event indicates that the execution of the debuggee has stopped due to some condition.
    This can be caused by a break point previously set, a stepping action has completed, by executing a debugger statement etc.
*/
typedef StoppedEvent = Event<TStoppedEvent>;

typedef TContinuedEvent = {
    /**
        The thread which was continued.
    **/
    var threadId:Int;

    /**
        If allThreadsContinued is true, a debug adapter can announce that all threads have continued.
    **/
    @:optional var allThreadsContinued:Bool;
};

/** Event message for 'continued' event type.
    The event indicates that the execution of the debuggee has continued.
    Please note: a debug adapter is not expected to send this event in response to a request that implies that execution continues, e.g. 'launch' or 'continue'.
    It is only necessary to send a ContinuedEvent if there was no previous request that implied this.
**/
typedef ContinuedEvent = Event<TContinuedEvent>;

typedef TExitedEvent = {
    /**
        The exit code returned from the debuggee.
    **/
    var exitCode: Int;
}

/** Event message for 'exited' event type.
    The event indicates that the debuggee has exited.
**/
typedef ExitedEvent = Event<TExitedEvent>;

typedef TTerminatedEvent = {
    /**
        A debug adapter may set 'restart' to true to request that the front end restarts the session.
    **/
    @:optional var restart:Bool;
};

/** Event message for 'terminated' event types.
    The event indicates that debugging of the debuggee has terminated.
**/
typedef TerminatedEvent = Event<TTerminatedEvent>;

@:enum
abstract ThreadEventReason(String) to String {
    var started = "started";
    var exited = "exited";
}

typedef TThreadEvent = {
    /**
        The reason for the event (such as: 'started', 'exited').
    **/
    var reason:ThreadEventReason;

    /**
        The identifier of the thread.
    **/
    var threadId:Int;
}

/** Event message for 'thread' event type.
    The event indicates that a thread has started or exited.
**/
typedef ThreadEvent = Event<TThreadEvent>;

@:enum
abstract OutputEventCategory(String) to String {
    var console = "console";
    var stdout  = "stdout";
    var stderr  = "stderr";
    var telemetry = "telemetry";
}

typedef TOutputEvent = {
    /**
        The category of output (such as: 'console', 'stdout', 'stderr', 'telemetry'). If not specified, 'console' is assumed.
    **/
    @:optional var category:OutputEventCategory;

    /**
        The output to report.
    **/
    var output:String;

    /**
        If an attribute 'variablesReference' exists and its value is > 0,
        the output contains objects which can be retrieved by passing variablesReference to the VariablesRequest.
    */
    @:optional var variablesReference:Int;

    /**
        Optional data to report. For the 'telemetry' category the data will be sent to telemetry, for the other categories the data is shown in JSON format.
    **/
    var data:Dynamic;
}

/** Event message for "output" event type.
    The event indicates that the target has produced output.
**/
typedef OutputEvent = Event<TOutputEvent>;

/**
    The reason for the breakpoint event.
**/
@:enum
abstract BreakpointEventReason(String) to String {
    var eventChanged = "changed";
    var eventNew = "new";
}

typedef TBreakpointEvent = {
    /**
        The reason for the event (such as: 'changed', 'new').
    */
    var reason:BreakpointEventReason;

    /**
        The breakpoint.
    **/
    var breakpoint: Breakpoint;
}

/** Event message for 'breakpoint' event type.
    The event indicates that some information about a breakpoint has changed.
**/
typedef BreakpointEvent = Event<TBreakpointEvent>;

/**
    The reason for the module event.
**/
@:enum
abstract ModuleEventReason(String) to String {
    var eventNew = "new";
    var eventChanged = "changed";
    var eventRemoved = "removed";
}

typedef TModuleEvent = {
    /**
        The reason for the event.
    */
    var reason:ModuleEventReason;

    /**
        The new, changed, or removed module. In case of 'removed' only the module id is used.
    **/
    var module:Module;
}

/** Event message for 'module' event type.
    The event indicates that some information about a module has changed.
**/
typedef ModuleEvent = Event<TModuleEvent>;

//---- Frontend Requests

/**
    runInTerminal request; value of command field is "runInTerminal".
    With this request a debug adapter can run a command in a terminal.
**/
typedef RunInTerminalRequest = Request<RunInTerminalRequestArguments>;

@:enum
abstract RunInTerminalArgumentsKind(String)
{
    var integrated = "integrated";
    var external = "external";
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
    @:optional var env:haxe.DynamicAccess<String>;
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

/**
    Initialize request; value of command field is "initialize".
*/
typedef InitializeRequest = Request<InitializeRequestArguments>;

typedef InitializeRequestArguments = {
    /**
    The ID of the debugger adapter. Used to select or verify debugger adapter.
    **/
    var adapterID:String;

    /**
    If true all line numbers are 1-based (default).
    **/
    @:optional var linesStartAt1:Bool;

    /**
    If true all column numbers are 1-based (default).
    **/
    @:optional var columnsStartAt1:Bool;

    /**
    Determines in what format paths are specified. Possible values are 'path' or 'uri'. The default is 'path', which is the native format.
    **/
    @:optional var pathFormat:String;

    /**
    Client supports the optional type attribute for variables.
    **/
    @:optional var supportsVariableType:Bool;

    /**
    Client supports the paging of variables.
    **/
    @:optional var supportsVariablePaging:Bool;

    /**
    Client supports the runInTerminal request.
    **/
    @:optional var supportsRunInTerminalRequest:Bool;
}

/**
    Response to Initialize request.
**/
typedef InitializeResponse = Response<Capabilities>;

/**
    ConfigurationDone request; value of command field is "configurationDone".
    The client of the debug protocol must send this request at the end of the sequence of configuration requests (which was started by the InitializedEvent)
*/
typedef ConfigurationDoneRequest = Request<ConfigurationDoneArguments>;

/**
    Arguments for "configurationDone" request.
**/
typedef ConfigurationDoneArguments = {
    /* The configurationDone request has no standardized attributes. */
};

/**
 Response to "configurationDone" request. This is just an acknowledgement, so no body field is required.
**/
typedef ConfigurationDoneResponse = Response<{}>;

/**
    Launch request; value of command field is "launch".
*/
typedef LaunchRequest = Request<LaunchRequestArguments>;

/**
    Arguments for "launch" request.
*/
typedef LaunchRequestArguments = {
    /*
    If noDebug is true the launch request should launch the program without enabling debugging.
    */
    @:optional var noDebug:Bool;
};

/**
    Response to "launch" request. This is just an acknowledgement, so no body field is required.
*/
typedef LaunchResponse = Response<{}>;

typedef AttachRequest = Request<AttachRequestArguments>;

typedef AttachRequestArguments = {};

typedef AttachResponse = Response<{}>;

typedef DisconnectRequest = Request<DisconnectArguments>;

typedef DisconnectArguments = {};

typedef DisconnectResponse = Response <{}>;

typedef SetBreakpointsRequest = Request<SetBreakpointsArguments>;

/**
    Arguments for "setBreakpoints" request.
**/
typedef SetBreakpointsArguments = {
    /**
        The source location of the breakpoints; either source.path or source.reference must be specified.
    **/
    var source:Source;

    /**
        The code locations of the breakpoints.
    **/
    @:optional var breakpoints:Array<SourceBreakpoint>;

    /**
        Deprecated: The code locations of the breakpoints.
    */
    @:optional var lines:Array<Int>;

    /**
        A value of true indicates that the underlying source has been modified which results in new breakpoint locations.
    */
    @:optional var sourceModified:Bool;
}

/** Response to "setBreakpoints" request.
        Returned is information about each breakpoint created by this request.
        This includes the actual code location and whether the breakpoint could be verified.
        The breakpoints returned are in the same order as the elements of the 'breakpoints'
        (or the deprecated 'lines') in the SetBreakpointsArguments.
*/
typedef SetBreakpointsResponse = Response<{
    var breakpoints:Array<Breakpoint>;
}>;

typedef SetFunctionBreakpointsRequest = Request<SetFunctionBreakpointsArguments>;

typedef SetFunctionBreakpointsArguments = {
    var breakpoints:Array<FunctionBreakpoint>;
};

typedef SetFunctionBreakpointsResponse = Response<{
    var breakpoints:Array<Breakpoint>;
}>;

typedef SetExceptionBreakpointsRequest = Request<SetExceptionBreakpointsArguments>;


typedef SetExceptionBreakpointsArguments = {
    var filters:Array<String>;
};

typedef SetExceptionBreakpointsResponse = Response<{}>;

typedef ContinueRequest = Request<ContinueArguments>;

typedef ContinueArguments = {
    var threadId:Int;
}

typedef ContinueResponse = Response<{
    @:optional var allThreadsContinued:Bool;
}>

typedef NextRequest = Request<NextArguments>;

typedef NextArguments = {
    var threadId:Int;
}

typedef NextResponse = Response<{}>;

typedef StepInRequest = Request<StepInArguments>;

typedef StepInArguments = {
    var threadId:Int;
    @:optional var targetId:Int;
}

typedef StepInResponse = Response<{}>;

typedef StepOutRequest = Request<StepOutArguments>;

typedef StepOutArguments = {
    var threadId:Int;
}

typedef StepOutResponse = Response<{}>;

typedef StepBackRequest = Request<StepBackArguments>;

typedef StepBackArguments = {
    var threadId:Int;
}

typedef StepBackResponse = Response<{}>;

typedef RestartFrameRequest = Request<RestartFrameArguments>;

typedef RestartFrameArguments = {
    var frameId:Int;
}

typedef RestartFrameResponse = Response<{}>;

typedef GotoRequest = Request<GotoArguments>;

typedef GotoArguments = {
    var threadId:Int;
    var targetId:Int;
}

typedef GotoResponse = Response<{}>;

typedef PauseRequest = Request<PauseArguments>;

typedef PauseArguments = {
    var threadId:Int;
}

typedef PauseResponse = Response<{}>;

typedef StackTraceRequest = Request<StackTraceArguments>;

typedef StackTraceArguments = {
    var threadId:Int;
    @:optional var startFrame:Int;
    @:optional var levels:Int;
}

typedef StackTraceResponse = Response<{
    var stackFrames: Array<StackFrame>;
    /** The total number of frames available. */
    @:optional var totalFrames: Int;
}>;

typedef ScopesRequest = Request<ScopesArguments>;

typedef ScopesArguments = {
    var frameId:Int;
}

typedef ScopesResponse = Response<{
    var scopes:Array<Scope>;
}>;

typedef VariablesRequest = Request<VariablesArguments>;

@:enum
abstract VariableArgumentsFilter(String)
{
    var indexed = "indexed";
    var named   = "named";
}

typedef VariablesArguments = {
    var variablesReference:Int;
    @:optional var filter:VariableArgumentsFilter;
    @:optional var start:Int;
    @:optional var count:Int;
}

typedef VariablesResponse = Response<{
    var variables: Array<Variable>;
}>;

typedef SetVariableRequest = Request<SetVariableArguments>;

typedef SetVariableArguments = {
    var variablesReference:Int;
    var name:String;
    var value:String;
}

typedef SetVariableResponse = Response<{
    var value:String;
}>;

typedef SourceRequest = Request<SourceArguments>;

typedef SourceArguments = {
    var sourceReference:Float;
}

typedef SourceResponse = Response<{
    var content:String;
    @:optional var mimeType:String;
}>;

typedef ThreadsRequest = Request<{}>;

typedef ThreadsResponse = Response<{
    var threads:Array<Thread>;
}>;

typedef ModulesRequest = Request<ModulesArguments>;

typedef ModulesArguments = {
    @:optional var startModule:Int;
    @:optional var moduleCount:Int;
}

typedef ModulesResponse = Response<{
    var modules:Array<Module>;
    var totalModules:Int;
}>;

typedef EvaluateRequest = Request<EvaluateArguments>;

typedef EvaluateArguments = {
    var expression:String;
    @:optional var frameId:Int;
    @:optional var context:String;
}

typedef EvaluateResponse = Response< {
    /** The result of the evaluate request. */
    var result: String;
    /** The optional type of the evaluate result. */
    @:optional var type: String;
    /** If variablesReference is > 0, the evaluate result is structured and its children can be retrieved by passing variablesReference to the VariablesRequest */
    var variablesReference: Int;
    /** The number of named child variables.
        The client can use this optional information to present the variables in a paged UI and fetch them in chunks. */
    @:optional var namedVariables: Int;
    /** The number of indexed child variables.
        The client can use this optional information to present the variables in a paged UI and fetch them in chunks. */
    @:optional var indexedVariables: Int;
}>;

typedef StepInTargetsRequest = Request<StepInTargetsArguments>;

typedef StepInTargetsArguments = {
    var frameId:Int;
}

typedef StepInTargetsResponse = Response< {
    var targets: Array<StepInTarget>;
}>

typedef GotoTargetsRequest = Request<GotoTargetsArguments>;

typedef GotoTargetsArguments = {
    var source:Source;
    var line:Int;
    @:optional var column:Int;
}

typedef GotoTargetsResponse = Response<{
    var targets:Array<GotoTarget>;
}>;

typedef CompletionsRequest = Request<CompletionsArguments>;

typedef CompletionsArguments = {
    @:optional var frameId:Int;
    var text:String;
    var column:Int;
    @:optional var line:Int;
}

typedef CompletionsResponse = Response<{
    /** The possible completions for . */
    var targets:Array<CompletionItem>;
}>;

typedef CompletionItem = {
    var label:String;
    @:optional var text:String;
    @:optional var start:Int;
    @:optional var length:Int;
};

typedef Capabilities = {
    @:optional var supportsConfigurationDoneRequest:Bool;
    @:optional var supportsFunctionBreakpoints:Bool;
    @:optional var supportsConditionalBreakpoints:Bool;
    @:optional var supportsEvaluateForHovers:Bool;
    @:optional var exceptionBreakpointFilters:Array<ExceptionBreakpointsFilter>;
    @:optional var supportsStepBack:Bool;
    @:optional var supportsSetVariable:Bool;
    @:optional var supportsRestartFrame:Bool;
    @:optional var supportsGotoTargetsRequest:Bool;
    @:optional var supportsStepInTargetsRequest:Bool;
    @:optional var supportsCompletionsRequest:Bool;
}

typedef ExceptionBreakpointsFilter = {
    var filter:String;
    var label:String;
    //@:optional var default:Bool;
}

typedef Message = {
    var id:Int;
    var format:String;
    @:optional var variables:haxe.DynamicAccess<String>;
    @:optional var sendTelemetry:Bool;
    @:optional var showUser:Bool;
    @:optional var url:String;
    @:optional var urlLabel:String;
}

/** A Module object represents a row in the modules view.
    Two attributes are mandatory: an id identifies a module in the modules view and is used in a ModuleEvent for identifying a module for adding, updating or deleting.
    The name is used to minimally render the module in the UI.

    Additional attributes can be added to the module. They will show up in the module View if they have a corresponding ColumnDescriptor.

    To avoid an unnecessary proliferation of additional attributes with similar semantics but different names
    we recommend to re-use attributes from the 'recommended' list below first, and only introduce new attributes if nothing appropriate could be found.
**/
typedef Module = {
    /**
        Unique identifier for the module.
    **/
    var id:EitherType<Int,String>;

    /**
        A name of the module.
    **/
    var name:String;

    /**
        Logical full path to the module. The exact definition is implementation defined, but usually this would be a full path to the on-disk file for the module.
    **/
    @:optional var path:String;

    /**
        True if the module is optimized.
    **/
    @:optional var isOptimized:Bool;

    /**
        True if the module is considered 'user code' by a debugger that supports 'Just My Code'.
    **/
    @:optional var isUserCode:Bool;

    /**
        Version of Module.
    **/
    @:optional var version:String;

    /**
        User understandable description of if symbols were found for the module (ex: 'Symbols Loaded', 'Symbols not found', etc.
    **/
    @:optional var symbolStatus:String;

    /**
        Logical full path to the symbol file. The exact definition is implementation defined.
    **/
    @:optional var symbolFilePath:String;

    /**
        Module created or modified.
    **/
    @:optional var dateTimeStamp:String;

    /**
        Address range covered by this module.
    **/
    @:optional var addressRange:String;
}

typedef ColumnDescriptor = {
    var attributeName:String;
    var label:String;
    var format:String;
    var width:Int;
}

typedef ModulesViewDescriptor = {
    var columns:Array<ColumnDescriptor>;
}

typedef Thread = {
    var id:Int;
    var name:String;
}

typedef Source = {
    @:optional var name:String;
    @:optional var path:String;
    @:optional var sourceReference:Int;
    @:optional var origin:String;
    @:optional var adapterData:Dynamic;
}

typedef StackFrame = {
    var id:Int;
    var name:String;
    @:optional var source:Source;
    var line:Int;
    var column:Int;
    @:optional var endLine:Int;
    @:optional var endColumn:Int;
}

typedef Scope = {
    var name:String;
    var variablesReference:Int;
    @:optional var namedVariables:Int;
    @:optional var indexedVariables:Int;
    var expensive:Bool;
}

typedef Variable = {
    var name:String;
    @:optional var type:String;
    var value:String;
    @:optional var kind:String;
    var variablesReference:Int;
    @:optional var namedVariables:Int;
    @:optional var indexedVariables:Int;
}

typedef SourceBreakpoint = {
    var line:Int;
    @:optional var column:Int;
    @:optional var condition:String;
}

typedef FunctionBreakpoint = {
    var name:String;
    @:optional var condition:String;
}

typedef Breakpoint = {
    @:optional var id:Int;
    var verified:Bool;
    @:optional var message:String;
    @:optional var source:Source;
    @:optional var line:Int;
    @:optional var column:Int;
    @:optional var endLine:Int;
    @:optional var endColumn:Int;
}

typedef StepInTarget = {
    var id:Int;
    var label:String;
}

typedef GotoTarget = {
    var id:Int;
    var label:String;
    var line:Int;
    @:optional var column:Int;
    @:optional var endLine:Int;
    @:optional var endColumn:Int;
}