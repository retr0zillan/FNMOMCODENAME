var redBeat:FlxSprite;
function postCreate() {
	for (event in events) {
		if (event.name == 'Heart_Beat') {
			redBeat = new FlxSprite(0,0);
			redBeat.screenCenter();
			redBeat.frames = Paths.getFrames('game/Redbeat');
			redBeat.animation.addByPrefix('beat', 'redbeat', 30, false);
			redBeat.alpha = 1/9999999;
			redBeat.animation.play('beat');
  
			redBeat.scale.set(20.5,20.5);

			var params = {
				strumIndex: event.params[0],
				charName: event.params[1],
				charIndex: event.params[2]
			};
			var layer:Character = strumLines.members[params.strumIndex].characters[params.charIndex];

			insert(members.indexOf(layer)-1, redBeat);

		}
	}
}
function onEvent(event) {
	if (event.event.name == 'Heart_Beat') {
		redBeat.alpha = 1;
		redBeat.animation.play('beat');

		redBeat.animation.finishCallback = function(_){
		  remove(redBeat);
		}
	}
}