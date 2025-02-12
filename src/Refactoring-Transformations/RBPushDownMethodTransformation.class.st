Class {
	#name : 'RBPushDownMethodTransformation',
	#superclass : 'RBCompositeMethodTransformation',
	#instVars : [
		'selectors',
		'classes'
	],
	#category : 'Refactoring-Transformations-Model-Migrated-Unused',
	#package : 'Refactoring-Transformations',
	#tag : 'Model-Migrated-Unused'
}

{ #category : 'api' }
RBPushDownMethodTransformation class >> model: aRBNamespace pushDown: selectorCollection from: aClass [
	^ self new
		model: aRBNamespace;
		pushDown: selectorCollection from: aClass;
		yourself
]

{ #category : 'api' }
RBPushDownMethodTransformation class >> model: aRBNamespace pushDown: selectorCollection from: aClass in: classes [
	^ self new
		model: aRBNamespace;
		pushDown: selectorCollection from: aClass in: classes;
		yourself
]

{ #category : 'api' }
RBPushDownMethodTransformation class >> pushDown: selectorCollection from: aClass [
	^ self new pushDown: selectorCollection from: aClass
]

{ #category : 'api' }
RBPushDownMethodTransformation class >> pushDown: selectorCollection from: aClass in: classes [
	^ self new pushDown: selectorCollection from: aClass in: classes
]

{ #category : 'accessing' }
RBPushDownMethodTransformation >> allClasses [

	^ classes ifNil: [ class subclasses ]
]

{ #category : 'preconditions' }
RBPushDownMethodTransformation >> applicabilityPreconditions [ 

	| condition |
	condition := selectors
		             inject: (RBCondition true)
		             into: [ :cond :each |
			             cond & (RBCondition definesSelector: each in: class)].
	^ condition 
]

{ #category : 'preconditions' }
RBPushDownMethodTransformation >> breakingChangePreconditions [
	"Check that that none of the subclasses of `class` is doing a supercall to any of the selectors
	that will be pushed down.
	
	Also, to ensure that an instance of the class is not sent a message which is pushed down,  forces that 
	we can only push down methods from abstract class. 
	This should be controlled via a flag on the ui.
	"
	
	| condition |
	condition := selectors
		             inject: (RBCondition isAbstractClass: class)
		             into: [ :cond :each |
			             cond & (RBCondition subclassesOf: class isDoingASuperSendFor: each) not ].
	^ condition 
]

{ #category : 'executing' }
RBPushDownMethodTransformation >> buildTransformations [

	^ self pushDownSelectors , {self removeSelectors}
]

{ #category : 'accessing' }
RBPushDownMethodTransformation >> classes: aCollection [
	classes := aCollection collect: [ :cls |
		self model classObjectFor: cls.
	]
]

{ #category : 'transforming' }
RBPushDownMethodTransformation >> pushDown: aSelector [

	| code protocols refactoring |
	code := class sourceCodeFor: aSelector.
	protocols := class protocolsFor: aSelector.
	refactoring := RBExpandReferencedPoolsTransformation
		               model: self model
		               forMethod: (class parseTreeForSelector: aSelector)
		               fromClass: class
		               toClasses: self allClasses.
	^ {refactoring}, (self allClasses select: [ :each | (each directlyDefinesMethod: aSelector) not ]
		thenCollect: [ :each |
				RBAddMethodTransformation
				model: self model
				sourceCode: code
				in: each
				withProtocol: protocols ])
]

{ #category : 'api' }
RBPushDownMethodTransformation >> pushDown: selectorCollection from: aClass [
	class := self model classObjectFor: aClass.
	selectors := selectorCollection
]

{ #category : 'api' }
RBPushDownMethodTransformation >> pushDown: selectorCollection from: aClass in: aCollection [
	class := self model classObjectFor: aClass.
	selectors := selectorCollection.
	self classes: aCollection
]

{ #category : 'transforming' }
RBPushDownMethodTransformation >> pushDownSelectors [
	^ selectors flatCollect: [:each | self pushDown: each]
]

{ #category : 'transforming' }
RBPushDownMethodTransformation >> removeSelectors [
	^ RBRemoveMethodTransformation
		model: self model
		selectors: selectors
		from: class
]

{ #category : 'printing' }
RBPushDownMethodTransformation >> storeOn: aStream [
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' pushDown: ';
		nextPutAll: selectors asString;
		nextPutAll: ' from: ';
		nextPutAll: class name;
		nextPutAll: ' in: '.
	(classes collect: [ :e | e name ]) storeOn: aStream.
	aStream nextPut: $)
]

{ #category : 'accessing' }
RBPushDownMethodTransformation >> targetClass [
	^ class
]
