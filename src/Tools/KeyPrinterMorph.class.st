"
I am a morph that prints the keys in the keyboard events.
Open the utility using:

    KeyPrinterMorph open

then click into it to activate the window and press keys on
your keyboard to display the key code.
"
Class {
	#name : 'KeyPrinterMorph',
	#superclass : 'Morph',
	#category : 'Tools-Debugger',
	#package : 'Tools',
	#tag : 'Debugger'
}

{ #category : 'open/close' }
KeyPrinterMorph class >> open [
	<script>

	self new openInWorld
]

{ #category : 'display' }
KeyPrinterMorph >> defaultLabel [

	^ 'KeyPrinter (click/activate and press a key)'
]

{ #category : 'event handling' }
KeyPrinterMorph >> handlesKeyboard: evt [
	^ true
]

{ #category : 'event handling' }
KeyPrinterMorph >> handlesMouseDown: evt [
	^ true
]

{ #category : 'event handling' }
KeyPrinterMorph >> keyDown: anEvent [
	UIManager default inform: anEvent key asString
]

{ #category : 'event handling' }
KeyPrinterMorph >> mouseDown: event [
	super mouseDown: event.
	self activeHand newKeyboardFocus: self
]

{ #category : 'display' }
KeyPrinterMorph >> preOpenInWorld: aWorld [

	self extent: 400@200
]
