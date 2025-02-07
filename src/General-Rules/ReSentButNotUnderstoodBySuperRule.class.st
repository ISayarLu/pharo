"
This rule checks for messages sent to superclass which are not implemented by superclass
"
Class {
	#name : 'ReSentButNotUnderstoodBySuperRule',
	#superclass : 'ReAbstractRule',
	#category : 'General-Rules-Migrated',
	#package : 'General-Rules',
	#tag : 'Migrated'
}

{ #category : 'testing - interest' }
ReSentButNotUnderstoodBySuperRule class >> checksMethod [

	^ true
]

{ #category : 'accessing' }
ReSentButNotUnderstoodBySuperRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"

	^'SentButNotUnderstoodBySuperRule'
]

{ #category : 'running' }
ReSentButNotUnderstoodBySuperRule >> check: aMethod forCritiquesDo: aCriticBlock [

	| superclass notUnderstoodSends |

	superclass := aMethod methodClass superclass.

	notUnderstoodSends := aMethod sendNodes select: [ :msgSend | msgSend receiver isSuperVariable ].
	notUnderstoodSends := notUnderstoodSends reject: [ :msgSend |
			superclass notNil and: [ superclass canUnderstand: msgSend selector ]].

	notUnderstoodSends do: [ :msgSend |
		aCriticBlock cull: (self
				 createTrivialCritiqueOn: aMethod
				 intervalOf: msgSend
				 hint: msgSend selector asString) ]
]

{ #category : 'accessing' }
ReSentButNotUnderstoodBySuperRule >> group [

	^ 'Bugs'
]

{ #category : 'accessing' }
ReSentButNotUnderstoodBySuperRule >> name [

	^ 'Messages sent that super can not understand'
]

{ #category : 'accessing' }
ReSentButNotUnderstoodBySuperRule >> rationale [

	^ 'Checks for messages that are sent by a method to super, but no superclass implements such a message. Reported methods will certainly cause a doesNotUnderstand: message when they are executed.'
]

{ #category : 'accessing' }
ReSentButNotUnderstoodBySuperRule >> severity [

	^ #error
]
