import funkin.menus.MainMenuState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import funkin.backend.scripting.ModState;
import lime.app.Promise;
import flixel.FlxObject;
import funkin.backend.shaders.CustomShader;
import haxe.Json;
import funkin.backend.FunkinText;
import funkin.menus.credits.CreditsMain;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.backend.MusicBeatState;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.events.Event;
import funkin.options.OptionsMenu;
import hxvlc.flixel.FlxVideoSprite;
import flixel.util.FlxTimer;
import openfl.system.System;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import openfl.net.FileFilter;
import flixel.util.FlxAxes;
import funkin.editors.EditorPicker;
import flixel.math.FlxRect;
import funkin.menus.FreeplayState.FreeplaySonglist;
import flixel.group.FlxSpriteGroup;
import haxe.xml.Access;
import haxe.xml.Parser;
import Xml;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import flixel.math.FlxMath;
import haxe.Json;
import funkin.backend.chart.Chart;
import flixel.FlxCamera;
import funkin.savedata.FunkinSave;
import funkin.backend.scripting.events.EventGameEvent;
import funkin.backend.scripting.events.FreeplaySongSelectEvent;
import funkin.backend.scripting.events.MenuChangeEvent;
import funkin.backend.scripting.EventManager;
import lime.graphics.Image;
import flixel.addons.transition.FlxTransitionableState;

import lime.app.Event;
import lime.app.Future;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import funkin.backend.MusicBeatState;

public var songs:Array<ChartMetaData> = [];
public var curSelected:Int = 0;
var pages:FlxText;
public var curDifficulty:Int = 1;
var grpSongs:FlxTypedGroup<FlxText> = new FlxTypedGroup();
var curPage:Int = 1;
var songsPerPage:Int = 6;
var totalPages:Int;
public var songList:FreeplaySonglist;
var numba:FlxText;
public var intendedScore:Int = 0;
public var lerpScore:Int = 0;
function create(){

	FlxG.mouse.visible = true;
	songList = FreeplaySonglist.get();
	songs = songList.songs;


	if (songs[curSelected] != null) {
		for(k=>diff in songs[curSelected].difficulties) {
			if (diff == Options.freeplayLastDifficulty) {
				curDifficulty = k;
			}
		}
	}


}
function postCreate(){

		FlxG.sound.playMusic(Paths.music('PasswordLoop'));
		

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		totalPages = Math.ceil(songs.length / songsPerPage);

		for (i in 0...songs.length)
			{
				var songText:FlxText = new FlxText(480, 120+((i % songsPerPage)*70),0, songs[i].displayName.toUpperCase(), 22);
				songText.visible = i < songsPerPage;
	
				songText.font = Paths.font("nes-godzilla.ttf");
				songText.ID = i;
	
				
				grpSongs.add(songText);
	
				
			}

		add(grpSongs);

		pages=new FlxText(485,564,0, 'PAGE ', 24, true);
		pages.color=0xEAC50101;

		pages.font = Paths.font("nes-godzilla.ttf");
		add(pages);
		
		numba=new FlxText(pages.x +140, pages.y - 2, 0, curPage + '/' + totalPages, 24, true);
		numba.color=0xFFFFFF;

		
	
		numba.font= Paths.font("nes-godzilla.ttf");
		add(numba);

		changeSelection(0, true);

}

public function changeSelection(change:Int = 0, force:Bool = false)
	{
		if (change == 0 && !force) return;

	

		var event = event("onChangeSelection", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, songs.length-1), change));
		if (event.cancelled) return;

		curSelected = event.value;
		trace(songs[curSelected].name);
		
		changeDiff(1);

		for (item in grpSongs.members)
			{
			
	
				item.color= FlxColor.WHITE;
				// item.setGraphicSize(Std.int(item.width * 0.8));
	
				if (item.ID == curSelected)
				{
					item.color= 0xEAC50101;
	
					// item.setGraphicSize(Std.int(item.width));
				}
			}

		

	}
public function changeDiff(change:Int = 0, force:Bool = false)
	{

		var curSong = songs[curSelected];
		var validDifficulties = curSong.difficulties.length > 0;
		var event = event("onChangeDiff", EventManager.get(MenuChangeEvent).recycle(curDifficulty, validDifficulties ? FlxMath.wrap(curDifficulty + change, 0, curSong.difficulties.length-1) : 0, change));

		if (event.cancelled) return;

		curDifficulty = event.value;


		updateScore();

	}
	function updateScore() {
			
		if (songs[curSelected].difficulties.length <= 0) {
			intendedScore = 0;
			trace('setting score to 0');
			return;
		}
		var changes:Array<HighscoreChange> = [];

	
		var difficulty:String = songs[curSelected].difficulties[curDifficulty].toLowerCase();
		trace(difficulty);
		
		var saveData = FunkinSave.getSongHighscore(songs[curSelected].name, difficulty, changes);
	
		intendedScore = saveData.score;
	}
	function changePage(guh:Int=1){
		var prevPage = curPage;

		curPage+=guh;
		if(curPage>totalPages){
			curPage=1;
		}
		if(curPage<1){
			curPage = totalPages;
		}

		updatePageVisibility();
		
		changeSelection((curPage - 1) * songsPerPage - curSelected, true);

   	 
	}
	function updatePageVisibility() {
		for (i in 0...songs.length) {
			grpSongs.members[i].visible = (i >= (curPage-1)*songsPerPage && i < curPage*songsPerPage);

		}
		numba.text = curPage + '/' + totalPages;
		
	}
	function update(elapsed:Float){
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		changeSelection(-1);
		
		if (downP)
		changeSelection(1);
		

		if (controls.RIGHT_P)
		changePage(1);
			
		if (controls.LEFT_P)
		changePage(-1);
			
	
		if (controls.BACK)
		FlxG.switchState(new MainMenuState());
		

		if (accepted)
		selectSong();
			
		lerpScore = Math.floor(lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
	}
	public function selectSong() {

	
		if (songs[curSelected].difficulties.length <= 0) return;

		//var event = event("onSelect", EventManager.get(FreeplaySongSelectEvent).recycle(songs[curSelected].name, songs[curSelected].difficulties[curDifficulty], __opponentMode, __coopMode));

		if (event.cancelled) return;

		Options.freeplayLastSong = songs[curSelected].name;
		Options.freeplayLastDifficulty = songs[curSelected].difficulties[curDifficulty];

		PlayState.loadSong(songs[curSelected].name, songs[curSelected].difficulties[curDifficulty], false, 0);

	
		FlxG.switchState(new PlayState());
		
	

		
	}