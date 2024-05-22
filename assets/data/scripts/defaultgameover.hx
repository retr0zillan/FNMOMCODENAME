import flixel.FlxSprite;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import funkin.game.Character;
import funkin.game.PlayState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import funkin.savedata.SaveGames;
import flixel.FlxCamera;
var character:Character;

public var characterName:String;
public var gameOverSong:String;
public var gameOverSongBPM:Float;
public var lossSFXName:String;
public var retrySFX:String;
var explosion:FlxSprite;
var blackScreen:FlxSprite;
var lifelost:FlxSound;
var retry:FlxText;
var camFollow:FlxObject;
var isEnding:Bool = false;
var canEnter:Bool=false;


public var game:PlayState = PlayState.instance; // shortcut
var blackSqr:FlxSprite;
var canExit:Bool=false;

var x:Float = 0;
var y:Float = 0;
var overlayCam:FlxCamera;
public var lossSFX:FlxSound;

function create(event){

	FlxG.cameras.add(overlayCam = new FlxCamera(), false);
    overlayCam.bgColor = '#00000000';

	overlayCam.addShader(crt);

	x = game.boyfriend.x;
	y = game.boyfriend.y;
	characterName = game.boyfriend.curCharacter;


	event.cancel();

	trace(characterName);


	camFollow = new FlxObject(game.camFollow.x, game.camFollow.y, 1, 1);
	add(camFollow);

	FlxG.camera.target = camFollow;

	blackSqr = new FlxSprite(0,0).makeSolid(FlxG.width, FlxG.height, 0xFF000000);
	blackSqr.alpha = 1/99999999;
	blackSqr.cameras = [overlayCam];

	add(blackSqr);

	retry=new FlxText(0,0, 0, 'GAME   OVER', 80);
	retry.font = Paths.font('nes-godzilla.ttf');
	retry.screenCenter();
	retry.scrollFactor.set();
	retry.cameras = [overlayCam];
	retry.alpha = 1/9999999;
	add(retry);



		doGameOver();

		
	trace("hello im deadscreen");
}
function update(elapsed:Float){
	if (controls.ACCEPT && canEnter)
		{
			endBullshit();
		}

		if (controls.BACK && canExit)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new ModState("SelectState"));
			else
				FlxG.switchState(new FreeplayState());
		}
}

function destroy(){
	overlayCam.setFilters([]);
	overlayCam.destroy();
}

function doGameOver(){

		FlxTween.tween(blackSqr,{alpha:1}, 0.4, {onComplete: function(_){
			FlxTween.tween(retry, {alpha:1}, 0.3, {onComplete: function(_) {
				canExit=true;
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music('game_oversdfsdf'));

				canEnter=true;
			}});
		}});
		
		


}
function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			
				FlxG.camera.fade(0xFF000000, 2, false, function()
				{
					if(PlayState.isStoryMode)
					FlxG.switchState(new ModState('BoardState'));
					else
						FlxG.switchState(new PlayState());

				});
			
		}
	}
	