
import funkin.savedata.SaveGames;

static var initialized:Bool = false;

var blackScreen:FlxSprite;
var credGroup:FlxGroup;
var credTextShit:Alphabet;
var textGroup:FlxGroup;
var ngSpr:FlxSprite;
public static var launchedAmount:Int=0;
var curWacky:Array<String> = [];
var test:GlitchEffect99;
var transitioning:Bool = false;
var scaler:Float = 1;
var canEnter:Bool=false;
var wackyImage:FlxSprite;
var jj:FlxSound;
var initialdiaPitch:Dynamic;
var logoBl:FlxSprite;
var gfDance:FlxSprite;
var speaker:FlxSprite;
var danceLeft:Bool = false;
var titleText:FlxSprite;
var bg:FlxSprite;
var bgLit:FlxSprite;
var introThing:FlxSprite;
var initalPitch:Dynamic;
function create() {
	SaveGames.init();

	if(FlxG.save.data.launchedAmount!=null){
		launchedAmount=FlxG.save.data.launchedAmount;
	}

}
function postCreate() {
	if (FlxG.sound.music != null)
		FlxG.sound.music.stop();

	#if !debug
		launchedAmount < 3 ? dialogue() : startIntro();
	
		#else
		startIntro();
		#end
}
function dialogue(){
	jj = new FlxSound();
	jj=FlxG.sound.load(Paths.sound('Zachary_dialogue2'));
	jj.play();
	
	jj.onComplete=function(){
		launchedAmount++;
		FlxG.save.data.launchedAmount = launchedAmount;
		FlxG.save.flush();
		
				startIntro();
	
	}
}
function startIntro()
	{
		FlxG.autoPause=true;

		FlxG.sound.playMusic(Paths.music('Title'));
		 initalPitch = FlxG.sound.music.pitch;
	FlxG.sound.music.fadeIn(4, 0, 0.7);

		Conductor.changeBPM(102);
		persistentUpdate = true;
		

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		
		 introThing = new FlxSprite(497,240);
		 introThing.antialiasing=false;
		introThing.frames = Paths.getFrames('menus/intro/intronueva');
		introThing.animation.addByPrefix('starter','intronueva monster intro0', 12, false);
		introThing.animation.addByPrefix('looper','intronueva Loop0', 12, true);
		introThing.animation.addByPrefix('enter','intronueva Enter0', 12, false);
		new FlxTimer().start(1.1, function(_){
			introThing.animation.play('starter');
			canEnter=true;
		});
		introThing.scale.set(4,4);
		add(introThing);
		introThing.animation.finishCallback=function(_){
			introThing.animation.play('looper');
		}
		var tapa = new FlxSprite(-474,0).makeGraphic(600, FlxG.height, FlxColor.BLACK);
		add(tapa);
		
		
		
		
		

			initialized = true;

		// credGroup.add(credTextShit);
	}
	function update(elapsed:Float){
	
		FlxG.watch.addQuick('amount of launchs', launchedAmount);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	
		
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		

		if(canEnter){
			if (pressedEnter && introThing.animation.curAnim.name!='enter')
				{
					introThing.animation.play('enter');
					FlxG.sound.music.pitch = initalPitch - 0.4;
		
					introThing.animation.finishCallback=function(_) {
						new FlxTimer().start(2, function(_){
							FlxG.switchState(new MainMenuState());
							FlxG.sound.music.pitch = initalPitch;
						});
						
		
					}
				}
		}
		
	
	}