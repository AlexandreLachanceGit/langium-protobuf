grammar Protobuf

entry Model:
    (
        empty+=';' 
        | syntax+=Syntax 
        | packages+=Package
    )*;

Syntax: 'syntax' '=' syntax=STRING ';';

Package: 'package' name=ID ';';

hidden terminal WS: /\s+/;
terminal ID: /[_a-zA-Z][\w_]*/;
terminal SIGNED_INT: ('+' | '-') INT;
terminal INT returns number: /[0-9]+/;
terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;
terminal BOOL: "true" | "false";

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;
