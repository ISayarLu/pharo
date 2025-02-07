"
I am a refactoring for removing a method and those of its subclasses,
 to remove the methods use RBRemoveMethodRefactoring.

Example
-------
Script
```
(RBRemoveHierarchyMethodRefactoring 
		removeMethods: #(#msg4)
		from: RBSharedPoolForTestData) execute
```
"
Class {
	#name : 'RBRemoveMethodsInHierarchyRefactoring',
	#superclass : 'RBRemoveMethodsRefactoring',
	#category : 'Refactoring-Core-Refactorings',
	#package : 'Refactoring-Core',
	#tag : 'Refactorings'
}

{ #category : 'removing' }
RBRemoveMethodsInHierarchyRefactoring class >> selectors: aSelectorsCollection from: aClass [ 
	
	^ self new selectors: aSelectorsCollection from: aClass
]

{ #category : 'transforming' }
RBRemoveMethodsInHierarchyRefactoring >> initializeRefactorings [

	classSelectorMapping keysAndValuesDo: [ :class :selectors |
		class allSubclasses do: [ :aClass |
			self remove: selectors in: aClass ] ]
]

{ #category : 'transforming' }
RBRemoveMethodsInHierarchyRefactoring >> remove: aSelectorsCollection in: aClass [

	| containingMethods |
	containingMethods := aSelectorsCollection select: [ :sel |
		                     aClass realClass includesSelector: sel ].
	containingMethods ifNotEmpty: [
		refactorings add: (RBRemoveMethodsRefactoring
				 model: self model
				 selectors: containingMethods
				 from: aClass) ]
]

{ #category : 'accessing' }
RBRemoveMethodsInHierarchyRefactoring >> selectors: aSelectorsCollection from: aClass [

	super selectors: aSelectorsCollection from: aClass.
	self initializeRefactorings 
]
