function postCreate(){
	forceIsOnScreen=true;
}
function update(elapsed:Float){
	timeElapsed +=elapsed;

	y += 0.2 * Math.cos((timeElapsed + 0 * 0.02) * Math.PI);

}
var timeElapsed:Float = 0;