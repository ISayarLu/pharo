"
I represent the declaration of a method.  My contents are the source code to import, and the category reader is the object who knows the class, category and timestamp where to install the method.

Sending me the message #import makes me install the method into the class.
"
Class {
	#name : 'MethodChunk',
	#superclass : 'BehaviorOwnedChunk',
	#instVars : [
		'stamp',
		'protocol'
	],
	#category : 'CodeImport-Chunks',
	#package : 'CodeImport',
	#tag : 'Chunks'
}

{ #category : 'instance creation' }
MethodChunk class >> contents: someContents behaviorName: behaviorName isMeta: isMeta protocol: protocol stamp: stamp [
	^self new
			contents: someContents;
			behaviorName: behaviorName;
			isMeta: isMeta;
			protocol: protocol;
			stamp: stamp;
			yourself
]

{ #category : 'visiting' }
MethodChunk >> accept: aVisitor [

	^ aVisitor visitMethodChunk: self
]

{ #category : 'accessing' }
MethodChunk >> description [

	^ 'Method ( ', behaviorName , ' >> ' , (contents first: (20 min: contents size)), ' )' , stamp asString
]

{ #category : 'printing' }
MethodChunk >> displayStringOn: stream [
	stream nextPutAll: self description
]

{ #category : 'importing' }
MethodChunk >> handleMissingBehavior [
	"self error: ('Cannot install method in unexistent behavior {1}' format: {(behaviorName asString)})"

	(MissingClassError
		className: behaviorName asString)
		signal: 'Cannot install method in non-existent behavior ', behaviorName asString
]

{ #category : 'importing' }
MethodChunk >> importFor: requestor logSource: logSource [

	self existsBehavior ifFalse: [ self handleMissingBehavior ].

	^ (self targetClass compiler
		   permitUndeclared: true;
		   protocol: protocol;
		   changeStamp: stamp;
		   logged: logSource;
		   install: contents) selector
]

{ #category : 'testing' }
MethodChunk >> isMethodDeclaration [

	^ true
]

{ #category : 'accessing' }
MethodChunk >> methodSelector [

	^ RBParser parseMethodPattern: self contents
]

{ #category : 'accessing' }
MethodChunk >> protocol [
	^ protocol
]

{ #category : 'accessing' }
MethodChunk >> protocol: aString [
	protocol := aString
]

{ #category : 'accessing' }
MethodChunk >> stamp [
	^ stamp
]

{ #category : 'accessing' }
MethodChunk >> stamp: aMethodStamp [
	stamp := aMethodStamp
]
