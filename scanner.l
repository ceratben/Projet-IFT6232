;;; File: "scanner.l"

sign   [-+]
digit  [0-9]
letter [a-zA-Z]
other  [_*/$!@<=>%]
ident  ({sign}|({letter}|{other})({letter}|{other}|{sign}|{digit})*)
text   [^"]*

%%

[ \n]+           (yycontinue)
"#"[tf]          (cons 'BOOL (string->symbol yytext))
{sign}?{digit}+  (cons 'INTEGER (string->number yytext))
\"{text}\"       (cons 'STRING yytext)
"'"{ident}       (cons 'SYM (string->symbol yytext))
"'("{text}")"    (cons 'LIST_SYM (string->symbol yytext))
{ident}          (cons 'IDENT   (string->symbol yytext))
"("              (cons '|(|     #f)
")"              (cons '|)|     #f)
<<EOF>>          (cons '*eoi*   #f)
<<ERROR>>        (error "invalid token")
