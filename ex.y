%{
	
	#include <stdio.h>
	#include <string.h>

	int yylex();
	int yyerror(const char *msg);


     	int EsteCorecta = 1;
	char msg[500];


	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
 	     bool atribuire;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}

%union { char* sir; int val; }

%token TOK_EQUALS TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_LEFT TOK_RIGHT TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIV TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_ERROR
%token <val> TOK_INT
%token <sir> TOK_ID

%type <sir> id_list

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIV


%%
prog : TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END '.'
       |
       error
	{ EsteCorecta = 0; }
       ;
prog_name : TOK_ID
            {
              ts=new TVAR();
            }
	;
dec_list : dec
	   |
	   dec_list ';' dec
	;
dec : id_list ':' type
       { 
         if(ts!=NULL)
         {
           if(ts->exists($1)==0)
            { 
              ts->add($1); 
            }

           } 
          else
	   {
             sprintf(msg,"%d:%d Eroare semantica: Variabila %s este declarata de mai multe ori!", @1.first_line, @1.first_column, $1);
             yyerror(msg);
             YYERROR;
	   }
	}
	;
type : TOK_INTEGER
	;
id_list : TOK_ID
	|
	 id_list ',' TOK_ID
	 { 
	  if(ts!=NULL)
	   {
	     if(ts->exists($3)==0)
	     {
	       ts->add($3);
	     }

           }
           else
           {
              sprintf(msg,"%d:%d Eroare semantica: Variabila %s este declarata de mai multe ori!", @1.first_line, @1.first_column, $3);
	      yyerror(msg);
              YYERROR;
           }
         }
 	;
stmt_list : stmt
	    |
	    stmt_list ';' stmt
	;
stmt :  assign
        |
	read
        |
	write
	|
	for
	;
assign : TOK_ID TOK_EQUALS exp
	{
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    ts->setValue($1,0);
	  }
	  else{
		sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost initializata!", @1.first_line, @1.first_column, $1);
	        yyerror(msg);
	        YYERROR;}
         }
       }
	;
exp : term
      |
      exp TOK_PLUS term
      |
      exp TOK_MINUS term
      ;
term : factor
       |
       term TOK_MULTIPLY factor
       |
       term TOK_DIV factor
       ;
factor : TOK_ID
{	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    if(ts->getValue($1) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost initializata!", @1.first_line, @1.first_column, $1);
	      yyerror(msg);
	      YYERROR;
	    }
	}
	else{
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
	      yyerror(msg);
	      YYERROR;}
	  }
        }
       
	 |
	 TOK_INT
	  { 
	  if($1 == 0) 
	  { 
	      sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } 
	 }
	 |
	 TOK_LEFT exp TOK_RIGHT
	 ;
read : TOK_READ TOK_LEFT id_list TOK_RIGHT
	{
	   if(ts != NULL)
	    {
	       if(ts->exists($3) == 0)
		{
		   sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, $3);
		   yyerror(msg);
		   YYERROR;
		}
		else{
		  ts->setValue($3,0);
		}
	    }
	}
	;
write : TOK_WRITE TOK_LEFT id_list TOK_RIGHT
	{
	if(ts != NULL)
	{
	  if(ts->exists($3) == 1)
	  {
	    if(ts->getValue($3) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost initializata!", @1.first_line, @1.first_column, $3);
	      yyerror(msg);
	      YYERROR;
	    }
	  }
           else{sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, $3);
	      yyerror(msg);
	      YYERROR;
	 }
        }
       }
	;
for : TOK_FOR index_exp TOK_DO body
	;
index_exp : TOK_ID TOK_EQUALS exp TOK_TO exp
	{
	   if(ts != NULL)
	    {
	       if(ts->exists($1) == 0)
		{
		   sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu a fost declarata!", @1.first_line, @1.first_column, $1);
		   yyerror(msg);
		   YYERROR;
		}
		else
		 {
                   ts->setValue($1,0);
		 }
	    }
	}
	;
body : stmt
       |
       TOK_BEGIN stmt_list TOK_END
       ;


	


%%

int main()
{
	try{
	     yyparse();
	
	      if(EsteCorecta == 1)
	      {
		printf("CORECTA\n");		
	      }	
           }
	catch( const char* err)
		{
		   printf("%s\n", err); 
        	}


       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}
