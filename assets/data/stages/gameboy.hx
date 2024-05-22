import flixel.FlxSprite;
import funkin.game.PlayState;
public var led:FlxSprite;

function postCreate(){
	dad.alpha = boyfriend.alpha = gf.alpha = 0;
	FlxG.camera.setFilters([]);
	led = new FlxSprite(290,238);
	led.frames = Paths.getFrames('stages/gameboy/GAMEBOY');
	led.antialiasing=false;
	led.animation.add('fuck', [0],12,false);
	led.animation.addByPrefix('intro', 'GAMEBOY animationintro', 12,false);
	led.animation.addByPrefix('idle', 'GAMEBOY static', 12,false);
	led.scale.set(11,11);
	led.animation.play('fuck');
	
	insert(members.indexOf(rocks)+1,led);
	PlayState.instance.stage.stageSprites.set("led",led);
}
function beatHit(curBeat:Int){
	if(curBeat==0){
		led.animation.play('intro');
		led.animation.finishCallback = function(_){
			led.animation.play('idle');
			led.alpha =dad.alpha = gf.alpha= boyfriend.alpha = 1;
	
		}
	}
		
}
function postUpdate(elapsed){
	camFollow.setPosition(500,350);
}
