%{
	#include <stdio.h>
	#include "zoomjoystrong.h"
	#include <unistd.h>
	int yylex(); // this statement removes an implicit warning found in the .tab.h file
	int yyerror(const char* s);

	int checkConstraints(int x, int y);
	int checkRGBConstraints(int r, int g, int b);
	int checkRecConstraints(int x, int y, int w, int h);
	int checkCircleConstraints(int x, int y, int r);
%}

%error-verbose

%union {
	int iVal;
	float fVal;
	char* sVal;
}

%token <iVal> INT
%token <fVal> FLOAT
%token <sVal> VAR

%token END
%token END_STATEMENT
%token POINT
%token LINE
%token CIRCLE
%token RECTANGLE
%token SET_COLOR

%%
program:	statement_list END END_STATEMENT;
statement_list: statement
	      | statement statement_list;

statement:	point
	 |	line
	 |	circle
	 |	rectangle
	 |      set_color
	 |      error { yyerrok; yyclearin; }
	 ;
	
	point:
	POINT
	INT
	INT
	END_STATEMENT
	{ if (checkConstraints($2, $3) == 0) { point($2, $3); } }

	line:
	LINE
	INT
	INT
	INT
	INT
	END_STATEMENT
	{ if (checkConstraints($2, $3) == 0 && checkConstraints($4, $5) == 0) { line($2, $3, $4, $5); } }

	circle:
	CIRCLE
	INT
	INT
	INT
	END_STATEMENT
	{ if (checkCircleConstraints($2, $3, $4) == 0) { circle($2, $3, $4); } } 

	rectangle:
	RECTANGLE
	INT
	INT
	INT
	INT
	END_STATEMENT
	{ if (checkRecConstraints($2, $3, $4, $5) == 0) { rectangle($2, $3, $4, $5); } }

	set_color:
	SET_COLOR
	INT
	INT
	INT
	END_STATEMENT
	{ if (checkRGBConstraints($2, $3, $4) == 0) { set_color($2, $3, $4); } }
%%

int main(int argc, char** argv) {
	if (isatty(STDIN_FILENO)) {
		fprintf(stderr, "Error! missing input command file!\n");
		return 1;
	}
	setup();
	yyparse();
	finish();
	return 0;
}

/*****************************************************************
This method alerts the user when their parameters are not within 
a valid range.
*****************************************************************/
int yyerror(const char* s) {
	fprintf(stderr, "%s\n", s);
}

/*****************************************************************
This method checks the x and y coordinates of a point to make sure
it does not exceed the size of the screen.
*****************************************************************/
int checkConstraints(int x, int y) {
	if (x > WIDTH || y > HEIGHT) {
		yyerror("Error, parameters exceed screen size!");
		return 1;
	}
	return 0;
}

/*****************************************************************
This method checks to make sure that each rgb value does not
exceed 255.
*****************************************************************/
int checkRGBConstraints(int r, int b, int g) {
	if (r > 255 || b > 255 || g > 255) {
		yyerror("Error, rgb value(s) exceeds the limit of 255!");
		return 1;
	}
	return 0;
}

/*****************************************************************
This method checks the parameters for a rectangle to make sure
it is not drawn off the screen.
*****************************************************************/
int checkRecConstraints(int x, int y, int w, int h) {
	if ((x + w) > WIDTH || (y + h) > HEIGHT) {
		yyerror("Error, rectangle exceeds screen size!");
		return 1;
	}
	return 0;
}

/*****************************************************************
This method checks the x and y coordinates of a circle and checks
that the diameter does not exceed the screen size.
*****************************************************************/
int checkCircleConstraints(int x, int y, int r) {
	int diameter = r * 2;
	
	if (x > WIDTH || y > HEIGHT) {
		yyerror("Error, the center of the circle exceeds screen size!");
		return 1;
	}
	if (diameter > WIDTH || diameter > HEIGHT) {
		yyerror("Error, circle exceeds screen size!");
		return 1;
	}
	return 0;
}

