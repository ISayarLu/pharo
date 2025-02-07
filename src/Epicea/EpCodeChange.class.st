"
I represent a change in a code entity.
"
Class {
	#name : 'EpCodeChange',
	#superclass : 'EpEvent',
	#category : 'Epicea-Model',
	#package : 'Epicea',
	#tag : 'Model'
}

{ #category : 'testing' }
EpCodeChange class >> isAbstract [

	^ self == EpCodeChange
]

{ #category : 'accessing' }
EpCodeChange >> affectedPackageName [

	^ self subclassResponsibility
]

{ #category : 'testing' }
EpCodeChange >> doesOverride: aCodeChange [

	^ self subclassResponsibility
]

{ #category : 'testing' }
EpCodeChange >> isCodeChange [

	^ true
]
