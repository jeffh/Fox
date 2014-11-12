Capabilities.todo
- Make the FSM transition API easier to use (shorter)
- Make the Assertion of the FSM easier to use (shorter)
- Make the Assertion of the data generators easier to use (shorter)
- Remove cocoapods workspace dependency

Documentation.todo
- Generators
- State Machine Generators
- Defining your own generators
	- Composing from existing generators
	- From scratch
- Internals
	- Data Structures
		- Clojure Mechanics (lazy, concrete sequences)
		- RoseTree
		- ProperyResults
		- Commands
	- Shrinking strategies
		- Basic data types (int)
		- Composite Types
			- Arrays
			- Dictionaries

Research.todo
- Generate parallel FSM tests that verify linearizability
- Generate async SM tests that verify within time constraints and basic linearizability