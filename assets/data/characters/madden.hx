import funkin.game.PlayState;
var anims:Array<String>=['dead', 'deadloop', 'pianospawn'];
function onPlaySingAnim(event){
	if(anims.contains(this.animation.curAnim.name))
		{
			event.cancel();
			this.animation.finishCallback=function(_){
				this.dance();
			}
		}
}