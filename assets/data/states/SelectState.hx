import funkin.editors.MapperState;
import funkin.options.OptionsMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.savedata.SaveGames;
import funkin.editors.EditorPicker;
import BoardCreatorState;
var yeah:FlxText;
var options:Array<String>=['PLAY', 'VAULT', 'SETTINGS', 'CREDITS', 'EXIT'];
var listString:String = '';
var opts:FlxTypedGroup<FlxText> = new FlxTypedGroup();

var jukeT:FlxText;
var sqr:FlxSprite;

var curS:Int=0;
var unlock:FlxSprite;
var completedGame:Bool=false;
function postCreate(){
	FlxG.mouse.visible=false;

	
	if(FlxG.save.data.completedGame!=null)
		completedGame=FlxG.save.data.completedGame;


	if(FlxG.sound.music!=null && FlxG.sound.music.playing)
		FlxG.sound.music.stop();

	FlxG.sound.play(Paths.music('Aftermenu'));

	
	for(i in 0...5){
		yeah = new FlxText(470,120 + (i*120), 0, options[i], 42, true);
		yeah.font = Paths.font('nes-godzilla.ttf');
		opts.add(yeah);
		
	   if(i==4)yeah.color=FlxColor.RED;
	}

	add(opts);

	sqr=new FlxSprite(opts.members[curS].x+-83,opts.members[curS].y+8).makeGraphic(40,40,FlxColor.RED);
	add(sqr);

	unlock = new FlxSprite(232 -50,1).loadGraphic(Paths.image('menus/ihatethinkingaboutnames'));
	unlock.scale.set(4.5,3.2);
	unlock.updateHitbox();
	unlock.visible = false;

	unlockT = new FlxText(264 -50, 3, unlock.width-10,'VAULT EXTRAS CAN ONLY BE UNLOCKED IN CAMPAIGN MODE' , 42,true);
	unlockT.color = 0xE3D60E0E;
	unlockT.font = Paths.font('nes-godzilla.ttf');
	unlockT.visible=false;
	if(!completedGame)
		{
			add(unlock);

			add(unlockT);
		}

		sel(0);
}
function sel(k:Int=0){
	curS+=k;

	if(curS>opts.members.length-1){
		curS=0;
	}
	if(curS<0){
		curS=opts.members.length-1;
	}
	sqr.x = opts.members[curS].x+-84;
	sqr.y = opts.members[curS].y+8;
}
function update(elapsed:Float) {
	if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new BoardCreatorState());
		}
	if (FlxG.keys.justPressed.SEVEN) {
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new EditorPicker());
	}
	if(controls.ACCEPT){

		switch(curS){
			case 0 :
			FlxG.switchState(new ModState("SaveGameState"));
		   case 1:
			FlxG.switchState(new ModState("VaultState"));

			case 2: 
				FlxG.switchState(new OptionsMenu());
			case 3: 
				FlxG.switchState(new ModState('CreditsState'));
			case 4: 
			Sys.exit(0);
		}
	
	}
  
	if(controls.UP_P)
		sel(-1);
	
	if(controls.DOWN_P)
		sel(1);
	
	if(controls.BACK)
		FlxG.switchState(new TitleState());
	

}