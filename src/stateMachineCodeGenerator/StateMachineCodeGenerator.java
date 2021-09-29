package stateMachineCodeGenerator;

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

import stateMachineCodeGenerator.Action;
import stateMachineCodeGenerator.Event;
import stateMachineCodeGenerator.State;
import stateMachineCodeGenerator.Transition;

public class StateMachineCodeGenerator {
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
            rs.getPackageRegistry().put(StateMachineCodeGeneratorPackage.eNS_URI, StateMachineCodeGeneratorPackage.eINSTANCE);
            System.out.println("End of initialization");
        }

        private static void loadModel() {
        	System.out.println("Start loading model");
            Resource r = rs.getResource(URI.createFileURI("stateMachineCodeGenerator.xmi"), true);
            
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
	        State green = StateMachineCodeGeneratorFactory.eINSTANCE.createState();
	        green.setName("Green");
	        State yellow = StateMachineCodeGeneratorFactory.eINSTANCE.createState();
	        yellow.setName("Yellow");
	        State red = StateMachineCodeGeneratorFactory.eINSTANCE.createState();
	        red.setName("Red");

	        Action turnOnGreen = StateMachineCodeGeneratorFactory.eINSTANCE.createAction();
	        turnOnGreen.setFonction("Turn on Green");
	        Action turnOnYellow = StateMachineCodeGeneratorFactory.eINSTANCE.createAction();
	        turnOnYellow.setFonction("Turn on Yellow");
	        Action turnOnRed = StateMachineCodeGeneratorFactory.eINSTANCE.createAction();
	        turnOnRed.setFonction("Turn on Red");
	        Action turnOffGreen = StateMachineCodeGeneratorFactory.eINSTANCE.createAction();
	        turnOffGreen.setFonction("Turn off Green");
	        Action turnOffYellow = StateMachineCodeGeneratorFactory.eINSTANCE.createAction();
	        turnOffYellow.setFonction("Turn off Yellow");
	        Action turnOffRed = StateMachineCodeGeneratorFactory.eINSTANCE.createAction();
	        turnOffRed.setFonction("Turn off Red");
	
	        Event passGreenToYellow = StateMachineCodeGeneratorFactory.eINSTANCE.createEvent();
	        Event passYellowToRed = StateMachineCodeGeneratorFactory.eINSTANCE.createEvent();
	        Event passRedToGreen = StateMachineCodeGeneratorFactory.eINSTANCE.createEvent();
	
	        Transition greenToYellow = StateMachineCodeGeneratorFactory.eINSTANCE.createTransition();
	        greenToYellow.setEvent(passGreenToYellow);
	        passGreenToYellow.getTransitions().add(greenToYellow);
	        greenToYellow.getAction().add(turnOffGreen);
	        turnOffGreen.getTransitions().add(greenToYellow);
	        greenToYellow.getAction().add(turnOnYellow);
	        turnOnYellow.getTransitions().add(greenToYellow);
	        greenToYellow.getStates().add(green);
	        green.getTransitions().add(greenToYellow);
	        greenToYellow.getStates().add(yellow);
	        yellow.getTransitions().add(greenToYellow);
	
	        Transition yellowToRed = StateMachineCodeGeneratorFactory.eINSTANCE.createTransition();
	        yellowToRed.setEvent(passYellowToRed);
	        passYellowToRed.getTransitions().add(yellowToRed);
	        yellowToRed.getAction().add(turnOffYellow);
	        turnOffYellow.getTransitions().add(yellowToRed);
	        yellowToRed.getAction().add(turnOnRed);
	        turnOnRed.getTransitions().add(yellowToRed);
	        yellowToRed.getStates().add(yellow);
	        yellow.getTransitions().add(yellowToRed);
	        yellowToRed.getStates().add(red);
	        red.getTransitions().add(yellowToRed);

	       Transition redToGreen = StateMachineCodeGeneratorFactory.eINSTANCE.createTransition();
	       redToGreen.setEvent(passRedToGreen);
	       passRedToGreen.getTransitions().add(redToGreen);
	       redToGreen.getAction().add(turnOffRed);
	       turnOffRed.getTransitions().add(redToGreen);
	       redToGreen.getAction().add(turnOnGreen);
	       turnOnGreen.getTransitions().add(redToGreen);
	       redToGreen.getStates().add(red);
	       red.getTransitions().add(redToGreen);
	       redToGreen.getStates().add(green);
	       green.getTransitions().add(redToGreen);
	       
	       System.out.println("End of model creation");
	       System.out.println("Start saving models");
	
	       Map<String, Object> options = new HashMap<>();
	       options.put(XMLResource.OPTION_ENCODING, "UTF-8");

	        Resource rGreen = rs.createResource(URI.createFileURI("stateMachineCodeGenerator.xmi"));
	        rGreen.getContents().add(green);
	        rGreen.getContents().add(yellow);
	        rGreen.getContents().add(red);
	        rGreen.getContents().add(greenToYellow);
	        rGreen.getContents().add(yellowToRed);
	        rGreen.getContents().add(redToGreen);
	        rGreen.getContents().add(turnOnGreen);
	        rGreen.getContents().add(turnOnYellow);
	        rGreen.getContents().add(turnOnRed);
	        rGreen.getContents().add(turnOffGreen);
	        rGreen.getContents().add(turnOffYellow);
	        rGreen.getContents().add(turnOffRed);
	        rGreen.getContents().add(passGreenToYellow);
	        rGreen.getContents().add(passYellowToRed);
	        rGreen.getContents().add(passRedToGreen);
	        rGreen.save(options);
	
	        System.out.println("End saving models");
	        // Resource rYellow = rs.createResource(URI.createFileURI("yellow.xmi"));
	        // rYellow.getContents().add(yellow);
	        // rYellow.save(options);
	
	        // Resource rRed = rs.createResource(URI.createFileURI("red.xmi"));
	        // rRed.getContents().add(red);
	        // rRed.save(options);
	
	
	        // Resource rGreenToYellow = rs.createResource(URI.createFileURI("greenToYellow.xmi"));
	        // rGreenToYellow.getContents().add(greenToYellow);
	        // rGreenToYellow.save(options);
	
	        // Resource rYellowToRed = rs.createResource(URI.createFileURI("yellowToRed.xmi"));
	        // rYellowToRed.getContents().add(yellowToRed);
	        // rYellowToRed.save(options);
	
	        // Resource rRedToGreen = rs.createResource(URI.createFileURI("redToGreen.xmi"));
	        // rRedToGreen.getContents().add(redToGreen);
	        // rRedToGreen.save(options);
	
	        // Resource rTurnOnGreen = rs.createResource(URI.createFileURI("turnOnGreen.xmi"));
	        // rTurnOnGreen.getContents().add(turnOnGreen);
	        // rTurnOnGreen.save(options);
	
	        // Resource rTurnOnYellow = rs.createResource(URI.createFileURI("turnOnYellow.xmiS"));
	        // rTurnOnYellow.getContents().add(turnOnYellow);
	        // rTurnOnYellow.save(options);
	
	        // Resource rTurnOnRed = rs.createResource(URI.createFileURI("turnOnRed.xmi"));
	        // rTurnOnRed.getContents().add(turnOnRed);
	        // rTurnOnRed.save(options);
	
	        // Resource rTurnOffGreen = rs.createResource(URI.createFileURI("turnOffGreen.xmi"));
	        // rTurnOffGreen.getContents().add(turnOffGreen);
	        // rTurnOffGreen.save(options);
	
	        // Resource rTurnOffYellow = rs.createResource(URI.createFileURI("turnOffYellow.xmi"));
	        // rTurnOffYellow.getContents().add(turnOffYellow);
	        // rTurnOffYellow.save(options);
	
	        // Resource rTurnOffRed = rs.createResource(URI.createFileURI("turnOffRed.xmi"));
	        // rTurnOffRed.getContents().add(turnOnRed);
	        // rTurnOffRed.save(options);
	
	        // Resource rPassGreenToYellow = rs.createResource(URI.createFileURI("passGreenToYellow.xmi"));
	        // rPassGreenToYellow.getContents().add(passGreenToYellow);
	        // rPassGreenToYellow.save(options);
	
	        // Resource rPassYellowToRed = rs.createResource(URI.createFileURI("passYellowToRed.xmi"));
	        // rPassYellowToRed.getContents().add(passYellowToRed);
	        // rPassYellowToRed.save(options);
	
	        // Resource rPassRedToGreen = rs.createResource(URI.createFileURI("passRedToGreen.xmi"));
	        // rPassRedToGreen.getContents().add(passRedToGreen);
	        // rPassRedToGreen.save(options);
    }
}
