"
I represent a class Variable
"
Class {
	#name : 'NECClassVarEntry',
	#superclass : 'NECCVariableEntry',
	#category : 'NECompletion-Model',
	#package : 'NECompletion',
	#tag : 'Model'
}

{ #category : 'accessing' }
NECClassVarEntry >> hightlightSymbol [
	^ #classVar
]

{ #category : 'accessing' }
NECClassVarEntry >> label [
	^ 'class variable'
]
