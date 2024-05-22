import funkin.menus.NewStoryMenuState;
import funkin.backend.scripting.ModState;
import flixel.text.FlxText.FlxTextAlign;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.savedata.SaveGames;

var curSel:Int = 1;
var box:FlxSprite;
var boxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var text:FlxText;
var textt:FlxTypedGroup<FlxText> = new FlxTypedGroup();
var erasing:Bool=false;

function postCreate(){

	prevPos = [];
	deadGoodGuys = [];
	deadassholes = [];
	SaveGames.save = SaveGames.SAVE1;

	for(i in 1...5){
		trace(i);
		box = new FlxSprite(270,10+(i*211));
	  
		box.loadGraphic(Paths.image('menus/savemenu/bbarras'), true, 202, 58);
		box.animation.add('idle', [1], 1, true);
		box.animation.add('sel', [0], 1, true);
		box.animation.add('eraser', [0,1], 7, true);

		box.y -= 200;
		box.scale.set(3.5,3.5);
		box.updateHitbox();
		box.ID =i;
		

	   
		text = new FlxText(469,90+(i*211),0, 'NEW GAME', 32, true);
		text.y -= 200;

		text.font = Paths.font('nes-godzilla.ttf');
		text.alignment = FlxTextAlign.CENTER;
		text.ID = i;
		text.x = box.x + (box.width - text.fieldWidth)/2;
	 
		switch(i){
			case 4: 
				text.text = 'ERASE';
				text.color = 0x999999; 
				text.y -= 60;
				text.x += 50;
			default: 
				
				if(SaveGames.hasData(SaveGames.saves[i]))
					text.text= 'SAVE'+i;

				
		}
		

		if(i<4)
		boxes.insert(i,box);
		
		textt.insert(i,text);
	}

	add(boxes);
	add(textt);
	changeSel(0);

}
function changeSel(pp:Int=0, erasing:Bool = false){
	if(pp == 0)curSel=1;

	curSel+=pp;
	if(curSel>textt.members.length)
		curSel =1;
	
	else if(curSel<1)
		curSel = textt.members.length;
	
	for(b in boxes.members){
		b.animation.play('idle');
		var textid = b.ID -1;
		textt.members[textid].color = 0xFFFFFF;
		textt.members[3].color = 0xFF808080;

		if(curSel == b.ID && curSel!=4){
		
				b.animation.play(erasing? "eraser":"sel");
				if(erasing)
					textt.members[textid].color =  0xe60000;	
				
				
		}
		else if(curSel == 4){
			textt.members[3].color = 0xe60000;

		}
		

	}
}
function regenText(){
	for(daT in textt){

		switch(daT.ID){
			case 4: 
				daT.text = erasing == true ? "CANCEL" : "ERASE";
			default: 
				daT.text = erasing == true ? "NO DATA" : "NEW GAME";
				if(SaveGames.hasData(SaveGames.saves[daT.ID]))
					daT.text = erasing == true ? "SAVE"+daT.ID : "ERASE";

				

		}
		daT.x = box.x + (box.width - daT.fieldWidth)/2;

	}
}
function selectText(erasing:Bool = false){
	if(!erasing)
	{
		SaveGames.save = curSel;
			
		FlxG.switchState(new ModState("BoardState"));
	}
	else{
		SaveGames.saves[curSel].erase();
			
		for(t in textt)if(t.ID!=3)t.color = 0xFFFFFF;

		
		regenText();
	}
}
 function update(elapsed:Float){

	FlxG.watch.addQuick("cursel", curSel);
	if(controls.UP_P)
	
		changeSel(-1, erasing);
	
	if(controls.DOWN_P)
		changeSel(1,erasing);
	
	if(controls.ACCEPT  ){
		switch(curSel){
			case 4:
			erasing=!erasing;
			for(t in textt)if(t.ID!=4)t.color = 0xFFFFFF;
			
			regenText();
			default: 
			selectText(erasing);
		}
	}
	if(FlxG.keys.justPressed.ESCAPE){
		FlxG.switchState(new MainMenuState());
	}
}
