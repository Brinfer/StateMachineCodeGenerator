package fr.eseo.idm.state_machine_code_generator.language

import fr.eseo.idm.state_machine_code_generator.language.Function
import java.util.List

class ActionFunction extends Function {
    final String actionName;

    new(String p_name, List<String> p_argument, String p_returnType) {
        super(p_name, p_argument, p_returnType);
        this.actionName = "A_" + Function.toSnakeCaseUpper(p_name);
    }

    new(String p_name, String p_returnType) {
        this(p_name, null, p_returnType);
    }

    def String getActionName() {
        return this.actionName;
    }

    override getPrototype() {
        val l_prototype = new StringBuffer();

        l_prototype.append(this.isStatic ? "static " : "extern ");
        l_prototype.append(super.returnType);
        l_prototype.append(" " + "action" + this.name.toFirstUpper());
        l_prototype.append("(");

        if (this.arguments !== null) {
            for (var i = 0; i < this.arguments.size; i += 2) {
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

    override getFunction() {
        return "action" + this.name.toFirstUpper() + "()";
    }
}
