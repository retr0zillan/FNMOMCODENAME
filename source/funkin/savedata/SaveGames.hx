package funkin.savedata;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxSave;
typedef SaveStruct ={
   @:optional var firstTime:Bool;
   @:optional var deadassholes:Array<String>;
   @:optional var deadGoodGuys:Array<String>;

} 
 class SaveGames{
    public static inline var SAVE1:Int=1;
    public static inline var SAVE2:Int=2;
    public static inline var SAVE3:Int=3;
    public static var saves:Array<FlxSave> = [];
    public static var save:Int;
   

    public static function init(args:Int=0){
           /*
               saves[args] = new FlxSave();
                saves[args].bind("SAVE"+args, 'GodSaves');
                trace(saves);
                */

                for(i in 1...4){
                    saves[i] = new FlxSave();
                    saves[i].bind("SAVE"+i, 'GodSaves');
                    trace('iniation of save ${i}');
                 
                }
           
    }
    public static function saveData(data:SaveStruct):Void{
        curSave().data.firstTime = data.firstTime;
        curSave().data.deadassholes = data.deadassholes;
        curSave().data.deadGoodGuys = data.deadGoodGuys;

    }
    public static function loadData():Null<SaveStruct>{
       
        var data:SaveStruct={
            firstTime : curSave().data.firstTime,
            deadassholes : curSave().data.deadassholes,
            deadGoodGuys : curSave().data.deadGoodGuys,
        }
        return data;
    }
	public static function hasData(daSave:FlxSave):Bool{
		if(daSave.data.deadassholes!=null||daSave.data.deadGoodGuys!=null ||daSave.data.firstTime!=null){
			return true;
		}
		return false;
	}
    public static function curSave():FlxSave{
        var curSave = saves[save];
        return curSave;

    }
   
}