function initUI()
{
	width = $('#guitar').width();
	height = $('#guitar').height();	
	x0s = [33, 29, 24, 20, 15, 10];
	y0s = [100, 102, 104, 106, 108, 110];
	x1s = [width, width, width, width, width, width];
	y1s = [370, 380, 390, 400, 410, 418];

	guitar = createGuitar();
	guitar.draw();
	
	window.onkeydown = keypress;
}

mappings = {
	'1': [5, 0], '2': [4, 0], '3': [3, 0], '4': [2, 0], '5': [1, 0], '6': [0, 0],
	'Q': [5, 1], 'W': [4, 1], 'E': [3, 1], 'R': [2, 1], 'T': [1, 1], 'Y': [0, 1],
	'A': [5, 2], 'S': [4, 2], 'D': [3, 2], 'F': [2, 2], 'G': [1, 2], 'H': [0, 2],
	'Z': [5, 3], 'X': [4, 3], 'C': [3, 3], 'V': [2, 3], 'B': [1, 3], 'N': [0, 3]
}

onload = function() {
	stomp = new STOMPClient();
	stomp.onopen = function() { };
	stomp.onclose = function(c) { alert("Lost Connection, Code: " + c); };
	stomp.onerror = function(e) { alert("Error: " + e); };
	stomp.onerrorframe = function(frame) { alert("Error: " + frame.body); };
	stomp.onconnectedframe = function() { stomp.subscribe("/bass/key"); };
	stomp.onmessageframe = function(frame) { modify_partner(frame.body); };
	stomp.connect('localhost', 61613);	
	
	initUI();
}

function keypress(e)
{
	var key = String.fromCharCode(e.keyCode || e.charCode);
	guitar.play(key);
	
//	message = JSON.stringify(key)
//	stomp.send(message, "/guitar/note");
//	$('#mine').html(key);
}

function InstrumentString(name,x0,y0,x1,y1) {
	this.name = name;
	this.audio = this.audio1 = new Audio(name + '.ogg');
	this.audio2 = new Audio(name + '.ogg');
	this.next_audio = 2;
	window[this.name + 'string'] = this;
	this.pluck = function(fret) {
		this.playAudio(fret);
		this.vibrate(fret);
		this.timeoutID = setTimeout(this.name + 'string.endVibration()', 5000);
	}
	this.playAudio = function(fret) {
		this.timeoutID && clearTimeout(this.timeoutID);
		this.audio.pause();
		this.switchAudio();
		this.audio.currentTime = fret*6 + .5;
		this.audio.play();
	}
	this.switchAudio = function() {
		if (this.next_audio == 1) {
			this.audio = this.audio1;
			this.next_audio = 2;
		} else {
			this.audio = this.audio2;
			this.next_audio = 1;
		}
	}
	this.vibrate = function(fret) {
		this.intervalID && clearInterval(this.intervalID);
		this.resetCanvas();
		for(var i=0; i<this.contexts.length; ++i)
		{
			if (i==2)
				continue;
			this.contexts[i].clearRect(0,0,this.canvases[i].width, this.canvases[i].height);
			this.contexts[i].beginPath();
			this.contexts[i].moveTo(this.x0,this.y0);
			this.contexts[i].arcTo(width/2, this.ymid0 + 2*(2-i), this.x1, this.y1, 1000);
			this.contexts[i].lineTo(this.x1,this.y1);
			this.contexts[i].stroke();
		}
		this.intervalID = setInterval(this.name + 'string.flipCanvases()', 30);
	}
	this.endVibration = function() {
		this.audio.pause();
		clearInterval(this.intervalID);
		this.resetCanvas();
	}

	this.x0=x0;
	this.y0=y0;
	this.x1=x1;
	this.y1=y1;
	this.ymid0 = (this.y0 + this.y1)/2;
	this.canvases = [];
	this.contexts = [];
	this.currentCanvas = 2;
	this.direction = -1;
	for(var i=0; i<5; ++i)
	{
		this.canvases[i] = document.getElementById(this.name + '_' + i);
		this.canvases[i].width = width;
		this.canvases[i].height = height;
		this.contexts[i] = this.canvases[i].getContext('2d');
	}
	this.draw = function() {
		for(var i=0; i<this.contexts.length; ++i)
		{
			this.contexts[i].beginPath();
			this.contexts[i].moveTo(this.x0,this.y0);  
			this.contexts[i].lineTo(this.x1,this.y1);  
			this.contexts[i].stroke();
		}
	}	
}

InstrumentString.prototype.flipCanvases = function()
{
	$('#' + this.name + '_' + this.currentCanvas).attr('style', "z-index: 0;");

	this.currentCanvas += this.direction;
	if(this.currentCanvas == 0)
		this.direction=1;
	else if(this.currentCanvas == 4)
		this.direction=-1;

	$('#' + this.name + '_' + this.currentCanvas).attr('style', "z-index: 2;");
}

InstrumentString.prototype.resetCanvas = function()
{
	$('#' + this.name + '_' + this.currentCanvas).attr('style', "z-index: 0;");

	this.currentCanvas = 2;

	$('#' + this.name + '_' + this.currentCanvas).attr('style', "z-index: 2;");
}

var createGuitar = function() {
	var strings = [
		new InstrumentString('guitar_e', x0s[0], y0s[0], x1s[0], y1s[0]),
		new InstrumentString('guitar_B', x0s[1], y0s[1], x1s[1], y1s[1]),
		new InstrumentString('guitar_G', x0s[2], y0s[2], x1s[2], y1s[2]),
		new InstrumentString('guitar_D', x0s[3], y0s[3], x1s[3], y1s[3]),
		new InstrumentString('guitar_A', x0s[4], y0s[4], x1s[4], y1s[4]),
		new InstrumentString('guitar_E', x0s[5], y0s[5], x1s[5], y1s[5])
	];
	var handPosition = 0;

	return {
		play: function(key) {
			var offset = mappings[key][0];
			var fret = mappings[key][1];
			strings[offset].pluck(fret);
		},
		shiftHand: function(newPosition) {
			handPosition = newPosition;
		},
		draw: function() {
			var canvas_base = document.getElementById('base_frame');
			canvas_base.width = width;
			canvas_base.height = height;
			context_base = canvas_base.getContext("2d");
			var	img = new Image();
			img.src = 'guitar_prototype_2.png';
			img.onload = function() {
				context_base.drawImage(img, 0, 0, img.width, img.height, 0,100,width, height-100);
				for(var i=0; i<strings.length; ++i)
				{
					strings[i].draw();
				}
			};
		}
	}
};

var createBass = function() {
	var strings = [
		new InstrumentString('guitar_G', x0s[2], y0s[2], x1s[2], y1s[2]),
		new InstrumentString('guitar_D', x0s[3], y0s[3], x1s[3], y1s[3]),
		new InstrumentString('guitar_A', x0s[4], y0s[4], x1s[4], y1s[4]),
		new InstrumentString('guitar_E', x0s[5], y0s[5], x1s[5], y1s[5])
	];
	var handPosition = 0;

	return {
		play: function(key) {
			var offset = mappings[key][0];
			var fret = mappings[key][1];
			strings[offset].pluck(fret);
		},
		shiftHand: function(newPosition) {
			handPosition = newPosition;
		},
		draw: function() {
			canvas_base = document.getElementById('base_frame');
			canvas_base.width = width;
			canvas_base.height = height;
			context_base = canvas_base.getContext("2d");
			img = new Image();
			img.src = 'bass_prototype_2.png';
			img.onload = function() {
				context_base.drawImage(img, 0, 0, img.width, img.height, 0,100,width, height-100);
				for(var i=0; i<strings.length; ++i)
				{
					strings[i].draw();
				}
			};
		}
	}
};

var modify_partner = function(payload) {
	var key = JSON.parse(payload);
	bass.play(key);
	$('#theirs').html(key);
}

