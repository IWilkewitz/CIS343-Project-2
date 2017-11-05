%{
	#include <stdio.h>
	#include "zoomjoystrong.h"
	int yylex(); // this statement removes an implicit warning found in the .tab.h file
	int yyerror(char* s);

	void checkConstraints(int x, int y);
	void checkRGBConstraints(int r, int g, int b);
	void checkRecConstraints(int x, int y, int w, int h);
	void checkCircleConstraints(int x, int y, int r);
%}

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
%token ERR

%%
program:	statement_list END END_STATEMENT;
statement_list: statement
	      | statement statement_list;

statement:	point
	 |	line
	 |	circle
	 |	rectangle
	 |      set_color
	 |	err
	 ;

	point:
	POINT
	INT
	INT
	END_STATEMENT
	{ checkConstraints($2, $3); point($2, $3); }

	line:
	LINE
	INT
	INT
	INT
	INT
	END_STATEMENT
	{ checkConstraints($2, $3); checkConstraints($4, $5); line($2, $3, $4, $5); }

	circle:
	CIRCLE
	INT
	INT
	INT
	END_STATEMENT
	{ checkCircleConstraints($2, $3, $4); circle($2, $3, $4); }

	rectangle:
	RECTANGLE
	INT
	INT
	INT
	INT
	END_STATEMENT
	{ checkRecConstraints($2, $3, $4, $5); rectangle($2, $3, $4, $5); }

	set_color:
	SET_COLOR
	INT
	INT
	INT
	END_STATEMENT
	{ checkRGBConstraints($2, $3, $4); set_color($2, $3, $4); }

	err:
	ERR
	{ }
%%

int main(int argc, char** argv) {
	if (argc != 3) {
		printf("Error, must specify a filename: %i\n", argc);
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
int yyerror(char* s) {
	fprintf(stderr, "%s\n", s);
}

/*****************************************************************
This method checks the x and y coordinates of a point to make sure
it does not exceed the size of the screen.
*****************************************************************/
void checkConstraints(int x, int y) {
	if (x > WIDTH || y > HEIGHT) {
		yyerror("Error, parameters exceed screen size!");
	}
	return;
}

/*****************************************************************
This method checks to make sure that each rgb value does not
exceed 255.
*****************************************************************/
void checkRGBConstraints(int r, int b, int g) {
	if (r > 255 || b > 255 || g > 255) {
		yyerror("Error, rgb value(s) exceeds the limit of 255!");
	}
	return;
}

/*****************************************************************
This method checks the parameters for a rectangle to make sure
it is not drawn off the screen.
*****************************************************************/
void checkRecConstraints(int x, int y, int w, int h) {
	if ((x + w) > WIDTH || (y + h) > HEIGHT) {
		yyerror("Error, rectangle exceeds screen size!");
	}
}

/*****************************************************************
This method checks the x and y coordinates of a circle and checks
that the diameter does not exceed the screen size.
*****************************************************************/
void checkCircleConstraints(int x, int y, int r) {
	int diameter = r * 2;
	
	if (x > WIDTH || y > HEIGHT) {
		yyerror("Error, the center of the circle exceeds screen size!");
	}
	if (diameter > WIDTH || diameter > HEIGHT) {
		yyerror("Error, circle exceeds screen size!");
	}
	return;
}

