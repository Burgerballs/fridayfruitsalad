import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
var tvThingie:FlxBackdrop;
var text:FlxText;
var intendedY = 720;
var camTv:FlxCamera = new FlxCamera();
function create() {
    FlxG.cameras.add(camTv, false);
    camTv.flipY = false;
    camTv.bgColor = 0x00000000;
    tvThingie = new FlxBackdrop(null, FlxAxes.X).loadGraphic(Paths.image('tvthing'));
    tvThingie.scale.y = 1;
    tvThingie.antialiasing = false;
    tvThingie.cameras = [camTv];
    add(tvThingie);
    text = new FlxText(0, -4, FlxG.width, 'Did you know that this is the only piece of text in the game aside from the fps text to use the system sans font?');
    text.setFormat('_sans', 16, FlxColor.YELLOW, 'left');
    text.antialiasing = false;
    text.screenCenter(FlxAxes.X);
    text.cameras = [camTv];
    add(text);
    tvThingie.y = 720;
}
function update(e) {
    var lerpThing = 1 - framerateAdjust(0.05);
    text.x += e*160;
    if (text.x > 1280)
        text.x = 0 - text.width;
    text.y = tvThingie.y - 2;
    tvThingie.y = FlxMath.lerp(intendedY, tvThingie.y, lerpThing);
    
}
function framerateAdjust(input:Float)
{
    return input * (60 / FlxG.drawFramerate);
}
var timerThing = new FlxTimer();

function onEvent(_){
    if (_.event.name == "tvthing"){
        text.text = _.event.params[0];
        intendedY = 704;
        text.x = 0;
        new FlxTimer().start(Conductor.crochet / 1000 * Std.parseFloat(_.event.params[1]), ()->{intendedY = 720;});
    }
}