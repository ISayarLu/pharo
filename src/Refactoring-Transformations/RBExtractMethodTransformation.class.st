"
Creates a method from a code fragment. Temporary variables and arguments are automatically calculated by the transformation.

If the name of the new method is not provided (i.e., nil), it prompts a dialog window so the developer provides a valid method name. In this new implementation, it is possible to add or remove arguments in the new extracted message.
Similarly, if the number of arguments in the new method provided by the developer is higher than the number of arguments as calculated by the transformation, it prompts a dialog window so the developer selects which values must be passed as arguments.

Usage:
transformation := (RBExtractMethodTransformation
	extract: '(RecursiveSelfRule executeTree: rewriteRule tree initialAnswer: false)
		ifFalse: [builder
					compile: rewriteRule tree printString
					in: class
					classified: aSmalllintContext protocols]'
	from: #checkMethod:
	to: #foo:
	in: #RBTransformationRuleTest)
	transform.
(ChangesBrowser changes: transformation model changes changes) open
"
Class {
	#name : 'RBExtractMethodTransformation',
	#superclass : 'RBCompositeMethodTransformation',
	#instVars : [
		'sourceCode',
		'newSelector',
		'newMethod',
		'parseTree',
		'subtree',
		'arguments',
		'temporaries',
		'assignments'
	],
	#category : 'Refactoring-Transformations-Model-Unused',
	#package : 'Refactoring-Transformations',
	#tag : 'Model-Unused'
}

{ #category : 'utilities' }
RBExtractMethodTransformation class >> allMethodsInHierarchyOf: aRBClass [

	^ ((aRBClass
		withAllSuperclassesUntil: Object)
		flatCollect: [ :class | class allMethods collect: [:each | each method] ])
		reject: #isNil
]

{ #category : 'api' }
RBExtractMethodTransformation class >> extract: aString from: aSelector to: aNewSelector in: aClass [

	^ self new
		extract: aString
		from: aSelector
		to: aNewSelector
		in: aClass;
		yourself
]

{ #category : 'api' }
RBExtractMethodTransformation class >> model: aRBModel extract: aString from: aSelector to: aNewSelector in: aClass [

	^ self new
		model: aRBModel;
		extract: aString
		from: aSelector
		to: aNewSelector
		in: aClass;
		yourself
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> applicabilityPreconditions [

	^ self preconditionParsableSubtree
	  & self preconditionNotInCascadedMessage
	  & self preconditionTemporariesAreNotReadBeforeWritten
	  & self preconditionOneAssignmentMaximum
	  & self preconditionAssignmentsNotReadBeforeWritten
	  & self preconditionSubtreeDoesNotContainsReturn
]

{ #category : 'executing' }
RBExtractMethodTransformation >> buildTransformationFor: newMethodName withRemovedTemps: tempsToRemove [

	| needsReturn messageSend newArguments |
	needsReturn := self calculateIfReturnIsNeeded.
	newMethod := self generateNewMethodWith: newMethodName.
	newArguments := self calculateNewArgumentsIn: newMethodName.
	messageSend := self
		               messageSendWith: newMethodName
		               and: newArguments
		               needsReturn: needsReturn.

	^ OrderedCollection new
		  add: (RBAddMethodTransformation
				   model: self model
				   sourceCode: newMethod newSource
				   in: class
				   withProtocol: Protocol unclassified);
		  add: (RBReplaceSubtreeTransformation
				   model: self model
				   replace: sourceCode
				   to: messageSend
				   inMethod: selector
				   inClass: class);
		  addAll: (tempsToRemove collect: [ :temporary |
					   RBRemoveTemporaryVariableTransformation
						   model: self model
						   variable: temporary
						   inMethod: selector
						   inClass: class ]);
		  yourself
]

{ #category : 'executing' }
RBExtractMethodTransformation >> buildTransformations [

	| selectorOfExistingMethod |
	
	selectorOfExistingMethod := self findMethodWithSimilarBody.
	selectorOfExistingMethod 
		ifNotNil: [
			^ OrderedCollection with: (self parseTreeRewriterClass
					   replaceCode: subtree
					   byMessageSendTo: selectorOfExistingMethod
					   in:
					   (self definingClass methodFor: self calculateTree selector)) ]
		ifNil: [
			^ (parseTree isNil or: [ subtree isNil ])
				  ifTrue: [ OrderedCollection new ]
				  ifFalse: [
					  | tempsToRemove |
					  tempsToRemove := self calculateTemporariesToRemove.

					  assignments size > 1
						  ifTrue: [ OrderedCollection new ]
						  ifFalse: [
							  | newMethodName |
							  newMethodName := self newMethodName.
							  newMethodName ifNil: [ ^ OrderedCollection new ].
							  self
								  buildTransformationFor: newMethodName
								  withRemovedTemps: tempsToRemove ] ] ]
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateArguments [
	"returns a collection of variables that should be passed as arguments"

	| allVariables accesses assigned |
	
	subtree ifNil: [ ^ nil ].
	
	allVariables := parseTree allDefinedVariables difference: subtree allDefinedVariables.

	accesses := allVariables select: [ :each | subtree references: each ].
	assigned := allVariables select: [ :each | subtree assigns: each ].

	^ accesses asOrderedCollection difference: assigned
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateAssignments [
	"checks how many variables in the subtree are assigned to values."
	"Those are temporaries (without temps defined in the subtree; see `calculateTemporaries` for details)
	that have reference in a statement outside of the subtree.
	For those variables we would need to return newly assigned value to preserve behavior."

	"asssignments depend on subtree, if the subtree is nil, assignment will be nil as well"
	subtree ifNil: [ ^ nil ].
	
	^ assignments ifNil: [
		| sequenceNode whoDefinesTemp |
		sequenceNode := (parseTree allChildren select: [ :each | each isSequence ]) last.

		assignments := temporaries select: [ :temp |
			whoDefinesTemp := (sequenceNode whoDefines: temp).
			whoDefinesTemp statements anySatisfy: [ :statement |
				(statement references: temp)
				and: [ (subtree allChildren includes: statement) not ] ] ] ]
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateIfReturnIsNeeded [

	| searcher |
	searcher := self parseTreeSearcher.
	searcher
		matches: '^self' do: [:aNode :answer | answer];
		matches: '^`@anything' do: [:aNode :answer | true].
	^ (searcher executeTree: subtree initialAnswer: false)
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateNewArgumentsIn: aMethodName [

	aMethodName arguments size > arguments size ifTrue: [
		| selection |
		selection := RBMethodArgumentsSelector
			openOn: aMethodName arguments copy
			and: (newMethod body allChildren
					select: #isLiteralNode
					thenCollect: [ :e | e value storeString ])
			in: newMethod.

		newMethod := selection newTree.
		^ selection argumentsAndValues ].
	^ Dictionary new
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateSubtree [

	^ subtree ifNil: [
		subtree := self calculateTree ifNotNil: [ parseTree extractSubtreeWith: sourceCode ] ]
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateTemporaries [
	"returns a collection of variables that should be defined inside the method.
	Those are all variables (temps and args) that are defined outside of subtree,
	but are part of an assignment in the subtree.
	If we want to assign something to them, we need to have a temp for it.
	See calculateAssignments which then checks if we can preserve behavior
	by returning that assignment value as extracted method's return value"
	
	"temporaries depend on subtree, if the subtree is nil, temporaries will be nil as well"
	subtree ifNil: [ ^ nil ].
	
	^ temporaries ifNil: [
		| allVariables accesses |
		allVariables := parseTree allDefinedVariables difference: subtree allDefinedVariables.
		accesses := allVariables select: [ :each | subtree references: each ].

		temporaries := accesses select: [ :each | subtree assigns: each ] ]
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateTemporariesToRemove [
	"returns a collection of variables that should be removed from the original method"

	| newParseTree |
	newParseTree := parseTree copy removeSubtree: subtree.
	^ newParseTree allDefinedVariables
		reject: [ :var | newParseTree references: var ]
]

{ #category : 'querying' }
RBExtractMethodTransformation >> calculateTree [

	^ parseTree ifNil: [ parseTree := self definingMethod ]
]

{ #category : 'api' }
RBExtractMethodTransformation >> extract: aString from: aSelector to: aNewSelector in: aClassName [

	class := aClassName.
	selector := aSelector.
	newSelector := aNewSelector.
	sourceCode := aString
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> findMethodWithSimilarBody [

	| searchSpace |
	searchSpace := (self class allMethodsInHierarchyOf:
		                self definingClass) reject: [ :m |
		               m selector = selector ].

	^ (self parseTreeSearcherClass
		   whichMethodIn: searchSpace
		   matches: subtree)
		  ifNotEmpty: [ :opportunities | "we found one method with similar body so we will use it instead of creating a new one"
			  ^ opportunities anyOne ]
		  ifEmpty: [ ^ nil ]
		
]

{ #category : 'executing' }
RBExtractMethodTransformation >> generateNewMethodWith: aMethodName [

	| args newMethodNode |
	args := aMethodName arguments
		collect: [ :p | RBVariableNode named: p ].

	newMethodNode := RBMethodNode
							selector: aMethodName selector
							arguments: args asArray
							body: (subtree isSequence
								ifTrue: [ subtree ]
								ifFalse: [ RBSequenceNode
									temporaries: #()
									statements: (OrderedCollection with: subtree)]).
	temporaries do: [:each | newMethodNode body addTemporaryNamed: each].

	((parseTree parentOfSubtree: subtree) uses: subtree)
		ifTrue: [ newMethodNode addReturn ].

	assignments size = 1 ifTrue: [
		newMethodNode addNode:
			(RBReturnNode value:
			(RBVariableNode named: assignments first asString)) ].

	^ newMethodNode
]

{ #category : 'executing' }
RBExtractMethodTransformation >> messageSendWith: aMethodName and: newArguments needsReturn: aBoolean [

	^ String streamContents: [ :string |
		aBoolean ifTrue: [ string nextPutAll: '^ ' ].

		assignments size = 1
			ifTrue: [ string
				nextPutAll: assignments first asString;
				nextPutAll: ' := ' ].

		string nextPutAll: 'self '.
		aMethodName arguments
			ifEmpty: [ string nextPutAll: aMethodName selector asString ]
			ifNotEmpty: [
				(aMethodName selector keywords size = aMethodName arguments size)
					ifTrue: [ aMethodName selector keywords
								with: aMethodName arguments
								do: [ :key :arg |
									string nextPutAll: key asString; nextPut: $ .
									(newArguments includesKey: arg asString)
										ifTrue: [ string nextPutAll: (newArguments at: arg asString) ]
										ifFalse: [ string nextPutAll: arg asString ].
								string nextPut: $ ] ] ] ]
]

{ #category : 'executing' }
RBExtractMethodTransformation >> newMethodName [

	| methodName newAttempt |
	newAttempt := newSelector isNil.

	methodName := RBMethodName new.
	methodName arguments: arguments.
	newSelector ifNotNil: [ methodName selector: newSelector ].

	[ newAttempt ] whileTrue: [
		methodName := (RBMethodNameEditor openOn: methodName) methodName.
		methodName
			ifNil: [ newAttempt := false ]
			ifNotNil: [ :newMethodName |
				newSelector := newMethodName selector.
				newAttempt := newSelector isNil.

				"it's a valid selector"
				(newSelector isString and: [newSelector isValidSelector])
					ifFalse: [ self inform: newSelector asString, ' is not a valid selector.'.
								  newSelector := nil ].

				"already exists in class"
				(self definingClass directlyDefinesLocalMethod: newSelector)
					ifTrue: [ self inform: newSelector, ' is already defined in ', class asString.
								 newSelector := nil ] ] ].

	^ methodName
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> preconditionAssignmentsNotReadBeforeWritten [

	assignments isEmptyOrNil ifTrue: [ ^ self trueCondition ].

	^ RBVariablesNotReadBeforeWrittenCondition new subtree: subtree; variables: assignments
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> preconditionNotInCascadedMessage [

	^ RBNotInCascadedMessageCondition new subtree: subtree
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> preconditionOneAssignmentMaximum [
	"When we have one assignment to temp or arg we don't need to worry about other references,
	since we can return newly assigned value from the extracted method and preserve behavior.
	When we have two or more assignments AND when they have references outside of extracted block,
	we don't support return of multiple values, instead we notify the user that all references
	to those temps should be extracted as well."

	^ RBMaxOneAssignmentWithReferencesCondition new
		  assignments: assignments
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> preconditionParsableSubtree [

	^ RBParsableSubtreeCondition new subtree: subtree
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> preconditionSubtreeDoesNotContainsReturn [

	assignments isEmptyOrNil ifTrue: [ ^ self trueCondition ].

	^ RBSubtreeDoesNotContainReturnCondition new subtree: subtree
]

{ #category : 'preconditions' }
RBExtractMethodTransformation >> preconditionTemporariesAreNotReadBeforeWritten [

	^ RBVariablesNotReadBeforeWrittenCondition new subtree: subtree; variables: temporaries 
]

{ #category : 'transforming' }
RBExtractMethodTransformation >> prepareForExecution [

	subtree := self calculateSubtree.
	temporaries := self calculateTemporaries.
	assignments := self calculateAssignments.
	arguments := self calculateArguments 
]

{ #category : 'printing' }
RBExtractMethodTransformation >> storeOn: aStream [

	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' extract: '''.
	sourceCode storeOn: aStream.
	aStream
		nextPutAll: ''' from: #';
		nextPutAll: selector asString;
		nextPutAll: ' to: #';
		nextPutAll: newSelector asString;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream nextPut: $)
]
