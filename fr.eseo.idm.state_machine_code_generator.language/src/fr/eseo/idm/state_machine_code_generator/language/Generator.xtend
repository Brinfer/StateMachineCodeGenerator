package fr.eseo.idm.state_machine_code_generator.language

import fr.eseo.idm.state_machine_code_generator.Event
import fr.eseo.idm.state_machine_code_generator.State
import fr.eseo.idm.state_machine_code_generator.StateMachine
import fr.eseo.idm.state_machine_code_generator.State_machine_code_generatorPackage
import fr.eseo.idm.state_machine_code_generator.Transition
import fr.eseo.idm.state_machine_code_generator.impl.StateImpl
import fr.eseo.idm.state_machine_code_generator.impl.TransitionImpl
import java.io.File
import java.io.FileWriter
import java.io.PrintWriter
import java.util.HashMap
import java.util.HashSet
import java.util.Map
import java.util.Set
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl

class Generator {

    Map<String, Function> functionSet;
    Set<State> stateSet;
    Set<Transition> transitionSet;
    Set<Event> eventSet;
    PrintWriter outputC;
    PrintWriter outputH;

    def static toSnakeCase(String p_string) {
        p_string.toFirstLower().replaceAll("([A-Z])", "_$1").toLowerCase();
    }

    def static void main(String[] args) {
        val rs = new ResourceSetImpl
        rs.getPackageRegistry().put(State_machine_code_generatorPackage.eNS_URI,
            State_machine_code_generatorPackage.eINSTANCE);

        StateMachineCodeGeneratorStandaloneSetup.doSetup

        val ressources = rs.getResource(
            URI.createFileURI("tests/fr/eseo/idm/state_machine_code_generator/language/trafficLights.smcg"), true)

        val sm = ressources.getContents().get(0) as StateMachine;

        val generator = new Generator(sm);
        generator.generate("TrafficLight");

    }

    new(StateMachine p_sm) {
        this.functionSet = new HashMap<String, Function>();
        this.stateSet = new HashSet<State>();
        this.transitionSet = new HashSet<Transition>();
        this.eventSet = new HashSet<Event>();
        this.fillSet(p_sm);
    }

    def generate(String path) {
        outputC = new PrintWriter(new FileWriter(new File(path + ".c")));
        outputH = new PrintWriter(new FileWriter(new File(path + ".h")));

        writeInOutputC(decoration("Include"));
        writeInOutputC(addInclude);

        writeInOutputC(decoration("Define"));
        writeInOutputC(addDefine());

        writeInOutputC(decoration("Variable and private structure"));
        writeInOutputC(createStateEnum(stateSet));
        writeInOutputC(createEventEnum(eventSet));
        writeInOutputC(createActionEnum(functionSet));
        writeInOutputC(createTransitionStruct());
        writeInOutputC(createMqMessageStruct());
        writeInOutputC(createMatrice(transitionSet));
        writeInOutputC(createVar());

        writeInOutputC(decoration("Function prototype"));
        writeInOutputC(createFunctionPrototype());

        writeInOutputC(decoration("Public function"));

        writeInOutputC(decoration("Private function"));
        writeInOutputC(createMqFunction());
        writeInOutputC(creeateRunFunction());

        writeInOutputH("TODO");

        outputC.close();
        outputH.close();
    }

    def private writeInOutputC(CharSequence p_stream) {
        outputC.write(p_stream.toString() + "\n");
        println(p_stream);
    }

    def private writeInOutputH(CharSequence p_stream) {
        outputH.write(p_stream.toString() + "\n");
        println(p_stream);
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
                    System.err.println(r.class);
                }
            }
        }

        for (t : transitionSet) {
            val l_temp = new Function(t.action.name);
            l_temp.isAction = true;
            this.functionSet.put(t.action.name, l_temp);

            eventSet.add(t.event as Event);
            stateSet.add(t.states.get(0) as State);
            stateSet.add(t.states.get(1) as State);
        }
        
        val l_temp = new Function("none");
        l_temp.isAction = true;
        this.functionSet.put("none", l_temp);
    }

    def private decoration(String p_decoration) {
        var l_deco = "/".repeat((118 - p_decoration.length) / 2)

        '''
            «l_deco» «p_decoration» «l_deco»
        '''
    }

    def private addInclude() '''
        #include <errno.h>
        #include <mqueue.h>
        #include <pthread.h>
        #include <stdio.h>
    '''

    def private addDefine() '''
        #define MQ_MAX_MESSAGES (10)
        #define MQ_LABEL "/MQ_STATE_MACHINE"
        #define MQ_FLAGS (O_CREAT | O_RDWR)
        #define MQ_MODE (S_IRUSR | S_IWUSR)
    '''

    def private createStateEnum(Set<State> p_states) '''
        typedef enum {
            S_NONE = 0,
            S_DEATH,
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

    def private createActionEnum(Map<String, Function> p_action) '''
        typedef enum {
            A_NONE = 0,
            «FOR l_actionKey : p_action.keySet»
                «IF p_action.get(l_actionKey).actionName == "none"»
                    A_«p_action.get(l_actionKey).actionName» = 0,
                «ELSE»
                    A_«p_action.get(l_actionKey).actionName»,
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

    def private createMqMessageStruct() '''
        typedef struct {
            Event event;
        } MqMsg;
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

    def private createVar() '''
        static State s_currentState;
        static pthread_t s_thread;
        static mqd_t s_mq;
    '''

    def private createFunctionPrototype() {
        this.functionSet.put("setUpMq", new Function("setUpMq", "int"));
        this.functionSet.put("tearDoneMq", new Function("tearDoneMq", "int"));
        this.functionSet.put("readMsgMq", new Function("readMsgMq", Map.of("dest", "MqMsg*"), "int"));
        this.functionSet.put("sendMsgMq", new Function("sendMsgMq", Map.of("msg", "MqMsg*"), "int"));
        this.functionSet.put("run", new Function("run"));
        this.functionSet.put("performAction", new Function("performAction", Map.of("p_action", "Action", "p_msg", "const MqMsgGeographer*"), "int"));
        this.functionSet.put("actionNone", new Function("none", "int"));
        
        // TODO Sort the list
        '''
            «FOR functionKey : functionSet.keySet»
                «this.functionSet.get(functionKey).prototype»;
            «ENDFOR»
        '''
    }

    def private createMqFunction() '''
        «this.functionSet.get("setUpMq").prototype»{
            mq_unlink(MQ_LABEL);

            struct mq_attr l_attr;
            l_attr.mq_flags = 0;
            l_attr.mq_maxmsg = MQ_MAX_MESSAGES;
            l_attr.mq_msgsize = sizeof(MqMsg);
            l_attr.mq_curmsgs = 0;

            s_mq = mq_open(MQ_LABEL, MQ_FLAGS, MQ_MODE, &l_attr);

            return s_mq < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
        
        «this.functionSet.get("tearDoneMq").prototype»{
            int l_errorCode = mq_unlink(MQ_LABEL);

            if (returnError >= 0) {
                l_errorCode = mq_close(geographerMq);
            }
        
            return l_errorCode < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
        
        «this.functionSet.get("readMsgMq").prototype»{
            return mq_receive(s_mq, (char*) dest, sizeof(MqMsgGeographer), NULL) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
        
        «this.functionSet.get("sendMsgMq").prototype»{
            return mq_send(s_mq, (char*) msg, sizeof(MqMsgGeographer), 0) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
    '''
    
    def private creeateRunFunction() '''
    «this.functionSet.get("run").prototype»{
            while (s_currentState != S_DEATH) {
                MqMsg l_msg;

                readMsgMq(&l_msg);
                Transition l_transition = stateMachine[s_currentState][l_msg.event];

                if (l_transition.stateEnd != S_NONE) {
                    performAction(l_transition.action, &l_msg);

                    s_currentState = l_transition.stateEnd;
                }
            }
            return NULL;
        }

    «this.functionSet.get("performAction").prototype»{
        int l_errorCode = EXIT_FAILURE;
        
        switch (p_action) {
                case A_NONE:
                default:
                    returnError = actionNone();
                    break;
    }
    '''
}
