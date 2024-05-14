grammar Protobuf

entry Model:
    (syntax=Syntax)? 
    (
        empty+=';' 
        | packages=Package
        | imports+=Import
        | messages+=Message
        | enums+=Enum
        | options+=Option
        | services+=Service
    )*;

Syntax: 
    'syntax' '=' syntax=('"proto3"' | "\\'proto3\\'") ';'; // \\ needed to fix bug in langium code gen

Import: 
    'import' (weak?='weak' | public?='public')? path=STRING ';';

Constant: 
    value=(ID | SIGNED_INT | STRING | BOOL); //TODO

Option:
    'option' name=ID '=' value=Constant ';'; //TODO: Fix option name

Package: 
    'package' name=ID ';'; 

FieldOption:
    name=ID '=' value=Constant;

FieldOptions:
    options+=FieldOption (',' options+=FieldOption);

NormalField:
    (repeated?='repeated') 'a' type=ID name=ID '=' fieldNumber=INT ('[' FieldOptions ']')? ';';

OneofField:
    type=ID name=ID '=' fieldNumber=INT ('[' FieldOptions ']')? ';';

Oneof:
    'oneof' name=ID '{' (options+=Option | oneofFields+=OneofField)* '}';

KeyType: 
    type=(
        'int32' | 'int64' | 'uint32' | 'uint64' | 'sint32' | 'sint64' |
        'fixed32' | 'fixed64' | 'sfixed32' | 'sfixed64' | 'bool' | 'string'
    );

MapField:
    'map' '<' keyType=KeyType ',' type=ID '>' name=ID '=' fieldNumber=INT ('[' FieldOptions ']')? ';';

Field: 
    NormalField | OneofField | MapField;

Range:
    start=INT ('to' (end=INT | max?='max'))?;

Ranges:
    ranges+=Range (',' ranges+=Range)*;

StringList:
    strings+=STRING (',' strings+=STRING)*;

Reserved:
    'reserved' (Ranges | StringList) ';';

EnumField:
    name=ID '=' ('-')? Integer ('[' FieldOptions ']')? ';';

Enum:
    'enum' name=ID '{' 
        (';' | options+=Option | reserved+=Reserved | fields+=EnumField)*
    '}';

Message:
    'message' name=ID '{' 
        (
            ';' | fields+=Field | oneofs+=Oneof | messages+=Message | enums+=Enum
            | options+=Option | mapFields+=MapField | reserved+=Reserved
        )* 
    '}';

Rpc:
    'rpc' name+=ID '(' stream?='stream' messageType=ID ')'
    'returns' '(' stream?='stream' messageType=ID ')'
    ( ('{' (options+=Option | ';')* '}') | ';')
    ;

Service:
    'service' name=ID '{'
        (';' | options+=Option | rpcs+=Rpc)*
    '}';

Integer:
    value=INT;

hidden terminal WS: /\s+/;
terminal ID: /[\._a-zA-Z][\w_\.]*/;
terminal SIGNED_INT: ('+' | '-')? INT;
terminal INT returns number: /\d+/;
terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;
terminal BOOL: "true" | "false";

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;
