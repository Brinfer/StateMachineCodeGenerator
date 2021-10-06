/*
 * generated by Xtext 2.20.0
 */
package fr.eseo.idm.state_machine_code_generator.language.ide;

import com.google.inject.Guice;
import com.google.inject.Injector;
import fr.eseo.idm.state_machine_code_generator.language.StateMachineCodeGeneratorRuntimeModule;
import fr.eseo.idm.state_machine_code_generator.language.StateMachineCodeGeneratorStandaloneSetup;
import org.eclipse.xtext.util.Modules2;

/**
 * Initialization support for running Xtext languages as language servers.
 */
public class StateMachineCodeGeneratorIdeSetup extends StateMachineCodeGeneratorStandaloneSetup {

	@Override
	public Injector createInjector() {
		return Guice.createInjector(Modules2.mixin(new StateMachineCodeGeneratorRuntimeModule(), new StateMachineCodeGeneratorIdeModule()));
	}
	
}
