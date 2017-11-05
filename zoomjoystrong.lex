%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "zoomjoystrong.tab.h"
%}

%option noyywrap

%%
[[:space:]]+
[0-9]*\.[0-9]+ { yylval.fVal = atof(yytext); return FLOAT; }
^end    { return END; }
[;$]	{ return END_STATEMENT; }
[0-9]+  { yylval.iVal = atoi(yytext); return INT; }
^point  { return POINT; }
^line   { return LINE; }
^circle { return CIRCLE; }
^rectangle { return RECTANGLE; }
^set_color { return SET_COLOR; }
^-?\d+  { return ERR; }
%%

