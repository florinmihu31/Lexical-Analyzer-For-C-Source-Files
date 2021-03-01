%{
	// Mihu Florin 334CC
	#include <stdio.h>
	#include <stdlib.h>

	char* type_name; // Buffer pentru numele tipului
	char* function_name; // Buffer pentru numele functiei
	char local_variables[100]; // Buffer pentru variabile locale
	unsigned int local_variables_no = 0; // Numarul variabilelor locale
%}

%option stack

signedType "signed"|"unsigned"
dataType "char"|"short"|"short int"|"int"|"long"|"long int"|"long long"|"long long int"
variableType ({signedType}\ )?{dataType}|{signedType}
returnType {variableType}|"void"
functionName [_a-zA-Z][_a-zA-Z0-9]*
variableName [_a-zA-Z][_a-zA-Z0-9]*(\[[_a-zA-Z0-9]*\])*

%s ARGUMENTS
%s DECLARATION
%s FUNCTION
%s VARIABLE_NAME
%s VARIABLE_ASSIGNMENT
%s ARRAY_ASSIGNMENT
%s STRING_ASSIGNMENT
%s LINE_COMMENT
%s BLOCK_COMMENT
%s INCLUDE
%s DEFINE
%s IF_MACRO

%%
<INITIAL>{returnType}(\ )+ {
	/*
	 * Daca gasesc un tip pe care il poate returna o functie, intru in starea 
	 * DECLARATION pentru a gasi un nume de functie
	 */
	BEGIN(DECLARATION);
	type_name = malloc(yyleng + 1);

	// Retin in variabila type_name ce am in yytext
	strcpy(type_name, yytext);
}
<INITIAL>"//"  { yy_push_state(LINE_COMMENT); }
<INITIAL>"/*" { yy_push_state(BLOCK_COMMENT); }
<INITIAL>"#include" { yy_push_state(INCLUDE); }
<INITIAL>"#define" { yy_push_state(DEFINE); }
<INITIAL>"#if"[a-z]* { yy_push_state(IF_MACRO); }

<DECLARATION>{functionName}(\ )*\( {
	/* 
	 * Daca am gasit in starea DECLARATION un nume de functie urmat de o 
	 * paranteza deschisa, atunci trec in starea ARGUMENTS pentru a citi 
	 * argumentele functiei
	 */
	BEGIN(ARGUMENTS);
	function_name = malloc(yyleng - 1);
	yyless(yyleng - 1);

	// Retin in variabila function_name ce am in yytext
	strcpy(function_name, yytext);
}
<DECLARATION>{variableName}[,;] {
	/*
	 * Daca gasesc un nume de variabila urmata de ',' sau ';', revin in starea 
	 * INITIAL 
	 */
	BEGIN(INITIAL);
}

<ARGUMENTS>\) {
	// Daca am citit caracterul ')', trec in starea FUNCTION
	BEGIN(FUNCTION);
	yyless(yyleng - 1);

	// Afisez semnatura functiei, tipul intors si numele
	printf("%s%s(%s)", type_name, function_name, yytext);
	printf("\n\tTip intors: %s", type_name);
	printf("\n\tNume: %s\n", function_name);
}
<ARGUMENTS>\, { 
	// Daca citesc ',', continui cu ajutorul functiei yymore
	yymore();
}
<ARGUMENTS>{variableType}(\ )+{variableName} {
	/*
	 * Daca citesc un tip si un nume de variabila, continui cu ajutorul 
	 * functiei yymore
	 */
	yymore();
}
<ARGUMENTS>\  {
	// Daca citesc ' ', continui cu ajutorul functiei yymore
	yymore();
}

<FUNCTION>\{ ;
<FUNCTION>{variableType}(\ )+ {
	// Daca gasesc un tip de variabila, pun pe stiva starea VARIABLE_NAME
	yymore();
	yy_push_state(VARIABLE_NAME);
}
<FUNCTION>\} {
	// Daca se termina functia (caracterul '}'), trec in starea INITIAL
	BEGIN(INITIAL);

	// Afisez variabilele locale
	printf("\tVariabile locale: %d (%s)\n", local_variables_no, local_variables);

	// "Sterg" bufferul in care am retinut variabilele locale
	strcpy(local_variables, "");

	// Resetez numarul variabilelor locale			
	local_variables_no = 0;
}
<FUNCTION>"//" { yy_push_state(LINE_COMMENT); }
<FUNCTION>"/*" { yy_push_state(BLOCK_COMMENT); }
<FUNCTION>"#include" { yy_push_state(INCLUDE); }
<FUNCTION>"#define" { yy_push_state(DEFINE); }
<FUNCTION>"#if"[a-z]* { yy_push_state(IF_MACRO); }

<VARIABLE_NAME>(\ )*{variableName}(\ )*, {
	/*
	 * Daca gasesc un nume de variabila urmat de ',', cresc numarul de 
	 * variabile locale
	 */ 
	yymore();
	local_variables_no++;
}
<VARIABLE_NAME>(\ )*{variableName}(\ )*= {
	/*
	 * Daca gasesc un nume de variabila urmat de ',', cresc numarul de 
	 * variabile locale si intru in starea VARIABLE_ASSIGNMENT
	 */
	yy_push_state(VARIABLE_ASSIGNMENT);
	
	// "Sterg" caracterul '=' cu ajutorul functiei yyless
	yyless(yyleng - 1);
	yymore();
	local_variables_no++;

	// Retin in local_variables valoarea din yytext
	strcat(local_variables, yytext);
}
<VARIABLE_NAME>(\ )*{variableName}(\ )*; {
	/*
	 * Daca gasesc un nume de variabila urmat de ';', cresc numarul de 
	 * variabile locale
	 */
	local_variables_no++;

	// Retin in local_variables valoarea din yytext
	strcat(local_variables, yytext);

	// Scot starea de pe stiva
	yy_pop_state();
}
<VARIABLE_NAME>;|\n { 
	// Scot starea de pe stiva
	yy_pop_state(); 
}

<VARIABLE_ASSIGNMENT>\{ {
	// Daca am declarat un vector static, intru in starea ARRAY_ASSIGNMENT 
	yy_push_state(ARRAY_ASSIGNMENT);
}
<VARIABLE_ASSIGNMENT>\" {
	// Daca am declarat un sir static, intru in starea STRING_ASSIGNMENT 
	yy_push_state(STRING_ASSIGNMENT);
}
<VARIABLE_ASSIGNMENT>, {
	// Daca citesc ',', scot starea VARIABLE_ASSIGNMENT de pe stiva
	yy_pop_state();

	// Adaug in buffer ','
	strcat(local_variables, ",");
}
<VARIABLE_ASSIGNMENT>; {
	// Daca citesc ';', scot starea VARIABLE_ASSIGNMENT de pe stiva
	yy_pop_state();

	// Adaug in buffer ';'
	strcat(local_variables, ";");
}

<ARRAY_ASSIGNMENT>\} { yy_pop_state(); }
<STRING_ASSIGNMENT>\" { yy_pop_state(); }

<LINE_COMMENT>\n { yy_pop_state(); }
<BLOCK_COMMENT>"*/" { yy_pop_state(); }
<INCLUDE>\n { yy_pop_state(); }
<DEFINE>\n { yy_pop_state(); }
<IF_MACRO>"#endif\n" { yy_pop_state(); }

.|\n ;
%%

char** files; // Lista de fisiere
unsigned int crtFileNo = 0; // Numarul fisierului curent
unsigned int filesNo; // Numarul total de fisiere

int yywrap(void) {
	FILE* crtFile = NULL;

	fclose(yyin);

	printf("End of file number %d\n\n", crtFileNo);
	crtFileNo++;

	// Daca numarul fisierului este egal cu numarul total, opresc citirea
	if (crtFileNo >= filesNo) {
		return 1;
	}

	// Deschid urmatorul fisier
	crtFile = fopen(files[crtFileNo], "r");

	if (!crtFile) {
		printf("Error reading file!");
		exit(1);
	}

	yyin = crtFile;

	return (crtFile ? 0 : 1);
}

int main(int argc, char** argv) {
	FILE* crtFile;
	files = argv + 1;
	filesNo = argc - 1;

	// Citesc primul fisier daca am argumente
	if (argc > 1) {
		crtFileNo = 0;
		crtFile = fopen(files[crtFileNo], "r");

		if (!crtFile) {
			printf("Error reading file!");
			exit(1);
		}

		yyin = crtFile;
	}
	
	yylex();

	return 0;
}