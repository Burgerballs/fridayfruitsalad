import flixel.FlxG;
function create() {
    if(FlxG.save.data.showMisses == null) FlxG.save.data.showMisses = true;
    if(FlxG.save.data.showAccuracy == null) FlxG.save.data.showAccuracy = true;
    if(FlxG.save.data.showScore == null) FlxG.save.data.showScore = true;
    if(FlxG.save.data.timeBar == null) FlxG.save.data.timeBar = true;
    if(FlxG.save.data.timeBarSize == null) FlxG.save.data.timeBarSize = 1.0;
    if(FlxG.save.data.animateText == null) FlxG.save.data.animateText = true;
    if(FlxG.save.data.scoreMultiplier == null) FlxG.save.data.scoreMultiplier = true;
    if(FlxG.save.data.scoreTextSize == null) FlxG.save.data.scoreTextSize = true;
    FlxG.save.flush();
}