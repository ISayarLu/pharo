"
Reader for Cypress format

see https://github.com/CampSmalltalk/Cypress
"
Class {
	#name : 'MCFileTreeStCypressReader',
	#superclass : 'MCFileTreeStSnapshotReader',
	#category : 'MonticelloFileTree-Core',
	#package : 'MonticelloFileTree-Core'
}

{ #category : 'accessing' }
MCFileTreeStCypressReader class >> extension [
    ^ 'package'
]

{ #category : 'accessing' }
MCFileTreeStCypressReader class >> monticelloMetaDirName [
    ^ MCFileTreeStCypressWriter monticelloMetaDirName
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addClassAndMethodDefinitionsFromDirectory: aDirectory [
    aDirectory entries
        do: [ :entry | 
            (entry name endsWith: '.trait')
                ifTrue: [ self addTraitAndMethodDefinitionsFromEntry: entry ].
            (entry name endsWith: '.class')
                ifTrue: [ self addClassAndMethodDefinitionsFromEntry: entry ].
            (entry name endsWith: '.extension')
                ifTrue: [ self addExtensionClassAndMethodDefinitionsFromEntry: entry ] ]
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addClassAndMethodDefinitionsFromEntry: classEntry [
	| classDirectory classPropertiesDict classComment entries methodPropertiesDict |
	classDirectory := self fileUtils directoryFromEntry: classEntry.
	entries := classDirectory entries.
	entries
		detect: [ :entry | self isPropertyFile: entry ]
		ifFound: [ :propertyEntry | 
			propertyEntry
				readStreamDo: [ :fileStream | classPropertiesDict := STON fromStream: fileStream ] ].
	entries
		detect: [ :entry | entry name = 'README.md' ]
		ifFound: [ :commentEntry | 
			commentEntry
				readStreamDo: [ :fileStream | classComment := fileStream contents ] ].
	methodPropertiesDict := Dictionary new.
	entries
		detect: [ :entry | self isMethodPropertyFile: entry ]
		ifFound: [ :propertyEntry | 
			propertyEntry
				readStreamDo:
					[ :fileStream | "Issue 33: https://github.com/dalehenrich/filetree/issues/33" methodPropertiesDict := STON fromStream: fileStream ] ].
	self
		addClassDefinitionFrom: classPropertiesDict
		comment: classComment withInternalLineEndings.
	self
		addMethodDefinitionsForClass: (classPropertiesDict at: 'name')
		methodProperties: methodPropertiesDict
		in: entries
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addClassDefinitionFrom: classPropertiesDict comment: classComment [

	| definition |
	definition := (MCClassDefinition named: (classPropertiesDict at: 'name'))
		              superclassName: (classPropertiesDict at: 'super');
		              packageName: self packageNameFromPackageDirectory;
		              comment: classComment;
		              yourself.

	classPropertiesDict
		at: 'category' ifPresent: [ :category | self setPackageTagIn: definition fromCategory: category ];
		at: 'traitcomposition' ifPresent: [ :composition | definition traitComposition: composition ];
		at: 'classtraitcomposition' ifPresent: [ :composition | definition classTraitComposition: composition ];
		at: 'instvars' ifPresent: [ :instVars | definition instVarNames: instVars ];
		at: 'classvars' ifPresent: [ :classVars | definition classVarNames: classVars ];
		at: 'pools' ifPresent: [ :pools | definition poolDictionaryNames: pools ];
		at: 'classinstvars' ifPresent: [ :classInstVars | definition classInstVarNames: classInstVars ];
		at: 'type' ifPresent: [ :type | definition type: type ];
		at: 'commentStamp' ifPresent: [ :stamp | definition commentStamp: stamp ].

	definitions add: definition
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addExtensionClassAndMethodDefinitionsFromEntry: classEntry [
	| classDirectory classPropertiesDict methodPropertiesDict entries |
	classDirectory := self fileUtils directoryFromEntry: classEntry.
	entries := classDirectory entries.
	entries
		detect: [ :entry | self isPropertyFile: entry ]
		ifFound: [ :propertyEntry | 
			propertyEntry
				readStreamDo: [ :fileStream | classPropertiesDict := STON fromStream: fileStream ] ].
	methodPropertiesDict := Dictionary new.
	entries
		detect: [ :entry | self isMethodPropertyFile: entry ]
		ifFound: [ :propertyEntry | 
			propertyEntry
				readStreamDo:
					[ :fileStream | "Issue 33: https://github.com/dalehenrich/filetree/issues/33" methodPropertiesDict := STON fromStream: fileStream ] ].
	self
		addMethodDefinitionsForClass: (classPropertiesDict at: 'name')
		methodProperties: methodPropertiesDict
		in: entries
		extensionMethod: true
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addMethodDefinitionsForClass: className methodProperties: methodProperties in: entries [
  ^ self
    addMethodDefinitionsForClass: className
    methodProperties: methodProperties
    in: entries
    extensionMethod: false
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addMethodDefinitionsForClass: className methodProperties: methodProperties in: entries extensionMethod: extensionMethod [
	entries
		do: [ :entry | 
			| classIsMeta |
			classIsMeta := false.
			entry name = 'class' ifTrue: [ classIsMeta := true ].
			(entry name = 'instance' or: [ entry name = 'class' ])
				ifTrue: [ (self loadableDefinitionsFrom: (self fileUtils directoryFromEntry: entry))
						do: [ :methodEntry | 
							methodEntry
								readStreamDo: [ :fileStream | 
									| category source timestamp selector |
									category := fileStream nextLine.
									source := fileStream upToEnd.
									selector := self methodSelectorFor: source.
									timestamp := methodProperties at: (classIsMeta ifTrue: [ 'class' ] ifFalse: [ 'instance' ]) ifPresent: [ :map | map at: selector asString ifAbsent: [  ] ].	"Issue 33: https://github.com/dalehenrich/filetree/issues/33"
									timestamp ifNil: [ timestamp := self info author , ' ' , self info date mmddyyyy , ' ' , self info time print24 ].
									extensionMethod ifTrue: [ self validateExtensionMethodCategory: category for: className selector: selector ].
									definitions
										add:
											(MCMethodDefinition
												className: className
												classIsMeta: classIsMeta
												selector: selector
												category: category
												timeStamp: timestamp
												source: source) ] ] ] ]
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addTraitAndMethodDefinitionsFromEntry: classEntry [
	| classDirectory classPropertiesDict classComment entries methodPropertiesDict |
	classDirectory := self fileUtils directoryFromEntry: classEntry.
	entries := classDirectory entries.
	entries
		detect: [ :entry | self isPropertyFile: entry ]
		ifFound: [ :propertyEntry | 
			propertyEntry
				readStreamDo: [ :fileStream | classPropertiesDict := STON fromStream: fileStream ] ].
	entries
		detect: [ :entry | entry name = 'README.md' ]
		ifFound: [ :commentEntry | 
			commentEntry
				readStreamDo: [ :fileStream | classComment := fileStream contents ] ]
		ifNone: [ classComment := '' ].
	methodPropertiesDict := Dictionary new.
	entries
		detect: [ :entry | self isMethodPropertyFile: entry ]
		ifFound: [ :propertyEntry | 
			propertyEntry
				readStreamDo:
					[ :fileStream | "Issue 33: https://github.com/dalehenrich/filetree/issues/33" methodPropertiesDict := STON fromStream: fileStream ] ].
	self
		addTraitDefinitionFrom: classPropertiesDict
		comment: classComment withInternalLineEndings.
	self
		addMethodDefinitionsForClass: (classPropertiesDict at: 'name')
		methodProperties: methodPropertiesDict
		in: entries
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> addTraitDefinitionFrom: traitPropertiesDict comment: traitComment [

	| definition |
	definition := (MCTraitDefinition named: (traitPropertiesDict at: 'name'))
		              packageName: self packageNameFromPackageDirectory;
		              comment: traitComment;
		              yourself.

	traitPropertiesDict
		at: 'category' ifPresent: [ :category | self setPackageTagIn: definition fromCategory: category ];
		at: 'traitcomposition' ifPresent: [ :composition | definition traitComposition: composition ];
		at: 'classtraitcomposition' ifPresent: [ :classTraitComposition | definition classTraitComposition: classTraitComposition ];
		at: 'instvars' ifPresent: [ :ivars | definition instVarNames: ivars ];
		at: 'commentStamp' ifPresent: [ :stamp | definition commentStamp: stamp ].

	definitions add: definition
]

{ #category : 'accessing' }
MCFileTreeStCypressReader >> basicVersion [
    self hasMonticelloMetadata
        ifTrue: [ ^ super basicVersion ].
    ^ MCVersion new
        setPackage: self package
            info: self info
            snapshot: self snapshot
            dependencies: #();
        yourself
]

{ #category : 'private' }
MCFileTreeStCypressReader >> isMethodPropertyFile: entry [
	^ entry name = 'methodProperties.ston' or: [ entry name = 'methodProperties.json']
]

{ #category : 'private' }
MCFileTreeStCypressReader >> isPropertyFile: entry [
	^ entry name = 'properties.ston' or: [ entry name = 'properties.json']
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> loadDefinitions [

	| entries directory |
	definitions := OrderedCollection new.
	directory := self fileUtils directoryFromPath: self monticelloMetaDirName relativeTo: packageDirectory.
	(self fileUtils directoryExists: directory)
		ifTrue: [
			entries := directory entries.
			self
				addDefinitionFromFile: (entries
						 detect: [ :entry | entry name beginsWith: 'categories' ]
						 ifNone: [  ])
				inDirectory: directory ]
		ifFalse: [ definitions add: (MCOrganizationDefinition packageName: self packageNameFromPackageDirectory) ].
	self addClassAndMethodDefinitionsFromDirectory: packageDirectory.
	(self fileUtils directoryExists: directory) ifTrue: [
		self
			addDefinitionFromFile: (entries
					 detect: [ :entry | entry name beginsWith: 'initializers' ]
					 ifNone: [  ])
			inDirectory: directory ]
]

{ #category : 'accessing' }
MCFileTreeStCypressReader >> loadPackage [
    self hasMonticelloMetadata
        ifTrue: [ ^ super loadPackage ].
    package := MCPackage named: self packageNameFromPackageDirectory
]

{ #category : 'accessing' }
MCFileTreeStCypressReader >> loadVersionInfo [
  self hasMonticelloMetadata
    ifTrue: [ ^ info := self extractInfoFrom: (self parseMember: 'version') ].
  info := MCVersionInfo
    name: self packageNameFromPackageDirectory , '-cypress.1'
    id: UUID new
    message: 'fabricated from a Cypress format repository'
    date: Date today
    time: Time now
    author: ''
    ancestors: #()
    stepChildren: #()

]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> methodSelectorFor: source [
    ^ Object compilerClass new parseSelector: source

]

{ #category : 'accessing' }
MCFileTreeStCypressReader >> packageNameFromPackageDirectory [
    | filename2 |
    filename2 := self fileUtils directoryName: packageDirectory.
    ^ filename2 copyFrom: 1 to: (filename2 lastIndexOf: $.) - 1
]

{ #category : 'utilities' }
MCFileTreeStCypressReader >> setPackageTagIn: definition fromCategory: category [

	| packageName |
	packageName := definition packageName.
	(self verifyCategory: category matches: packageName) ifFalse: [
		self error: 'Class category name ' , category , ' for the class ' , definition name , ' is inconsistent with the package name ' , packageName ].

	"If the category is the package name then it means that there is not tag"
	category = packageName ifFalse: [ definition tagName: (category withoutPrefix: packageName , '-') ]
]

{ #category : 'validation' }
MCFileTreeStCypressReader >> validateExtensionMethodCategory: categoryName for: className selector: selector [
  "https://github.com/dalehenrich/filetree/issues/136"

  "method category must match the package name for extension methods... guard against manual editing mistakes"

  "extracted from PackageInfo>>isForeignClassExtension:"

  | prefix |
  prefix := '*' , self packageNameFromPackageDirectory asLowercase.
  categoryName
    ifNotNil: [ 
      (categoryName isEmpty not
        and: [ 
          categoryName first = $*
            and: [ 
              "asLowercase needed in GemStone 3.1.0.6?"
              self verifyCategory: categoryName asLowercase matches: prefix ] ])
        ifTrue: [ ^ self ] ].
  self
    error:
      'Method protocol ' , categoryName printString , ' for the method '
        , selector asString printString , ' in class ' , className printString
        , ' is inconsistent with the package name ' , prefix printString

]

{ #category : 'validation' }
MCFileTreeStCypressReader >> verifyCategory: categoryName matches: basicPackageName [
  "https://github.com/dalehenrich/filetree/issues/136"

  "copied from PackageInfo>>category:matches: and GoferVersionReference>>parseName:"

  | prefixSize catSize packagePrefix |
  categoryName ifNil: [ ^ false ].
  packagePrefix := basicPackageName.
  (packagePrefix includes: $.)
    ifTrue: [ 
      "exclude branch name"
      packagePrefix := packagePrefix copyUpTo: $. ].
  catSize := categoryName size.
  prefixSize := packagePrefix size.
  catSize < prefixSize
    ifTrue: [ ^ false ].
  (categoryName findString: packagePrefix startingAt: 1 caseSensitive: false)
    = 1
    ifFalse: [ ^ false ].
  ^ (categoryName at: packagePrefix size + 1 ifAbsent: [ ^ true ]) = $-
]
