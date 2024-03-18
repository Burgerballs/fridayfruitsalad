import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.math.FlxRandom;
import funkin.backend.utils.FlxInterpolateColor;
var centerMark:FlxText;
var barPercent = 0.5;
var barEmpty = '-';
var barFilled = '|';
var timeBarWidth = true;
var divider = '•';
var downscrollMult = 1;
var possibleScore = 0.0;
var showMisses = true;
var showAccuracy = true;
var showScore = true;
var showNPS = false;
var animateText = true;
var scoreMultiplier = true;
var timeBarVisible = true;
var scoreTextSize = 20;
var noteRecentHits:Array<Dynamic> = [];
var maxInterval = 1000;
var noteSum:Int = 0;
var npsPeak = 0;

function postCreate() {
    showMisses = FlxG.save.data.showMisses;
    showAccuracy = FlxG.save.data.showAccuracy;
    showScore = FlxG.save.data.showScore;
    animateText = FlxG.save.data.animateText;
    timeBarVisible = FlxG.save.data.timeBar;
    timeBarWidth = FlxG.save.data.timeBarSize;
    scoreTextSize = FlxG.save.data.scoreTextSize;
    scoreMultiplier = FlxG.save.data.scoreMultiplier;
    centerMark = new FlxText(0, 20, Std.int(FlxG.width*timeBarWidth), curSong.toUpperCase());
    centerMark.setFormat(Paths.font('vcr.ttf'), scoreTextSize, FlxColor.WHITE, 'center');
    centerMark.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    centerMark.antialiasing = true;
    centerMark.screenCenter(FlxAxes.X);
    centerMark.cameras = [camHUD];
    add(centerMark);
    centerMark.alpha = 0;
    scoreTxt.size = scoreTextSize;
    missesTxt.visible = false;
    scoreTxt.fieldWidth = 1280;
    accuracyTxt.visible = false;
    scoreTxt.alignment = 'center';
    scoreTxt.screenCenter(FlxAxes.X);
    scoreTxt.borderSize = 2;
    scoreTxt.antialiasing = true;
    scoreTxt.alpha = 0;
    scoreTxt.y = 0;
    downscrollMult = (downscroll ? 1 : -1);
}
function onSongStart() {
    FlxTween.tween(centerMark, {"alpha": 1}, 0.2);
    FlxTween.tween(scoreTxt, {"alpha": 1}, 0.2);
    scoreTxt.scale.set(0.1,0.1);
}
var comboMult = 1.0;
var lerpedVals:Array<Dynamic> = [0,0,0]; // for stat lerping
var shake = false;
var missedTimer = 0;
var sine = 0;
var scoreString = '';
var missesString = '';
var accuracyString = '';
var npsString = '';
function postUpdate(e) {
    missedTimer += e;
    sine += e;
    //BAR TEXT
    if (timeBarVisible) {
        barPercent = Conductor.songPosition / FlxG.sound.music.length;
        var glythwidth = Math.ceil(centerMark.width / centerMark.size);
        centerMark.text = curSong.toUpperCase() + '\n' + FlxStringUtil.formatTime(Conductor.songPosition/1000)+ ' ';
        for (i in 0...glythwidth)
        {
            if (i <= glythwidth * barPercent)
                centerMark.text += barFilled;
            else
                centerMark.text += barEmpty;
        }
        centerMark.text += ' ' + FlxStringUtil.formatTime((FlxG.sound.music.length-Conductor.songPosition)/1000);
    } else {
        centerMark.text = curSong.toUpperCase();
    }

    //LERP STUFF
    var lerpThing = 1 - framerateAdjust(0.15);
    scoreTxt.y = FlxMath.lerp(healthBarBG.y - 70, scoreTxt.y, 1 - framerateAdjust(Conductor.stepCrochet/500));
    centerMark.scale.set(FlxMath.lerp(1, centerMark.scale.x, lerpThing), FlxMath.lerp(1, centerMark.scale.y, lerpThing));
    comboMult = 1 + (combo / 50);
    lerpedVals[0] = FlxMath.lerp(songScore, lerpedVals[0], 1 - framerateAdjust(0.4));
    lerpedVals[1] = FlxMath.lerp(accuracy, lerpedVals[1], lerpThing);
    lerpedVals[2] = FlxMath.lerp(comboMult, lerpedVals[2], lerpThing);
    removeNote();
    if (getCurNPS() > npsPeak) npsPeak = getCurNPS();
    // TEXT STUFF
    scoreTxt.text = getText();
    scoreTxt.scale.x = centerMark.scale.y;
    scoreTxt.scale.y = centerMark.scale.x;
    scoreTxt.angle = (missedTimer <=Conductor.stepCrochet/1000 ? FlxMath.fastSin(sine*100)*5 : 0);
}
function getText() {
    var ret = '';
    var iterate = [];
    if (showScore) {
        scoreString = 'Silly Points: '+Math.ceil(lerpedVals[0])+ (scoreMultiplier ? ' ['+Math.ceil(lerpedVals[2]*100)/100+'x]' : '');
        iterate.push(scoreString);
    }
    if (showMisses) {
        missesString = 'Misses: '+misses +(misses == 0 && accuracy > 0 ? ' [FC]' : (accuracy < 0 ? ' [?]' : ' [CLEAR]'));
        iterate.push(missesString);
    }
    if (showAccuracy) {
        accuracyString = 'Accuracy: '+ (accuracy < 0 ? "-% [?]" : Math.ceil(lerpedVals[1]*10000)/100+'% [' + curRating.rating + ']');
        iterate.push(accuracyString);
    }
    if (showNPS) {
        npsString = 'NPS: '+ getCurNPS() + (npsPeak == 0 ? ' [?]': ' [PEAK: '+npsPeak+']');
        iterate.push(npsString);
    }
    for (i in 0...iterate.length) {
        var txt = iterate[i];
        ret += txt;
        if (i != iterate.length - 1)
            ret += ' ' + divider + ' ';
    }
    return ret;
}
function addNoteToNPS(time,size) {
    noteSum += size;
    noteRecentHits.push([time,size]);
}
function getCurNPS() return Std.int(noteSum / (maxInterval/1000));
function removeNote() {
    var exit = false;
    while (!exit) {
        if (noteRecentHits.length != 0) {
            if (noteRecentHits[0][0] + (maxInterval) < Conductor.songPosition) {
                noteSum -= Std.int(noteRecentHits[0][1]);
                noteRecentHits.shift();
            }
            else
                exit = true;
        }
        else
            exit = true;
    }
}
function onPlayerHit(e) {
    if (scoreMultiplier)
        e.score = Std.int(e.score * comboMult);
    if (animateText)
        scoreTxt.y += 5*downscrollMult;
    if (!e.note.isSustainNote)
        addNoteToNPS(e.note.strumTime,1);
}
function onPlayerMiss(e) {
    if (animateText) {
        scoreTxt.y -= 5*downscrollMult;
        missedTimer = 0;
    }
}
function beatHit(e) {
    if (!startingSong && animateText) {
        centerMark.scale.y += 0.05;
        centerMark.scale.x -= 0.05;
    }
}
function framerateAdjust(input:Float)
{
    return input * (60 / FlxG.drawFramerate);
}