package fr.eseo.idm.state_machine_code_generator.language

import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import fr.eseo.idm.state_machine_code_generator.Transition
import fr.eseo.idm.state_machine_code_generator.State
import fr.eseo.idm.state_machine_code_generator.Event
import fr.eseo.idm.state_machine_code_generator.Action
import fr.eseo.idm.state_machine_code_generator.State_machine_code_generatorPackage
import org.eclipse.emf.common.util.URI
import fr.eseo.idm.state_machine_code_generator.StateMachine
import fr.eseo.idm.state_machine_code_generator.impl.StateImpl
import fr.eseo.idm.state_machine_code_generator.impl.TransitionImpl
import java.util.Set
import java.util.HashSet

class Generator {

    Set<Action> actionSet;
    Set<State> stateSet;
    Set<Transition> transitionSet;
    Set<Event> eventSet;

    def static void main(String[] args) {
        val rs = new ResourceSetImpl
        rs.getPackageRegistry().put(State_machine_code_generatorPackage.eNS_URI,
            State_machine_code_generatorPackage.eINSTANCE);

        StateMachineCodeGeneratorStandaloneSetup.doSetup

        val ressources = rs.getResource(
            URI.createFileURI("tests/fr/eseo/idm/state_machine_code_generator/language/trafficLights.smcg"), true)

        val sm = ressources.getContents().get(0) as StateMachine;

        val generator = new Generator(sm);
        generator.generate("Test.c");

    }
    
    def static toSnakeCase(String p_string) {
        p_string.toFirstLower().replaceAll("([A-Z])", "_$1").toLowerCase();
    }

    new (StateMachine p_sm) {
        actionSet = new HashSet<Action>();
        stateSet = new HashSet<State>();
        transitionSet = new HashSet<Transition>();
        eventSet = new HashSet<Event>();

        this.fillSet(p_sm);
    }

    def generate(String path) {
        writeInOutput(("Include").decoration);
        writeInOutput(addInclude);

        writeInOutput(("Define").decoration);
        
        writeInOutput(("Variable and private structure").decoration);
        writeInOutput((stateSet).createStateEnum);
        writeInOutput((eventSet).createEventEnum);
        writeInOutput((actionSet).createActionEnum);
        writeInOutput(createTransitionStruct);
        writeInOutput((transitionSet).createMatrice);

        writeInOutput(("Function prototype").decoration);
        
        writeInOutput(("Public function").decoration);
        
        writeInOutput(("Private function").decoration);
    }

    def private writeInOutput(CharSequence p_stream) {
        println(p_stream);
        // TODO Redirect the stream in a file
    }

    def private fillSet(StateMachine p_sm) {
        for (r : p_sm.elements) {
            switch (r.class) {
                case StateImpl: {
                    stateSet.add(r as State)
                }
                case TransitionImpl: {
                    transitionSet.add(r as Transition)
                }
                default: {
                    println(r.class)
                }
            }
        }

        for (t : transitionSet) {
            actionSet.add(t.action as Action);
            eventSet.add(t.event as Event);
            stateSet.add(t.states.get(0) as State);
            stateSet.add(t.states.get(1) as State);
        }
    }

    def private decoration(String p_decoration) {
        var l_deco = "/".repeat((118 - p_decoration.length) / 2)

        '''
            «l_deco» «p_decoration» «l_deco»
        '''
    }

    def private addInclude() '''
        #include <mqueue.h>
        #include <pthread.h>
    '''

    def private createStateEnum(Set<State> p_states) '''
        typedef enum {
            S_NONE = 0,
            «FOR l_state : p_states»
                S_«l_state.name.toSnakeCase().toUpperCase()»,
            «ENDFOR»
            S_COUNTER
        } State;
    '''

    def private createEventEnum(Set<Event> p_event) '''
        typedef enum {
            E_NONE = 0,
            «FOR l_event : p_event»
                E_«l_event.name.toSnakeCase().toUpperCase()»,
            «ENDFOR»
            E_COUNTER
        } Event;
    '''

    def private createActionEnum(Set<Action> p_action) '''
        typedef enum {
            A_NONE = 0,
            «FOR l_action : p_action»
                «IF l_action !== null»
                    A_«l_action.name.toSnakeCase().toUpperCase()»,
                «ENDIF»
            «ENDFOR»
            A_COUNTER
        } Action;
    '''

    def private createTransitionStruct() '''
        typedef struct {
            State stateEnd;
            Action action;
        } Transition;
    '''

    def private createMatrice(Set<Transition> p_transition) '''
        static const Transition stateMachine [S_COUNTER][E_COUNTER] = {
            «FOR l_transition : p_transition»
                «IF l_transition.action !== null»
                    [S_«l_transition.states.get(0).name.toSnakeCase().toUpperCase()»][E_«l_transition.event.name.toSnakeCase().toUpperCase()»] = {S_«l_transition.states.get(1).name.toSnakeCase().toUpperCase()», A_«l_transition.action.name.toSnakeCase().toUpperCase()»},
                «ELSE»
                    [S_«l_transition.states.get(0).name.toSnakeCase().toUpperCase()»][E_«l_transition.event.name.toSnakeCase().toUpperCase()»] = {S_«l_transition.states.get(1).name.toSnakeCase().toUpperCase()», A_NONE},    
                «ENDIF»
            «ENDFOR»
        };
    '''
}
