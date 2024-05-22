import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;

import flixel.FlxG;
import funkin.backend.scripting.ModState;
import flixel.tweens.FlxTween;
import funkin.backend.assets.Paths;
import funkin.backend.utils.CoolUtil;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

var iconsGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var curSelected:Int = 0;
var arrows:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var descriptionSqr:FlxSprite;
var descriptionText:FlxText;
var descriptionMap:Map<String, String>=[
	"yesnt" => "“If you know the enemy and know yourself, you need not fear the result of a hundred battles. If you know yourself but not the enemy, for every victory gained you will also suffer a defeat. If you know neither the enemy nor yourself, you will succumb in every battle.”
― Sun Tzu, The Art of War",
	"cherlok" => "Escúchame bien hijo de tu puta madre vuélveme a mandar otro de tus pinches videos de anime y juro que te voy a ir a tu casa y te voy a putear cabrón que es esa mamada de que sube puros videos de otakus que realmente no tienen nada de sentido wey ponte a estudiar pinche cabrón deja tus pinches mamadas niñita marica estúpida desperdicio de semen cállate el puto osico y mejor ponte a procurarte a hacer tu tarea pendejo y ya me mandaste tus pinches videos de anime que son esas mamadas wey mejor ve porno real en vez de tus pinches otakurecerias
    -Sun Tzu El arte de la guerra",
	"springy" => "Being a femboy is a beautiful celebration of gender expression, where individuals can freely embrace their femininity. It's about breaking away from societal norms and expressing oneself authentically. Be yourself; everyone else is already taken - Oscar Wilde",
	"destrio" => "“A delayed mod is bad,a rushed mod is bad, all   mods are bad, I fucking hate mods and making them.”
	― Sock.clip",
	"dathree" => "Tuve que darle una actualización a mis sprites porque ya estaban algo viejo :T. Disfruta del mod y sigue al que me ayudó con los videos para First Instance. PanConPollo2004 en Twitter/X.
	― Dathree_O
	Hey! todo lo que hice fue la sección de vídeo en “first instance”, todas esas partes extrañas fueron solo yo haciendo el tonto con una cámara no te equivoques XD también ve y sigué a dathree_O en twitter, es chévere :D.
    ― PanConPollo2004",
	"cumi" => "Handicap From Wikipedia, the free encyclopedia at en.wikipedia.org
	Handicap (Handicap) is a sexual activity involving application of pain or constriction to the male genitals. This may involve directly painful activities, such as genital piercing, wax play, genital spanking, squeezing, ball-busting, genital flogging, urethral play, tickle torture, erotic electrostimulation or even kicking. The recipient of such activities may receive direct physical pleasure via masochism, or knowledge that the play is pleasing to a sadistic dominant.
	Image: Electrostimulation applied on a penis",
	"teeth" => "Normalizo panzones peludos con amor.",

];
var icons:Array<String>;
function postCreate(){


	FlxG.sound.playMusic(Paths.music('JokasDroid_Winter_Forest'), 1, true);

	trace('created');
	icons = CoolUtil.coolTextFile(Paths.txt('creditswow'));
	for(i in 0...icons.length){
		var icon = new FlxSprite(0,200).loadGraphic(Paths.image('menus/credits/'+icons[i]));
		icon.scale.set(4.5,4.5);
		icon.alpha = 0;
		icon.screenCenter(0x01);
		icon.antialiasing = false;
		icon.ID = i;
		iconsGroup.add(icon);
		var arrow = new FlxSprite(0,icon.y + 370);
		arrow.frames = Paths.getFrames('menus/credits/flecha');
		arrow.scale.set(7,7);
		arrow.antialiasing = false;
		arrow.updateHitbox();
		arrow.flipX = i == 0;
		arrow.animation.addByPrefix('idle', 'flecha IDLE', 7,true);
		arrow.animation.addByPrefix('press', 'flecha PRESS', 7,false);
		arrow.animation.play('idle');
		arrow.x = icon.x - 300 + (i*650);
		if(i<2)arrows.add(arrow);
			

	}
	add(iconsGroup);
	add(arrows);

	


	descriptionSqr = new FlxSprite(0,0).loadGraphic(Paths.image('menus/menuStuff/decSquare'));
	descriptionSqr.antialiasing = false;
	descriptionSqr.scale.set(2,3);
	descriptionSqr.updateHitbox();

	descriptionText = new FlxText(0,20, 500, '', 15);
	descriptionText.alignment = FlxTextAlign.JUSTIFY;
	descriptionText.font = Paths.font('nes-godzilla.ttf');
	descriptionText.setPosition(descriptionSqr.x + 20, 20);
    description.add(descriptionSqr);
	description.add(descriptionText);

	add(description);

	description.screenCenter();
	description.alpha = 0;

	changeSelection(0, true);
}
var description:FlxSpriteGroup = new FlxSpriteGroup();
var inDescription:Bool = false;
function displayDesc(appear:Bool = true){
	inDescription = appear;
	description.alpha = appear == true ? 1:0;
	for(arr in arrows)arr.alpha = appear == true ? 0:1;
	

}
function changeDescription(what:Int){
	if(descriptionMap.exists(icons[what]))
	descriptionText.text = descriptionMap.get(icons[what]).toUpperCase();
	else 
	descriptionText.text = "NONE";
	
}
function getIcon(id:Int):FlxSprite{
	for(icon in iconsGroup){
		if(icon.ID == id){
			return icon;
			break;
		}
	}
	return null;
}
var canChange:Bool = false;
function changeSelection(huh:Int = 0, force:Bool = false){
	var leArrow = arrows.members[huh == -1 ? 0 : 1];
	leArrow.animation.play('press');
	leArrow.animation.finishCallback = function(_) {
		leArrow.animation.play('idle');

	}
	var prevIcon = getIcon(curSelected);
	

	curSelected = (curSelected + huh + iconsGroup.members.length) % iconsGroup.members.length;

	if(force)
		curSelected=huh;
	changeDescription(curSelected);
	if(prevIcon!=null){
		canChange = true;
		FlxTween.tween(prevIcon, {alpha:0}, 0.5, {onComplete: function(_){
			var currentIcon = getIcon(curSelected);
			FlxTween.tween(currentIcon, {alpha:1}, 0.5, {onComplete: function(_){
				canChange = false;
			}});
			
		}});

	}

}
function goBack(){
	FlxG.switchState(new ModState('SelectState'));

}
function update(elapsed:Float){
	if(controls.ACCEPT && !inDescription)
		displayDesc(true);
	if(controls.LEFT_P && !canChange && !inDescription)
		changeSelection(-1);
	if(controls.RIGHT_P && !canChange && !inDescription)
		changeSelection(1);
	if(controls.BACK)
		inDescription == true ? displayDesc(false) : goBack();
}