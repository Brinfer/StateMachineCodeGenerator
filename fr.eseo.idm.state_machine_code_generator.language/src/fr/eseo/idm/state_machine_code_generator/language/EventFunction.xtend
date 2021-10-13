package fr.eseo.idm.state_machine_code_generator.language

import fr.eseo.idm.state_machine_code_generator.language.Function
import java.util.List

class EventFunction extends Function {
    final String eventName;

    new(String p_name, List<String> p_argument, String p_returnType) {
        super(p_name, p_argument, p_returnType);
        this.eventName = "E_" + Function.toSnakeCaseUpper(p_name);
    }
    
    new(String p_name, String p_returnType) {
        this(p_name, null, p_returnType);
    }
    
    def String getEventName() {
        return this.eventName;
    }
}