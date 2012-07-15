// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.svg.min.js
//= require jwm_header
//= require pages
//= require jamwithme

/*$(document).ready(function(){
  function debug(str){ $("#debug").append("<p>"+str+"</p>"); };

  $('#echo-form').change(function() {
    ws.send($('#echo-form').val());
  });

  $('#pairup-button').click(function() {
    ws = new WebSocket("ws://192.168.1.3:8080/websocket");
    ws.onmessage = function(evt) { 
      $("#message").append("<p>"+evt.data+"</p>");
      jwm.message_handler(evt);
    };
    ws.onclose = function() { debug("socket closed"); };
    ws.onopen = function() {
      debug("connected...");
    };
  });

  var fret = 15;

  var onSvgLoaded = function () {
    var svg = $(this).svg('get');
    var regex = /-?\d+.\d+,-?\d+.\d+/g;
    var coordinates;
    var coord_set = [];
    var $frames = [];

    var EString = svg.getElementById('stringe');

    var strings = svg.getElementById('strings');
    var path = EString.getAttribute('d');
    while(coordinates = regex.exec(path)) {
      tokens = coordinates[0].split(','); 
      coord_set.push([parseFloat(tokens[0]),parseFloat(tokens[1])]);
    }

    var addVibString = function(fret, pos, id) {
      // draw an arc from one of the center frets
      var x0 = coord_set[0][0];
      var y0 = coord_set[0][1];

      var xfret = coord_set[fret][0];
      var yfret = coord_set[fret][1];

      var x1 = coord_set[21][0];
      var y1 = coord_set[21][1];

      var m = -1.0*(x1-x0)/(y1-y0);
      var delx = pos;
      cx = (xfret + x1)/2 + delx;
      cy = (yfret + y1)/2 + delx*m;

      var color_dark = '#000000';
      var color_light = '#001111';

      var newPath = svg.createPath();
      svg.path(
        strings, 
        newPath
          .move(x0, y0)
          .line(xfret, yfret)
          .curveQ(cx, cy, x1, y1),
        {
          'stroke-opacity': '.2',
          id: id,
          style:
'fill:none;stroke:#000000;stroke-width:0.91477633px;stroke-linecap:butt;stroke-linejoin:miter;display:inline'
        });

        $frames.push($(svg.getElementById(id)));

      };

      var flip_order = ['3239', '3239-hi', '3239-HI', '3239-lo', '3239-LO'];
      addVibString(fret, -1, flip_order[4]);
      addVibString(fret, -.5, flip_order[3]);
      $frames.push($(EString));
      
      addVibString(fret, .5,flip_order[1]);
      addVibString(fret, 1,flip_order[2]);
      var current_flip = 2;
      var direction = 1;
      var cycles = 0;
      var max = 4;

      var flip = function() {
        $frames[current_flip].attr('stroke-opacity', .2);
      
        if (current_flip == max) {
          direction = -1;
          cycles+=1;
        } else if (current_flip == 0) {
          direction = 1;
        }
    
        current_flip += direction;

        $frames[current_flip].attr('stroke-opacity', 1);
      }
      
      setInterval(flip, 30);
    };

    $('#guitar').svg({
      loadURL: '/assets/guitar_prototype_2.svg',
      onLoad: onSvgLoaded
    });

    

});*/
