"
SUnit tests for trait definitions
"
Class {
	#name : 'RGTraitDefinitionTest',
	#superclass : 'TestCase',
	#category : 'Ring-Definitions-Core-Tests-Base',
	#package : 'Ring-Definitions-Core-Tests',
	#tag : 'Base'
}

{ #category : 'testing' }
RGTraitDefinitionTest >> testAddingMethods [
	| newMethod newClass |
	newClass := RGTraitDefinition named: #TSortable.
	newMethod := (RGMethodDefinition named: #sort)
		parent: newClass;
		protocol: 'sorting';
		sourceCode:
			'sort
									self sort: [:a :b | a <= b]'.

	self assert: newMethod isMeta not.
	self assert: newClass hasMethods not.

	newClass addMethod: newMethod.
	newClass
		addSelector: #size
		classified: 'accessing'
		sourced:
			'foo
							^lastIndex - firstIndex + 1'.

	self assert: newClass hasMethods.
	self assert: newClass selectors asSet equals: #(sort size) asSet.
	self assert: (newClass includesSelector: #sort).
	self assert: (newClass methodNamed: #sort) equals: newMethod.
	self assert: newClass methods size equals: 2.
	self assert: newClass selectors size equals: 2.
	self assert: newClass allSelectors size equals: 2.	"no hierarchy"

	newMethod := newClass methodNamed: #size.
	self assert: newMethod parent equals: newClass.

	self assert: (newClass compiledMethodNamed: #sort) notNil.
	self assert: (newClass compiledMethodNamed: #foo) isNil
]

{ #category : 'testing' }
RGTraitDefinitionTest >> testAsTraitDefinition [

	| newTrait |
	newTrait := TSortable asRingDefinition.
	self assert: newTrait isRingObject.
	self assert: newTrait isTrait.
	self assert: newTrait name identicalTo: #TSortable.
	self assert: newTrait package isNotNil.
	self assert: newTrait packageTag isNotNil.
	self assert: newTrait superclassName isNotNil.


	self assert: newTrait classSide isRingObject.
	self assert: newTrait classSide isTrait.
	self assert: newTrait classSide traitCompositionSource equals: '{}'
]

{ #category : 'testing' }
RGTraitDefinitionTest >> testExistingTrait [
	| newClass metaClass |
	newClass := RGTraitDefinition named: #TSortable.
	self assert: newClass isTrait.
	self assert: newClass isDefined.
	self assert: newClass realClass equals: TSortable.
	self assert: newClass isMeta not.

	newClass withMetaclass.
	self assert: newClass hasMetaclass.
	metaClass := newClass classSide.
	self assert: metaClass isMeta.
	self assert: metaClass name equals: 'TSortable classTrait'.
	self assert: metaClass instanceSide equals: newClass.
	self assert: metaClass realClass equals: TSortable classSide
]

{ #category : 'testing' }
RGTraitDefinitionTest >> testNonExistingClass [

	| newClass |
	newClass := RGTraitDefinition named: #TConnection.
	self assert: newClass isTrait.
	self assert: newClass hasMetaclass not.
	self assert: newClass hasComment not.
	self assert: newClass hasStamp not.
	self assert: newClass parent equals: Smalltalk globals.
	self assert: newClass package isNil.
	self assert: newClass packageTag isNil.
	self assert: newClass hasMethods not.
	self assert: newClass hasSuperclass not.
	self assert: newClass hasTraitComposition not.
	self assert: newClass isDefined not.
	self assert: newClass hasProtocols not
]

{ #category : 'testing' }
RGTraitDefinitionTest >> testTraitEquality [

	| newClass |
	self assert: TSortable asRingDefinition equals: TSortable asRingDefinition.

	newClass := TSortable asRingDefinition package: (RGPackageDefinition named: #Kernel).
	self assert: TSortable asRingDefinition equals: newClass
]
