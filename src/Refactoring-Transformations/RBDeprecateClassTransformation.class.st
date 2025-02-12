"
Marks a class as deprecated and suggests the use of the superclass.

Usage:
transformation := (RBDeprecateClassTransformation 
		class: #RBRemoveClassTransformation)
		transform. 
(ChangesBrowser changes: transformation model changes changes) open
"
Class {
	#name : 'RBDeprecateClassTransformation',
	#superclass : 'RBClassTransformation',
	#category : 'Refactoring-Transformations-Model-Unused',
	#package : 'Refactoring-Transformations',
	#tag : 'Model-Unused'
}

{ #category : 'instance creation' }
RBDeprecateClassTransformation class >> className: aClassName [

	^ self new
		className: aClassName;
		yourself
]

{ #category : 'instance creation' }
RBDeprecateClassTransformation class >> model: aRBModel className: aClassName [

	^ self new
		model: aRBModel;
		className: aClassName;
		yourself
]

{ #category : 'preconditions' }
RBDeprecateClassTransformation >> applicabilityPreconditions [

	^ {
		  (RBClassesExistCondition new classes: { class }).
		  (RBClassesAreNotMetaClassCondition new classes: { class }) }
]

{ #category : 'preconditions' }
RBDeprecateClassTransformation >> checkPreconditions [ 

	self checkApplicabilityPreconditions 
]

{ #category : 'transforming' }
RBDeprecateClassTransformation >> prepareForExecution [ 

	class := self model classNamed: className
]

{ #category : 'transforming' }
RBDeprecateClassTransformation >> privateTransform [

	self generateChangesFor: (RBAddMethodTransformation
			 sourceCode: (String streamContents: [ :code |
					  code
						  nextPutAll: 'isDeprecated';
						  nextPutAll: String cr;
						  nextPutAll: String tab;
						  nextPutAll: '^ true' ])
			 in: (className , ' class') asSymbol
			 withProtocol: #deprecation)
]

{ #category : 'printing' }
RBDeprecateClassTransformation >> storeOn: aStream [

	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' className: '.
	className storeOn: aStream.
	aStream nextPut: $)
]
