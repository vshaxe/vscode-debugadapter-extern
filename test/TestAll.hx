package test;
import protocol.debug.Types;
import adapter.DebugSession;

class CustomAdapter extends adapter.DebugSession
{
    public function new()
    {
        super();
    
		setDebuggerLinesStartAt1(false);
		setDebuggerColumnsStartAt1(false);
        
    }

    override function initializeRequest(response:InitializeResponse, args:InitializeRequestArguments):Void
    {
        
        sendEvent(new InitializedEvent());
        var b = new BreakpointEvent(BreakpointEventReason.CHANGED, new Breakpoint(true, 10, 10));
        trace(b.body.reason);
		// This debug adapter implements the configurationDoneRequest.
		response.body.supportsConfigurationDoneRequest = true;

		// make VS Code to use 'evaluate' when hovering over source
		response.body.supportsEvaluateForHovers = true;

		// make VS Code to show a 'step back' button
		response.body.supportsStepBack = true;
        sendResponse( response );
            
    }

    override function attachRequest(response:AttachResponse, args:AttachRequestArguments):Void
    {

    } 
}

class TestAll
{
    public function new()
    {
        var ds = new CustomAdapter();
        
    }

    public static function main()
    {
        new TestAll();
    }
}