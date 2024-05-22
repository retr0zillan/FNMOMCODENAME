var self = this;
var anims:Array<String>=['huhintro', 'huhloop', 'deusExEnd'];
function create(){
	trace(self.curCharacter);
}
function onPlaySingAnim(event){
	if(anims.contains(this.animation.curAnim.name))
		{
			event.cancel();
			this.animation.finishCallback=(name:String)->{
				switch(name){
					default: 
						this.dance();
					case 'huhintro': 
					this.playAnim('huhloop');
				}
			}
		}
}
