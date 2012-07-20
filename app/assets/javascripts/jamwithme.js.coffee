COORDS_REGEX = /-?\d+.\d+,-?\d+.\d+/g
STRING_STYLE = 'fill:none;stroke:#000000;stroke-width:0.91477633px;stroke-linecap:butt;stroke-linejoin:miter;display:inline'
KEY_BINDINGS = {
	'1': [5, 0], '2': [4, 0], '3': [3, 0], '4': [2, 0], '5': [1, 0], '6': [0, 0],
	'Q': [5, 1], 'W': [4, 1], 'E': [3, 1], 'R': [2, 1], 'T': [1, 1], 'Y': [0, 1],
	'A': [5, 2], 'S': [4, 2], 'D': [3, 2], 'F': [2, 2], 'G': [1, 2], 'H': [0, 2],
	'Z': [5, 3], 'X': [4, 3], 'C': [3, 3], 'V': [2, 3], 'B': [1, 3], 'N': [0, 3]
}
GUITAR = undefined
BASS = undefined
WS = undefined
GUITAR_LOADED = false
BASS_LOADED = false
USE_GUITAR = true

class InstrumentString
  constructor: (@instrument, @audio_offset, @stringSvg, options) ->
    @svg = options.svg
    @stringsSvg = options.strings
    @audioSource = options.audio

    @audio = new Audio @audioSource
    
    coordinate_set = @stringSvg.getAttribute 'd'
    
    @coordinates = while matchData = COORDS_REGEX.exec(coordinate_set)
      coords = matchData[0].split ','
      parseFloat(coord) for coord in coords

    @$frames = []

  pluck: (fret) ->
    start = 8*(@audio_offset + fret) + .05
    end = start + 7.5

    @audio.pause()
    this.endVibrationGraphics() unless @$frames.length == 0
    @audio.currentTime = start
    @audio.play()
    this.beginVibrationGraphics fret

    clearInterval(@timer)
    
    thisString = this
    @timer = setInterval((->
#      console.log thisString.audio.currentTime + ' ' + end
      if thisString.audio.currentTime >= end
        thisString.audio.pause()
        clearInterval(thisString.timer)
        thisString.endVibrationGraphics()
        true),20)

  beginVibrationGraphics: (fret) ->
    this.addVibrationPhase(fret, -1)
    this.addVibrationPhase(fret, -.5)
    @$frames.push($(@stringSvg))
    this.addVibrationPhase(fret, .5)
    this.addVibrationPhase(fret, 1)

    @vibPhase = 2
    @vibDirection = 1
    @vibMaxPhase = 4
    that = this

    flip = ->
      that.$frames[that.vibPhase].attr 'stroke-opacity', '.2'
      
      that.vibPhase += switch that.vibPhase
        when that.vibMaxPhase then that.vibDirection = -1
        when 0 then that.vibDirection = 1
        else that.vibDirection

      that.$frames[that.vibPhase].attr 'stroke-opacity',  '1'
      true

    @vibrationLoop = setInterval flip, 100
    true

  endVibrationGraphics: ->
    clearInterval @vibrationLoop
    @$frames[0].remove()
    @$frames[1].remove()
    @$frames[3].remove()
    @$frames[4].remove()
    @$frames[2].attr 'stroke-opacity',  '1'
    @$frames = []

  addVibrationPhase: (fret, deltaX) ->
    id = @audio_offset + '_' + fret + '_' + deltaX + '_' + @instrument
    xNeck = @coordinates[0][0]
    yNeck = @coordinates[0][1]

    xFret = @coordinates[fret][0]
    yFret = @coordinates[fret][1]

    xBridge = @coordinates[@coordinates.length-1][0]
    yBridge = @coordinates[@coordinates.length-1][1]

    perpSlope = -1.0*(xBridge-xNeck)/(yBridge-yNeck)
    
    # control points are used to model the standing wave with second order
    # Bezier curves
    xControl = (xFret+xBridge)/2 + deltaX
    yControl = (yFret+yBridge)/2 + deltaX*perpSlope

    phasePath = @svg.createPath()
    @svg.path(
      @stringsSvg,
      phasePath
        .move(xNeck, yNeck)
        .line(xFret, yFret)
        .curveQ(xControl, yControl, xBridge, yBridge),
      {
        'stroke-opacity' : .2
        id: id
        style: STRING_STYLE; }
    )
    
    @$frames.push $(@svg.getElementById id)
    true

class Bass
  constructor: (@svg) ->
    strings = @svg.getElementById 'bass_strings'
    options = {
      svg: @svg,
      strings: strings,
      audio: 'BassNotes.ogg'
    }

    @strings = [
      new InstrumentString 'bass', 15, @svg.getElementById('bass_stringG'), options
      new InstrumentString 'bass', 10, @svg.getElementById('bass_stringD'), options
      new InstrumentString 'bass', 5, @svg.getElementById('bass_stringA'), options
      new InstrumentString 'bass', 0, @svg.getElementById('bass_stringE'), options
    ]

  play: (key) ->
    offset = KEY_BINDINGS[key][0] - 2
    return false unless 0 <= offset <= 3
    fret = KEY_BINDINGS[key][1]
    @strings[offset].pluck fret
    true

class Guitar
  constructor: (@svg) ->
    strings = @svg.getElementById 'guitar_strings'
    options = {
      svg: @svg,
      strings: strings,
      audio: 'AllNotes.ogg'
    }
    @strings = [
      new InstrumentString 'guitar', 24, @svg.getElementById('guitar_stringe'), options
      new InstrumentString 'guitar', 19, @svg.getElementById('guitar_stringB'), options
      new InstrumentString 'guitar', 15, @svg.getElementById('guitar_stringG'), options
      new InstrumentString 'guitar', 10, @svg.getElementById('guitar_stringD'), options
      new InstrumentString 'guitar', 5, @svg.getElementById('guitar_stringA'), options
      new InstrumentString 'guitar', 0, @svg.getElementById('guitar_stringE'), options
    ]

  play: (key) ->
    offset = KEY_BINDINGS[key][0]
    return false unless 0 <= offset <= 5
    fret = KEY_BINDINGS[key][1]
    @strings[offset].pluck fret
    true
     

initApp = ->
  debug = (str) ->
    $("#debug").append("<p>" + str + "</p>")
    true

  onBassSvgLoaded = (_this) ->
    bass = new Bass $(_this).svg('get')
    BASS = bass
    $svg = $ $(_this).svg('get').root()
    true

  loadBass = (callback) ->
    if $('#bass').length == 0
      $('<div id="bass"></div>').insertAfter($('#guitar'))
    $('#bass').svg {
      loadURL: '/assets/bass_prototype_2.svg'
      changeSize: true
      onLoad: ->
        onBassSvgLoaded(this)
        callback() if callback
    }
    BASS_LOADED = true
    true

  playSessionAs = (instrument) ->
    
    setUpSplitScreen = ->
      $guitarSvg = $($('div#guitar').svg('get').root())
      $bassSvg = $($('div#bass').svg('get').root())
      $guitar = $('g#guitar')
      $bass = $('g#bass')
      alert $bass.attr('style')
      console.log $bass
      scale = .75
      width = $guitarSvg.width()
      height = $guitarSvg.width()
      if instrument == 'guitar'
        $('#guitar').css {
          top: 0
          left: 0
        }
        $('#bass').css {
          top: 0
          left: '50%'
        }
        $('#guitar').show()
        $('#bass').show()
      else if instrument == 'bass'
        $('#bass').css {
          top: 0
          left: 0
        }
        $('#guitar').css {
          top: 0
          left: '50%'
        }
        $('#bass').show()
        $('#guitar').show()
      $guitarSvg.attr('width', width*scale)
      $guitarSvg.attr('height', height*scale)
      $bassSvg.attr('width', width*scale)
      $bassSvg.attr('height', height*scale)
      $guitar.attr('transform',"scale(#{scale})")
      $bass.attr('transform',"scale(#{scale})")

      switch instrument
        when 'guitar' then USE_GUITAR = true
        when 'bass' then USE_GUITAR = false

    if BASS_LOADED then setUpSplitScreen else loadBass(setUpSplitScreen)
    true
      
  onGuitarSvgLoaded = ->
    guitar = new Guitar $(this).svg('get')
    $svg = $ $(this).svg('get').root()
    GUITAR = guitar

    onKeyPress = (e) ->
      key = String.fromCharCode(e.keyCode || e.charCode)
      if USE_GUITAR then GUITAR.play key else BASS.play key
      WS.send key if WS?

    window.onkeydown = onKeyPress
    
    jwm.startWebSocket = ->
      console.log 'starting web socket'
      ws = new WebSocket("ws://192.168.1.2:8080/websocket")
      ws.onmessage = (evt) ->
        $('#message').append('<p>' + evt.data + '</p>')
        if KEY_BINDINGS[evt.data]?
          if USE_GUITAR then BASS.play evt.data else GUITAR.play evt.data
        else
          switch evt.data
            when 'instrument: guitar' then playSessionAs 'guitar'
            when 'instrument: bass' then playSessionAs 'bass'
        true
      ws.onclose = ->
        debug "socket closed"
        true
      ws.onopen = ->
        debug "connected..."
        true
      WS = ws
      GUITAR_LOADED = true
      true

    $('#switch-guitar')
    .click ->
      switch $(this).attr('class')
        when 'bass-loader'
          loadBass() unless BASS_LOADED
          $(this).attr('class', 'guitar-loader')
          $(this).find('a').attr('title', 'Switch to Guitar')
          $(this).find('img').attr('src', '/assets/guitar.png')
          $('#guitar').hide()
          $('#bass').show()
          USE_GUITAR = false
        when 'guitar-loader'
          $(this).attr('class', 'bass-loader')
          $(this).find('a').attr('title', 'Switch to Bass')
          $(this).find('img').attr('src', '/assets/bass.png')
          $('#bass').hide()
          $('#guitar').show()
          USE_GUITAR = true
      true
  
  loadGuitar = ->
    $('#guitar').svg {
      loadURL: '/assets/guitar_prototype_2.svg'
      changeSize: true
      onLoad: onGuitarSvgLoaded
    }
    true

  loadGuitar()

  $('#about-icon').click ->
    jwm.about.open('#about')
  
  $('#help-icon').click ->
    jwm.help.open('#help')

  $('#partner-icon').click ->
    console.log 'going to sign in the user'
    # check whether the user is signed in
    # if not sign them in, then proceed as normal
    $.ajax({
      url: "/partner"
      type: "GET"
    }).done (data) ->
      alert data

  true

$(document).ready(initApp)
