package stateMachineCodeGenerator

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl

class StateMachineGenerator {
    def static void main(String[] args) {
        val rs = new ResourceSetImpl();
        rs.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
        rs.getPackageRegistry().put(StateMachineCodeGeneratorPackage.eNS_URI, StateMachineCodeGeneratorPackage.eINSTANCE);
        val r = rs.getResource(URI.createFileURI("stateMachineCodeGenerator.xmi"), true);
        System.out.println((r.getContents().get(0) as State).toHTML);
    }

    def static toHTML(State state) '''
		State «state.name»
		    <ul>
		        Transition :
		        «FOR transition : state.transitions»
		        	<li>Transition «transition.hashCode» - Event «transition.event.hashCode»</li>
		        	<ul>
		        	     <li>From «transition.states.get(0).name» to «transition.states.get(1).name»</li>
		        	     <li>Actions</li>
		        	     <ul>
		        	        «FOR action : transition.action»
		        	        	<li>«action.fonction»</li>
		        	        «ENDFOR»
		        	</ul>
		        	</ul>
		        «ENDFOR»
		    </ul>
	'''
}
