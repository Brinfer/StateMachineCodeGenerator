# StateMachineCodeGenerator

This project consists in designing a code generator.
This code generator should be able to generate a __C__ state machine from a __plantuml__ file.

## Test

It is possible to test the current state of the project, a test [__plantuml__ file](fr.eseo.idm.state_machine_code_generator.language/tests/fr/eseo/idm/state_machine_code_generator/language/trafficLights.plantuml) is provided (it's a simple traffic light state machine). Run the this [__Xtend__ file](fr.eseo.idm.state_machine_code_generator.language/src/fr/eseo/idm/state_machine_code_generator/language/Generator.xtend), a _header_ and a _source_ file in __C__ will be generated in `fr.eseo.idm.state_machine_code_generator.language/src/fr/eseo/idm/state_machine_code_generator/language/gen/src/` folder.

## TO-DO List

- [X] Create a model, see [the model file](fr.eseo.idm.state_machine_code_generator/model/state_machine_code_generator.svg)
- [X] Generate resources and display them in __HTML__ format, see the [file to create the ressource](fr.eseo.idm.state_machine_code_generator/src/fr/eseo/idm/state_machine_code_generator/Main.java) and the [file to display in __HTML__](fr.eseo.idm.state_machine_code_generator/src/fr/eseo/idm/state_machine_code_generator/Generator.xtend)
- [ ] Generate a __C__ state machine the [parser](fr.eseo.idm.state_machine_code_generator.language/src/fr/eseo/idm/state_machine_code_generator/language/StateMachineCodeGenerator.xtext) which is responsible for parsing the __plantuml__ file and creating instances according to the [model](fr.eseo.idm.state_machine_code_generator/model/state_machine_code_generator.svg), and giving these instances to the [generator](fr.eseo.idm.state_machine_code_generator.language/src/fr/eseo/idm/state_machine_code_generator/language/Generator.xtend) which will create the _source_ and _header_ files in __C__.
   - [X] Support different Action
   - [X] Support differnet Event
   - [X] Support differente State
   - [X] Support `<<choice>>` states
   - [X] Generate compilable and executable code
     - [X] Generate _source_ file
     - [X] Generate _header_ file 
   - [ ] Ignore `@startuml` and `@enduml`
   - [ ] Ignore comment in the __plantuml__ file
   - [ ] Support arguments in the action functions
   - [ ] Ability to create states without having to declare them at the beginning of the file

## Authors

- GAUTIER Pierre-Louis
- JOUFFRIEAU Timothée
