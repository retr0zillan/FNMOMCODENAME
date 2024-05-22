function postCreate(){
	var bgrey = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	bgrey.antialiasing = true;
	bgrey.scrollFactor.set(0.9, 0.9);
	bgrey.scale.set(1.5,1.5);
	//insert(members.indexOf(dad), bgrey);
}
function postUpdate(elapsed){
	camFollow.setPosition(500,500);
}
