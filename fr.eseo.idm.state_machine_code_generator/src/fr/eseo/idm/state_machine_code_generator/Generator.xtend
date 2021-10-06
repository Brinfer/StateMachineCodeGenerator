package fr.eseo.idm.state_machine_code_generator;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;

import fr.eseo.idm.state_machine_code_generator.State_machine_code_generatorPackage;

class Generator {
    def static void main(String[] args) {
        val rs = new ResourceSetImpl();
        rs.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
        rs.getPackageRegistry().put(State_machine_code_generatorPackage.eNS_URI,
            State_machine_code_generatorPackage.eINSTANCE);
        val r = rs.getResource(URI.createFileURI("state_machine_code_generator.xmi"), true);
        System.out.println((r.getContents().get(0) as Transition).toHTML);
    }

    def static toHTML(Transition transition) '''
		Transition «transition.name»
		  <ul>
		     	<li>Event : «transition.event.name»</li>
		     	<li>Actions : «transition.action.name»</li>
		     	<li>States linked :</li>
		     	<ul>
		     	  «FOR state : transition.states»
		     	  	<li>State: «state.name»</li>
		     	  «ENDFOR»
		     	</ul>
		   </ul>
	'''
}
