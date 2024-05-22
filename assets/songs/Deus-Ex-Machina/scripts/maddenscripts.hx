import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import funkin.game.PlayState;
var game = PlayState.instance;
var ignoreNotes:Bool = false;
var anims:Array<String>=['huhintro', 'huhloop', 'deusExEnd'];

function onNoteHit(event){
	if(event.character!=dad && ignoreNotes && !anims.contains(event.character.animation.curAnim.name)){
		event.preventAnim();
	}
}

function showBoppers(event){
	var cheers = game.stage.stageSprites.get("cheers");
	cheers.alpha=1;

	cheers.animation.play(event == "in" ? "intro":"fade");
	cheers.animation.finishCallback = (animname:String)->{
		switch(animname){
			case "intro":
				cheers.animation.play('idle');

			case "fade":
				cheers.kill();
		}
	}
}
 function melileaves(){
	game.stage.stageSprites.get("melissa").animation.play('end');
    game.stage.stageSprites.get("melissa").animation.finishCallback=function(_){
		game.stage.stageSprites.get("melissa").kill();

    }
}
function melidrop(){
	game.stage.stageSprites.get("melissa").alpha=1;
    game.stage.stageSprites.get("melissa").animation.play('intro');
    game.stage.stageSprites.get("melissa").animation.finishCallback=function(_){
		game.stage.stageSprites.get("melissa").animation.play('idle');

    }
}
function beatHit(curBeat:Int){
	switch(curBeat){
		case 183: 
			ignoreNotes = true;
		case 246: 
			ignoreNotes = false;

	}
}