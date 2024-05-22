import flixel.group.FlxGroup.FlxTypedGroup;

var yeah:FlxText;
var options:Array<String>=['JUKEBOX', 'BESTIARY', 'CARDS', 'BACK'];
var listString:String = '';
var opts:FlxTypedGroup<FlxText> = new FlxTypedGroup();

var jukeT:FlxText;
var sqr:FlxSprite;

var curS:Int=0;
var unlock:FlxSprite;
var completedGame:Bool=false;
function postCreate(){
	FlxG.mouse.visible=false;




	
	for(i in 0...options.length){
		yeah = new FlxText(470, 210 + (i*120), 0, options[i], 42,true);
		yeah.font = Paths.font('nes-godzilla.ttf');
		opts.add(yeah);
	
	
		if(i==3){
			yeah.y += 80;
		}
		
		switch(i){
			case 1,2:
				yeah.color=0xEAC50101;
			case 0: 
				if(completedGame){
					yeah.color = FlxColor.WHITE;
				}else
				yeah.color=0xEAC50101;
		}
	}

	add(opts);

	sqr=new FlxSprite(opts.members[curS].x+-83,opts.members[curS].y+8).makeGraphic(40,40,FlxColor.RED);
	add(sqr);



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
	if(controls.ACCEPT){

		switch(curS){
			case 0 :    
			#if !debug
			if(completedGame)
			FlxG.switchState(new FreeplayState());
			#else
			FlxG.switchState(new FreeplayState());
			#end
			case 3:
				FlxG.switchState(new MainMenuState());

	
		}
	
	}
  
	if(controls.UP_P)
		sel(-1);
	
	if(controls.DOWN_P)
		sel(1);
	
	if(controls.BACK)
		FlxG.switchState(new MainMenuState());
	

}