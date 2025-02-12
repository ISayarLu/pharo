Class {
	#name : 'RBAddClassVariableTransformationParametrizedTest',
	#superclass : 'RBWithDifferentConstructorsParametrizedTest',
	#category : 'Refactoring-Transformations-Tests-Parametrized',
	#package : 'Refactoring-Transformations-Tests',
	#tag : 'Parametrized'
}

{ #category : 'building suites' }
RBAddClassVariableTransformationParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBAddVariableTransformation .
					  #constructor -> #classVariable:class: };
		addCase: { #rbClass -> RBAddClassVariableRefactoring .
					  #constructor -> #variable:class: };
		yourself
]

{ #category : 'running' }
RBAddClassVariableTransformationParametrizedTest >> setUp [
	super setUp.
	model := self rbModelForVariableTest
]

{ #category : 'tests' }
RBAddClassVariableTransformationParametrizedTest >> testAddClassVariable [
	| refactoring |
	refactoring := self createRefactoringWithArguments:
		{'Asdf' . #RBTransformationRuleTestData }.

	self executeRefactoring: refactoring.

	self assert: ((refactoring model
		classNamed: #RBTransformationRuleTestData)
		directlyDefinesClassVariable: #Asdf)
]

{ #category : 'failure tests' }
RBAddClassVariableTransformationParametrizedTest >> testFailureMetaClassFailure [

	self shouldFail: (self createRefactoringWithArguments:
			 { #VariableName. #'RBTransformationRuleTestData class' })
]

{ #category : 'failure tests' }
RBAddClassVariableTransformationParametrizedTest >> testFailureMetaclass [

	| refactoring |
	self skip.
	refactoring := self
		               createRefactoringWithModel: model
		               andArguments: { #ClassVarName3. #'Object class' }.
	self shouldFail: refactoring
]

{ #category : 'failure tests' }
RBAddClassVariableTransformationParametrizedTest >> testFailureModelMetaclass [

	| refactoring |
	self skip.
	refactoring := self
		               createRefactoringWithModel: model
		               andArguments: { #ClassVarName3. #'Bar class' }.
	self shouldFail: refactoring
]

{ #category : 'tests' }
RBAddClassVariableTransformationParametrizedTest >> testModelAddClassVariable [
	| refactoring |
	refactoring := self createRefactoringWithModel: model
		andArguments: { #ClassVarName3 . #Bar }.

	self executeRefactoring: refactoring.

	self assert: ((model classNamed: #Bar)
				directlyDefinesClassVariable: #ClassVarName3)
]
