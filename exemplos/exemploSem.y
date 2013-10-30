	
%{
  import java.io.*;
%}


%token IDENT, INT, FLOAT, BOOL, NUM, STRING
%token LITERAL, AND, VOID, MAIN, IF
%token STRUCT

%nonassoc '>'
%left '+'
%left AND
%left '['  

%type <sval> IDENT
%type <ival> NUM
%type <ival> type
%type <ival> exp

%%

prog : { currEscopo = ""; currClass = ClasseID.VarGlobal; } dList main ;

dList : decl dList | ;

decl : declStruct 

      | type IDENT ';' {  TS_entry nodo = ts.pesquisa($2);
    	                if (nodo != null) 
                            yyerror("(sem) variavel >" + $2 + "< jah declarada");
                        else ts.insert(new TS_entry($2, $1, currEscopo, currClass)); }
      | type '[' NUM ']' IDENT  ';' {  TS_entry nodo = ts.pesquisa($5);
    	                if (nodo != null) 
                            yyerror("(sem) variavel >" + $5 + "< jah declarada");
                    else ts.insert(new TS_entry($5, ARRAY, $3, $1, currEscopo, currClass)); 
                     }
      ;
              
declStruct : STRUCT IDENT  {  TS_entry nodo = ts.pesquisa($2);
    	                      if (nodo != null) 
                                 yyerror("(sem) variavel >" + $2 + "< jah declarada");
                               else ts.insert(new TS_entry($2, -1, currEscopo, ClasseID.NomeStruct));
 currEscopo = $2; currClass = ClasseID.CampoStruct; }
               
               '{' dList '}'
                { currEscopo = ""; currClass = ClasseID.VarGlobal; }
                ';'
             ;

type : INT    { $$ = INT; }
     | FLOAT  { $$ = FLOAT; }
     | BOOL   { $$ = BOOL; }
	 | STRING { $$ = LITERAL; }
     ;

main :  VOID MAIN '(' ')' bloco ;

bloco : '{' listacmd '}';

listacmd : listacmd cmd
		|
 		;

cmd : IDENT '=' exp ';'  { TS_entry nodo = ts.pesquisa($1);
    	                if (nodo == null) 
                           yyerror("(sem) variavel >" + $1 + "< nao declarada");
                        else 
                            if (nodo.getTipo() != $3)                
                               yyerror("tipos diferentes na atribuição: "+nodo.getTipo() + " = " + $3);
                     } 
      | IF '(' exp ')' cmd 
                   {if ( $3 != BOOL) 
                           yyerror("(sem) expressão (if) deve ser lógica "+$3);
                     }     


;


exp : exp '+' exp { if ($1 == INT && $3 == INT)
                         $$ = INT;
                    else if ( ($1 == FLOAT && ($3 == INT || $3 == FLOAT)) ||
						      ($3 == FLOAT && ($1 == INT || $1 == FLOAT)) ) 
                         $$ = FLOAT;
                    else if ($1==STRING || $3==STRING)
                        $$ = STRING;
                    else
                        yyerror("(sem) tipos incomp. para soma: "+ $1 + " + "+$3);
                   }
   	|  exp '>' exp { if (($1 == INT || $1 == FLOAT) && ($3 == INT || $3 == FLOAT))
                         $$ = BOOL;
					 else
                        yyerror("(sem) tipos incomp. para op relacional: "+ $1 + " > "+$3);
					}
 	|  exp AND exp { if ($1 == BOOL && $3 == BOOL)
                         $$ = BOOL;
					 else
                        yyerror("(sem) tipos incomp. para op lógica: "+ $1 + " && "+$3);
                   } 
    | NUM  { $$ = INT; }      
    | '(' exp ')' { $$ = $2; }
    | LITERAL  { $$ = STRING; }      
    | IDENT   { TS_entry nodo = ts.pesquisa($1);
    	     if (nodo == null) 
	        yyerror("(sem) var <" + $1 + "> nao declarada");                
             else
			   $$ = nodo.getTipo();
			}   
    | IDENT '[' exp ']'     { if ($3 != INT)
                    	        yyerror("(sem) expressão indexadora deve ser inteira: " + $3);                
                            else {
                                  TS_entry nodo = ts.pesquisa($1);
    	                          if (nodo == null) 
	                                 yyerror("(sem) var <" + $1 + "> nao declarada");                
                             else
			                      if (nodo.getTipo() != ARRAY)
	                                 yyerror("(sem) var <" + $1 + "> nao é do tipo array");                
								  else 
									$$ = nodo.getTipoBase();
								}
						}
    ;

%%

  private Yylex lexer;

  private TabSimb ts = new TabSimb();

  public static final int ARRAY = 1500;

  private String currEscopo;
  private ClasseID currClass;

  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }


  public void yyerror (String error) {
    System.err.println ("Error: " + error + "  linha: " + lexer.getLine());
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }  

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}

  public static void main(String args[]) throws IOException {
    System.out.println("\n\nVerificador semantico simples\n");

    Parser yyparser;
    if ( args.length > 0 ) {
      // parse a file
      yyparser = new Parser(new FileReader(args[0]));
    }
    else {
      // interactive mode
      System.out.println("[Quit with CTRL-D]");
      System.out.print("Programa de entrada:\n");
	  yyparser = new Parser(new InputStreamReader(System.in));
    }

    yyparser.yyparse();

	yyparser.listarTS();

	  System.out.print("\n\nFeito!\n");
    
  }
