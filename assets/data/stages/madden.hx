import funkin.backend.shaders.CustomShader;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import funkin.game.PlayState;
var game = PlayState.instance;
var overlayCam:FlxCamera;
var absorb:CustomShader;
function postCreate(){
	boyfriend.playAnim("intro");
	FlxG.cameras.add(overlayCam= new FlxCamera(), false);
	overlayCam.bgColor = 0;
	var blackSqr = new FlxSprite(-445,339).makeGraphic(FlxG.width, FlxG.height, 0x000000);
	add(blackSqr);
	blackSqr.scale.set(1.6,1.6);
	game.stage.stageSprites.set("blackSqr",blackSqr);
	insert(members.indexOf(fire)+1, blackSqr);


	var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stages/madden/bg'));
	bg.antialiasing = true;
	//bg.scrollFactor.set(0.9, 0.9);
	bg.scale.set(1.8,1.8);
	bg.active = false;
	insert(members.indexOf(fire)+1, bg);
	game.stage.stageSprites.set("bg",bg);


	var cheers:FlxSprite = new FlxSprite(-462, 85);
	cheers.frames = Paths.getFrames('stages/madden/Cheers');
	cheers.animation.addByPrefix('idle', 'Cheers Idle',15,true);
	cheers.animation.addByPrefix('fade', 'Cheers Fade',15,false);
	cheers.animation.addByPrefix('intro', 'Cheers Intro',15,false);

	cheers.antialiasing = false;
	cheers.scale.set(1.8,1.8);
	cheers.alpha =1/99999;
	//cheers.animation.play('cheer');
	insert(members.indexOf(bg)+1, cheers);
	game.stage.stageSprites.set("cheers",cheers);



	var melissa:FlxSprite = new FlxSprite(-333, -149);
	melissa.frames = Paths.getFrames('stages/madden/Melissa');
	melissa.animation.addByPrefix('idle', 'Melissa Idle',7,true);
	melissa.animation.addByPrefix('intro', 'Melissa Intro',7,false);
	melissa.animation.addByPrefix('end', 'Melissa End',7,false);
	melissa.antialiasing = false;
	melissa.alpha=1/99999999;
	//cheers.animation.play('cheer');
	insert(members.indexOf(cheers)+1, melissa);

	game.stage.stageSprites.set("melissa",melissa);



	var mygame:FlxSprite = new FlxSprite(-470, -367).loadGraphic(Paths.image('stages/madden/mygame'));
	mygame.antialiasing = true;
	mygame.scrollFactor.set();
	mygame.active = false;
	mygame.alpha=1/99999999;
	mygame.cameras= [overlayCam];

	insert(members.indexOf(boyfriend)+1, mygame);

	game.stage.stageSprites.set("mygame",mygame);
	absorb = new CustomShader("absorbShader");

	camGame.addShader(absorb);
}
function beatHit(curBeat:Int){
switch(curBeat){
	case 30:
		game.stage.getSprite("mygame").alpha = 1;
		new FlxTimer().start(2,function(_){
			game.stage.getSprite("mygame").destroy();
		  });
}
}
var updater:Float = 0;
function update(elapsed:Float) {
	FlxG.watch.addQuick("beat", curBeat);
	updater += elapsed;
	absorb.time = updater;
}
