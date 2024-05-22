
package funkin.menus;

import flixel.util.FlxSave;
import haxe.xml.Access;
import haxe.io.Path;
import funkin.backend.scripting.events.*;

import haxe.rtti.CType.Platforms;
import flixel.system.FlxSound;
import flixel.FlxObject;
import funkin.game.FuckinGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flash.events.MouseEvent;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import funkin.menus.StoryMenuState.WeekData;
import funkin.menus.StoryMenuState.WeekSong;

import flixel.math.FlxPoint;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.FileSystem;
import sys.io.File;
import funkin.savedata.SaveGames;
using StringTools;

typedef MapStruct =
{
	var villains:Map<String, Array<Float>>;
	var actorsPosition:Map<String, Array<Float>>;
	var tiles:Array<Array<Dynamic>>;
	@:optional var movemap:Map<String, Array<Dynamic>>;
}

class NewStoryMenuState extends MusicBeatState{
    var map:FlxSprite;
    var char:GodziChar;
    var companion:GodziChar;
    var enemy1:GodziChar;
    public static var firstTime:Bool = true;
    var enemies:Array<GodziChar> = [];
    public var enemiees:FlxTypedGroup<GodziChar>;
    public static var instance:NewStoryMenuState;
    var charss:Array<String>=['gezora', 'titano', 'biollante','moguera'];
    var curSelected:Int = 0;
    public var goodGuys:FuckinGroup;
    var weekMap:Map<String, Int>=[
        //bad omen
        'GEZORA'=>1,
        //bad signal
        'MOGUERA'=>2,
        //out of place
        'TITANO'=>3,
    ];
    
                 //left, right, up,down
    var moveMap:Map<BoardTile, Array<BoardTile>>=[];
    var positions:Array<Array<Int>>=[[785,460],[863,347],[1026,257],[711,339]];
    var text:FlxText;
    public static var curBoss:GodziChar;
    public static var player:String;
    var aasjasjas:String;
    var selectedWeek:Bool = false;
    var colG:BoardTile;
    public static var curCharacter:Int = 0;
    var colsGroup:Array<BoardTile>=[];
    public static var prevPos:Array<FlxPoint>=[];
    var actorsCointainer:Array<GodziChar>=[];
    var canSkip:Bool = false;
    var camFollow:FlxObject;
    var introCut:FlxSprite;
    var curDec:Int=0;
	public var weeks:Array<WeekData> = [];
    var sound1:FlxSound;
    var sound2:FlxSound;
    var arrow:FlxSprite;
    var sound3:FlxSound;
    var sound4:FlxSound;
    public static var deathFlag:Bool=false;
    var fText:FlxText;
    var selector:GodziChar;
    var curMap:String;
    var tiles:FlxSprite;
    var curTile:Int=0;
    public  var deadGoodGuys:Array<String>=[];
    public  var deadassholes:Array<String>=[];
    var metaData:MapStruct;
    var turns:Map<String, Int>=[
        'godzilla'=>2,
        'mothra'=>4,
        
    ];

    var camFocus:String='godzilla';
   public function new(?map:String){
    this.curMap = map;
    super();
    }

    var path:String;
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
			for(s in weeksFound)
				weeks.push(s);
			return false;
		}
		return true;
	}
	public function loadXMLs() {
		// CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		var weeks:Array<String> = [];
		if (getWeeksFromSource(weeks, MODS))
			getWeeksFromSource(weeks, SOURCE);

		for(k=>weekName in weeks) {
			var week:Access = null;
			try {
				week = new Access(Xml.parse(Assets.getText(Paths.xml('weeks/weeks/$weekName'))).firstElement());
			} catch(e) {
				Logs.trace('Cannot parse week "$weekName.xml": ${Std.string(e)}`', ERROR);
			}

			if (week == null) continue;

			if (!week.has.name) {
				Logs.trace('Story Menu: Week at index ${k} has no name. Skipping...', WARNING);
				continue;
			}
			var weekObj:WeekData = {
				name: week.att.name,
				id: weekName,
				sprite: week.getAtt('sprite').getDefault(weekName),
				chars: [null, null, null],
				songs: [],
				difficulties: ['easy', 'normal', 'hard']
			};

			var diffNodes = week.nodes.difficulty;
			if (diffNodes.length > 0) {
				var diffs:Array<String> = [];
				for(e in diffNodes) {
					if (e.has.name) diffs.push(e.att.name);
				}
				if (diffs.length > 0)
					weekObj.difficulties = diffs;
			}

			if (week.has.chars) {
				for(k=>e in week.att.chars.split(",")) {
					if (e.trim() == "" || e == "none" || e == "null")
						weekObj.chars[k] = null;
					
				}
			}
			for(k2=>song in week.nodes.song) {
				if (song == null) continue;
				try {
					var name = song.innerData.trim();
					if (name == "") {
						Logs.trace('Story Menu: Song at index ${k2} in week ${weekObj.name} has no name. Skipping...', WARNING);
						continue;
					}
					weekObj.songs.push({
						name: name,
						hide: song.getAtt('hide').getDefault('false') == "true"
					});
				} catch(e) {
					Logs.trace('Story Menu: Song at index ${k2} in week ${weekObj.name} cannot contain any other XML nodes in its name.', WARNING);
					continue;
				}
			}
			if (weekObj.songs.length <= 0) {
				Logs.trace('Story Menu: Week ${weekObj.name} has no songs. Skipping...', WARNING);
				continue;
			}
			this.weeks.push(weekObj);
			
		}
		trace(this.weeks);
	}
    function parseMapData(){
        path = Paths.json('mapData/${curMap.toUpperCase()}-DATA');
        if (FileSystem.exists(path))
            {
                var shit = Json.parse(File.getContent(path));
    
                metaData = {
                    villains: new Map<String, Array<Float>>(),
                    actorsPosition: new Map<String, Array<Float>>(),
                    tiles: shit.tiles,
                    movemap: new Map<String, Array<Dynamic>>()
                }
                trace(metaData.tiles);
                for (key in Reflect.fields(shit.villains))
                {
                    metaData.villains.set(key, Reflect.field(shit.villains, key));
                }
    
                
                for (key in Reflect.fields(shit.actorsPosition))
                {
                    metaData.actorsPosition.set(key, Reflect.field(shit.actorsPosition, key));
                }
                for (key in Reflect.fields(shit.movemap))
                    {
                        metaData.movemap.set(key, Reflect.field(shit.movemap, key));
                    }

                    
                trace(metaData.actorsPosition);
            }
    }
    function mapTheMapLol()
        {
            for (key in metaData.movemap.keys())
            {
                var master:BoardTile = colsGroup[Std.parseInt(key)];
                var directions:Array<BoardTile> = [
                    metaData.movemap.get(key)[0] == null ? null : colsGroup[metaData.movemap.get(key)[0]],
                    metaData.movemap.get(key)[1] == null ? null : colsGroup[metaData.movemap.get(key)[1]],
                    metaData.movemap.get(key)[2] == null ? null : colsGroup[metaData.movemap.get(key)[2]],
                    metaData.movemap.get(key)[3] == null ? null : colsGroup[metaData.movemap.get(key)[3]],
                    metaData.movemap.get(key)[4] == null ? null : colsGroup[metaData.movemap.get(key)[4]],
                    metaData.movemap.get(key)[5] == null ? null : colsGroup[metaData.movemap.get(key)[5]]
                ];
    
                moveMap.set(master, directions);
               
            }
        }
        var currentSave:FlxSave;
    override function create(){
        super.create();
		loadXMLs();
        parseMapData();
        currentSave = SaveGames.curSave();
    
      

        if(currentSave.data.firstTime!=null){
            firstTime=currentSave.data.firstTime;
            trace('not the first time');
        }
        else{
            firstTime=true;
			#if debug
			firstTime=false;

			#end
        }

            FlxG.sound.playMusic(Paths.music('mars'),1, true);
        instance = this;
       
        if(currentSave.data.deadassholes!=null){
            deadassholes = currentSave.data.deadassholes;
            trace('found data');
            trace(currentSave.data.deadassholes);

        }
    
        if(currentSave.data.deadGoodGuys!=null){
            trace('found dead good guys');

            deadGoodGuys = currentSave.data.deadGoodGuys;
            trace(deadGoodGuys);

        }

        /*
        if(FlxG.save.data.prevPos!=null){
            prevPos = FlxG.save.data.prevPos;
            trace('loaded pos save');
        }
        */
      
        for(i in 0...metaData.tiles.length){
            colG =new BoardTile(metaData.tiles[i][0], metaData.tiles[i][1], metaData.tiles[i][2]);
            colG.scale.set(2.5, 2.5);
		
            
            colG.ID = i;
          
          
            add(colG);
            colsGroup.push(colG);
        }
        //up, down, right,left
        //public function new(x:Float, y:Float, ?material:String = 'squareOrange', ?isEnemy:Bool = false, ?tileOwner:String = 'public', ?canGo:Bool = false){

        /*
        switch(curMap){
            case 'PATHOS': 
                
            case 'MARS': 
                colsGroup[21].setTileOwnerShip('MOGUERA', true, true);
                colsGroup[22].setTileOwnerShip('MOGUERA', true, true);

                colsGroup[28].setTileOwnerShip('TITANO', true, true);
                colsGroup[29].setTileOwnerShip('TITANO', true, true);

                colsGroup[23].setTileOwnerShip('GEZORA', true, true);
                colsGroup[24].setTileOwnerShip('GEZORA', true, true);
                //marquita

        }
        */
     
      

       /*
       colsGroup[1].enemyName = 'MOTHRA';

       colsGroup[0].enemyName = 'GODZILLA';
       */

                       //enemy cols, 23:Moguera, 33:Dragon, 29:gezora, 39:boss

        //mapPositions(curMap);
        mapTheMapLol();
   

        enemiees = new FlxTypedGroup<GodziChar>();
        add(enemiees);
        goodGuys = new FuckinGroup();
        add(goodGuys);

        
       
      
     

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
        trace(enemiees.members.length);

        /*
        switch(curMap){
            case 'PATHOS': 
                mapAssholes.set(enemiees.members[0], [29]);
                mapAssholes.set(enemiees.members[1], [33]);
                mapAssholes.set(enemiees.members[2], [39]);
                mapAssholes.set(enemiees.members[3], [23]);
            case 'MARS': 
                mapAssholes.set(enemiees.members[0], [27,23,24]);
                mapAssholes.set(enemiees.members[1], [30,28,29]);
                mapAssholes.set(enemiees.members[2], [25, 21,22]);
                //marquita
    
        }
       */

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
                              
                            trace('moving to alive player, ${aliveCharacter.curChar}');

                        }
                    }
                    

                }
        
            goodGuys.members[0].revive();
            curCharacter=0;
        }
    
  

      
        decG1 = new FlxTypedGroup<FlxSprite>();
        add(decG1);
        decG2 = new FlxTypedGroup<FlxSprite>();
        add(decG2);
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
		FlxG.camera.follow(camFollow, NO_DEAD_ZONE, 9);
		FlxG.camera.zoom = FlxG.camera.zoom + 0.37;
		FlxG.camera.focusOn(camFollow.getPosition());
       
        
    }
   
    var coverer:FlxSprite;
    var secondPartTimer:FlxTimer;
   
    var howToPlay:FlxSprite;
    

    var decG1:FlxTypedGroup<FlxSprite>;
    var decG2:FlxTypedGroup<FlxSprite>;
    var cantMove:Bool=false;
    var decText:FlxText;
    var square:FlxSprite;
    var width:Int = 30;
    var height:Int = 30;
    var selectedSmth:Bool = false;
    var tweening:Bool = false;
    var objID:BoardTile;

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
    var makingDes:Bool=false;
    var diffX:Float = 0;
    var diffY:Float = 0;
    var mapAssholes:Map<FlxSprite, Array<Int>>=[];

    var currentEnemyCam:GodziChar;

    var turnIndex:Int=0;
   
    function triggerEnemyTurn(){
        //marquita2
       
        cantMove = true;
        

        if(enemiees.members[turnIndex]==null)
            turnIndex = enemiees.getFirstExisting().ID;
        
        currentEnemyCam = enemiees.members[turnIndex];
        camFocus = 'enemy';
        var currentPlayer = goodGuys.members[curCharacter];
        trace('player is ${currentPlayer.curChar}');

        var closestDirection: FlxPoint = null;
        var closestDistance: Float = -1;
        new FlxTimer().start(0.3, function(_){
        currentEnemyCam.animation.play('${currentEnemyCam.curChar} selected');
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
                currentEnemyCam.animation.play('${currentEnemyCam.curChar} moving');

                FlxTween.tween(enemiees.members[turnIndex], {x:closestDirection.x, y:closestDirection.y-20}, 0.3,{onComplete:function(_){
                        currentEnemyCam.animation.play('${currentEnemyCam.curChar} selected');
                        if(objID.isEnemy){
                            trace('fuck man help me');
                           
    
                            for(c in enemiees){
                                if(c.curChar.toUpperCase()==objID.tileOwner){
                                    curBoss=c;
                                }
                            }
                          
                            player = goodGuys.members[curCharacter].curChar;

                            trace('player is ${player}');

                            PlayState.loadWeek(weeks[weekMap.get(curBoss.curChar.toUpperCase())],"normal");

                            for(i in 0...actorsCointainer.length){
                                prevPos[i] = actorsCointainer[i].getPosition();
                            
                            }
                      
                               new FlxTimer().start(0.5,function(_){

                              FlxG.switchState(new PlayState());
                               });
                            
    
    
                        }
                    new FlxTimer().start(1, function(_){
    
                                turnIndex++;
                                if(turnIndex>enemiees.length-1){
                                    turnIndex=0;
                                }
    
                                cantMove = false;
                                currentEnemyCam.animation.play('${currentEnemyCam.curChar} idle');
    
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
                                currentEnemyCam.animation.play('${currentEnemyCam.curChar} idle');
    
                                camFocus = 'godzilla';
            
                                turns.set(goodGuys.members[curCharacter].curChar, currentPlayer.curChar=='godzilla'?2:4);
            }
            
        });
       
        


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
    function moveToNextSquare(index:Int, ?enemyCollisionlistener:Int = 0){
        switch(enemyCollisionlistener){
            case 0:
                for(e in decG1){
                    if(e.alpha==1){
                        e.alpha=0;
                       
                    }
                }
                tweening=true;
                var daX = moveMap.get(objID)[index].x + diffX;
                var daY = moveMap.get(objID)[index].y + diffY;
        
                if(curCharacter!=0)
                goodGuys.members[curCharacter].animation.play('${goodGuys.members[curCharacter].curChar} moving');
                FlxTween.tween(goodGuys.members[curCharacter], {x:daX, y:daY}, 0.3, {onComplete:function(_) {
                    tweening = false;
                    if(curCharacter!=0){
                        goodGuys.members[curCharacter].animation.play('${goodGuys.members[curCharacter].curChar} selected');
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
                        fText.text = 'WILL YOU FIGHT ${moveMap.get(objID)[index].tileOwner}?';
                        aasjasjas=moveMap.get(objID)[index].tileOwner;
                        for(c in enemiees){
                            if(c.curChar.toUpperCase()==moveMap.get(objID)[index].tileOwner){
                                curBoss=c;
                                trace(curBoss);
                                break;
                            }
                        }
                        goodGuys.members[curCharacter].animation.play('${goodGuys.members[curCharacter].curChar} moving');
                        FlxTween.tween(goodGuys.members[curCharacter], {x:daX, y:daY}, 0.3, {onComplete:function(_) {
                            tweening = false;
                            goodGuys.members[curCharacter].animation.play('${goodGuys.members[curCharacter].curChar} selected');
                           

                            //    var charss:Array<String>=['gezora', 'titano', 'biollante','moguera'];
        
                         
                        
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
                                FlxG.sound.play(Paths.sound('selection'));
                                makingDes = true;
                                curBoss.animation.play('${curBoss.curChar} selected');

                        }
                         });
                    
                case 1: 
                    
                        trace('enemy in sight');
                        fText.text = 'WILL YOU FIGHT ${moveMap.get(objID)[index].tileOwner}?';

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
                            curBoss.animation.play('${curBoss.curChar} selected');

                   

                  

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
    public static var timingController:Float = 0.9;
    var startFollow:Bool=false;
    var prevCharacter:Int;
    var scalerWidth:Float = 1;
    var scalerHeight:Float = 1;

    var enemyNextMove:FlxPoint=new FlxPoint(0,0);
    public function chooseSelector(){
        if(!goodGuys.members[0].alive){
            goodGuys.members[0].revive();
        }
        startFollow=false;
       
     

        curCharacter=0;
        goodGuys.members[1].animation.play('godzilla idle');
        goodGuys.members[2].animation.play('mothra idle');
    }
    public function restartPlayersPos() {
   

        char.setPosition(metaData.actorsPosition.get('godzilla')[0], metaData.actorsPosition.get('godzilla')[1]);
        companion.setPosition(metaData.actorsPosition.get('mothra')[0], metaData.actorsPosition.get('mothra')[1]);
        selector.setPosition(metaData.actorsPosition.get('selector')[0], metaData.actorsPosition.get('selector')[1]);

        
    }
    function bruh(direction:Int){
        switch(curCharacter){
            default: 

                if((!moveMap.get(objID)[direction].isEnemy && !moveMap.get(objID)[direction].isAlly)){
  
   
                    moveToNextSquare(direction);
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
               
                      
    
                        moveToNextSquare(direction);
    
                     
        }
    }
    var page2:Bool=false;
    var editingX:Bool=true;
    var differ:FlxPoint=new FlxPoint(0,0);
    override function update(elapsed:Float){
        super.update(elapsed);
        
        var up = FlxG.keys.justPressed.UP;
        var down = FlxG.keys.justPressed.DOWN;
        var rightU=FlxG.keys.pressed.RIGHT && FlxG.keys.justPressed.UP;
        var rightD=FlxG.keys.pressed.RIGHT && FlxG.keys.justPressed.DOWN;
        var leftU=FlxG.keys.pressed.LEFT && FlxG.keys.justPressed.UP;
        var leftD=FlxG.keys.pressed.LEFT && FlxG.keys.justPressed.DOWN;

        var shifting:Bool = FlxG.keys.pressed.SHIFT;
        var differm=shifting?FlxG.keys.justPressed.Q:FlxG.keys.pressed.Q;
        var differp=shifting?FlxG.keys.justPressed.E:FlxG.keys.pressed.E;
        FlxG.watch.addQuick('deadGoodguys', deadGoodGuys);
        FlxG.watch.addQuick('deadBadGuys', deadassholes);
        FlxG.watch.addQuick('curChar', curCharacter);
        FlxG.watch.addQuick('nextIAmove', 'X:${enemyNextMove.x} Y:${enemyNextMove.y}');
        
  

       
    switch(camFocus){

        case 'godzilla':
            if(goodGuys.members[curCharacter]!=null)
                camFollow.setPosition(goodGuys.members[curCharacter].getGraphicMidpoint().x, goodGuys.members[curCharacter].getGraphicMidpoint().y);
        case 'enemy':
            if(currentEnemyCam!=null)
                camFollow.setPosition(currentEnemyCam.getGraphicMidpoint().x, currentEnemyCam.getGraphicMidpoint().y);

    }
        

        #if debug
        FlxG.watch.addQuick('curTile', curTile);
     
        #end
      
      

         
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
            if(FlxG.mouse.overlaps(col) && FlxG.mouse.justPressed){
                trace('current col is ${col.ID}, x: ${col.x}  y: ${col.y}');
            }
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
                                /*
                                var distance = FlxMath.distanceBetween(goodGuys.members[curCharacter], c);
                                var minDistance:Float = -1;
                                if (minDistance < 0 || distance < minDistance) {
                                    minDistance = distance;
                                    var closestCeill = c;
                                    enemyNextMove.set(c.x, c.y);
                                }
                                */
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
                    bruh(dirMaster);
                }
               
            
        }

        if(leftD && !tweening && !makingDes && !cantMove){

            trace('leftD');

            var dirMaster = 5;
            if(moveMap.get(objID)[dirMaster]!=null)
                {
                    bruh(dirMaster);

                }
          
            
        }

        if(rightU && !tweening && !makingDes && !cantMove){
            trace('rightU');

            var dirMaster = 2;
            if(moveMap.get(objID)[dirMaster]!=null)
                {
                    bruh(dirMaster);

                }
        }

           if(rightD && !tweening && !makingDes && !cantMove){
            trace('rightD');

            var dirMaster = 3;
            if(moveMap.get(objID)[dirMaster]!=null)
                {
                    bruh(dirMaster);

                }
        }
        if(down && !tweening && !makingDes && !cantMove){
            trace('down');

            var dirMaster = 1;
            if(moveMap.get(objID)[dirMaster]!=null)
                {
                    bruh(dirMaster);

                }
        }
        if(up && !tweening && !makingDes && !cantMove){
            trace('up');

            var dirMaster = 0;
            if(moveMap.get(objID)[dirMaster]!=null)
                {
                    bruh(dirMaster);

                }
        }
        if(makingDes){
            if(controls.BACK){
                changeDec(0);
                makingDes = false;
                if(curBoss!=null)curBoss.animation.play('${curBoss.curChar} idle');

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
                            player = goodGuys.members[curCharacter].curChar;

                            trace('player is ${player}');
							PlayState.loadWeek(weeks[weekMap.get(aasjasjas)],"normal");


                            for(i in 0...actorsCointainer.length){
                                prevPos[i] = actorsCointainer[i].getPosition();
                            
                            }
                      

                                FlxG.switchState(new PlayState());
                               
                                      
                                   
                       
                                makingDes = false;

                                  
                             case 1: 
                                trace('nope i dont wanna fight');
                            if(curBoss!=null)curBoss.animation.play('${curBoss.curChar} idle');

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
	var cameFromPlayState:Bool = false;
 
   
    
}

class GodziChar extends FlxSprite{
   public var curChar:String;
   public var offSets:Map<String,Array<Int>>=[];
   public var broIsDead:Bool = false;

    public function new(x:Float,y:Float, char:String, ?enemy:Bool = false, ?isAnimated:Bool=true ,?updatehit:Bool=true)
    {
        super(x,y);
        
        curChar = char;
        if(enemy){
            flipX = true;
        }
        if(isAnimated){
            frames = Paths.getFrames('menus/menuStuff/SelectionMap2');
            animation.addByPrefix('moguera idle', 'SelectionMap Mogueranotselecte', 12, false);
           animation.addByPrefix('moguera selected', 'SelectionMap Mogueraselected', 12, false);
           animation.addByPrefix('moguera moving', 'SelectionMap Mogueramoving', 12, false);

    
            animation.addByPrefix('gezora idle', 'SelectionMap GezoranoSelected', 12, false);
            animation.addByPrefix('gezora selected', 'SelectionMap GezoraSelected', 12, false);
            animation.addByPrefix('gezora moving', 'SelectionMap GezoraMoving', 12, false);


    
           animation.addByPrefix('titano idle', 'SelectionMap TitanoNoselected', 12, false);
           animation.addByPrefix('titano selected', 'SelectionMap Titanoselected', 12, false);
           animation.addByPrefix('titano moving', 'SelectionMap TitanoMoving', 12, false);

            animation.addByPrefix('biollante idle', 'SelectionMap BiollanteNoSelected', 12, false);
           animation.addByPrefix('biollante selected', 'SelectionMap BiollanteSelected', 12, false);
    
            animation.addByPrefix('godzilla idle', 'SelectionMap GodzillaNoselected', 12, false);
            animation.addByPrefix('godzilla selected', 'SelectionMap Godzillaselected', 12, false);
            animation.addByPrefix('godzilla moving', 'SelectionMap Godzillamoving', 12, false);

            animation.addByPrefix('mothra idle', 'SelectionMap MothraNoSelected', 12, false);
           animation.addByPrefix('mothra selected', 'SelectionMap MothraSelected', 12, false);
           animation.addByPrefix('mothra moving', 'SelectionMap Mothramoving', 12, false);

            animation.addByPrefix('varano idle', 'SelectionMap VaranNoSelected', 12, false);
            animation.addByPrefix('varano selected', 'SelectionMap VaranSelected', 12, false);
            animation.play('${curChar} idle');
            scale.set(2.5,2.5);
        }
        else{
            loadGraphic(Paths.image('menus/menuStuff/${char}'));
        }
      
     
    }
    
    override function update(elapsed:Float){
        super.update(elapsed);
       

    }
}
class BoardTile extends FlxSprite{
    public var tileOwner:String;
    public var isEnemy:Bool = false;
    public var canGo:Bool = false;
    public var isAlly:Bool = false;
    public function new(x:Float, y:Float, ?material:String = 'squareOrange'){
        super(x,y);
        loadGraphic(Paths.image('game/materials/${material}'));


        

        

    }
    public function setTileOwnerShip(owner:String, isEnemy:Bool, canGo:Bool){
        this.tileOwner = owner;
        this.isEnemy=isEnemy;
        this.canGo=canGo;
    }
    override function update(elapsed:Float){
        super.update(elapsed);
    }
}