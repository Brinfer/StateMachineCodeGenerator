package fr.eseo.idm.state_machine_code_generator.language

import java.util.Map

class Function {
    final String name;
    final Map<String, String> arguments;
    final String actionName;
    final String returnType;
    boolean isStatic = true;
    boolean isAction = false;

    def static toActionName(String p_string) {
        p_string.toFirstLower().replaceAll("([A-Z])", "_$1").toUpperCase();
    }

    new(String p_name) {
        this(p_name, null, "void");
    }
    
    new(String p_name, String p_returnType) {
        this(p_name, null, p_returnType);
    }
    
    new(String p_name, Map<String, String> p_argument) {
        this(p_name, p_argument, "void");
    }

    new(String p_name, Map<String, String> p_argument, String p_returnType) {
        this.name = p_name;
        this.arguments = p_argument;
        this.returnType = p_returnType;
        this.actionName = Function.toActionName(p_name);
    }
    
    def boolean isStatic() {
        return this.isStatic;
    }
    
    def setIsStatic(boolean p_val){
        this.isStatic = p_val;
    }
    
    def boolean isAction() {
        return this.isAction;
    }
    
    def setIsAction(boolean p_val){
        this.isAction = p_val;
    }

    def String getName() {
        return this.name;
    }

    def Map<String, String> getArguments() {
        return this.arguments;
    }

    def String getActionName() {
        return this.actionName;
    }

    def getPrototype() {
        val l_prototype = new StringBuffer();

        l_prototype.append(this.isStatic ? "static " : "extern ");
        l_prototype.append(this.returnType);
        l_prototype.append(" " + (this.isAction ? ("action" + this.name.toFirstUpper()) : this.name));
        l_prototype.append("(");

        if (this.arguments !== null) {
            for (String l_name : this.arguments.keySet) {
                l_prototype.append(this.arguments.get(l_name) + " " + l_name);
            }
        } else {
            l_prototype.append("void");
        }

        l_prototype.append(")");

        return l_prototype.toString();
    }
}
