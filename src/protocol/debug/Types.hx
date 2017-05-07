package protocol.debug;

import haxe.extern.EitherType;
import haxe.DynamicAccess;

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
    runInTerminal request; value of command field is 'runInTerminal'.
    With this request a debug adapter can run a command in a terminal.
*/
typedef RunInTerminalRequest = Request<RunInTerminalRequestArguments>;

@:enum
abstract RunInTerminalRequestArgumentsKind(String) to String {
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
    @:optional var kind:RunInTerminalRequestArgumentsKind;

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
    @:optional var env:DynamicAccess<String>;
};

/**
    Response to Initialize request.
**/
typedef RunInTerminalResponse = Response<{
    /**
        The process ID
    **/
    @:optional var processId:Int;
}>;

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
    Initialize request; value of command field is 'initialize'.
*/
typedef InitializeRequest = Request<InitializeRequestArguments>;

@:enum
abstract InitializeRequestArgumentsPathFormat(String) to String {
    var path = "path";
    var uri = "uri";
}

/**
    Arguments for 'initialize' request.
**/
typedef InitializeRequestArguments = {
    /**
        The ID of the (frontend) client using this adapter.
    **/
    @:optional var clientID:String;

    /**
        The ID of the debug adapter.
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
    @:optional var pathFormat:InitializeRequestArgumentsPathFormat;

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
    Response to 'initialize' request.
**/
typedef InitializeResponse = Response<Capabilities>;

/** ConfigurationDone request; value of command field is 'configurationDone'.
    The client of the debug protocol must send this request at the end of the sequence of configuration requests (which was started by the InitializedEvent).
**/
typedef ConfigurationDoneRequest = Request<ConfigurationDoneArguments>;

/** Arguments for 'configurationDone' request.
    The configurationDone request has no standardized attributes.
*/
typedef ConfigurationDoneArguments = {};

/**
    Response to 'configurationDone' request. This is just an acknowledgement, so no body field is required.
**/
typedef ConfigurationDoneResponse = Response<{}>;

/**
    Launch request; value of command field is 'launch'.
*/
typedef LaunchRequest = Request<LaunchRequestArguments>;

/**
    Arguments for 'launch' request.
*/
typedef LaunchRequestArguments = {
    /*
        If noDebug is true the launch request should launch the program without enabling debugging.
    */
    @:optional var noDebug:Bool;
};

/**
    Response to 'launch' request. This is just an acknowledgement, so no body field is required.
*/
typedef LaunchResponse = Response<{}>;

/**
    Attach request; value of command field is 'attach'.
**/
typedef AttachRequest = Request<AttachRequestArguments>;

/**
    Arguments for 'attach' request.
    The attach request has no standardized attributes.
**/
typedef AttachRequestArguments = {};

/**
    Response to 'attach' request. This is just an acknowledgement, so no body field is required.
**/
typedef AttachResponse = Response<{}>;


/** Restart request; value of command field is 'restart'.
    Restarts a debug session. If the capability 'supportsRestartRequest' is missing or has the value false,
    the client will implement 'restart' by terminating the debug adapter first and then launching it anew.
    A debug adapter can override this default behaviour by implementing a restart request
    and setting the capability 'supportsRestartRequest' to true.
*/
typedef RestartRequest = Request<RestartArguments>;

/** Arguments for 'restart' request.
    The restart request has no standardized attributes.
*/
typedef RestartArguments = {}

/** Response to 'restart' request. This is just an acknowledgement, so no body field is required. */
typedef RestartResponse = Response<{}>;

/**
    Disconnect request; value of command field is 'disconnect'.
**/
typedef DisconnectRequest = Request<DisconnectArguments>;

/**
    Arguments for 'disconnect' request.
**/
typedef DisconnectArguments = {
    /** Indicates whether the debuggee should be terminated when the debugger is disconnected.
        If unspecified, the debug adapter is free to do whatever it thinks is best.
        A client can only rely on this attribute being properly honored if a debug adapter returns true for the 'supportTerminateDebuggee' capability.
    **/
    @:optional var terminateDebuggee:Bool;
};

/** Response to 'disconnect' request. This is just an acknowledgement, so no body field is required. **/
typedef DisconnectResponse = Response <{}>;

/** SetBreakpoints request; value of command field is 'setBreakpoints'.
    Sets multiple breakpoints for a single source and clears all previous breakpoints in that source.
    To clear all breakpoint for a source, specify an empty array.
    When a breakpoint is hit, a StoppedEvent (event type 'breakpoint') is generated.
**/
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
    @:deprecated
    @:optional var lines:Array<Int>;

    /**
        A value of true indicates that the underlying source has been modified which results in new breakpoint locations.
    */
    @:optional var sourceModified:Bool;
}

/** Response to 'setBreakpoints' request.
    Returned is information about each breakpoint created by this request.
    This includes the actual code location and whether the breakpoint could be verified.
    The breakpoints returned are in the same order as the elements of the 'breakpoints'
    (or the deprecated 'lines') in the SetBreakpointsArguments.
**/
typedef SetBreakpointsResponse = Response<{
    /** Information about the breakpoints. The array elements are in the same order as the elements of the 'breakpoints' (or the deprecated 'lines') in the SetBreakpointsArguments. */
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

/** Scopes request; value of command field is 'scopes'.
    The request returns the variable scopes for a given stackframe ID.
**/
typedef ScopesRequest = Request<ScopesArguments>;

/** Arguments for 'scopes' request. */
typedef ScopesArguments = {
    /** Retrieve the scopes for this stackframe. */
    var frameId:Int;
}

/** Response to 'scopes' request. */
typedef ScopesResponse = Response<{
    /** The scopes of the stackframe. If the array has length zero, there are no scopes available. */
    var scopes:Array<Scope>;
}>;

/** Variables request; value of command field is 'variables'.
    Retrieves all child variables for the given variable reference.
    An optional filter can be used to limit the fetched children to either named or indexed children.
**/
typedef VariablesRequest = Request<VariablesArguments>;

@:enum
abstract VariableArgumentsFilter(String) to String {
    var indexed = "indexed";
    var named = "named";
}

/** Arguments for 'variables' request. */
typedef VariablesArguments = {
    /** The Variable reference. */
    var variablesReference:Int;

    /** Optional filter to limit the child variables to either named or indexed. If ommited, both types are fetched. */
    @:optional var filter:VariableArgumentsFilter;

    /** The index of the first variable to return; if omitted children start at 0. */
    @:optional var start:Int;

    /** The number of variables to return. If count is missing or 0, all variables are returned. */
    @:optional var count:Int;

    /** Specifies details on how to format the Variable values. */
    @:optional var format:ValueFormat;
}

/** Response to 'variables' request. */
typedef VariablesResponse = Response<{
    /** All (or a range) of variables for the given variable reference. */
    var variables:Array<Variable>;
}>;

/** Provides formatting information for a value. */
typedef ValueFormat = {
    /** Display the value in hex. */
    @:optional var hex:Bool;
}

typedef SetVariableRequest = Request<SetVariableArguments>;

/** Arguments for 'setVariable' request. */
typedef SetVariableArguments = {
    /** The reference of the variable container. */
    var variablesReference:Int;
    /** The name of the variable. */
    var name:String;
    /** The value of the variable. */
    var value:String;
    /** Specifies details on how to format the response value. */
    @:optional var format:ValueFormat;
}

/** Response to 'setVariable' request. */
typedef SetVariableResponse = Response<{
    /** The new value of the variable. */
    var value:String;

    /** The type of the new value. Typically shown in the UI when hovering over the value. */
    @:optional var type:String;

    /** If variablesReference is > 0, the new value is structured and its children can be retrieved by passing variablesReference to the VariablesRequest. */
    @:optional var variablesReference:Int;

    /** The number of named child variables.
        The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
    */
    @:optional var namedVariables:Int;
    /** The number of indexed child variables.
        The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
    */
    @:optional var indexedVariables:Int;
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


/** ExceptionInfoRequest request; value of command field is 'exceptionInfo'.
    Retrieves the details of the exception that caused the StoppedEvent to be raised.
*/
typedef ExceptionInfoRequest = Request<ExceptionInfoArguments>;

/** Arguments for 'exceptionInfo' request. */
typedef ExceptionInfoArguments = {
    /** Thread for which exception information should be retrieved. */
    var threadId:Int;
}

/** Response to 'exceptionInfo' request. */
typedef ExceptionInfoResponse = Response<TExceptionInfoResponse>;

typedef TExceptionInfoResponse = {
    /** ID of the exception that was thrown. */
    var exceptionId:String;
    /** Descriptive text for the exception provided by the debug adapter. */
    @:optional var description:String;
    /** Mode that caused the exception notification to be raised. */
    var breakMode:ExceptionBreakMode;
    /** Detailed information about the exception. */
    @:optional var details:ExceptionDetails;
}

/** This enumeration defines all possible conditions when a thrown exception should result in a break.
    never: never breaks,
    always: always breaks,
    unhandled: breaks when excpetion unhandled,
    userUnhandled: breaks if the exception is not handled by user code.
*/
@:enum abstract ExceptionBreakMode(String) to String {
    var never = 'never';
    var always = 'always';
    var unhandled = 'unhandled';
    var userUnhandled = 'userUnhandled';
}

/** Detailed information about an exception that has occurred. */
typedef ExceptionDetails = {
    /** Message contained in the exception. */
    @:optional var message:String;
    /** Short type name of the exception object. */
    @:optional var typeName:String;
    /** Fully-qualified type name of the exception object. */
    @:optional var fullTypeName:String;
    /** Optional expression that can be evaluated in the current scope to obtain the exception object. */
    @:optional var evaluateName:String;
    /** Stack trace at the time the exception was thrown. */
    @:optional var stackTrace:String;
    /** Details of the exception contained by this exception, if any. */
    @:optional var innerException:Array<ExceptionDetails>;
}

/**
    Information about the capabilities of a debug adapter.
**/
typedef Capabilities = {
    /** The debug adapter supports the configurationDoneRequest. */
    @:optional var supportsConfigurationDoneRequest:Bool;
    /** The debug adapter supports function breakpoints. */
    @:optional var supportsFunctionBreakpoints:Bool;
    /** The debug adapter supports conditional breakpoints. */
    @:optional var supportsConditionalBreakpoints:Bool;
    /** The debug adapter supports breakpoints that break execution after a specified number of hits. */
    @:optional var supportsHitConditionalBreakpoints:Bool;
    /** The debug adapter supports a (side effect free) evaluate request for data hovers. */
    @:optional var supportsEvaluateForHovers:Bool;
    /** Available filters or options for the setExceptionBreakpoints request. */
    @:optional var exceptionBreakpointFilters:Array<ExceptionBreakpointsFilter>;
    /** The debug adapter supports stepping back via the stepBack and reverseContinue requests. */
    @:optional var supportsStepBack:Bool;
    /** The debug adapter supports setting a variable to a value. */
    @:optional var supportsSetVariable:Bool;
    /** The debug adapter supports restarting a frame. */
    @:optional var supportsRestartFrame:Bool;
    /** The debug adapter supports the gotoTargetsRequest. */
    @:optional var supportsGotoTargetsRequest:Bool;
    /** The debug adapter supports the stepInTargetsRequest. */
    @:optional var supportsStepInTargetsRequest:Bool;
    /** The debug adapter supports the completionsRequest. */
    @:optional var supportsCompletionsRequest:Bool;
    /** The debug adapter supports the modules request. */
    @:optional var supportsModulesRequest:Bool;
    /** The set of additional module information exposed by the debug adapter. */
    @:optional var additionalModuleColumns:Array<ColumnDescriptor>;
    /** Checksum algorithms supported by the debug adapter. */
    @:optional var supportedChecksumAlgorithms:Array<ChecksumAlgorithm>;
    /** The debug adapter supports the RestartRequest. In this case a client should not implement 'restart' by terminating and relaunching the adapter but by calling the RestartRequest. */
    @:optional var supportsRestartRequest:Bool;
    /** The debug adapter supports 'exceptionOptions' on the setExceptionBreakpoints request. */
    @:optional var supportsExceptionOptions:Bool;
    /** The debug adapter supports a 'format' attribute on the stackTraceRequest, variablesRequest, and evaluateRequest. */
    @:optional var supportsValueFormattingOptions:Bool;
    /** The debug adapter supports the exceptionInfo request. */
    @:optional var supportsExceptionInfoRequest:Bool;
    /** The debug adapter supports the 'terminateDebuggee' attribute on the 'disconnect' request. */
    @:optional var supportTerminateDebuggee:Bool;
}

/**
    Names of checksum algorithms that may be supported by a debug adapter.
**/
@:enum
abstract ChecksumAlgorithm(String) to String {
    var MD5 = 'MD5';
    var SHA1 = 'SHA1';
    var SHA256 = 'SHA256';
    var timestamp = 'timestamp';
}

typedef ExceptionBreakpointsFilter = {
    var filter:String;
    var label:String;
    //@:optional var default:Bool;
}

typedef Message = {
    var id:Int;
    var format:String;
    @:optional var variables:DynamicAccess<String>;
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

/**
    A Source is a descriptor for source code.
    It is returned from the debug adapter as part of a StackFrame and it is used by clients when specifying breakpoints.
**/
typedef Source = {
    /** The short name of the source. Every source returned from the debug adapter has a name. When sending a source to the debug adapter this name is optional. */
    @:optional var name:String;
    /** The path of the source to be shown in the UI. It is only used to locate and load the content of the source if no sourceReference is specified (or its vaule is 0). */
    @:optional var path:String;
    /** If sourceReference > 0 the contents of the source must be retrieved through the SourceRequest (even if a path is specified). A sourceReference is only valid for a session, so it must not be used to persist a source. */
    @:optional var sourceReference:Int;
    /** An optional hint for how to present the source in the UI. A value of 'deemphasize' can be used to indicate that the source is not available or that it is skipped on stepping. */
    @:optional var presentationHint:SourcePresentationHint;
    /** The (optional) origin of this source: possible values 'internal module', 'inlined content from source map', etc. */
    @:optional var origin:String;
    /** Optional data that a debug adapter might want to loop through the client. The client should leave the data intact and persist it across sessions. The client should not interpret the data. */
    @:optional var adapterData:Dynamic;
    /** The checksums associated with this file. */
    @:optional var checksums:Array<Checksum>;
}

/** The checksum of an item calculated by the specified algorithm. */
typedef Checksum = {
    /** The algorithm used to calculate this checksum. */
    var algorithm:ChecksumAlgorithm;
    /** Value of the checksum. */
    var checksum:String;
}

@:enum abstract SourcePresentationHint(String) to String {
    var emphasize = 'emphasize';
    var deemphasize = 'deemphasize';
}

@:enum
abstract StackFramePresentationHint(String) to String {
    var normal = 'normal';
    var label = 'label';
}

/**
    A Stackframe contains the source location.
**/
typedef StackFrame = {
    /**
        An identifier for the stack frame. It must be unique across all threads.
        This id can be used to retrieve the scopes of the frame with the 'scopesRequest' or to restart the execution of a stackframe.
    **/
    var id:Int;

    /**
        The name of the stack frame, typically a method name.
    **/
    var name:String;

    /**
        The optional source of the frame.
    **/
    @:optional var source:Source;

    /**
        The line within the file of the frame. If source is null or doesn't exist, line is 0 and must be ignored.
    **/
    var line:Int;

    /**
        The column within the line. If source is null or doesn't exist, column is 0 and must be ignored.
    **/
    var column:Int;

    /**
        An optional end line of the range covered by the stack frame.
    **/
    @:optional var endLine:Int;

    /**
        An optional end column of the range covered by the stack frame.
    **/
    @:optional var endColumn:Int;

    /**
        The module associated with this frame, if any.
    **/
    @:optional var moduleId:EitherType<Int,String>;

    /**
        An optional hint for how to present this frame in the UI.
        A value of 'label' can be used to indicate that the frame is an artificial frame that is used as a visual label or separator.
    **/
    @:optional var presentationHint:StackFramePresentationHint;
}

/** A Scope is a named container for variables. Optionally a scope can map to a source or a range within a source. */
typedef Scope = {
    /** Name of the scope such as 'Arguments', 'Locals'. */
    var name:String;
    /** The variables of this scope can be retrieved by passing the value of variablesReference to the VariablesRequest. */
    var variablesReference:Int;
    /** The number of named variables in this scope.
        The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
    */
    @:optional var namedVariables:Int;
    /** The number of indexed variables in this scope.
        The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
    */
    @:optional var indexedVariables:Int;
    /** If true, the number of variables in this scope is large or expensive to retrieve. */
    var expensive:Bool;
    /** Optional source for this scope. */
    @:optional var source:Source;
    /** Optional start line of the range covered by this scope. */
    @:optional var line:Int;
    /** Optional start column of the range covered by this scope. */
    @:optional var column:Int;
    /** Optional end line of the range covered by this scope. */
    @:optional var endLine:Int;
    /** Optional end column of the range covered by this scope. */
    @:optional var endColumn:Int;
}

/** A Variable is a name/value pair.
    Optionally a variable can have a 'type' that is shown if space permits or when hovering over the variable's name.
    An optional 'kind' is used to render additional properties of the variable, e.g. different icons can be used to indicate that a variable is public or private.
    If the value is structured (has children), a handle is provided to retrieve the children with the VariablesRequest.
    If the number of named or indexed children is large, the numbers should be returned via the optional 'namedVariables' and 'indexedVariables' attributes.
    The client can use this optional information to present the children in a paged UI and fetch them in chunks.
*/
typedef Variable = {
    /** The variable's name. */
    var name:String;
    /** The variable's value. This can be a multi-line text, e.g. for a function the body of a function. */
    var value:String;
    /** The type of the variable's value. Typically shown in the UI when hovering over the value. */
    @:optional var type:String;
    /** Properties of a variable that can be used to determine how to render the variable in the UI. Format of the string value: TBD. */
    @:optional var kind:String;
    /** Optional evaluatable name of this variable which can be passed to the 'EvaluateRequest' to fetch the variable's value. */
    @:optional var evaluateName:String;
    /** If variablesReference is > 0, the variable is structured and its children can be retrieved by passing variablesReference to the VariablesRequest. */
    var variablesReference:Int;
    /** The number of named child variables.
        The client can use this optional information to present the children in a paged UI and fetch them in chunks.
    */
    @:optional var namedVariables:Int;
    /** The number of indexed child variables.
        The client can use this optional information to present the children in a paged UI and fetch them in chunks.
    */
    @:optional var indexedVariables:Int;
}

/**
    Properties of a breakpoint passed to the setBreakpoints request.
**/
typedef SourceBreakpoint = {
    /**
        The source line of the breakpoint.
    **/
    var line:Int;

    /**
        An optional source column of the breakpoint.
    **/
    @:optional var column:Int;

    /**
        An optional expression for conditional breakpoints.
    **/
    @:optional var condition:String;

    /**
        An optional expression that controls how many hits of the breakpoint are ignored.
        The backend is expected to interpret the expression as needed.
    **/
    @:optional var hitCondition:String;
}

typedef FunctionBreakpoint = {
    var name:String;
    @:optional var condition:String;
}

/**
    Information about a Breakpoint created in setBreakpoints or setFunctionBreakpoints.
**/
typedef Breakpoint = {
    /** An optional unique identifier for the breakpoint. */
    @:optional var id:Int;
    /** If true breakpoint could be set (but not necessarily at the desired location). */
    var verified:Bool;
    /** An optional message about the state of the breakpoint. This is shown to the user and can be used to explain why a breakpoint could not be verified. */
    @:optional var message:String;
    /** The source where the breakpoint is located. */
    @:optional var source:Source;
    /** The start line of the actual range covered by the breakpoint. */
    @:optional var line:Int;
    /** An optional start column of the actual range covered by the breakpoint. */
    @:optional var column:Int;
    /** An optional end line of the actual range covered by the breakpoint. */
    @:optional var endLine:Int;
    /** An optional end column of the actual range covered by the breakpoint. If no end line is given, then the end column is assumed to be in the start line. */
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