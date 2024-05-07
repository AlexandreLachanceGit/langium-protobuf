import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { ProtobufAstType, Person } from './generated/ast.js';
import type { ProtobufServices } from './protobuf-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: ProtobufServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.ProtobufValidator;
    const checks: ValidationChecks<ProtobufAstType> = {
        Person: validator.checkPersonStartsWithCapital
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class ProtobufValidator {

    checkPersonStartsWithCapital(person: Person, accept: ValidationAcceptor): void {
        if (person.name) {
            const firstChar = person.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept('warning', 'Person name should start with a capital.', { node: person, property: 'name' });
            }
        }
    }

}
