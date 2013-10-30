%{
  /**
   * This is the syntactic specification for the ZSharp Language.
   * The language specification is available at:
   * Description about the language avaliable at:
   *   http://dotnet.jku.at/courses/CC/
   *
   * @author Italo Lobato Qualisoni - 12104861-5 - <italo.qualisoni@acad.pucrs.br>
   * @author William Henrihque Martins - 12104965-4 - <william.henrihque@acad.pucrs.br>
   */
  import java.io.*;
%}

%token EQEQ DIF GT GTE LT LTE 
%token ADDITIVESUM ADDITIVESUB LOGICALAND LOGICALOR CHARCONST
%token IF BREAK CONST ELSE CLASS NEW READ WRITE VOID WHILE RETURN
%token IDENT NUMBER 

%left LOGICALOR
%left LOGICALAND
%nonassoc  GTE EQEQ DIF LTE  '>' '<'
%left '+' '-'
%left '*' '/' '%'  
%left NEG    

%%

Program    : CLASS IDENT ListDecl '{' ListMethodsDecl '}'
           ;

ListDecl   : ConstDecl ListDecl
	   | VarDecl ListDecl
	   | ClassDecl ListDecl
	   |;
	
ConstDecl  : CONST Type IDENT '=' NUMBER ';'
	   | CONST Type IDENT '=' CHARCONST';'
	   ;

VarDecl    : Type IDENT ListIDENT ';';

ListIDENT  : ',' IDENT ListIDENT
	   |
	   ;

ClassDecl  : CLASS IDENT '{' ListVarDecl '}';

ListVarDecl: VarDecl ListVarDecl
           | 
           ;
MethodDecl : Type IDENT '(' ')' ListVarDecl Block
           | VOID IDENT '(' ')' ListVarDecl Block
           | Type IDENT '(' FormPars ')' ListVarDecl Block
           | VOID IDENT '(' FormPars ')' ListVarDecl Block
           ;
ListMethodsDecl: MethodDecl ListMethodsDecl 
           | 
	   ;

FormPars   : Type IDENT
           | Type IDENT ',' FormPars
           ;


Type       : IDENT 
           | IDENT '[' ']'
           ;

Statment   : Designator '=' Expr ';'
	   | Designator '(' ')' ';' 
	   | Designator '(' ActPars ')' ';' 
	   | Designator ADDITIVESUM ';'
	   | Designator ADDITIVESUB ';'
	   | IF '(' Expr ')' Statment 
	   | IF '(' Expr ')' Statment ELSE Statment
	   | WHILE '(' Expr ')' Statment 
     | BREAK ';'
	   | RETURN Expr ';'
	   | RETURN ';'
	   | READ  '(' Designator ')' ';'
	   | WRITE '(' Expr ')' ';'
	   | WRITE '(' Expr ',' NUMBER  ')' ';'
	   | Block
	   | ';' 
	   ;

ListStatment : Statment ListStatment
             |
             ;

Block        : '{' ListStatment '}'
             ;

ActPars      : Expr ListExpr
             ;
             
ListExpr     : ',' Expr ListExpr
             |
             ;

Expr         : Expr LOGICALOR Expr 
             | Expr  LOGICALAND Expr  
             | Expr  GTE  Expr 
             | Expr  EQEQ Expr 
             | Expr  DIF  Expr 
             | Expr  LTE  Expr 
             | Expr  '>'  Expr 
             | Expr  '<'  Expr 
             | Expr  '+'  Expr 
             | Expr  '-'  Expr 
             | '-' Expr  %prec NEG
             | Expr  '*'  Expr 
             | Expr  '/'  Expr 
             | Expr  '%'  Expr 
             | Designator
             | Designator '(' ')'
             | Designator '(' ActPars ')'
             | NUMBER
             | CHARCONST
             | NEW IDENT
             | NEW IDENT '[' Expr ']'
             | '(' Expr ')'
             ;

Designator   : IDENT ListIdentExpr
             ;
             
ListIdentExpr: '.' IDENT ListIdentExpr
             | '[' Expr ']' ListIdentExpr
             |
             ;
     

%%

  private Yylex lexer;


  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e.getMessage());
    }
    return yyl_return;
  }


  public void yyerror (String error) {
    System.err.println ("Error: " + error);
    System.err.println ("Line: " + lexer.getLine());
    System.err.println ("Column: " + lexer.getColumn());
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }


  static boolean interactive;

  public static void main(String args[]) throws IOException {
    System.out.println("");

    Parser yyparser;
    if ( args.length > 0 ) {
      // parse a file {
      // interactive mode
      interactive = true;
      yyparser = new Parser(new FileReader(args[0]));
    }
    else {
      // interactive mode
      System.out.println("[Quit with CTRL-D]");
      System.out.print("> ");
      interactive = true;
	    yyparser = new Parser(new InputStreamReader(System.in));
    }

    yyparser.yyparse();
    
    if (interactive) {
      System.out.print("\ndone!");
    }
  }

