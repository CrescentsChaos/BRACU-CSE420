%{
#include"symbol_info.h"
#include <bits/stdc++.h>   /* bring in iostream, fstream, etc. */

using namespace std;

#define YYSTYPE symbol_info*

int yyparse(void);
int yylex(void);
void yyerror(const char *);

extern FILE *yyin;


ofstream outlog;

int lines;

// declare any other variables or functions needed here

%}

%token IF ELSE FOR
%token ID LPAREN RPAREN COMMA LCURL RCURL SEMICOLON
%token INT FLOAT LTHIRD RTHIRD CONST_INT CONST_FLOAT
%token WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT INCOP DECOP
%token VOID DO SWITCH DEFAULT GOTO CHAR DOUBLE CASE CONTINUE BREAK COLON
%nonassoc LOWER_THAN_ELSE

%%

start : program
	{
		outlog << "At line no: " << lines << " start : program " << endl << endl;
		$$ = new symbol_info($1->getname(), "start");
	}
;
program : program unit
	{
		outlog << "At line no: " << lines << " program : program unit " << endl << endl;
		string code = $1->getname() + "\n" + $2->getname();
		outlog << code << endl << endl;
		$$ = new symbol_info(code, "program");
	}
	| unit
	{
		outlog << "At line no: " << lines << " program : unit " << endl << endl;
		outlog << $1->getname() << endl << endl;
		$$ = new symbol_info($1->getname(), "program");
	}
;
unit : var_declaration
| func_definition
;
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
	{
		outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " << endl << endl;
		string code = $1->getname() + " " + $2->getname() + "(" + $4->getname() + ")" + $6->getname();
		outlog << code << endl << endl;
		$$ = new symbol_info(code, "func_def");
	}
	| type_specifier ID LPAREN RPAREN compound_statement
	{
		outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN RPAREN compound_statement " << endl << endl;
		string code = $1->getname() + " " + $2->getname() + "()" + $5->getname();
		outlog << code << endl << endl;
		$$ = new symbol_info(code, "func_def");
	}
;
parameter_list : parameter_list COMMA type_specifier ID
{
		$$ = new symbol_info($1->getname() + "," + $3->getname() + " " + $4->getname(), "param");
	}
	| parameter_list COMMA type_specifier
	{
		$$ = new symbol_info($1->getname() + "," + $3->getname(), "param");
	}
	| type_specifier ID
	{
		$$ = new symbol_info($1->getname() + " " + $2->getname(), "param");
	}
	| type_specifier
	{
		$$ = new symbol_info($1->getname(), "param");
	}
;
compound_statement : LCURL statements RCURL
	{
		outlog << "At line no: " << lines << " compound_statement : LCURL statements RCURL " << endl << endl;
		string code = "{\n" + $2->getname() + "\n}";
		outlog << code << endl << endl;
		$$ = new symbol_info(code, "comp_stmt");
	}
	| LCURL RCURL
	{
		$$ = new symbol_info("{}", "comp_stmt");
	}
;
var_declaration : type_specifier declaration_list SEMICOLON
	{
        outlog << "At line no: " << lines << " var_declaration : type_specifier declaration_list SEMICOLON " << endl << endl;
        string code = $1->getname() + " " + $2->getname() + ";";
        outlog << code << endl << endl;
        $$ = new symbol_info(code, "var_dec");
    }
;
type_specifier : INT
    {
        outlog << "At line no: " << lines << " type_specifier : INT " << endl << endl;
        outlog << "int" << endl << endl;
        $$ = new symbol_info("int", "type");
    }
    | FLOAT
    {
        outlog << "At line no: " << lines << " type_specifier : FLOAT " << endl << endl;
        outlog << "float" << endl << endl;
        $$ = new symbol_info("float", "type");
    }
    ;
;
declaration_list : declaration_list COMMA ID
{
		$$ = new symbol_info($1->getname() + "," + $3->getname(), "decl_list");
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
	{
		$$ = new symbol_info($1->getname() + "," + $3->getname() + "[" + $5->getname() + "]", "decl_list");
	}
	| ID
	{
		$$ = new symbol_info($1->getname(), "decl_list");
	}
	| ID LTHIRD CONST_INT RTHIRD
	{
		$$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "decl_list");
	}
;
statements : statement
| statements statement
;
statement : var_declaration
| expression_statement
| compound_statement
| FOR LPAREN expression_statement expression_statement expression RPAREN
statement
{
		$$ = new symbol_info("for(" + $3->getname() + $4->getname() + $5->getname() + ")" + $7->getname(), "stmt");
	}
	| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	{
		$$ = new symbol_info("if(" + $3->getname() + ")" + $5->getname(), "stmt");
	}
	| IF LPAREN expression RPAREN statement ELSE statement
	{
		$$ = new symbol_info("if(" + $3->getname() + ")" + $5->getname() + "else" + $7->getname(), "stmt");
	}
	| WHILE LPAREN expression RPAREN statement
	{
		$$ = new symbol_info("while(" + $3->getname() + ")" + $5->getname(), "stmt");
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		$$ = new symbol_info("println(" + $3->getname() + ");", "stmt");
	}
	| RETURN expression SEMICOLON
	{
		$$ = new symbol_info("return " + $2->getname() + ";", "stmt");
	}
;
expression_statement : SEMICOLON
{
		$$ = new symbol_info(";", "expr_stmt");
	}
	| expression SEMICOLON
	{
		$$ = new symbol_info($1->getname() + ";", "expr_stmt");
	}
;
variable : ID
{
		$$ = new symbol_info($1->getname(), "var");
	}
	| ID LTHIRD expression RTHIRD
	{
		$$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "var");
	}
;
expression : logic_expression
| variable ASSIGNOP logic_expression {
		$$ = new symbol_info($1->getname() + "=" + $3->getname(), "expr");
	}
;
logic_expression : rel_expression
| rel_expression LOGICOP rel_expression {
		$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "logic_expr");
	}
;
rel_expression : simple_expression
| simple_expression RELOP simple_expression {
		$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "rel_expr");
	}
;
simple_expression : term
| simple_expression ADDOP term {
		$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "simple_expr");
	}
;
term : unary_expression
| term MULOP unary_expression {
		$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "term");
	}
;
unary_expression : ADDOP unary_expression
{
		$$ = new symbol_info($1->getname() + $2->getname(), "unary");
	}
	| NOT unary_expression
	{
		$$ = new symbol_info("!" + $2->getname(), "unary");
	}
| factor
;
factor : variable
| ID LPAREN argument_list RPAREN
{
		$$ = new symbol_info($1->getname() + "(" + $3->getname() + ")", "factor");
	}
	| LPAREN expression RPAREN
	{
		$$ = new symbol_info("(" + $2->getname() + ")", "factor");
	}
	| CONST_INT
	| CONST_FLOAT
	| variable INCOP
	{
		$$ = new symbol_info($1->getname() + "++", "factor");
	}
	| variable DECOP
	{
		$$ = new symbol_info($1->getname() + "--", "factor");
	}
;
argument_list : arguments
| { $$ = new symbol_info("", "arg_list"); }
;
arguments : arguments COMMA logic_expression {
		$$ = new symbol_info($1->getname() + "," + $3->getname(), "args");
	}
| logic_expression
;

%%
void yyerror(const char *s)
{
    outlog << "Error at line no " << lines << " : " << s << endl << endl;
}
int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
        printf("Usage: ./a.exe input1.txt\n");
        return 1;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("my_log.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
    
	yyparse();
	
	//print number of lines
	
	outlog.close();
	
	fclose(yyin);
	
	return 0;
}