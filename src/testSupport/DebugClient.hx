package testSupport;

import protocol.debug.Types;
import js.lib.Promise;

@:jsRequire("vscode-debugadapter-testsupport", "DebugClient")
extern class DebugClient {
	var defaultTimeout:Int;
	function new(runtime:String, executable:String, debugType:String);
	function start(?port:Int):Promise<Dynamic>;
	function stop():Promise<Dynamic>;
	function initializeRequest(?args:InitializeRequestArguments):Promise<InitializeResponse>;
	function configurationDoneRequest(?args:ConfigurationDoneArguments):Promise<ConfigurationDoneResponse>;
	function launchRequest(args:LaunchRequestArguments):Promise<LaunchResponse>;
	function attachRequest(args:AttachRequestArguments):Promise<AttachResponse>;
	function disconnectRequest(?args:DisconnectArguments):Promise<DisconnectResponse>;
	function setBreakpointsRequest(args:SetBreakpointsArguments):Promise<SetBreakpointsResponse>;
	function setFunctionBreakpointsRequest(args:SetFunctionBreakpointsArguments):Promise<SetFunctionBreakpointsResponse>;
	function setExceptionBreakpointsRequest(args:SetExceptionBreakpointsArguments):Promise<SetExceptionBreakpointsResponse>;
	function continueRequest(args:ContinueArguments):Promise<ContinueResponse>;
	function nextRequest(args:NextArguments):Promise<NextResponse>;
	function stepInRequest(args:StepInArguments):Promise<StepInResponse>;
	function stepOutRequest(args:StepOutArguments):Promise<StepOutResponse>;
	function pauseRequest(args:PauseArguments):Promise<PauseResponse>;
	function stackTraceRequest(args:StackTraceArguments):Promise<StackTraceResponse>;
	function scopesRequest(args:ScopesArguments):Promise<ScopesResponse>;
	function variablesRequest(args:VariablesArguments):Promise<VariablesResponse>;
	function sourceRequest(args:SourceArguments):Promise<SourceResponse>;
	function threadsRequest():Promise<ThreadsResponse>;
	function evaluateRequest(args:EvaluateArguments):Promise<EvaluateResponse>;
	// ---- convenience methods -----------------------------------------------------------------------------------------------
	/*
	 * Returns a promise that will resolve if an event with a specific type was received within some specified time.
	 * The promise will be rejected if a timeout occurs.
	 */
	public function waitForEvent<T>(eventType:String, ?timeout:Int):Promise<Event<T>>;
	/*
	 * Returns a promise that will resolve if an 'initialized' event was received within some specified time
	 * and a subsequent 'configurationDone' request was successfully executed.
	 * The promise will be rejected if a timeout occurs or if the 'configurationDone' request fails.
	 */
	public function configurationSequence():Promise<Dynamic>;

	/**
	 * Returns a promise that will resolve if a 'initialize' and a 'launch' request were successful.
	 */
	public function launch(launchArgs:Dynamic):Promise<LaunchResponse>;
	/*
	 * Returns a promise that will resolve if a 'stopped' event was received within some specified time
	 * and the event's reason and line number was asserted.
	 * The promise will be rejected if a timeout occurs, the assertions fail, or if the 'stackTrace' request fails.
	 */
	public function assertStoppedLocation(reason:String, expected:{?path:String, ?line:Int, ?column:Int}):Promise<StackTraceResponse>;
	/*
	 * Returns a promise that will resolve if enough output events with the given category have been received
	 * and the concatenated data match the expected data.
	 * The promise will be rejected as soon as the received data cannot match the expected data or if a timeout occurs.
	 */
	public function assertOutput<T>(category:String, expected:String, ?timeout:Int):Promise<Event<T>>;
	public function assertPath(path:String, expected:String, ?message:String):Void;
	// ---- scenarios ---------------------------------------------------------------------------------------------------------

	/**
	 * Returns a promise that will resolve if a configurable breakpoint has been hit within some time
	 * and the event's reason and line number was asserted.
	 * The promise will be rejected if a timeout occurs, the assertions fail, or if the requests fails.
	 */
	public function hitBreakpoint(launchArgs:Dynamic, location:{
		path:String,
		line:Int,
		?column:Int,
		?verified:Bool
	}, ?expected:{
		?path:String,
		?line:Int,
		?column:Int,
		?verified:Bool
	}):Promise<Dynamic>;
}
