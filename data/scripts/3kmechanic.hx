var keys = ['J','K','L'];
var originalStrumPositions:Array<Dynamic> = [];
function onSongStart() {
    for (i in playerStrums.members) {
        originalStrumPositions.push([i.x,i.y]);
    }
}
var shiftedStrums = false;
function onPostStrumCreation(e) {
    var strum = e.strum;
    switch (strum.ID) {
        case 0:
            strum.getPressed = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.pressed, keys[0]) : false);
            strum.getJustPressed = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.justPressed, keys[0]) : false);
            strum.getJustReleased = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.justReleased, keys[0]) : false);
        case 1:
            strum.getPressed = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.pressed, keys[1]) : Reflect.getProperty(FlxG.keys.pressed, keys[0]));
            strum.getJustPressed = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.justPressed, keys[1]) : Reflect.getProperty(FlxG.keys.justPressed, keys[0]));
            strum.getJustReleased = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.justReleased, keys[1]) : Reflect.getProperty(FlxG.keys.justReleased, keys[0]));
        case 2:
            strum.getPressed = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.pressed, keys[2]) : Reflect.getProperty(FlxG.keys.pressed, keys[1]));
            strum.getJustPressed = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.justPressed, keys[2]) : Reflect.getProperty(FlxG.keys.justPressed, keys[1]));
            strum.getJustReleased = () -> return (!shiftedStrums ? Reflect.getProperty(FlxG.keys.justReleased, keys[2]) : Reflect.getProperty(FlxG.keys.justReleased, keys[1]));
        case 3:
            strum.getPressed = () -> return (shiftedStrums ? Reflect.getProperty(FlxG.keys.pressed, keys[2]) : false);
            strum.getJustPressed = () -> return (shiftedStrums ? Reflect.getProperty(FlxG.keys.justPressed, keys[2]) : false);
            strum.getJustReleased = () -> return (shiftedStrums ? Reflect.getProperty(FlxG.keys.justReleased, keys[2]) : false);
    }
}
function shiftAmount() {
    return (shiftedStrums ? 1 : -1);
}
function animAmt() {
    return (shiftedStrums ? 1 : 0);
}
function postUpdate() {
    if (FlxG.keys.justPressed.A) {
        shiftedStrums = false;
        shiftStrums();
    }
    if (FlxG.keys.justPressed.D) {
        shiftedStrums = true;
        shiftStrums();
    }
    prevShiftedStrums = shiftedStrums;
    playerStrums.members[3].alpha = 0;
}
function shiftStrums() {
    playerStrums.forEach((s) -> {
        if (shiftedStrums != prevShiftedStrums)
            s.x += ((cpuStrums.members[1].x - cpuStrums.members[0].x) * shiftAmount());
    });
}
function onNoteCreation(e) {
    e.note.strumRelativePos = false;
    e.note.onDraw = modchartRenderer;
}
function onPostInputUpdate() {
    playerStrums.forEach(function(str) {
        str.updatePlayerInput(Reflect.getProperty(FlxG.keys.pressed, keys[str.ID]), Reflect.getProperty(FlxG.keys.justPressed, keys[str.ID]), Reflect.getProperty(FlxG.keys.justReleased, keys[str.ID]));
    });
}

function modchartRenderer(note) {
    if (note.strumLine == playerStrums) {
        note.x += (shiftedStrums ? cpuStrums.members[0].x - cpuStrums.members[1].x : 0);
        note.alpha = 1;
        note.draw();
        note.x -= (shiftedStrums ? cpuStrums.members[0].x - cpuStrums.members[1].x : 0);
    } else {
        note.draw();
    }
}