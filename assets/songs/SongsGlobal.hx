import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import haxe.iterators.ArrayIterator;
import funkin.backend.scripting.ModState;
import funkin.backend.system.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.PlayState;
import openfl.display.BitmapData;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.FlxObject;
import flixel.util.FlxAxes;
import openfl.geom.ColorTransform;
import flixel.util.FlxColor;
import funkin.savedata.FunkinSave;
import flixel.FlxG;
import funkin.savedata.SaveGames;
import sys.FileSystem;
import Date;
import flixel.ui.FlxBar;
import flixel.group.FlxSpriteGroup;
var game = PlayState.instance;
public var camHealth:FlxCamera;
var playerHealthBar:FlxSpriteGroup = new FlxSpriteGroup(177,55);
var playerPowerBar:FlxSpriteGroup = new FlxSpriteGroup(177,35);
var enemyHealthBar:FlxSpriteGroup = new FlxSpriteGroup(177,126);
var enemyPowerBar:FlxSpriteGroup = new FlxSpriteGroup(177,106);
var power:Float = 2;
var objPower = {power:0};
var enHealth:Float = 2;
var objenHealth = {enHealth:inst.length};

function makePixBar(group:FlxSpriteGroup, instance:Dynamic, value:String, baseColor:FlxColor, secondaryColor:FlxColor, createDisplay:Bool = true){
	var bar = new FlxBar(0,0, FlxBarFillDirection.LEFT_TO_RIGHT, 245, 14, instance, value,0,2);
	bar.createFilledBar(baseColor,secondaryColor);

	var daBg=new FlxSprite(0,0).loadGraphic(Paths.image('game/bar'));
	daBg.antialiasing = false;
	group.cameras = [camHealth];

	if(createDisplay)
	{
		for(i in 0...2){
			var displayText = new FlxText(daBg.x - 140, daBg.y - 30 + (i*25), 0,i==0?"POWER":"LIFE", 20);
			displayText.alignment=FlxTextAlign.LEFT;
			displayText.font = Paths.font('nes-godzilla.ttf');
			group.add(displayText);
		}
		var nameText = new FlxText(daBg.x - 160, daBg.y - 53, 0, value == "health" ? game.boyfriend.curCharacter.toUpperCase() : game.dad.curCharacter.toUpperCase(), 20);
		nameText.alignment=FlxTextAlign.LEFT;
		nameText.font = Paths.font('nes-godzilla.ttf');
		group.add(nameText);

	}
	
	if(value == 'enHealth')
		bar.setRange(0, inst.length);

	

	group.add(bar);
	group.add(daBg);

	add(group);
}
function create(){


	var dedScript = Reflect.field(PlayState.SONG.meta.customValues, "deathscript");
	if(dedScript==null)
		dedScript = "defaultgameover";
	trace(dedScript);
	GameOverSubstate.script = 'data/scripts/' + dedScript;
	if(PlayState.isStoryMode){
		for(i=>strumLine in SONG.strumLines){
			for(k=>charName in strumLine.characters){
				if(strumLine.type == 1){
					remove(boyfriend);

					var charName:String = daPlayer;
					if(charName=="godzilla")charName = "gojira";

					var charPosName:String = strumLine.position == null ? (switch(strumLine.type) {
						case 0: "dad";
						case 1: "boyfriend";
						case 2: "girlfriend";
					}) : strumLine.position;
					
					boyfriend = new Character(0, 0, charName, stage.isCharFlipped(charPosName, false));
					stage.applyCharStuff(boyfriend, charPosName, k);
	
				
	
					trace(charName);
	
				}
	
			}
		}
		if (PlayState.SONG.meta.needsVoices != false) // null or true
			vocals = FlxG.sound.load(Paths.voices(PlayState.SONG.meta.name, game.difficulty, daPlayer == "godzilla" ? "": "-" + daPlayer));
		else
			vocals = new FlxSound();
	}

}
function update(elapsed:Float){
	if(!game.startingSong)
	objenHealth.enHealth = inst.length - Conductor.songPosition;

}
function onNoteCreation(event) {
	if (event.note.strumLine == cpuStrums)
		event.note.visible = false;

}
function onStrumCreation(event) {
		
		if(event.player == 0){
			event.strum.visible=false;
		}
		event.strum.y -= 20;


}
function destroy(){
	if(camHealth!=null){
		camHealth.setFilters([]);
		camHealth.destroy();

	}
}
function createStoryHud(){
	health = 2;
	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.add(camHealth = new FlxCamera(), false);
	camHealth.bgColor = 0;

	FlxG.cameras.add(camHUD, false);
	camHealth.addShader(crt);


	remove(iconP2);
	remove(iconP1);

	remove(healthBar);
	remove(healthBarBG);

	var squr = new FlxSprite(0,0).makeGraphic(1280, 172, FlxColor.BLACK);
	squr.cameras = [camHealth];

    squr.scrollFactor.set();
    add(squr);

	makePixBar(playerPowerBar, objPower,"power", 0xFF000000, 0xFFFA0000, false);
	makePixBar(playerHealthBar, this,"health", 0xFF000000, 0xFFFA0000, true);
	makePixBar(enemyPowerBar, objPower,"power", 0xFF000000, 0xFFFA0000, false);
	makePixBar(enemyHealthBar, objenHealth,"enHealth", 0xFF000000, 0xFFFA0000, true);

	var greenXD = new FlxSprite(0,144.00).makeGraphic(1280,28, 0xFF515e06);
	greenXD.cameras = [camHealth];
    add(greenXD);
}
function postCreate(){

	if(PlayState.isStoryMode)createStoryHud();
	remove(scoreTxt);
	remove(missesTxt);
	remove(accuracyTxt);

}
function onGameOver(event){
	event.cancel();
	trace("gameover");

	if (game.boyfriend != null)
		game.boyfriend.stunned = true;

	persistentUpdate = false;
	persistentDraw = true;
	paused = true;

	vocals.stop();
	if (FlxG.sound.music != null)
		FlxG.sound.music.stop();
	for (strumLine in strumLines.members) strumLine.vocals.stop();

	openSubState(new GameOverSubstate(game.boyfriend.x, game.boyfriend.y));
}
function onSongPostEnd(e){
	e.cancel();
	if (PlayState.isStoryMode)
		{
			PlayState.campaignScore += PlayState.instance.songScore;
			PlayState.campaignMisses += PlayState.instance.misses;
			PlayState.campaignAccuracyTotal += PlayState.instance.accuracy;
			PlayState.campaignAccuracyCount++;
			PlayState.storyPlaylist.shift();

			if (PlayState.storyPlaylist.length <= 0)
			{
				
			

				if(PlayState.SONG.meta.name.toLowerCase()!='amoeba'){
					deadassholes.push(curBoss.curChar);

					SaveGames.curSave().data.deadassholes = deadassholes;			   
					SaveGames.curSave().flush();
				}
					

			
				if(PlayState.SONG.meta.name.toLowerCase()=='amoeba'||PlayState.SONG.meta.name.toLowerCase()=='out-of-place')
					doExplosionEnd();
				else 
					doBlackInEnd();
				

				if (PlayState.instance.validScore)
				{
					// TODO: more week info saving
					FunkinSave.setWeekHighscore(PlayState.storyWeek.id, PlayState.difficulty, {
						score: PlayState.campaignScore,
						misses: PlayState.campaignMisses,
						accuracy: PlayState.campaignAccuracy,
						hits: [],
						date: Date.now().toString()
					});
				}
				FlxG.save.flush();
			}
			else
			{
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase(), PlayState.difficulty);

				PlayState.instance.registerSmoothTransition();

				FlxG.sound.music.stop();

				PlayState.__loadSong(PlayState.storyPlaylist[0].toLowerCase(), PlayState.difficulty);

				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			if (PlayState.chartingMode)
				FlxG.switchState(new funkin.editors.charter.Charter(PlayState.SONG.meta.name, PlayState.difficulty, false));
			else
				FlxG.switchState(new FreeplayState());
		}
}
function doExplosionEnd(){
	persistentUpdate = false;
	persistentDraw = true;
	paused = true;

	vocals.stop();
	inst.stop();
		
	camHUD.visible=false;
	camZooming=false;

	boyfriend.animation.pause();
	dad.animation.pause();
	var explosion = new FlxSprite(0,0);
	explosion.frames = Paths.getFrames('game/death/DeathParticle');
	explosion.animation.addByPrefix('explode', 'DeathParticle', 8, true);
	explosion.scale.set(7.5,7.5);
	explosion.updateHitbox();
	explosion.animation.play('explode');
	var victory:FlxSound = new FlxSound();
	victory = FlxG.sound.load(Paths.sound('victory'));
	victory.play();
	add(explosion);
	explosion.setPosition(dad.getGraphicMidpoint().x+ -190, dad.getGraphicMidpoint().y + -130);

	FlxTween.tween(dad, {y: dad.y + 800}, 7);
	FlxTween.tween(explosion, {y: explosion.y + 800}, 7);


	victory.onComplete=function(){
		checkBosses();
	}
}
function doBlackInEnd(){
	camGame.fade(FlxColor.BLACK, 3, false, function(){
		checkBosses();
	});
	camHUD.fade(FlxColor.BLACK, 3, false);
}
function checkBosses(){
	if(PlayState.SONG.meta.name.toLowerCase()!='amoeba')
		{
			

			if(deadassholes.length>=3){
				SaveGames.curSave().data.deadassholes=[];
				SaveGames.curSave().data.deadGoodGuys=[];
				//SaveGames.curSave().data.daprevHealth = null;
				curCharacter=0;
				prevPos=[];
	
	
		
				SaveGames.curSave().flush();
				trace("finished game");
				//FlxG.switchState(new CreditsState(true));

			}
			else
				FlxG.switchState(new ModState('BoardState'));

		}
		else
			FlxG.switchState(new ModState('BoardState'));


}