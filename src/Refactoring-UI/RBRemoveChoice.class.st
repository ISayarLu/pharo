Class {
	#name : 'RBRemoveChoice',
	#superclass : 'RBRemoveMethodChoice',
	#category : 'Refactoring-UI-Choices',
	#package : 'Refactoring-UI',
	#tag : 'Choices'
}

{ #category : 'execution' }
RBRemoveChoice >> action [

	driver applyChanges
]

{ #category : 'accessing' }
RBRemoveChoice >> description [

	^ 'Remove it'
]
