Extension { #name : 'RGMethodDefinitionTest' }

{ #category : '*Ring-Definitions-Monticello-Tests' }
RGMethodDefinitionTest >> testAsFullMethodDefinition [
	| rgMethod |
	rgMethod := (Class >> #asRingDefinition) asRingDefinition.
	self assert: rgMethod parent isNil.
	self assert: rgMethod package isNil.

	"retrieves package information from protocol name (class extension)"
	rgMethod := (Class >> #asRingDefinition) asFullRingDefinition.
	self assert: rgMethod parent notNil.
	self assert: rgMethod parentName equals: #Class.
	self assert: rgMethod parent methods size equals: Class methods size.
	self assert: rgMethod parent package name equals: #'Kernel-CodeModel'.
	self assert: rgMethod package notNil.
	self assert: rgMethod package name equals: #'Ring-Definitions-Core'.

	"retrieves package information from class package name "
	rgMethod := (Class >> #name) asFullRingDefinition.
	self assert: rgMethod parent notNil.
	self assert: rgMethod parentName equals: #Class.
	self assert: rgMethod parent methods size equals: Class methods size.
	self assert: rgMethod parent package name equals: #'Kernel-CodeModel'.
	self assert: rgMethod package notNil.
	self assert: rgMethod package name equals: #'Kernel-CodeModel'
]
