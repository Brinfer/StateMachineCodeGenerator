package fr.eseo.idm.state_machine_code_generator.language

import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import fr.eseo.idm.state_machine_code_generator.Transition
import fr.eseo.idm.state_machine_code_generator.State
import fr.eseo.idm.state_machine_code_generator.Event
import fr.eseo.idm.state_machine_code_generator.Action
import fr.eseo.idm.state_machine_code_generator.State_machine_code_generatorPackage
import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import fr.eseo.idm.state_machine_code_generator.StateMachine

class Generator {
    def static void main(String[] args) {
        val rs = new ResourceSetImpl
        rs.getPackageRegistry().put(State_machine_code_generatorPackage.eNS_URI,
            State_machine_code_generatorPackage.eINSTANCE);

        StateMachineCodeGeneratorStandaloneSetup.doSetup

        val ressources = rs.getResource(
            URI.createFileURI("tests/fr/eseo/idm/state_machine_code_generator/language/trafficLights.smcg"), true)

        val sm = ressources.getContents().get(0) as StateMachine

        var stateList = new ArrayList<State>();
        var ArrayList<Event> eventList = new ArrayList<Event>();
        var ArrayList<Action> actionList = new ArrayList<Action>();
        var ArrayList<Transition> transitionList = new ArrayList<Transition>();

        for (r : sm.elements.filter(State)) {
            stateList.add(r as State)
        }
        for (r : sm.elements.filter(Event)) {
            eventList.add(r as Event)
        }
        for (r : sm.elements.filter(Action)) {
            actionList.add(r as Action)
        }
        for (r : sm.elements.filter(Transition)) {
            transitionList.add(r as Transition)
        }

        System.out.println((stateList).createStateEnum);
        System.out.println((eventList).createEventEnum);
        System.out.println((actionList).createActionEnum);
        System.out.println(createTransitionStruct);
        System.out.println((transitionList).createMatrice);
    }

    def static createStateEnum(ArrayList<State> p_states) '''
        enum {
            S_NONE = 0,
            «FOR l_state : p_states»
                S_«l_state.name.toUpperCase()»,
            «ENDFOR»
            S_COUNTER
        } State;
    '''

    def static createEventEnum(ArrayList<Event> p_event) '''
        enum {
            E_NONE = 0,
            «FOR l_event : p_event»
                E_«l_event.name.toUpperCase()»,
            «ENDFOR»
            E_COUNTER
        } Event;
    '''

    def static createActionEnum(ArrayList<Action> p_action) '''
        enum {
            A_NONE = 0,
            «FOR l_action : p_action»
                A_«l_action.name.toUpperCase()»,
            «ENDFOR»
            A_COUNTER
        } Action;
    '''

    def static createTransitionStruct() '''
        struct {
            State stateEnd;
            Action action;
        } Transition;
    '''

    def static createMatrice(ArrayList<Transition> p_transition) '''
        static const Transition stateMachine [S_COUNTER][E_COUNTER] = {
            «FOR l_transition : p_transition»
                [S_«l_transition.states.get(0).name.toUpperCase()»][E_«l_transition.event.name.toUpperCase()»] = {S_«l_transition.states.get(1).name.toUpperCase()», A_«l_transition.action.name.toUpperCase()»},
            «ENDFOR»
        };
    '''
}
