"
Tests related to SharedPool
"
Class {
	#name : 'SharedPoolTest',
	#superclass : 'TestCase',
	#category : 'Kernel-Tests-Classes',
	#package : 'Kernel-Tests',
	#tag : 'Classes'
}

{ #category : 'tests' }
SharedPoolTest >> testIncludesKey [

	self assert: (ChronologyConstants includesKey: #DayNames).
	self deny: (ChronologyConstants includesKey: #DependentsFields)
]
