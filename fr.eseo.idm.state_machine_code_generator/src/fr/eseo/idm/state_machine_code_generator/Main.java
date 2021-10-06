package fr.eseo.idm.state_machine_code_generator;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;

import fr.eseo.idm.state_machine_code_generator.Action;
import fr.eseo.idm.state_machine_code_generator.Event;
import fr.eseo.idm.state_machine_code_generator.State;
import fr.eseo.idm.state_machine_code_generator.Transition;

public class Main {
    private static ResourceSet rs;

    public static void main(String[] args) throws IOException {
            init();
            createAndSave();
            loadModel();
        }

        private static void init() {
        	System.out.println("Start of the initialization");
            rs = new ResourceSetImpl();
            rs.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
            rs.getPackageRegistry().put(State_machine_code_generatorPackage.eNS_URI, State_machine_code_generatorPackage.eINSTANCE);
            System.out.println("End of initialization");
        }

        private static void loadModel() {
        	System.out.println("Start loading model");
            Resource r = rs.getResource(URI.createFileURI("state_machine_code_generator.xmi"), true);

            for(EObject content : r.getContents()) {
            	System.out.println("\t" + content);
            }
            System.out.println("End of model loading");
        }

        /**
         * @details
         * ++++++++++     ++++++++++     ++++++++++
         * + green  + --> + yellow + --> +  red   +
         * ++++--^-++     ++++++++++     ++++++++++
         *       |                         |
         *       +-------------------------+
         *
         * @throws IOException
         */
        private static void createAndSave() throws IOException {
        	System.out.println("Start of model creation");
	        State green = State_machine_code_generatorFactory.eINSTANCE.createState();
	        green.setName("Green");
	        State yellow = State_machine_code_generatorFactory.eINSTANCE.createState();
	        yellow.setName("Yellow");
	        State red = State_machine_code_generatorFactory.eINSTANCE.createState();
	        red.setName("Red");

	        Action turnOnGreen = State_machine_code_generatorFactory.eINSTANCE.createAction();
	        turnOnGreen.setName("Turn on Green");
	        Action turnOnYellow = State_machine_code_generatorFactory.eINSTANCE.createAction();
	        turnOnYellow.setName("Turn on Yellow");
	        Action turnOnRed = State_machine_code_generatorFactory.eINSTANCE.createAction();
	        turnOnRed.setName("Turn on Red");
	        Action turnOffGreen = State_machine_code_generatorFactory.eINSTANCE.createAction();
	        turnOffGreen.setName("Turn off Green");
	        Action turnOffYellow = State_machine_code_generatorFactory.eINSTANCE.createAction();
	        turnOffYellow.setName("Turn off Yellow");
	        Action turnOffRed = State_machine_code_generatorFactory.eINSTANCE.createAction();
	        turnOffRed.setName("Turn off Red");

	        Event passGreenToYellow = State_machine_code_generatorFactory.eINSTANCE.createEvent();
	        passGreenToYellow.setName("Pass Green to Yellow");
	        Event passYellowToRed = State_machine_code_generatorFactory.eINSTANCE.createEvent();
	        passYellowToRed.setName("Pass Yellow to Red");
	        Event passRedToGreen = State_machine_code_generatorFactory.eINSTANCE.createEvent();
	        passRedToGreen.setName("Pass Red to Green");

	        Transition greenToYellow = State_machine_code_generatorFactory.eINSTANCE.createTransition();
	        greenToYellow.setEvent(passGreenToYellow);
	        greenToYellow.getStates().add(green);
	        greenToYellow.getStates().add(yellow);
	        greenToYellow.setAction(turnOffGreen);
	        greenToYellow.setAction(turnOnYellow);
	
	        Transition yellowToRed = State_machine_code_generatorFactory.eINSTANCE.createTransition();
	        yellowToRed.setEvent(passYellowToRed);
	        yellowToRed.getStates().add(yellow);
	        yellowToRed.getStates().add(red);
	        yellowToRed.setAction(turnOffYellow);
	        yellowToRed.setAction(turnOnRed);
	
	       Transition redToGreen = State_machine_code_generatorFactory.eINSTANCE.createTransition();
	       redToGreen.setEvent(passRedToGreen);
	       redToGreen.getStates().add(red);
	       redToGreen.getStates().add(green);
	       redToGreen.setAction(turnOffRed);
	       redToGreen.setAction(turnOnGreen);
	
	       System.out.println("End of model creation");
	       System.out.println("Start saving models");

	       Map<String, Object> options = new HashMap<>();
	       options.put(XMLResource.OPTION_ENCODING, "UTF-8");

	        Resource rStateMachine = rs.createResource(URI.createFileURI("state_machine_code_generator.xmi"));
	        rStateMachine.getContents().add(greenToYellow);
	        rStateMachine.getContents().add(yellowToRed);
	        rStateMachine.getContents().add(redToGreen);
	        rStateMachine.getContents().add(green);
	        rStateMachine.getContents().add(yellow);
	        rStateMachine.getContents().add(red);
	        rStateMachine.getContents().add(turnOnGreen);
	        rStateMachine.getContents().add(turnOnYellow);
	        rStateMachine.getContents().add(turnOnRed);
	        rStateMachine.getContents().add(turnOffGreen);
	        rStateMachine.getContents().add(turnOffYellow);
	        rStateMachine.getContents().add(turnOffRed);
	        rStateMachine.getContents().add(passGreenToYellow);
	        rStateMachine.getContents().add(passYellowToRed);
	        rStateMachine.getContents().add(passRedToGreen);
	        rStateMachine.save(options);

	        System.out.println("End saving models");
    }
}
