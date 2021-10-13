package fr.eseo.idm.state_machine_code_generator.language

import java.util.List

class Function {
    protected String name;
    protected final List<String> arguments;
    protected final String returnType;
    boolean isStatic = true;

    def static toSnakeCaseUpper(String p_string) {
        p_string.toFirstLower().replaceAll("([A-Z])", "_$1").toUpperCase();
    }

    new(String p_name) {
        this(p_name, null, "void");
    }

    new(String p_name, String p_returnType) {
        this(p_name, null, p_returnType);
    }

    new(String p_name, List<String> p_argument) {
        this(p_name, p_argument, "void");
    }

    new(String p_name, List<String> p_argument, String p_returnType) {
        this.name = p_name;
        this.arguments = p_argument;
        this.returnType = p_returnType;
    }

    def boolean isStatic() {
        return this.isStatic;
    }

    def setIsStatic(String p_moduleName) {
        this.isStatic = true;
        this.name = p_moduleName + "_" + this.name;
    }

    def String getName() {
        return this.name;
    }

    def List<String> getArguments() {
        return this.arguments;
    }

    def getPrototype() {
        val l_prototype = new StringBuffer();

        l_prototype.append(this.isStatic ? "static " : "extern ");
        l_prototype.append(this.returnType);
        l_prototype.append(" " + this.name);
        l_prototype.append("(");

        if (this.arguments !== null) {
            for(var i = 0; i < this.arguments.size; i += 2) {
                l_prototype.append(this.arguments.get(i) + " " + this.arguments.get(i + 1));
                if (i < this.arguments.size - 2) {
                    l_prototype.append(", ");
                }
            }
        } else {
            l_prototype.append("void");
        }

        l_prototype.append(")");

        return l_prototype.toString();
    }

    def getFunction() {
        return this.name + "()";
    }
}
