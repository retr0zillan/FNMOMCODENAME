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


	

	game.remove(game.boyfriend);
	character = new Character(x, y, characterName, true);
	var prevAnim = game.boyfriend.animation.curAnim.name;
	character.danceOnBeat = false;
	character.playAnim(prevAnim);

	character.animation.pause();
	add(character);



	camFollow = new FlxObject(game.camFollow.x, game.camFollow.y, 1, 1);
	add(camFollow);

	FlxG.camera.target = camFollow;
	FlxG.sound.playMusic(Paths.music('Lifelost'));

	explosion = new FlxSprite(0,0);
	explosion.frames = Paths.getFrames('game/death/DeathParticle');
	explosion.animation.addByPrefix('explode', 'DeathParticle', 8, true);
	explosion.scale.set(7.5,7.5);
	explosion.updateHitbox();
	explosion.animation.play('explode');
	add(explosion);
	explosion.setPosition(character.getCameraPosition().x + 600, character.getCameraPosition().y + 400);

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


	if(PlayState.isStoryMode){
		switch(PlayState.SONG.meta.name.toLowerCase()){
			case 'amoeba':
			default: 
				storyCheck();
		}
	}
	else
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
function storyCheck(){
	deadGoodGuys.push(daPlayer);
	trace(deadGoodGuys);
	SaveGames.curSave().data.deadGoodGuys=deadGoodGuys;
	trace('got a dead body '+SaveGames.curSave().data.deadGoodGuys);

	SaveGames.curSave().flush();

	FlxTween.tween(character, {y: character.y + 800}, 6);
	FlxTween.tween(explosion, {y: explosion.y + 800}, 6);

	if(deadGoodGuys.length>=2){
		trace('no more characters left');
		restartData();

		doGameOver();
	}
	else{
		new FlxTimer().start(5, function(_){
			trace('more characters left');

			endBullshit();

		});
	}
}
function destroy(){
	overlayCam.setFilters([]);
	overlayCam.destroy();
}
function restartData(){
	SaveGames.curSave().data.deadassholes=[];
	SaveGames.curSave().data.deadGoodGuys=[];
	SaveGames.curSave().data.daprevHealth = null;
	curCharacter=0;
	prevPos=[];


	SaveGames.curSave().flush();
}
function doGameOver(){
	new FlxTimer().start(6, function(_){
		FlxTween.tween(blackSqr,{alpha:1}, 0.4, {onComplete: function(_){
			FlxTween.tween(retry, {alpha:1}, 0.3, {onComplete: function(_) {
				canExit=true;
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music('game_oversdfsdf'));

				canEnter=true;
			}});
		}});
		
		
	});

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
	