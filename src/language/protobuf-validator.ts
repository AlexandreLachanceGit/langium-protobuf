import type { ValidationAcceptor, ValidationChecks } from 'langium';
import { type ProtobufAstType, type EnumField, EnumBody } from './generated/ast.js';
import type { ProtobufServices } from './protobuf-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: ProtobufServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.ProtobufValidator;
    const checks: ValidationChecks<ProtobufAstType> = {
        EnumField: validator.checkEnumFieldIdIsAllCaps
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class ProtobufValidator {
    checkEnumFieldIdIsAllCaps(enumField: EnumField, accept: ValidationAcceptor): void {
        if (enumField.name && enumField.name != enumField.name.toUpperCase()) {
            if (enumField.$container?.$type == EnumBody) { // necessary because of bug?
                accept('warning', 'Enum field identifier should be ALL CAPS.',  {node: enumField, property: 'name'})
            }
        }
    }
}
