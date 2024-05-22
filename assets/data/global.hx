import funkin.backend.scripting.ModState;
import funkin.menus.NewStoryMenuState.BoardTile;
import funkin.menus.NewStoryMenuState.GodziChar;

import MoarUtils;
import Xml;

static var crt:CustomShader  = new CustomShader("vcrshader");
static var curBoss:GodziChar;
var updater:Float = 0;
static var MoarUtils = new MoarUtils();
static var redirectStates:Map<FlxState, String> = [
        TitleState => "TitleScreenState",
        MainMenuState => "SelectState",
        FreeplayState => "FreeplayState",


];
static var BoardState:ModState;
function new(){
	if(FlxG.save.data.shaders==null)FlxG.save.data.shaders==true;
	
}
function preStateCreate(){

	
	@:privateAccess
	if(FlxG.camera._filters==null && FlxG.save.data.shaders){
		FlxG.camera.setFilters([]);
		FlxG.camera.addShader(crt);
		trace("adding crt shader");

	}
	
}
function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}
function update(elapsed:Float){
	updater+=elapsed;
	crt.time = updater;
    if (FlxG.keys.justPressed.F5) FlxG.resetState();
}
