"
SUnit tests for Package
"
Class {
	#name : 'PackageObsoleteTest',
	#superclass : 'PackageTestCase',
	#instVars : [
		'notRun'
	],
	#category : 'RPackage-Tests',
	#package : 'RPackage-Tests'
}

{ #category : 'accessing' }
PackageObsoleteTest >> setNotRun [
	notRun := true
]

{ #category : 'tests' }
PackageObsoleteTest >> testAnnouncementClassRemovedIsRaisedOnRemoveFromSystem [

	| foo |
	[
	notRun := false.
	SystemAnnouncer uniqueInstance weak when: ClassRemoved send: #setNotRun to: self.
	foo := self newClassNamed: #FooForTest2 in: self xPackageName.
	self deny: notRun.
	foo removeFromSystem.
	self assert: notRun ] ensure: [ SystemAnnouncer uniqueInstance unsubscribe: self ]
]

{ #category : 'tests' }
PackageObsoleteTest >> testMethodPackageFromObsoleteClass [

	| pack method foo |
	pack := self ensurePackage: 'P1'.
	foo := self newClassNamed: #FooForTest in: pack.
	foo compile: 'bar ^42'.
	method := foo >> #bar.

	[
	foo obsolete.
	self assert: method package equals: foo package ] ensure: [
		foo ifNotNil: [
			foo setName: foo originalName.
			foo removeFromSystem ].
		testingEnvironment removeKey: #FooForTest ifAbsent: [  ] ]
]

{ #category : 'tests' }
PackageObsoleteTest >> testMethodPackageOfRemovedClass [

	| pack method foo |
	pack := self ensurePackage: 'P1'.
	foo := self newClassNamed: #FooForTest2 in: pack.
	foo compile: 'bar ^42'.
	method := foo >> #bar.
	foo removeFromSystem.
	self deny: (pack includesClassNamed: #FooForTest2)
]
