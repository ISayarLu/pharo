"
**MetacelloLookupProjectSpecForLoad** ends up returning an instance of **MetacelloProjectSpecForLoad**
"
Class {
	#name : 'MetacelloLookupProjectSpecForLoad',
	#superclass : 'MetacelloScriptProjectSpecNotification',
	#category : 'Metacello-Core-Scripts',
	#package : 'Metacello-Core',
	#tag : 'Scripts'
}

{ #category : 'exception description' }
MetacelloLookupProjectSpecForLoad >> defaultAction [
    "Result of signal should be the MetacelloProjectSpecForLoad to be used to perform the load. 
	Create a MetacelloProjectSpecForLoad and use the overrideProjectSpec: if you want to supply a different projectSpec"

    ^ MetacelloProjectSpecForLoad new
        projectSpec: self projectSpec;
        yourself
]

{ #category : 'handlers' }
MetacelloLookupProjectSpecForLoad >> handleResolutionFor: aScriptEngine [
    ^ aScriptEngine handleLookupProjectSpecForLoad: self
]
