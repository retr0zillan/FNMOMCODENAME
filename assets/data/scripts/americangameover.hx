import funkin.backend.scripting.ModState;
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
public var lossSFX:FlxSound;


public var game:PlayState = PlayState.instance; // shortcut
var blackSqr:FlxSprite;
var canExit:Bool=false;

var x:Float = 0;
var y:Float = 0;
var overlayCam:FlxCamera;
public var lossSFX:FlxSound;
var character:Character;

function create(event){
	event.cancel();

	x = game.boyfriend.x;
	y = game.boyfriend.y;
	characterName = game.boyfriend.curCharacter;

	character = new Character(x, y, characterName, true);
	add(character);

	camFollow = new FlxObject(game.camFollow.x, game.camFollow.y, 1, 1);
	add(camFollow);

	FlxG.camera.target = camFollow;

	game.remove(game.boyfriend);

	FlxTween.tween(game.dad, {alpha:0}, 0.5);
	FlxTween.tween(game.gf, {alpha:0}, 0.5);

	FlxTween.tween(game.stage.getSprite("rocks"), {alpha:0}, 0.5);

	character.playAnim('firstDeath');

	lossSFX = FlxG.sound.play(Paths.sound('punchGameboyZilla'));
	Conductor.changeBPM(100);

	

}
 function update(elapsed:Float)
	{
	
		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new ModState("SelectState"));
			else
				FlxG.switchState(new FreeplayState());
		}

	
		if (!isEnding && ((!lossSFX.playing) || (character.getAnimName() == "firstDeath" && character.isAnimFinished())) && (FlxG.sound.music == null || !FlxG.sound.music.playing))
			{
				CoolUtil.playMusic(Paths.music("GAMEOVER"), false, 1, true, 100);
			}

	}

	 function beatHit(curBeat:Int)
		{
		
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				character.playAnim("deathLoop", true, "DANCE");
		}
	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			character.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('continue'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
