package fr.eseo.idm.state_machine_code_generator.language

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
import java.util.Arrays

class Generator {

    Map<String, ActionFunction> actionFunction;
    Map<String, EventFunction> eventFunction;
    Map<String, Function> privateFunction;
    Map<String, Function> publicFunction;
    Set<State> stateSet;
    Set<Transition> transitionSet;
    PrintWriter outputC;
    PrintWriter outputH;
    String stateMachineName = "";

    def static toSnakeCase(String p_string) {
        p_string.toFirstLower().replaceAll("([A-Z])", "_$1").toLowerCase();
    }

    def static void main(String[] args) {
        val rs = new ResourceSetImpl
        rs.getPackageRegistry().put(State_machine_code_generatorPackage.eNS_URI,
            State_machine_code_generatorPackage.eINSTANCE);

        StateMachineCodeGeneratorStandaloneSetup.doSetup

        val ressources = rs.getResource(
            URI.createFileURI("tests/fr/eseo/idm/state_machine_code_generator/language/trafficLights.plantuml"), true)

        val sm = ressources.getContents().get(0) as StateMachine;

        val generator = new Generator(sm, "TrafficLight");
        generator.generate("./gen/src/");

    }

    new(StateMachine p_sm, String p_name) {
        this.actionFunction = new HashMap<String, ActionFunction>();
        this.eventFunction = new HashMap<String, EventFunction>();
        this.privateFunction = new HashMap<String, Function>();
        this.publicFunction = new HashMap<String, Function>();
        this.stateSet = new HashSet<State>();
        this.transitionSet = new HashSet<Transition>();
        this.stateMachineName = p_name.toFirstUpper();
        this.fillSet(p_sm);
    }

    def generate(String p_path) {
        outputC = new PrintWriter(new FileWriter(new File(p_path + this.stateMachineName + ".c")));
        writeInOutputC(decoration("Include"));
        writeInOutputC(addInclude());

        writeInOutputC(decoration("Define"));
        writeInOutputC(addDefine());

        writeInOutputC(decoration("Variable and private structure"));
        writeInOutputC(createStateEnum());
        writeInOutputC(createEventEnum());
        writeInOutputC(createActionEnum(actionFunction));
        writeInOutputC(createTransitionStruct());
        writeInOutputC(createMqMessageStruct());
        writeInOutputC(createMatrice(transitionSet));
        writeInOutputC(createVar());

        writeInOutputC(decoration("Function prototype"));
        writeInOutputC(createFunctionPrototype());

        writeInOutputC(decoration("Extern function"));
        writeInOutputC(createPublicFunction());

        writeInOutputC(decoration("Private function"));
        writeInOutputC(createMqFunction());
        writeInOutputC(createRunFunction());
        writeInOutputC(createActionFunction());
        outputC.close();

        outputH = new PrintWriter(new FileWriter(new File(p_path + this.stateMachineName + ".h")));
        writeInOutputH(fillHeader());
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
            this.actionFunction.put(t.action.name, new ActionFunction(t.action.name, "int"));

            val l_tempEvent = new EventFunction(t.event.name, "int");
            l_tempEvent.isExtern = this.stateMachineName;

            this.eventFunction.put(t.event.name, l_tempEvent);
            stateSet.add(t.states.get(0) as State);
            stateSet.add(t.states.get(1) as State);
        }

        {
            this.actionFunction.put("none", new ActionFunction("none", "int"));

            this.privateFunction.put("setUpMq", new Function("setUpMq", "int"));
            this.privateFunction.put("tearDoneMq", new Function("tearDoneMq", "int"));
            this.privateFunction.put("readMsgMq",
                new Function("readMsgMq", Arrays.asList("MqMsg" + this.stateMachineName + "*", "dest"), "int"));
            this.privateFunction.put("sendMsgMq",
                new Function("sendMsgMq", Arrays.asList("MqMsg" + this.stateMachineName + "*", "msg"), "int"));
            this.privateFunction.put("run",
                new Function("run" + this.stateMachineName, Arrays.asList("void*", "p_param"), "void*"));
            this.privateFunction.put("performAction",
                new Function("performAction",
                    Arrays.asList("Action" + this.stateMachineName, "p_action",
                        "const MqMsg" + this.stateMachineName + "*", "p_msg"), "int"));
        }

        var l_tempPublic = new Function("new", "int");
        l_tempPublic.isExtern = this.stateMachineName;
        this.publicFunction.put("new", l_tempPublic);

        l_tempPublic = new Function("free", "int");
        l_tempPublic.isExtern = this.stateMachineName;
        this.publicFunction.put("free", l_tempPublic);

        l_tempPublic = new Function("start", "int");
        l_tempPublic.isExtern = this.stateMachineName;
        this.publicFunction.put("start", l_tempPublic);

        l_tempPublic = new Function("stop", "int");
        l_tempPublic.isExtern = this.stateMachineName;
        this.publicFunction.put("stop", l_tempPublic);
    }

    def private decoration(String p_decoration) {
        var l_deco = "/".repeat((118 - p_decoration.length) / 2)

        '''
            «l_deco» «p_decoration» «l_deco»
        '''
    }

    def private fillHeader() '''
        #ifndef «this.stateMachineName.toSnakeCase().toUpperCase()»_H
        #define «this.stateMachineName.toSnakeCase().toUpperCase()»_H
        
        «decoration("Include")»
        
        
        
        «decoration("Extern function")»
        
        «FOR publicKey : this.publicFunction.keySet»
            «this.publicFunction.get(publicKey).prototype»;
        «ENDFOR»
        
        «FOR l_eventKey : this.eventFunction.keySet»
            «this.eventFunction.get(l_eventKey).prototype»;
        «ENDFOR»
        
        #endif /* «this.stateMachineName.toSnakeCase().toUpperCase()»_H */
    '''

    def private addInclude() '''
        #include <stdlib.h>
        #include <mqueue.h>
        #include <pthread.h>
        #include <stdio.h>
        
        #include "«this.stateMachineName».h"
    '''

    def private addDefine() '''
        #define MQ_MAX_MESSAGES (10)
        #define MQ_LABEL "/MQ_«this.stateMachineName.toSnakeCase().toUpperCase()»"
        #define MQ_FLAGS (O_CREAT | O_RDWR)
        #define MQ_MODE (S_IRUSR | S_IWUSR)
    '''

    def private createStateEnum() '''
        typedef enum {
            S_NONE = 0,
            S_DEATH,
            «FOR l_state : this.stateSet»
                S_«l_state.name.toSnakeCase().toUpperCase()»,
            «ENDFOR»
            S_COUNTER
        } State«this.stateMachineName»;
    '''

    def private createEventEnum() '''
        typedef enum {
            E_NONE = 0,
            «FOR l_eventKey : this.eventFunction.keySet»
                «this.eventFunction.get(l_eventKey).eventName»,
            «ENDFOR»
            E_COUNTER
        } Event«this.stateMachineName»;
    '''

    def private createActionEnum(Map<String, ActionFunction> p_action) '''
        typedef enum {
            «FOR l_actionKey : p_action.keySet»
                «IF p_action.get(l_actionKey).actionName == "none"»
                    «p_action.get(l_actionKey).actionName» = 0,
                «ELSE»
                    «p_action.get(l_actionKey).actionName»,
                «ENDIF»
            «ENDFOR»
            A_COUNTER
        } Action«this.stateMachineName»;
    '''

    def private createTransitionStruct() '''
        typedef struct {
            State«this.stateMachineName» stateEnd;
            Action«this.stateMachineName» action;
        } Transition«this.stateMachineName»;
    '''

    def private createMqMessageStruct() '''
        typedef struct {
            Event«this.stateMachineName» event;
        } MqMsg«this.stateMachineName»;
    '''

    def private createMatrice(Set<Transition> p_transition) '''
        static const Transition«this.stateMachineName» stateMachine«this.stateMachineName» [S_COUNTER][E_COUNTER] = {
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
        static State«this.stateMachineName» s_«this.stateMachineName.toFirstLower()»State;
        static pthread_t s_«this.stateMachineName.toFirstLower()»Thread;
        static mqd_t s_«this.stateMachineName.toFirstLower()»Mq;
    '''

    def private createFunctionPrototype() {
        '''
            «FOR actionKey : actionFunction.keySet»
                «this.actionFunction.get(actionKey).prototype»;
            «ENDFOR»
            «FOR functionKey : privateFunction.keySet»
                «this.privateFunction.get(functionKey).prototype»;
            «ENDFOR»    
        '''
    }

    def private createMqFunction() '''
        «this.privateFunction.get("setUpMq").prototype»{
            mq_unlink(MQ_LABEL);
        
            struct mq_attr l_attr;
            l_attr.mq_flags = 0;
            l_attr.mq_maxmsg = MQ_MAX_MESSAGES;
            l_attr.mq_msgsize = sizeof(MqMsg«this.stateMachineName»);
            l_attr.mq_curmsgs = 0;
        
            s_«this.stateMachineName.toFirstLower()»Mq = mq_open(MQ_LABEL, MQ_FLAGS, MQ_MODE, &l_attr);
        
            return s_«this.stateMachineName.toFirstLower()»Mq < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
        
        «this.privateFunction.get("tearDoneMq").prototype»{
            int l_errorCode = mq_unlink(MQ_LABEL);
        
            if (l_errorCode >= 0) {
                l_errorCode = mq_close(s_«this.stateMachineName.toFirstLower()»Mq);
            }
        
            return l_errorCode < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
        
        «this.privateFunction.get("readMsgMq").prototype»{
            return mq_receive(s_«this.stateMachineName.toFirstLower()»Mq, (char*) dest, sizeof(MqMsg«this.stateMachineName»), NULL) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
        
        «this.privateFunction.get("sendMsgMq").prototype»{
            return mq_send(s_«this.stateMachineName.toFirstLower()»Mq, (char*) msg, sizeof(MqMsg«this.stateMachineName»), 0) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
        }
    '''

    def private createRunFunction() '''
        «this.privateFunction.get("run").prototype»{
                while (s_«this.stateMachineName.toFirstLower()»State != S_DEATH) {
                    MqMsg«this.stateMachineName» l_msg;
        
                    readMsgMq(&l_msg);
                    Transition«this.stateMachineName» l_transition = stateMachine«this.stateMachineName»[s_«this.stateMachineName.toFirstLower»State][l_msg.event];
        
                    if (l_transition.stateEnd != S_NONE) {
                        «this.privateFunction.get("performAction").name»(l_transition.action, &l_msg);
                        s_«this.stateMachineName.toFirstLower()»State = l_transition.stateEnd;
                    }
                }
                return NULL;
            }
        
        «this.privateFunction.get("performAction").prototype»{
            int l_errorCode = EXIT_FAILURE;
        
            switch (p_action) {
                «FOR l_actionKey : this.actionFunction.keySet»
                    case «this.actionFunction.get(l_actionKey).actionName»:
                        l_errorCode = «this.actionFunction.get(l_actionKey).function»;
                        break;
                «ENDFOR»
                default:
                    l_errorCode = «this.actionFunction.get("none").function»;
                    break;
            }
            return l_errorCode;
        }
    '''

    def private createActionFunction() '''
        «FOR l_actionKey : this.actionFunction.keySet»
            «this.actionFunction.get(l_actionKey).prototype» {
                // TODO auto-generated code
                int l_errorCode = EXIT_SUCCESS;
                printf("[«this.stateMachineName»] Perform action «this.actionFunction.get(l_actionKey).actionName»");
                return l_errorCode;
            }
            
        «ENDFOR»
    '''

    def private createPublicFunction() '''
        «this.publicFunction.get("new").prototype» {
            int l_errorCode = EXIT_FAILURE;
            
            // TODO auto-generated code
            printf("[«this.stateMachineName»] setting up the state machine");
            l_errorCode = setUpMq();
            
            return l_errorCode;
        }
        
        «this.publicFunction.get("free").prototype» {
            int l_errorCode = EXIT_FAILURE;
            
            // TODO auto-generated code
            printf("[«this.stateMachineName»] tearring down the state machine");
            l_errorCode = tearDoneMq();
            
            return l_errorCode;
        }
        
        «this.publicFunction.get("start").prototype» {
            int l_errorCode = EXIT_FAILURE;
            
            // TODO auto-generated code
            printf("[«this.stateMachineName»] starting the state machine");
            s_«this.stateMachineName.toFirstLower()»State = S_NONE;
            l_errorCode = pthread_create(&s_«this.stateMachineName.toFirstLower()»Thread, NULL, &run«this.stateMachineName», NULL);
        
            return l_errorCode;
        }
        
        «this.publicFunction.get("stop").prototype» {
            int l_errorCode = EXIT_FAILURE;
            
            // TODO auto-generated code
            printf("[«this.stateMachineName»] stopping the state machine");
            l_errorCode = pthread_join(s_«this.stateMachineName.toFirstLower()»Thread, NULL);
        
            return l_errorCode;
        }
        
        «FOR l_eventKey : this.eventFunction.keySet»
            «this.eventFunction.get(l_eventKey).prototype» {
                int l_errorCode = EXIT_FAILURE;
                
                MqMsg«this.stateMachineName» msg = { .event = «this.eventFunction.get(l_eventKey).eventName» };
                l_errorCode = sendMsgMq(&msg);
                
                return l_errorCode;
            }
        «ENDFOR»
    '''
}
