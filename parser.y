%{

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#define ID_SIZE 100
#define MAX_CHILDREN 3

int yylex();

struct Node;
struct Node* globaltree;
int yywrap( );
void yyerror(const char* str);

/* the result variable */
double result = 0;

struct Node* make_node(int type, double value, char* id);
void attach_node(struct Node* parent, struct Node* child);
void print_tree(struct Node* node, int tabs);


%}


/*	bison definitions	*/

/* declare type possibilities of symbols */
%union {
    char Id[100];
    double value;
    struct Node* nodetree;

}





/* declare tokens (default is typeless) */
%token <Id> Identifier
%token <value> VAL
%token PLUS
%token MINUS
%token DIVIDE
%token TIMES
%token LESS
%token GREATER
%token LESSEQ
%token GREATEREQ
%token EQUALS
%token NEQUALS
%token AND
%token OR
%token NOT
%token SEMICOLON
%token COLONEQUAL
%token Kbegin
%token END
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO
%token PRINT
%token INPUT
%token STATEMENT
%token LEFT
%token RIGHT
%token ASSIGN





/* declare non-terminals */
%type <nodetree> stmts stmt factor whilestmt ifstmt ifelsestmt notexp orexp andexp relatexp
%type <nodetree> plusminusexp multdivexp printstmt beginendstmt assignmentstmt

/* give us more detailed errors */
%error-verbose

%%


/* one expression only followed by a new line */
/* start statement */
program: stmts {globaltree = $1; return 0;}




/* 	grammar rules		*/



orexp: orexp OR andexp {
  $$ = make_node(OR, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| andexp{$$ = $1;}

andexp: andexp AND relatexp {
  $$ = make_node(AND, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| relatexp{$$ = $1;}

relatexp: relatexp NEQUALS plusminusexp {
  $$ = make_node(NEQUALS, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| plusminusexp{$$ = $1;}

relatexp: relatexp EQUALS plusminusexp {
  $$ = make_node(EQUALS, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| plusminusexp{$$ = $1;}

relatexp: relatexp GREATEREQ plusminusexp {
  $$ = make_node(GREATEREQ, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| plusminusexp{$$ = $1;}

relatexp: relatexp GREATER plusminusexp {
  $$ = make_node(GREATER, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| plusminusexp{$$ = $1;}

relatexp: relatexp LESSEQ plusminusexp {
  $$ = make_node(LESSEQ, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| plusminusexp{$$ = $1;}

relatexp: relatexp LESS plusminusexp {
  $$ = make_node(LESS, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| plusminusexp{$$ = $1;}

plusminusexp: plusminusexp MINUS multdivexp {
  $$ = make_node(MINUS, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| multdivexp{$$ = $1;}
  
plusminusexp: plusminusexp PLUS multdivexp {
  $$ = make_node(PLUS, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| multdivexp{$$ = $1;}

multdivexp: multdivexp DIVIDE notexp {
  $$ = make_node(DIVIDE, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| notexp{$$ = $1;}

multdivexp: multdivexp TIMES notexp {
  $$ = make_node(TIMES, 0, "");
  attach_node($$, $1);
  attach_node($$, $3);
}
| notexp{$$ = $1;}

notexp: NOT notexp {
  $$ = make_node(NOT, 0, "");
  attach_node($$, $2);
}
| factor{$$ = $1;}


factor: VAL {$$ = make_node(VAL, $1, "");}
| LEFT orexp RIGHT {$$ = $2;}
| INPUT {$$ = make_node(INPUT, 0, "");}
| Identifier {$$ = make_node(Identifier, 0, $1);}



/* Programs in Sloth consist of zero or more statements */
stmts: stmt stmts {
    $$ = make_node(STATEMENT, 0, "");
    attach_node($$, $1);
    attach_node($$, $2);
}
|
{$$ = NULL;}



/*matches stmt */
stmt: ifstmt
{$$ = $1;}
|
ifelsestmt
{$$ = $1;}
|
whilestmt
{$$ = $1;}
|
printstmt
{$$ = $1;}
|
assignmentstmt
{$$ = $1;}
|
beginendstmt
{$$ = $1;}


/* matches assignment statement */
assignmentstmt: Identifier COLONEQUAL orexp SEMICOLON{
    $$ = make_node(Identifier, 0, "");
    attach_node($$, make_node(Identifier, 0, $1));
    attach_node($$, $3);
}

/* matches if statement */
ifstmt: IF orexp THEN stmt {
    $$ = make_node(IF, 0, "");
    attach_node($$, $2);
    attach_node($$, $4);
}

/* matches while statement */
whilestmt: WHILE orexp DO stmt {
  $$ = make_node(WHILE, 0, "");
  attach_node($$, $2);
  attach_node($$, $4);
}

/* matches if/else statement */
ifelsestmt: IF orexp THEN stmt ELSE stmt {
  $$ = make_node(IF, 0, "");
  attach_node($$, $2);
  attach_node($$, $4);
  attach_node($$, $6);
}


/* matches print statement */
printstmt: PRINT orexp SEMICOLON {
  $$ = make_node(PRINT, 0, "");
  attach_node($$, $2);
}


/* matches begin/end statement */
beginendstmt: Kbegin stmts END {
    $$ = make_node(Kbegin, 0, "");
    attach_node($$, $2);
}




%%

/* a tree node definition */
struct Node {
  /* the type of the node */
  int type;

  /* the value of the node if it can have one */
  double value;

  /* the id of the node (used for identifiers only) */
  char id[ID_SIZE];

  /* at most three children nodes */
  int num_children;
  struct Node* children[MAX_CHILDREN];
};

/* creates a new node and returns it */
struct Node* make_node(int type, double value, char* id) {
  int i;

  /* allocate space */
  struct Node* node = malloc(sizeof(struct Node));

  /* set properties */
  node->type = type;
  node->value = value;
  strcpy(node->id, id);
  node->num_children = 0;
  for(i = 0; i < MAX_CHILDREN; i++) {
    node->children[i] = NULL;
  }

  /* return new node */
  return node;
}

/* attach an existing node onto a parent */
void attach_node(struct Node* parent, struct Node* child) {
  /* connect it */
  parent->children[parent->num_children] = child;
  parent->num_children++;
  assert(parent->num_children <= MAX_CHILDREN);
}



void print_tree(struct Node* node, int tabs) {
    int i;
    
    /* base case */
    if(!node) return;
    
    /* print leading tabs */
    for(i = 0; i < tabs; i++) {
        printf("    ");
    }
    
    switch(node->type) {
        case Identifier: printf("IDENTIFIER: %s\n", node->id); break;
        case VAL: printf("VALUE: %lf\n", node->value); break;
        case PLUS: printf("PLUS:\n"); break;
        case MINUS: printf("MINUS:\n"); break;
        case DIVIDE: printf("DIVIDE:\n"); break;
        case TIMES: printf("TIMES:\n"); break;
        case LESS: printf("LESS THAN:\n"); break;
        case GREATER: printf("GREATER:\n"); break;
        case LESSEQ: printf("LESS EQUAL:\n"); break;
        case GREATEREQ: printf("GREATER EQUAL:\n"); break;
        case EQUALS: printf("EQUALS:\n"); break;
        case NEQUALS: printf("NOT EQUALS:\n"); break;
        case AND: printf("AND:\n"); break;
        case OR: printf("OR:\n"); break;
        case NOT: printf("NOT:\n"); break;
        case COLONEQUAL: printf("ASSIGN:\n"); break;
        case IF: printf("IF:\n"); break;
        case WHILE: printf("WHILE:\n"); break;
        case PRINT: printf("PRINT:\n"); break;
        case Kbegin: printf("BEGIN:\n"); break;
        case END: printf("END:\n"); break;
        case INPUT: printf("INPUT:\n"); break;
        case STATEMENT: printf("STATEMENT:\n"); break;
        default:
        printf("Error, %d not a valid node type.\n", node->type);
        exit(1);
    }
    
    /* print all children nodes underneath */
    for(i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], tabs + 1);
    }
}



int yywrap( ) {
  return 1;
}

void yyerror(const char* str) {
  fprintf(stderr, "Compiler error: '%s'.\n", str);
}
/**/
int main( ) {
   
    yyparse( );
    

    print_tree(globaltree, 0);

    return 0;
}
