/*
 * generated by Xtext 2.20.0
 */
package fr.eseo.idm.state_machine_code_generator.language;


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
public class StateMachineCodeGeneratorStandaloneSetup extends StateMachineCodeGeneratorStandaloneSetupGenerated {

	public static void doSetup() {
		new StateMachineCodeGeneratorStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}