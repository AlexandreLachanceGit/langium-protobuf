import { type Module, inject } from 'langium';
import { createDefaultModule, createDefaultSharedModule, type DefaultSharedModuleContext, type LangiumServices, type LangiumSharedServices, type PartialLangiumServices } from 'langium/lsp';
import { ProtobufGeneratedModule, ProtobufGeneratedSharedModule } from './generated/module.js';
import { ProtobufDocumentValidaor, ProtobufValidator, registerValidationChecks } from './protobuf-validator.js';

/**
 * Declaration of custom services - add your own service classes here.
 */
export type ProtobufAddedServices = {
    validation: {
        ProtobufValidator: ProtobufValidator
    }
}

/**
 * Union of Langium default services and your custom services - use this as constructor parameter
 * of custom service classes.
 */
export type ProtobufServices = LangiumServices & ProtobufAddedServices

/**
 * Dependency injection module that overrides Langium default services and contributes the
 * declared custom services. The Langium defaults can be partially specified to override only
 * selected services, while the custom services must be fully specified.
 */
export const ProtobufModule: Module<ProtobufServices, PartialLangiumServices & ProtobufAddedServices> = {
    validation: {
        ProtobufValidator: () => new ProtobufValidator(),
        DocumentValidator: () => new ProtobufDocumentValidaor(),
    },
};

/**
 * Create the full set of services required by Langium.
 *
 * First inject the shared services by merging two modules:
 *  - Langium default shared services
 *  - Services generated by langium-cli
 *
 * Then inject the language-specific services by merging three modules:
 *  - Langium default language-specific services
 *  - Services generated by langium-cli
 *  - Services specified in this file
 *
 * @param context Optional module context with the LSP connection
 * @returns An object wrapping the shared services and the language-specific services
 */
export function createProtobufServices(context: DefaultSharedModuleContext): {
    shared: LangiumSharedServices,
    Protobuf: ProtobufServices
} {
    const shared = inject(
        createDefaultSharedModule(context),
        ProtobufGeneratedSharedModule
    );
    const Protobuf = inject(
        createDefaultModule({ shared }),
        ProtobufGeneratedModule,
        ProtobufModule
    );
    shared.ServiceRegistry.register(Protobuf);
    registerValidationChecks(Protobuf);
    return { shared, Protobuf };
}
