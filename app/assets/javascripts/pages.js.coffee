# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jwm.about = (->
	return(
		open: (selector) ->
			$dialog = $(selector)
				.dialog(
					title: 'About'
					modal: true
					width: 500
					height: 190
					resizable: false
					draggable: false
				)
			return false
		destroy: ->
			$dialog.dialog 'close'
			$dialog.destroy
	)
)()
  

jwm.help = (->
	return(
		open: (selector) ->
			$dialog = $(selector)
				.dialog(
					title: 'Help'
					modal: true
					width: 500
					height: 190
					resizable: false
					draggable: false
				)
			return false
		destroy: ->
			$dialog.dialog 'close'
			$dialog.destroy
	)
)()

jwm.authDialog = (->
	$dialog = {}

	return(
		open: (selector) ->
			$dialog = $(selector)
				.dialog(
					title: 'Choose a Username'
					modal: true
					width: 500
					height: 190
					resizable: false
					draggable: false
				)
			return false
		destroy: ->
			$dialog.dialog 'close'
			$dialog.destroy
		showNewUser: ->
			$dialog.dialog 'option', 'title', 'Choose a username'
			$('#username-form').removeAttr 'hidden'
			$('#signin-form').attr 'hidden', 'true'
			return false
		showLogin: ->
			$dialog.dialog 'option', 'title', 'Login'
			$('#username-form').attr 'hidden', 'true'
			$('#signin-form').removeAttr 'hidden'
			return false
	)
)()
