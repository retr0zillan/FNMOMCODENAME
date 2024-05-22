import flixel.FlxCamera.FlxCameraFollowStyle;
import funkin.backend.utils.CoolUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.savedata.SaveGames;
import funkin.game.FuckinGroup;
import flixel.FlxObject;
import funkin.menus.NewStoryMenuState.BoardTile;
import funkin.menus.NewStoryMenuState.GodziChar;
import sys.FileSystem;
import flixel.tweens.FlxTween;
import sys.io.File;
import Xml;

var map:FlxSprite;
var char:GodziChar;
var companion:GodziChar;
var enemy1:GodziChar;
public static var firstTime:Bool = true;
//var enemies:Array<GodziChar> = [];
public var enemiees:FlxTypedGroup<GodziChar> = new FlxTypedGroup();
var charss:Array<String>=['gezora', 'titano', 'biollante','moguera'];
var curSelected:Int = 0;
public var goodGuys:FuckinGroup = new FuckinGroup();
var weekMap:Map<String, Int>=[
	//bad omen
	'GEZORA'=>1,
	//bad signal
	'MOGUERA'=>2,
	//out of place
	'TITANO'=>3,
];

			 //left, right, up,down
var positions:Array<Array<Int>>=[[785,460],[863,347],[1026,257],[711,339]];
var text:FlxText;
public static var daPlayer:String;
var aasjasjas:String;
var selectedWeek:Bool = false;
//var colG:BoardTile;
public static var curCharacter:Int = 0;
var colsGroup:Array<BoardTile>=[];
public static var prevPos:Array<FlxPoint>=[];
var actorsCointainer:Array<GodziChar>=[];
var canSkip:Bool = false;
var camFollow:FlxObject;
var introCut:FlxSprite;
var curDec:Int=0;
var weekData:Array<WeekData>;
var sound1:FlxSound;
var sound2:FlxSound;
var arrow:FlxSprite;
var sound3:FlxSound;
var sound4:FlxSound;
public static var deathFlag:Bool=false;
var fText:FlxText;
var selector:GodziChar;
var curMap:String = "MARS";
var tiles:FlxSprite;
var curTile:Int=0;
public static var deadGoodGuys:Array<String>=[];
public static var deadassholes:Array<String>=[];
var metaData:MapStruct;
var turns:Map<String, Int>=[
	'godzilla'=>2,
	'mothra'=>4,
	
];
var path:String;

var camFocus:String='godzilla';

var currentSave:FlxSave;
var moveMap:Map<BoardTile, Array<BoardTile>>=[];

var decG1:FlxTypedGroup<FlxSprite>=new FlxTypedGroup();
var decG2:FlxTypedGroup<FlxSprite>=new FlxTypedGroup();
var cantMove:Bool=false;
var decText:FlxText;
var square:FlxSprite;
var width:Int = 30;
var height:Int = 30;
var selectedSmth:Bool = false;
var tweening:Bool = false;
var objID:BoardTile;
var makingDes:Bool=false;
var diffX:Float = 0;
var diffY:Float = 0;
var mapAssholes:Map<FlxSprite, Array<Int>>=[];

var currentEnemyCam:GodziChar;

var turnIndex:Int=0;
var startFollow:Bool=false;
var prevCharacter:Int;
var daWeeks:Array<WeekData> = [];
public function getWeeksFromSource(weeks:Array<String>, source:funkin.backend.assets.AssetsLibraryList.AssetSource) {
	var path:String = Paths.txt('freeplaySonglist');
	var weeksFound:Array<String> = [];
	if (Paths.assetsTree.existsSpecific(path, "TEXT", source)) {
		var trim = "";
		weeksFound = CoolUtil.coolTextFile(Paths.txt('weeks/weeks'));
	} else {
		weeksFound = [for(c in Paths.getFolderContent('data/weeks/weeks/', false, source)) if (Path.extension(c).toLowerCase() == "xml") Path.withoutExtension(c)];
	}
	
	if (weeksFound.length > 0) {
		for(s in weeksFound){
			weeks.push(s);
	

		}
		return false;
	}
	return true;
}

public function loadXMLs() {
	// CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
	var weeks:Array<String> = [];
	if (getWeeksFromSource(weeks, false))
		getWeeksFromSource(weeks, true);

	for(k=>weekName in weeks) {

		var week = null;
		
		week = Xml.parse(Assets.getText(Paths.xml('weeks/weeks/'+weekName))).firstElement();
		
		var weekObj:WeekData = {
            name: week.get("name"),
            id: weekName,
            sprite: week.get("sprite"),
            chars: [null, null, null],
            songs: [],
            difficulties: ['easy', 'normal', 'hard']
        };

		var songNodes = week.elementsNamed("song");
        if (songNodes != null && songNodes.hasNext()) {
            var k2 = 0;
            while (songNodes.hasNext()) {
                var song = songNodes.next();
                if (song == null) continue;

                var name = MoarUtils.get_innerData(song);
				name = StringTools.trim(name);
				
				weekObj.songs.push({
					name: name,
					hide: song.get("hide", "false") == "true"
				});

                k2++;
            }
        }
	
		daWeeks.push(weekObj);

		


	}
	trace(daWeeks);
}
function loadWeek(numba:Int){
	PlayState.loadWeek(daWeeks[numba],"normal");

    FlxG.switchState(new PlayState());
}
function makeSel(fiu:Int = 0){
	curSelected+=fiu;
	if(curSelected>enemiees.length-1){
		curSelected = 0;
	}
	if(curSelected<0){
		curSelected = enemiees.length-1;

	}
	for(char in enemiees){
		if(char.ID == curSelected){
			char.animation.play('${charss[char.ID]} selected');
		}
		else{
			char.animation.play('${charss[char.ID]} idle');

		}
	}
	
}
function bruh(direction:Int){
	switch(curCharacter){
		default: 

			if((!moveMap.get(objID)[direction].isEnemy && !moveMap.get(objID)[direction].isAlly)){


				moveToNextSquare(direction,0);
			}
		  
			else if(moveMap.get(objID)[direction]!=null && moveMap.get(objID)[direction].isEnemy && !moveMap.get(objID)[direction].canGo){
				trace('enemy');

				moveToNextSquare(direction, 1);


			}
			else if(moveMap.get(objID)[direction]!=null && moveMap.get(objID)[direction].isEnemy && moveMap.get(objID)[direction].canGo){
				moveToNextSquare(direction, 4);

			}
			else if(moveMap.get(objID)[direction].isAlly){
				moveToNextSquare(direction, 2);

			}
		case 0: 
		   
				  
					trace("wow");
					moveToNextSquare(direction,0);

				 
	}
}
public function restartPlayersPos() {
   

	char.setPosition(metaData.actorsPosition.get('godzilla')[0], metaData.actorsPosition.get('godzilla')[1]);
	companion.setPosition(metaData.actorsPosition.get('mothra')[0], metaData.actorsPosition.get('mothra')[1]);
	selector.setPosition(metaData.actorsPosition.get('selector')[0], metaData.actorsPosition.get('selector')[1]);

	
}
public function chooseSelector(){
	if(!goodGuys.members[0].alive){
		goodGuys.members[0].revive();
	}
	startFollow=false;
   
 

	curCharacter=0;
	goodGuys.members[1].animation.play('godzilla idle');
	goodGuys.members[2].animation.play('mothra idle');
}
function moveToNextSquare(index:Int, enemyCollisionlistener:Int = 0){
	switch(enemyCollisionlistener){
		case 0:
			for(e in decG1){
				if(e.alpha==1){
					e.alpha=0;
				   
				}
			}
			trace("moving");

			tweening=true;
			var daX = moveMap.get(objID)[index].x + diffX;
			var daY = moveMap.get(objID)[index].y + diffY;
	
			trace("tween pos" + daX + " " + daY);
			if(curCharacter!=0)
			goodGuys.members[curCharacter].animation.play(goodGuys.members[curCharacter].curChar+' moving');
			FlxTween.tween(goodGuys.members[curCharacter], {x:daX, y:daY}, 0.3, {onComplete:function(_) {
				tweening = false;
				if(curCharacter!=0){
					goodGuys.members[curCharacter].animation.play(goodGuys.members[curCharacter].curChar+' selected');
					checkTurns();
				   
				}
			   

			}
			 });

			 case 4: 
			   
					for(e in decG1){
						if(e.alpha==1){
							e.alpha=0;
						   
						}
					}
					tweening=true;
					var daX = moveMap.get(objID)[index].x + diffX;
					var daY = moveMap.get(objID)[index].y + diffY;
					fText.text = 'WILL YOU FIGHT '+moveMap.get(objID)[index].tileOwner + '?';
					aasjasjas=moveMap.get(objID)[index].tileOwner;
					for(c in enemiees){
						if(c.curChar.toUpperCase()==moveMap.get(objID)[index].tileOwner){
							curBoss=c;
							trace(curBoss);
							break;
						}
					}
					goodGuys.members[curCharacter].animation.play(goodGuys.members[curCharacter].curChar+' moving');
					FlxTween.tween(goodGuys.members[curCharacter], {x:daX, y:daY}, 0.3, {onComplete:function(_) {
						tweening = false;
						goodGuys.members[curCharacter].animation.play(goodGuys.members[curCharacter].curChar+' selected');
					   
						for(e in decG1){
							e.alpha=1;
						}
						for(e in decG2){
							e.alpha=1;
						}
							FlxG.sound.play(Paths.sound('selection'));
							makingDes = true;
							curBoss.animation.play(curBoss.curChar+' selected');

					}
					 });
				
			case 1: 
				
					trace('enemy in sight');
					fText.text = 'WILL YOU FIGHT '+moveMap.get(objID)[index].tileOwner + '?';

					aasjasjas=moveMap.get(objID)[index].tileOwner;
					//    var charss:Array<String>=['gezora', 'titano', 'biollante','moguera'];

					for(c in enemiees){
						if(c.curChar.toUpperCase()==moveMap.get(objID)[index].tileOwner){
							curBoss=c;
							trace(curBoss);
							break;
						}
					}

					/*
					switch(moveMap.get(objID)[index].enemyName){
						case 'GEZORA': 
							curBoss=enemiees.members[0];
							case 'MOGUERA': 
								curBoss=enemiees.members[1];
					}
					*/
					for(e in decG1){
						e.alpha=1;
					}
					for(e in decG2){
						e.alpha=1;
					}
						makingDes = true;
						curBoss.animation.play(curBoss.curChar+' selected');

			   

			  

			case 2: 
				trace('ally in sight');
				cantMove = true;
				fText.text = 'THERES A MONSTER IN THE WAY';
	
				for(e in decG1){
					e.alpha=1;
				}
				new FlxTimer().start(0.8, function(_){
					for(e in decG1){
						e.alpha=0;
					}
					cantMove = false;

				});
	}
  

	 
 
	
}
function checkTurns(){
	if(turns.get(goodGuys.members[curCharacter].curChar)>0)
		turns.set(goodGuys.members[curCharacter].curChar, turns.get(goodGuys.members[curCharacter].curChar)-1);
	if(turns.get(goodGuys.members[curCharacter].curChar)==0)
		{
			cantMove=true;
			new FlxTimer().start(0.7, function(_){
				triggerEnemyTurn();

			});
		}
		trace(turns);
}
function triggerEnemyTurn(){
	//marquita2
   
	cantMove = true;
	

	if(enemiees.members[turnIndex]==null)
		turnIndex = enemiees.getFirstExisting().ID;
	
	currentEnemyCam = enemiees.members[turnIndex];
	camFocus = 'enemy';
	var currentPlayer = goodGuys.members[curCharacter];
	trace('player is '+currentPlayer.curChar);

	var closestDirection: FlxPoint = null;
	var closestDistance: Float = -1;
	new FlxTimer().start(0.3, function(_){
	currentEnemyCam.animation.play(currentEnemyCam.curChar+' selected');
	});

	new FlxTimer().start(1, function(_){

	  
		for(tile in colsGroup){
			if(enemiees.members[turnIndex].overlaps(tile)){
				for(dir in moveMap.get(tile)){

					if(dir!=null && dir.canGo && (dir.tileOwner==enemiees.members[turnIndex].curChar.toUpperCase()||dir.tileOwner=='public')){

					   var distance = FlxMath.distanceBetween(currentPlayer, dir);

						// Si es la primera dirección que evaluamos o si esta dirección es más cercana que la anterior jiji
						if (closestDirection == null || distance < closestDistance) {
							closestDirection = dir.getPosition();
							closestDistance = distance;
						}
					}
					
				}
			}
		}

		if(closestDirection!=null){
			currentEnemyCam.animation.play(currentEnemyCam.curChar+' moving');

			FlxTween.tween(enemiees.members[turnIndex], {x:closestDirection.x, y:closestDirection.y-20}, 0.3,{onComplete:function(_){
					currentEnemyCam.animation.play(currentEnemyCam.curChar+' selected');
					if(objID.isEnemy){
						trace('fuck man help me');
					   

						for(c in enemiees){
							if(c.curChar.toUpperCase()==objID.tileOwner){
								curBoss=c;
							}
						}
					  
						daPlayer = goodGuys.members[curCharacter].curChar;

						trace('player is '+daPlayer);


						for(i in 0...actorsCointainer.length){
							prevPos[i] = actorsCointainer[i].getPosition();
						
						}
						loadWeek(weekMap.get(curBoss.curChar.toUpperCase()));
						

					}
				new FlxTimer().start(1, function(_){

							turnIndex++;
							if(turnIndex>enemiees.length-1){
								turnIndex=0;
							}

							cantMove = false;
							currentEnemyCam.animation.play(currentEnemyCam.curChar+' idle');

							camFocus = 'godzilla';
		
							turns.set(goodGuys.members[curCharacter].curChar, currentPlayer.curChar=='godzilla'?2:4);
						   
					   


			
					   
				});
			   
					
			}});
		}
		else{
			turnIndex++;
							if(turnIndex>enemiees.length-1){
								turnIndex=0;
							}

							cantMove = false;
							currentEnemyCam.animation.play(currentEnemyCam.curChar+' idle');

							camFocus = 'godzilla';
		
							turns.set(goodGuys.members[curCharacter].curChar, currentPlayer.curChar=='godzilla'?2:4);
		}
		
	});
   
	


}
function changeDec(kk:Int){
	if(kk==0)
	curDec=kk;
	else
		{
			curDec+=kk;
	
			if(curDec>1){
				curDec=0;
			}
			 if(curDec<0){
				trace('blablabla');
				curDec=1;
			}
		}
	 
	arrow.x = decG2.members[curDec].x -20;

}

function postCreate(){
	
	BoardState = this;
	trace(BoardState.deadassholes);
	loadXMLs();
	metaData = CoolUtil.parseMapData("MARS");
	currentSave = SaveGames.curSave();
	if(currentSave.data.firstTime!=null){
		firstTime=currentSave.data.firstTime;
		trace('not the first time');
	}
	else{
		firstTime=true;
	}

	FlxG.sound.playMusic(Paths.music('mars'),1, true);

	if(currentSave.data.deadassholes!=null){
		deadassholes = currentSave.data.deadassholes;
		trace('found data');
		trace(currentSave.data.deadassholes);

	}

	if(currentSave.data.deadGoodGuys!=null){
		trace('found dead good guys');

		deadGoodGuys = currentSave.data.deadGoodGuys;

	}

	
	for(i in 0...metaData.tiles.length){
		
			var colG =new BoardTile(metaData.tiles[i][0], metaData.tiles[i][1], metaData.tiles[i][2]);
			colG.scale.set(2.5, 2.5);
		
			
			colG.ID = i;
		  
		
			add(colG);
		
			colsGroup.push(colG);
	}
	moveMap = CoolUtil.mapTheMapLol(metaData,colsGroup);



	
	selector = new GodziChar(colsGroup[0].x,colsGroup[0].y,'cuadroblanco',false, false, false);
	selector.ID = 0;
	selector.scale.set(2.3,2.3);
 
	goodGuys.add(selector);



	
	char =  new GodziChar(metaData.actorsPosition.get('godzilla')[0],metaData.actorsPosition.get('godzilla')[1], 'godzilla');
   
	char.ID = 1;

	goodGuys.add(char);

	companion =  new GodziChar(metaData.actorsPosition.get('mothra')[0],metaData.actorsPosition.get('mothra')[1], 'mothra');

	companion.ID = 2;

	goodGuys.add(companion);

	var i:Int = 0;
	for(key in metaData.villains.keys()){
	   
		enemy1 = new GodziChar(metaData.villains.get(key)[0],metaData.villains.get(key)[1], key);
		
		enemy1.ID = i;
		enemiees.add(enemy1);
		i++;
	}
	add(goodGuys);
	add(enemiees);

	for(char in goodGuys){
        actorsCointainer.push(char);
       }
       for(char in enemiees){
        actorsCointainer.push(char);
       }

	   if(prevPos.length!=0){
            
		for(i in 0...actorsCointainer.length){
			trace('save data found');
			actorsCointainer[i].setPosition(prevPos[i].x, prevPos[i].y);
		 
		}
			//goodGuys.members[curCharacter].setPosition(prevPos.x, prevPos.y);
		
	}else{
		trace('save not found');

	}
	if(deadGoodGuys.length < 2 && deadGoodGuys.length > 0){
		for(g in goodGuys){
			if(deadGoodGuys.contains(g.curChar)){
				trace('killing good guy');
				g.kill();
				g.broIsDead = true;
				
				
			}

		}
	 
		goodGuys.members[0].kill();
		var aliveCharacter = goodGuys.getDeath();
		if(aliveCharacter!=null)
			{
				for(col in colsGroup){
					if(aliveCharacter.overlaps(col)){
					goodGuys.members[0].setPosition(col.x,col.y);
						  
						trace('moving to alive player, '+aliveCharacter.curChar);

					}
				}
				

			}
	
		goodGuys.members[0].revive();
		curCharacter=0;
	}
	square = new FlxSprite(200,382).loadGraphic(Paths.image('menus/menuStuff/decSquare'));
	square.scrollFactor.set();

   square.scrollFactor.set();
   decG1.add(square);

  
   fText = new FlxText(219,403, square.width-30, 'WILL YOU FIGHT NAME?', 19);
   fText.font = Paths.font('nes-godzilla.ttf');

   fText.scrollFactor.set();
   decG1.add(fText);
   
 
 
   for(i in 0...2){
	   decText = new FlxText(fText.x + 30 +(i * 120),fText.y +130, 0, 'YES', 19);
	   decText.font = Paths.font('nes-godzilla.ttf');
	   decText.scrollFactor.set();

	   decText.ID = i;
	   switch(i)
	   {
		   case 0:
			   decText.text = 'YES';
		   case 1:
			   decText.text = 'NO';
	   }
	   decG2.add(decText);
   }
   arrow=new FlxSprite(decG2.members[0].x - 20,decG2.members[0].y +10).loadGraphic(Paths.image('menus/menuStuff/flechita'));
   arrow.scrollFactor.set(0,0);
   arrow.scale.set(3.75999999999996,3.75999999999996);
   decG2.add(arrow);

   for(e in decG1){
	   e.alpha=0;
   }
   for(e in decG2){
	   e.alpha=0;
   }
   
   for(e in enemiees){
	   if(deadassholes.contains(e.curChar)){
		   trace('we got one');
		  
		
		   enemiees.remove(e);
		   remove(e);
		   var arr:Array<Int>;
		
	   }

   }
  
  
   camFollow = new FlxObject(0, 0,1,1);
   add(camFollow);

   FlxG.camera.follow(camFollow, FlxCameraFollowStyle.NO_DEAD_ZONE, 9);
   FlxG.camera.zoom = FlxG.camera.zoom + 0.37;
   FlxG.camera.focusOn(camFollow.getPosition());

	add(decG1);
	add(decG2);
}
function postUpdate(elapsed:Float){
	var up = FlxG.keys.justPressed.UP;
	var down = FlxG.keys.justPressed.DOWN;
	var rightU=FlxG.keys.pressed.RIGHT && FlxG.keys.justPressed.UP;
	var rightD=FlxG.keys.pressed.RIGHT && FlxG.keys.justPressed.DOWN;
	var leftU=FlxG.keys.pressed.LEFT && FlxG.keys.justPressed.UP;
	var leftD=FlxG.keys.pressed.LEFT && FlxG.keys.justPressed.DOWN;

	
	switch(camFocus){

        case 'godzilla':
            if(goodGuys.members[curCharacter]!=null)
                camFollow.setPosition(goodGuys.members[curCharacter].getGraphicMidpoint().x, goodGuys.members[curCharacter].getGraphicMidpoint().y);
        case 'enemy':
            if(currentEnemyCam!=null)
                camFollow.setPosition(currentEnemyCam.getGraphicMidpoint().x, currentEnemyCam.getGraphicMidpoint().y);

    }

	if(controls.BACK && !cantMove && curCharacter==0){
        FlxG.switchState(new MainMenuState());
       }
	   if(curCharacter==0){
		if(controls.ACCEPT && !cantMove){
			if(goodGuys.members[0].overlaps(goodGuys.members[1]) && !goodGuys.members[1].broIsDead){
				trace('selected godzilla');
				goodGuys.members[0].kill();
				curCharacter=1;
				goodGuys.members[1].animation.play('godzilla selected');
			}
			else if(goodGuys.members[0].overlaps(goodGuys.members[2]) && !goodGuys.members[2].broIsDead){
				trace('selected mothra');
				goodGuys.members[0].kill();
				curCharacter=2;

				goodGuys.members[2].animation.play('mothra selected');

			}
		   
		}
	}
	else if(curCharacter!=0){
		if(goodGuys.members[0].alive){
			goodGuys.members[0].kill();
			switch(curCharacter){
				case 1: 
					goodGuys.members[curCharacter].animation.play('godzilla selected');

				case 2:
					goodGuys.members[curCharacter].animation.play('mothra selected');

			}

		}


		if(!makingDes&& (controls.BACK) && !cantMove){
			for(col in colsGroup){
				if(goodGuys.members[curCharacter].overlaps(col)){
					switch(curMap){
						case 'PATHOS': 
							goodGuys.members[0].setPosition(col.x,col.y);
						case 'MARS': 
							goodGuys.members[0].setPosition(col.x,col.y);


					}
					break;
				}
		 
		 
			}
			if(!goodGuys.members[0].alive){
				goodGuys.members[0].revive();
			}
			startFollow=false;
		   
		 

			curCharacter=0;
			goodGuys.members[1].animation.play('godzilla idle');
			goodGuys.members[2].animation.play('mothra idle');


		}
	}
	switch(curCharacter){
		case 0: 
			diffY = 0;

		case 1,2: 
			
			diffY = -20;
			
	}

	for(col in colsGroup){
		
		if(goodGuys.members[curCharacter].overlaps(col) && goodGuys.members[curCharacter].alive){
		   
			objID = col;
		}
	   
		switch(curCharacter){
			case 1: 
				if(goodGuys.members[2].overlaps(col) && goodGuys.members[2].alive)
					{
						col.isAlly=true;
					  
					}
					else{
						col.isAlly=false;

					}

			case 2: 
				if(goodGuys.members[1].overlaps(col)  && goodGuys.members[1].alive){
					col.isAlly=true;
					
				}
				else{
					col.isAlly=false;

				}
		}
		//marquita
		col.setTileOwnerShip('public', false, true);
		for(enemy in enemiees){
			if(!deadassholes.contains(enemy.curChar))
				{
					if(enemy.overlaps(col)){
						col.setTileOwnerShip(enemy.curChar.toUpperCase(), true, false);
						for(c in moveMap.get(col)){
							
							if(c!=null)
								c.setTileOwnerShip(enemy.curChar.toUpperCase(), true, true);
						}
					}
				}
		}
	   
	}

	if(leftU && !tweening && !makingDes && !cantMove){

		trace('leftU');
		var dirMaster = 4;
		if(moveMap.get(objID)[dirMaster]!=null)
			{
				trace("we can move leftU");
				bruh(dirMaster);
			}
		   
		
	}

	if(leftD && !tweening && !makingDes && !cantMove){

		trace('leftD');

		var dirMaster = 5;
		if(moveMap.get(objID)[dirMaster]!=null)
			{
				trace("we can move leftD");

				bruh(dirMaster);

			}
	  
		
	}

	if(rightU && !tweening && !makingDes && !cantMove){
		trace('rightU');

		var dirMaster = 2;
		if(moveMap.get(objID)[dirMaster]!=null)
			{
				trace("we can move rightU");

				bruh(dirMaster);

			}
	}

	   if(rightD && !tweening && !makingDes && !cantMove){
		trace('rightD');

		var dirMaster = 3;
		if(moveMap.get(objID)[dirMaster]!=null)
			{
				trace("we can move rightD");

				bruh(dirMaster);

			}
	}
	if(down && !tweening && !makingDes && !cantMove){
		trace('down');

		var dirMaster = 1;
		if(moveMap.get(objID)[dirMaster]!=null)
			{
				trace("we can move down");

				bruh(dirMaster);

			}
	}
	if(up && !tweening && !makingDes && !cantMove){
		trace('up');

		var dirMaster = 0;
		if(moveMap.get(objID)[dirMaster]!=null)
			{
				trace("we can move up");

				bruh(dirMaster);

			}
	}

	if(makingDes){
		if(controls.BACK){
			changeDec(0);
			makingDes = false;
			if(curBoss!=null)curBoss.animation.play(curBoss.curChar+' idle');

			for(e in decG1){
				e.alpha=0;
			}
			for(e in decG2){
				e.alpha=0;
			}
		}
		if(controls.LEFT_P)
			{
				changeDec(-1);
			}
			if(controls.RIGHT_P)
				{
					changeDec(1);

				}
				if(controls.ACCEPT){

				   switch(curDec){
					case 0: 
						trace(aasjasjas); 
						daPlayer = goodGuys.members[curCharacter].curChar;

						trace('player is '+daPlayer);


						for(i in 0...actorsCointainer.length){
							prevPos[i] = actorsCointainer[i].getPosition();
						
						}
				  


							loadWeek(weekMap.get(aasjasjas));

								  
							   
				   
							makingDes = false;

							  
						 case 1: 
							trace('nope i dont wanna fight');
						if(curBoss!=null)curBoss.animation.play(curBoss.curChar+' idle');

						changeDec(0);
						makingDes = false;

						for(e in decG1){
							e.alpha=0;
						}
						for(e in decG2){
							e.alpha=0;
						}
				   }
				}
			 
	}
   
}
