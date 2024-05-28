import { AstNode, DocumentValidator, LangiumDocument, ValidationOptions, type ValidationAcceptor, type ValidationChecks } from 'langium';
import { type ProtobufAstType, type EnumField, EnumBody } from './generated/ast.js';
import type { ProtobufServices } from './protobuf-module.js';
import { CancellationToken } from 'vscode-languageserver';
import { Diagnostic, Range, Position } from 'vscode-languageserver-types';
import { exec } from 'child_process';

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
                accept('warning', 'Enum field identifier should be ALL CAPS.', { node: enumField, property: 'name' })
            }
        }
    }
}

class Range_ implements Range {
    start: Position;
    end: Position;

    constructor(start: Position, end: Position) {
        this.start = start;
        this.end = end;
    }
}

class Pos implements Position {
    line: number;
    character: number;

    constructor(line: number, character: number) {
        this.line = line;
        this.character = character;
    }
}

interface JsonDiagnostic {
    message: string;
    startLine: number;
    endLine: number;
    startCol: number;
    endCol: number;
}

interface Result {
    diagnostics: JsonDiagnostic[];
}

const command = '/home/alex/Documents/University/Master/langium/langium-protobuf/external_tools/test_tool.py ';

export class ProtobufDocumentValidaor implements DocumentValidator {
    validateDocument(document: LangiumDocument<AstNode>, options?: ValidationOptions | undefined, cancelToken?: CancellationToken | undefined): Promise<Diagnostic[]> {
        return new Promise((resolve, reject) => {
            let diagnostics: Diagnostic[] = [];

            exec(command + document.uri.path, (error, stdout, stderr) => {
                if (error) {
                    return reject(error);
                }

                try {
                    let result: Result = JSON.parse(stdout);
                    diagnostics.push(Diagnostic.create(new Range_(new Pos(0, 0), new Pos(0, 10)), stdout));

                    for (var diag of result.diagnostics) {
                        let range = new Range_(
                            new Pos(diag.startLine, diag.startCol),
                            new Pos(diag.endLine, diag.endCol)
                        );

                        diagnostics.push(Diagnostic.create(range, diag.message));
                    }

                    resolve(diagnostics)

                } catch(error) {
                    reject(error)
                }
           });
        })
    }
}
