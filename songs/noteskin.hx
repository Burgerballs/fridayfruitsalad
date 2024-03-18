var daPixelZoom = 6;
var notePool = [0,3,4,5,6,7]; // gold coin gonna be done later!!
var susPool = [0,1,2,3]; // gold coin gonna be done later!!
function onStrumCreation(event) {
	event.cancel();

	var strum = event.strum;
	strum.loadGraphic(Paths.image('noteskin'), true, 17, 17);
	strum.animation.add("static", [event.strumID,4 + event.strumID,8 + event.strumID],12,true);
	strum.animation.add("pressed", [24 + event.strumID, 28 + event.strumID, 32 + event.strumID], 12, false);
	strum.animation.add("confirm", [36 + event.strumID, 40 + event.strumID, 44 + event.strumID,48 + event.strumID], 12, false);

	strum.scale.set(daPixelZoom, daPixelZoom);
	strum.updateHitbox();
}

function onNoteCreation(event) {
	event.cancel();

	var note = event.note;
	if (event.note.isSustainNote) {
		note.loadGraphic(Paths.image('noteskin_holds'), true, 7, 6);
		note.animation.add("hold", [FlxG.random.getObject(susPool)]);
		note.animation.add("holdend", [4 + FlxG.random.getObject(susPool)]);
        note.onDraw = awesome;
	} else {
		note.loadGraphic(Paths.image('noteskin'), true, 17, 17);
		note.animation.add("scroll", [12 + getIntFromPool(notePool)]);
		note.alpha = 1;
	}
	note.scale.set(daPixelZoom, daPixelZoom);
	note.updateHitbox();
}
function onPostNoteCreation(event) {
	event.cancel();
	event.note.antialiasing = false;
}

function getIntFromPool(arr:Array<Int>) {
    var rand:Int = FlxG.random.int(0,arr.length);
    for (i in 0...arr.length) {
        if (i == rand) 
            return Std.int(arr[i]);
    }
    return Std.int(arr[0]);
}
function postUpdate(e) {
    for(p in strumLines) {
        p.notes.forEach(function(n) {
            n.y -= n.y % daPixelZoom;
            n.x -= n.x % daPixelZoom;
            n.scale.set(daPixelZoom, daPixelZoom);
			n.alpha = 1;
            n.updateHitbox();
        });
    }
}