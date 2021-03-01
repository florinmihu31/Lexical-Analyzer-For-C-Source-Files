	Mihu Florin - 334CC
	Tema C - LFA

	Reguli:
	In primul rand, am definit reguli pentru tipul unei variabile sau a valorii 
intoarse de functie (variableType si returnType). De asemenea, am definit 
reguli pentru nume de functii si de variabile. Un nume de functie trebuie sa 
inceapa cu '_' sau cu o litera, apoi poate avea oricate litere sau cifre. O 
variabila poate avea in plus la final si caractarele '[' si ']', daca este un 
vector.

	Stari:
	Am definit starile urmatoare:
	- ARGUMENTS = citirea argumentelor functiei;
	- DECLARATION = declararea unei functii sau variabile globale;
	- FUNCTION = interiorul unei functii;
	- VARIABLE_NAME = numele unei variabile locale;
	- VARIABLE_ASSIGNMENT = atribuirea unei valori unei variabile locale;
	- ARRAY_ASSIGNMENT = atribuirea unui vector static;
	- STRING_ASSIGNMENT = atribuirea unui sir de caractere;
	- LINE_COMMENT = comentariu pe o linie;
	- BLOCK_COMMENT = comentariu bloc;
	- INCLUDE = directiva preprocesor #include;
	- DEFINE = directiva preprocesor #define;
	- IF_MACRO = directive preprocesor care incep cu #if (#if, #ifndef etc.).

	Logica de functionare:
	Se incepe in starea INITIAL. Daca se gaseste un comentariu sau o directiva 
preprocesor se intra in starea specifica, altfel, daca se gaseste un tip de 
date, se intra in starea DECLARATION. In starea DECLARATION, daca am un numen 
de functie, urmat de '(' trec in ARGUMENTS, salvand tipul si numele functiei, 
altfel, se intoarce in INITIAL. Citesc tipuri si nume de variabila, separate 
prin virgula pana cand intalnesc caracterul ')'. In acel moment, afisez pe 
ecran semnatura functiei si trec in starea FUNCTION. Daca gasesc comentarii sau 
directive preprocesor, trec in starile specifice, altfel daca gasesc un tip de 
variabila, pun pe stiva starea VARIABLE_NAME. In aceasta stare, citesc nume de 
variabile urmate de ',', '=' sau ';' si le numar. Daca am la final ',' citesc 
in continuare, daca am '=', citesc doar pana la egal si trec in starea 
VARIABLE_ASSIGNMENT, unde pot avea declarari de vectori(ARRAY_ASSIGNMENT) sau 
de siruri(STRING_ASSIGNMENT). Daca citesc ';', afisez ce am in bufferul de 
variabile locale si scot starea de pe stiva. Orice alt caracter ce nu se 
potriveste pe nicio regula este ignorat.

	Rulare Makefile:
	Comanda "make"("make build") compileaza fisierul ".l", apoi cel ".c", 
generandu-se executabilul exec.
	Pentru a rula executabilul cu parametrii cele trei fisiere din arhiva
(input0.in, input1.in si input2.in) se foloseste comanda "make run".
	Pentru stergerea executabilului, se va utiliza "make clean".

	Observatie: Este posibil ca la crearea fisierului ".c" sa dispara 
comentariul cu numele, prenumele si grupa.
