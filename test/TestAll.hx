package test;

import protocol.debug.Types;
import adapter.DebugSession;
import testSupport.DebugClient;

class CustomAdapter extends adapter.DebugSession {

    public function new()
    {
        super();
    
        setDebuggerLinesStartAt1(false);
        setDebuggerColumnsStartAt1(false);
    }

    override function initializeRequest(response:InitializeResponse, args:InitializeRequestArguments)
    {
        
        sendEvent(new InitializedEvent());
        // This debug adapter implements the configurationDoneRequest.
        response.body.supportsConfigurationDoneRequest = true;

        // make VS Code to use 'evaluate' when hovering over source
        response.body.supportsEvaluateForHovers = true;

        // make VS Code to show a 'step back' button
        response.body.supportsStepBack = true;
        sendResponse( response );
    }

    override function attachRequest(response:AttachResponse, args:AttachRequestArguments) {} 
}

class TestAll {

    public function new() {
        var ds = new CustomAdapter();
        var testClient = new DebugClient("", "", "node");
    }

    public static function main() {
        new TestAll();
    }
}