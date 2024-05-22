package funkin.game;


import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;

import flixel.input.mouse.FlxMouseEventManager;

import flixel.input.keyboard.FlxKey;
import funkin.menus.NewStoryMenuState.GodziChar;
class FuckinGroup extends FlxTypedGroup<GodziChar>{
   public function new(maxSize:Int = 0) {
    super();
   }
  
   override function update(elapsed:Float) {
      super.update(elapsed);
   }
   public function getDeath():GodziChar
    {
        for(c in this.members){
            if(c.broIsDead == false && c.ID!=0){
                return c;
                break;
            }
        }
        return null;
    }

}