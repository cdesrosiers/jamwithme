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
  constructor: (@instrument, @audio_offset, @svg, @stringsSvg, @stringSvg) ->
    @audio = new Audio 'AllNotes.ogg'
    
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
    @strings = [
      new InstrumentString 'bass', 15, @svg, strings, @svg.getElementById 'bass_stringG'
      new InstrumentString 'bass', 10, @svg, strings, @svg.getElementById 'bass_stringD'
      new InstrumentString 'bass', 5,  @svg, strings, @svg.getElementById 'bass_stringA'
      new InstrumentString 'bass', 0,  @svg, strings, @svg.getElementById 'bass_stringE'
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
    @strings = [
      new InstrumentString 'guitar', 24, @svg, strings, @svg.getElementById 'guitar_stringe'
      new InstrumentString 'guitar', 19, @svg, strings, @svg.getElementById 'guitar_stringB'
      new InstrumentString 'guitar', 15, @svg, strings, @svg.getElementById 'guitar_stringG'
      new InstrumentString 'guitar', 10, @svg, strings, @svg.getElementById 'guitar_stringD'
      new InstrumentString 'guitar', 5,  @svg, strings, @svg.getElementById 'guitar_stringA'
      new InstrumentString 'guitar', 1,  @svg, strings, @svg.getElementById 'guitar_stringE'
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

  onBassSvgLoaded = ->
    bass = new Bass $(this).svg('get')
    BASS = bass
    true

  loadBass = ->
    if $('#bass').length == 0
      $('<div id="bass"></div>').insertAfter($('#guitar'))
    $('#bass').svg {
      loadURL: '/assets/bass_prototype_2.svg'
      onLoad: onBassSvgLoaded
    }
    BASS_LOADED = true
    true

  onGuitarSvgLoaded = ->
    guitar = new Guitar $(this).svg('get')
    GUITAR = guitar

    onKeyPress = (e) ->
      key = String.fromCharCode(e.keyCode || e.charCode)
      if USE_GUITAR then GUITAR.play key else BASS.play key
      WS.send key if WS?

    window.onkeydown = onKeyPress
    
    $('#pairup-button').click ->
      ws = new WebSocket("ws://192.168.1.3:8080/websocket")
      ws.onmessage = (evt) ->
        $('#message').append('<p>' + evt.data + '</p>')
        if KEY_BINDINGS[evt.data]?
          GUITAR.play evt.data
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

    $('<button id="switch-guitar" class="bass-loader">Switch to Bass</button>')
    .insertBefore($('#pairup-button'))
    .click ->
      switch $(this).attr('class')
        when 'bass-loader'
          loadBass() unless BASS_LOADED
          $(this).attr('class', 'guitar-loader')
          $(this).html('Switch to Guitar')
          $('#guitar').hide()
          $('#bass').show()
          USE_GUITAR = false
        when 'guitar-loader'
          $(this).attr('class', 'bass-loader')
          $(this).html('Switch to Bass')
          $('#bass').hide()
          $('#guitar').show()
          USE_GUITAR = true
      true
  
  loadGuitar = ->
    $('#guitar').svg {
      loadURL: '/assets/guitar_prototype_2.svg'
      onLoad: onGuitarSvgLoaded
    }
    true

  loadGuitar()

  true

$(document).ready(initApp)
