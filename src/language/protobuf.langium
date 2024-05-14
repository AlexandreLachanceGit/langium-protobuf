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

Type:
    type=('double' | 'float' | 'int32' | 'int64' | 'uint32' | 'uint64'
      | 'sint32' | 'sint64' | 'fixed32' | 'fixed64' | 'sfixed32' | 'sfixed64'
      | 'bool' | 'string' | 'bytes') | (message=[Message:ID] | enum=[Enum:ID] | other=ID);

Syntax: 
    'syntax' '=' syntax=('"proto3"' | "\\'proto3\\'") ';'; // \\ needed to fix bug in langium code gen

Import: 
    'import' (weak?='weak' | public?='public')? path=STRING ';';

Constant: 
    value=(ID | INT | STRING | BOOL); //TODO

Option:
    'option' name=ID '=' value=Constant ';'; //TODO: Fix option name

Package: 
    'package' name=ID ';'; 

FieldNumber:
    value=INT;

FieldOption:
    name=ID '=' value=Constant;

FieldOptions:
    options+=FieldOption (',' options+=FieldOption);

NormalField:
    (repeated?='repeated')? type=Type name=ID '=' FieldNumber ('[' FieldOptions ']')? ';';

OneofField:
    type=Type name=ID '=' FieldNumber ('[' FieldOptions ']')? ';';

Oneof:
    'oneof' name=ID '{' (options+=Option | oneofFields+=OneofField)* '}';

KeyType: 
    type=(
        'int32' | 'int64' | 'uint32' | 'uint64' | 'sint32' | 'sint64' |
        'fixed32' | 'fixed64' | 'sfixed32' | 'sfixed64' | 'bool' | 'string'
    );

MapField:
    'map' '<' keyType=KeyType ',' type=Type '>' name=ID '=' FieldNumber ('[' FieldOptions ']')? ';';

Field: 
    NormalField | MapField;

Range:
    start=INT ('to' (end=INT | max?='max'))?;

Ranges:
    ranges+=Range (',' ranges+=Range)*;

StringList:
    strings+=STRING (',' strings+=STRING)*;

Reserved:
    'reserved' (Ranges | StringList) ';';

EnumField:
    name=ID '=' ('-')? FieldNumber ('[' FieldOptions ']')? ';';

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
    'rpc' name+=ID '(' stream?='stream' message=[Message:ID] ')'
    'returns' '(' stream?='stream' message=[Message:ID] ')'
    ( ('{' (options+=Option | ';')* '}') | ';')
    ;

Service:
    'service' name=ID '{'
        (';' | options+=Option | rpcs+=Rpc)*
    '}';

hidden terminal WS: /\s+/;
terminal ID: /[\._a-zA-Z][\w_\.]*/;
terminal INT returns number: /[0-9]+/;
terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;
terminal BOOL: "true" | "false";

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;