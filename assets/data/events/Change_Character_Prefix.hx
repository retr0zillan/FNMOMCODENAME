import haxe.ds.StringMap;
import funkin.game.PlayState;

var game = PlayState.instance;
function onEvent(event) {
	if (event.event.name == 'Change_Character_Prefix') {
		trace('Change_Character_Prefix');
		var params = {
			strumIndex: event.event.params[0],
			prefix: event.event.params[1]
		};
		if(params.prefix == "none"||params.prefix==null||params.prefix=="")
			params.prefix = "";
		
		trace(params.prefix);

		var strLine = game.strumLines.members[params.strumIndex];
		if (strLine != null) {
			strLine.animSuffix = params.prefix;
			if (strLine.characters != null) // Alt anim Idle
				for (character in strLine.characters) {
					if (character == null) continue;
					character.idleSuffix = params.prefix;
				}
		}

	}
}