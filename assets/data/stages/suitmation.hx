import funkin.backend.shaders.CustomShader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import funkin.game.PlayState;
var game = PlayState.instance;
var overlayCam:FlxCamera;
var vhs:CustomShader;
var glitch:CustomShader;
var twirl:CustomShader;
function create(){
	importScript("data/scripts/loadsuitnotes");

}
function postCreate(){
	camGame.setFilters([]);
	camGame.bgColor = 0x000000;
	FlxG.cameras.add(overlayCam = new FlxCamera(), false);
	overlayCam.bgColor = 0;
	boyfriend.visible = false;




	var clouds = new FlxBackdrop(Paths.image('stages/suitmation/analog_godzilla_cloud2'), 0x01, 0,0);
	clouds.setPosition(0,250);
	clouds.velocity.set(20, 0);
	clouds.antialiasing=true;
	insert(members.indexOf(bg)+1, clouds);
	game.stage.stageSprites.set('clouds',clouds);

	var borders = new FlxSprite(0,0).loadGraphic(Paths.image('stages/suitmation/analog_godzilla_marco'));
	borders.antialiasing=true;
	insert(members.indexOf(dad)+1, borders);
	game.stage.stageSprites.set('borders',borders);

	if(FlxG.save.data.shaders){
		vhs = new CustomShader("vhShader");
		glitch = new CustomShader("glitchShader");
		glitch.display = false;

		camGame.addShader(glitch);

		camGame.addShader(vhs);

	}

}
function onPostNoteCreation(event) {  
    var splashes = event.note;
	
		splashes.splash = "suitmation";
}
var updater:Float = 0;
function onCountdown(event) {

	event.spritePath = switch(event.swagCounter) {
		case 0: null;
		case 1: 'stages/suitmation/ready';
		case 2: 'stages/suitmation/set';
		case 3: 'stages/suitmation/go';
	};
}
function beatHit(curBeat:Int){
	switch(curBeat){
		case 33: 
			dad.playAnim("enter");
		case 69: 
			glitch.display = true;
		case 85:
			glitch.display = false;
			
			FlxG.camera.removeShader(glitch);


	}
}
function update(elapsed:Float){
	FlxG.watch.addQuick("beat", curBeat);
	updater += elapsed;
	if(FlxG.save.data.shaders){
		vhs.time = updater;
	
		glitch.iTime = updater;

	}
}
