%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include<vector>
#include<sstream>
#include<list>
#include<string>

#include "symbolinfo.h"




using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

extern int line_count;
extern int error_count;

FILE * logout;//log file
FILE * errorout;//error file

bool global_scope = true;


bool first_entry;



list<SymbolInfo> *declaredList;

list<string> *parameterList;

int currentIndex;


string allProgram = "";

string funcString = "";

string varDeclareSum = "";



string varString = "";
string varStringSum = "";
list<string> * varStringCollections;



string declared_type_specifier;



class ScopeTable{

    private:

        list<SymbolInfo> *keySets;
        int total_bucket;

        string scopeTableName;

    protected:

        int hash_func(string);


    public:
        //ScopeTable(const ScopeTable &obj);
        ScopeTable(int,string);
        bool push_key(SymbolInfo);
        bool delete_key(SymbolInfo);
        bool delete_key_here(string);
        void display_key();
        SymbolInfo * LookIn(SymbolInfo);
        SymbolInfo * LookInTo(string);
        string getscopeTableName();
        ~ScopeTable();


};

/*

ScopeTable::ScopeTable(const ScopeTable &obj){
    keySets = obj.keySets;
    total_bucket = obj.total_bucket;
    scopeTableName = obj.scopeTableName;
}
*/





ScopeTable::ScopeTable(int x,string name){
    total_bucket = x;
    keySets = new list<SymbolInfo>[total_bucket];
    scopeTableName = name;
}

string ScopeTable::getscopeTableName(){


    return scopeTableName;
}

int ScopeTable::hash_func(string temp){
    int total_value = 0;

    for(int i=0;i<temp.size();i++){

        total_value += (int)temp[i];

    }

    return total_value % total_bucket;
}

bool ScopeTable::push_key(SymbolInfo temp){
    int temp_index = hash_func(temp.getsymbolName());

    bool done = false;


    list<SymbolInfo>::iterator i;
    bool found = false;

    for(i=keySets[temp_index].begin();i!=keySets[temp_index].end();i++){

        SymbolInfo more_temp = *i;

        //more_temp.getsymbolName() == temp.getsymbolName()

        if(!((*i).getsymbolName()).compare(temp.getsymbolName())){
            found = true;
            break;
        }
    }

    if(!found){

        keySets[temp_index].push_back(temp);

        LookIn(temp);//later added just to check whether its working or not

        done = true;

    }
    else{
        cout<<"<"<<temp.getsymbolName()<<","<<temp.getsymbolType()<<">"<<" couldn't be inserted due to existence!"<<endl;
    }


    return done;

}

bool ScopeTable::delete_key(SymbolInfo temp){
    list<SymbolInfo>::iterator i;
    bool done = false;
    int temp_index = hash_func(temp.getsymbolName());
    bool found = false;

    for(i=keySets[temp_index].begin();i!=keySets[temp_index].end();i++){

        SymbolInfo more_temp = *i;

        if(more_temp.getsymbolName() == temp.getsymbolName()){
            found = true;
            break;
        }
    }

    if(found){
        keySets[temp_index].erase(i);
        done = true;
    }

    return done;
}

bool ScopeTable::delete_key_here(string temp){
    list<SymbolInfo>::iterator i;
    bool done = false;
    int temp_index = hash_func(temp);
    bool found = false;

    int col_position = 0;

    for(i=keySets[temp_index].begin();i!=keySets[temp_index].end();i++){



        if(!((*i).getsymbolName()).compare(temp)){
            found = true;
            break;
        }
        col_position++;

    }

    if(found){
        keySets[temp_index].erase(i);
        cout<<temp<<" deleted entry at "<<temp_index<<", "<<col_position<<" "<<"from "<<scopeTableName<<endl;
        done = true;
    }

    return done;
}

void ScopeTable::display_key(){
    list<SymbolInfo>::iterator iter;

    char * mySymbolName;
    char * mySymbolType;

    for(int i=0;i<total_bucket;i++){
        //cout<<i<<"-->";

        if(keySets[i].size() > 0){


            fprintf(logout,"%d --->",i);

            for(iter=keySets[i].begin();iter!=keySets[i].end();iter++){
                SymbolInfo sinfo = *iter;

                string s1 = sinfo.getsymbolName();
                string s2 = sinfo.getsymbolType();

                char tempSName[s1.size()];
                char tempSType[s2.size()];

                strcpy(tempSName,s1.c_str());
                strcpy(tempSType,s2.c_str());

                mySymbolName = tempSName;
                mySymbolType = tempSType;

                fprintf(logout,"<%s, %s> ",mySymbolName,mySymbolType);

                //cout<<"<"<< sinfo.getsymbolName()<<":"<<sinfo.getsymbolType()<<"> ";
            }
            //cout<<endl;
            fprintf(logout,"\n");


        }

    }
}

SymbolInfo * ScopeTable::LookIn(SymbolInfo symbolInfo){
    list<SymbolInfo>::iterator iter;

    int col_counter = 0;

    for(int i=0;i<total_bucket;i++){
        for(iter=keySets[i].begin();iter!=keySets[i].end();iter++,col_counter++){

            if(!((*iter).getsymbolName()).compare(symbolInfo.getsymbolName())
                 && !((*iter).getsymbolType()).compare(symbolInfo.getsymbolType())
              ){

                  cout<<"'"<<symbolInfo.getsymbolName()<<"'"<<" inserted in "<<scopeTableName<<" at position "<<i<<", "<<col_counter<<endl;

                  return &(*iter);

            }

        }

        col_counter = 0;
    }

    return NULL;
}

SymbolInfo * ScopeTable::LookInTo(string symbolInfo){
    list<SymbolInfo>::iterator iter;

    int col_counter = 0;

    for(int i=0;i<total_bucket;i++){
        for(iter=keySets[i].begin();iter!=keySets[i].end();iter++,col_counter++){

            if(!((*iter).getsymbolName()).compare(symbolInfo)){

                  cout<<"'"<<symbolInfo<<"'"<<"found in "<<scopeTableName<<" at position "<<i<<", "<<col_counter<<endl;

                  return &(*iter);

            }

        }
        col_counter = 0;
    }

    return NULL;
}



ScopeTable::~ScopeTable(){

    delete [] keySets;
}


class SymbolTable{

    private:
        list<ScopeTable> * mySymbolTable;
        int total_table;
        ScopeTable * retCurrentScopeTable();

        string nameScope;


    public:

        SymbolTable();
        SymbolTable * enterScope(int);
        SymbolTable * exitScope();
        bool insertSymbolInCurrentScope(SymbolInfo);
        bool removeSymbolFromCurrentScope(SymbolInfo);
        ScopeTable * lookUp(SymbolInfo);
        ScopeTable * lookUpHere(string);
        void printCurrentScope();
        void printAllScope();
        void printAllScopeReverse();
        void deleteElement(string);
        ~SymbolTable();

};


SymbolTable::SymbolTable(){
    mySymbolTable = new list<ScopeTable>();
    total_table = 0;
    nameScope = "ScopeTable # ";

}

ScopeTable * SymbolTable::retCurrentScopeTable(){
    list<ScopeTable>::iterator iter;
    iter = mySymbolTable->end();
    iter--;
    return &(*iter);
}



SymbolTable * SymbolTable::enterScope(int buckets){

    total_table++;


    nameScope += to_string(total_table);



    mySymbolTable->push_back(*(new ScopeTable(buckets,nameScope)));

    //cout<<nameScope<<" has been created!"<<endl;

    nameScope = "Scopetable # ";

    return this;


}

SymbolTable * SymbolTable::exitScope(){

    cout<<retCurrentScopeTable()->getscopeTableName()<<" has been removed."<<endl;

    mySymbolTable->pop_back();

    total_table--;
    return this;

}

bool SymbolTable::insertSymbolInCurrentScope(SymbolInfo symbolInfo){

    bool done;
    done = retCurrentScopeTable()->push_key(symbolInfo);
    return done;
}

bool SymbolTable::removeSymbolFromCurrentScope(SymbolInfo symbolInfo){

    bool done;
    done = retCurrentScopeTable()->delete_key(symbolInfo);
    return done;

}

ScopeTable * SymbolTable::lookUp(SymbolInfo symbolInfo){

    list<ScopeTable>::reverse_iterator riter;
    for(riter = mySymbolTable->rbegin();riter != mySymbolTable->rend();++riter){


        if((*riter).LookIn(symbolInfo) != NULL){
            return &(*riter);
        }

    }

    return NULL;

}

void SymbolTable::deleteElement(string element){
    list<ScopeTable>::reverse_iterator riter;

    bool gottcha = false;

    for(riter = mySymbolTable->rbegin();riter!=mySymbolTable->rend();++riter){

        if((*riter).delete_key_here(element)){

            gottcha = true;
            break;

        }

    }

    if(!gottcha){
        cout<<"'"<<element<<"'"<<"Not found to be deleted!"<<endl;
    }
}


ScopeTable * SymbolTable::lookUpHere(string symbolInfo){

    list<ScopeTable>::reverse_iterator riter;

    bool success = false;

    for(riter = mySymbolTable->rbegin();riter != mySymbolTable->rend();++riter){


        if((*riter).LookInTo(symbolInfo) != NULL){
            success = true;//useless
            return &(*riter);
        }

    }

    if(!success){
        cout<<"'"<<symbolInfo<<"'"<<" not found in SymbolTable."<<endl;
    }

    return NULL;

}


void SymbolTable::printCurrentScope(){


    cout<<"current_scope_table :"<<endl;

    list<ScopeTable>::iterator iter;

    iter = mySymbolTable->end();
    iter--;

    cout<<(*iter).getscopeTableName()<<endl;

    (*iter).display_key();

    cout<<"end_of_current_scope_table.\n"<<endl;

}


void SymbolTable::printAllScope(){
    list<ScopeTable>::iterator i;

    char * myTableName;

    int counter = 0;

    fprintf(logout,"all_scope_table:\n");

    //cout<<"all_scope_table:"<<endl;

    for(i = mySymbolTable->begin();i!=mySymbolTable->end();i++){

        counter++;

        string s1 = (*i).getscopeTableName();
        char tempS1[s1.size()];
        strcpy(tempS1,s1.c_str());
        
        myTableName = tempS1;

        fprintf(logout,"%s\n",myTableName);

        //cout<<(*i).getscopeTableName()<<endl;

        (*i).display_key();

        fprintf(logout,"\n");

        //cout<<endl;
    }

    fprintf(logout,"end_of_all_scope\n");

    //cout<<"end_of_all_scope_tables.\n"<<endl;

}

void SymbolTable::printAllScopeReverse(){
    list<ScopeTable>::reverse_iterator i;

    int counter = 0;

    cout<<"all_scope_table:\n"<<endl;

    for(i = mySymbolTable->rbegin();i!=mySymbolTable->rend();i++){

        counter++;
        //cout<<"elements of scopeTable_"<<counter<<":"<<endl;

        cout<<(*i).getscopeTableName()<<endl;

        (*i).display_key();
        cout<<endl;
    }

    cout<<"end_of_all_scope_tables.\n"<<endl;

}



SymbolTable::~SymbolTable(){
    delete mySymbolTable;
}

char * mystringConverter(string input){
    char arr[input.size()];
    strcpy(arr,input.c_str());
    return arr;

}


#define YYSTYPE SymbolInfo*

SymbolTable * mysymbolTable;






void yyerror(char *s)
{
	//write your code
}


%}

%define api.value.type { SymbolInfo* }

%token  IF ELSE FOR WHILE ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL VOID INT FLOAT LTHIRD RTHIRD CONST_INT PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_FLOAT INCOP DECOP DO BREAK DOUBLE CHAR SWITCH CASE DEFAULT CONTINUE MAIN BITOP CONST_CHAR

%left '+' '-'
%left '*' '/'



%nonassoc '|' UMINUS 
%nonassoc THEN
%nonassoc ELSE


%%

start : program
	{
		
	}
	;

program : program unit 
          {
              
              string another_temp = allProgram; //for funtional definitions string

              


              if(another_temp.size() > 0){
                 
                  char * t1;
                  char ar1[another_temp.size()];
                  strcpy(ar1,another_temp.c_str());
                  t1 = ar1;
                  fprintf(logout,"At line no: %d program : program unit\n\n%s\n\n",line_count,t1);//it should be printed from allProgram buffer string 
                  
              }

              //for variable declaration
              //for func () declaration
              //all needed to be sum if its greater than zero to the buffer string allProgram
              //& print them finally
              
          }
	| unit
          {


       
          }
	;
	
unit : var_declaration
       {

         

           fprintf(logout,"At line no: %d unit : var_declaration\n\n",line_count);


           string anotherTemp = varDeclareSum;
           

           allProgram += anotherTemp;
           allProgram += "\n";

           char * mylit;
           char litArr[anotherTemp.size()];
           strcpy(litArr,anotherTemp.c_str());
           mylit = litArr;

           fprintf(logout,"%s\n\n",mylit);

           varDeclareSum = "";

      
          

       }
     | func_declaration
       {
           
           
       }
     | func_definition
       {

           string myTemp = varStringSum;
           allProgram += myTemp;
           allProgram += "\n";
           char * temp7;
           char temparr[myTemp.size()];
           strcpy(temparr,myTemp.c_str());
           temp7 = temparr;

           fprintf(logout,"At line no : %d unit : func_definition \n\n%s\n\n",line_count,temp7);

           varStringSum = "";
           
         
           
           
       }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
                   {

                       mysymbolTable->insertSymbolInCurrentScope(*$2);//newly added

                       fprintf(logout,"At line no: %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
                       string tempName = declared_type_specifier;

                       char * adt;
                       char adtarr[tempName.size()];
                       strcpy(adtarr,tempName.c_str());
                       adt = adtarr;

                       string get_para = "";
                       list<string>::iterator tempit;
                       for(tempit = parameterList->begin();tempit != parameterList->end();tempit++){
                           get_para += *tempit;
                           get_para += ",";
                       }


                       char * para_point;
                       char arrpoint[get_para.size()];
                       strcpy(arrpoint,get_para.c_str());
                       para_point = arrpoint;


                       char * sym_point;
                       string symp = $2->getsymbolName();
                       char symarr[symp.size()];
                       strcpy(symarr,symp.c_str());
                       sym_point = symarr;

                       fprintf(logout,"%s %s (%s);\n\n",adt,sym_point,para_point);

                       parameterList = new list<string>();//initialized again
                       

                       

                   }
		| type_specifier ID LPAREN RPAREN SEMICOLON
                  {
                       fprintf(logout,"At line no: %d func_declaration : type_specifier ID LPAREN  RPAREN SEMICOLON\n\n",line_count);
                       string tempName = declared_type_specifier;

                       

                       char * adt;
                       char adtarr[tempName.size()];
                       strcpy(adtarr,tempName.c_str());
                       adt = adtarr;

                       

                       char * sym_point;
                       string symp = $2->getsymbolName();
                       char symarr[symp.size()];
                       strcpy(symarr,symp.c_str());
                       sym_point = symarr;

                       fprintf(logout,"%s %s ();\n\n",adt,sym_point);                       
                  }
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
                  {

                      
                      mysymbolTable->insertSymbolInCurrentScope(*$2);//newly added

                      

                      string tempName = declared_type_specifier;
                      tempName += " ";
                      tempName += $2->getsymbolName();
                      tempName += "(";
                      int i_size = parameterList->size()-1;
                      int i_counter = 0;

                      list<string>::iterator myTemp;

                      for(myTemp = parameterList->begin();myTemp != parameterList->end();myTemp++){
                          if(i_counter < i_size && (i_counter % 2)){
                              tempName += *myTemp;
                              tempName += ",";
                          }
                          else if(i_counter < i_size && !(i_counter % 2)){
                              tempName += *myTemp;
                              tempName += " ";
                          }
                          else{
                              tempName += *myTemp;
                          }
                          i_counter++;
                      }

                      tempName += ")";
                      tempName += varStringSum;

                      char * at;
                      char arr[tempName.size()];
                      strcpy(arr,tempName.c_str());
                      at = arr;

                      fprintf(logout,"At line no: %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n%s\n\n",line_count,arr);

                      varStringSum = "";
                      varStringSum = tempName;

                      

                      

                      



             
                      
                      
                      
                  }
		| type_specifier ID LPAREN RPAREN compound_statement
                  {

                      fprintf(logout,"At line no: %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);

                      string tempName = declared_type_specifier;

                  }
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
                  {
                      parameterList->push_back(declared_type_specifier);
                      parameterList->push_back($4->getsymbolName());
                  }
		| parameter_list COMMA type_specifier
                  {
                      parameterList->push_back(declared_type_specifier);
                      
                  }
 		| type_specifier ID
                  {
                      parameterList->push_back(declared_type_specifier);
                      parameterList->push_back($2->getsymbolName());
                  }
		| type_specifier
                  {
                      parameterList->push_back(declared_type_specifier);

                  }
 		;

 		
compound_statement : LCURL statements RCURL
                     {

                      string tempVar = "{";
                      tempVar += "\n";
                      tempVar += varStringSum;
                      tempVar += "\n";
                      tempVar += "}";
                      

                      char * temp3;
                      char arr3[tempVar.size()];
                      strcpy(arr3,tempVar.c_str());
                      temp3 = arr3;

                      fprintf(logout,"At line no : %d statements : statement\n\n%s\n\n",line_count,temp3); 

                      varStringSum = "";
                      varStringSum = tempVar;

                      fprintf(logout,"\n\n");

                      mysymbolTable->printAllScope();//newly added

                      fprintf(logout,"\n\n");

                                            

                     }
 		    | LCURL RCURL
                     {

                         fprintf(logout,"At line no: %d compound_statement : LCURL RCURL\n\n",line_count);
                         fprintf(logout,"{\n\n}\n\n");

                     }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
                  {


                      fprintf(logout,"At line no: %d var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);

                      string tempName = declared_type_specifier;

                      varDeclareSum = declared_type_specifier;
                      varDeclareSum += " ";

                      char * fin_spec;
                      char arrspec[declared_type_specifier.size()];
                      strcpy(arrspec,declared_type_specifier.c_str());
                      fin_spec = arrspec;
                      
                      
                      
                      list<SymbolInfo>::iterator p;

                      

                      int i_counter = 0;
                      int i_size = declaredList[currentIndex].size()-1;

                     
                      

                      for(p = declaredList[currentIndex].begin();p!=declaredList[currentIndex].end();p++){


                          

                          
                          
                          string dummy = (*p).getsymbolName();

                          if(i_counter < i_size ){
                              varDeclareSum += dummy;
                              varDeclareSum += ",";
                          }
                          else{
                              varDeclareSum += dummy;
                              varDeclareSum += ";";
                          }
                          
                         
                         
                          i_counter ++;
                          
                      }
                      

                      string tempHer = varDeclareSum;
                      char * tempMy;
                      char myArr[tempHer.size()];
                      strcpy(myArr,tempHer.c_str());
                      tempMy = myArr;

                      fprintf(logout,"%s\n\n",tempMy);
                      
 
                      currentIndex++;

                      
                      

                  }
 		 ;
 		 
type_specifier	: INT
                  {

                      declared_type_specifier = "int";
                      
                      fprintf(logout,"At line no: %d type_specifier : INT\n\nint\n\n",line_count);
                      
                      
                  }
 		| FLOAT
                  {
                      declared_type_specifier = "float";

                      fprintf(logout,"At line no: %d type_specifier : FLOAT\n\nfloat\n\n",line_count);
                  }
 		| VOID
                  {
                      declared_type_specifier = "void";

                      fprintf(logout,"At line no: %d type_specifier : VOID\n\nvoid\n\n",line_count);
                  }
 		;
 		
declaration_list : declaration_list COMMA ID
                   {

                       declaredList[currentIndex].push_back(*$3);

                       mysymbolTable->insertSymbolInCurrentScope(*$3);//newly added

                       

                       fprintf(logout,"At line no : %d declaration_list : declaration_list COMMA ID\n\n",line_count);
                       
                       list<SymbolInfo>::iterator temps;
                       for(temps = declaredList[currentIndex].begin();temps!=declaredList[currentIndex].end();temps++){
                           string dummy = temps->getsymbolName();
                           char arrdummy[dummy.size()];
                           char * final_string;
                           strcpy(arrdummy,dummy.c_str());
                           final_string = arrdummy;
                           fprintf(logout,"%s,",final_string);
                       }

                       fprintf(logout,"\n\n");

                   }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
 		  | ID
                    {
                       declaredList[currentIndex].push_back(*$1);

                       mysymbolTable->insertSymbolInCurrentScope(*$1);//newly added


                       

                       

                       fprintf(logout,"At line no : %d declaration_list : ID\n\n",line_count);
                       
                       list<SymbolInfo>::iterator temps;
                       for(temps = declaredList[currentIndex].begin();temps!=declaredList[currentIndex].end();temps++){
                           string dummy = temps->getsymbolName();
                           char arrdummy[dummy.size()];
                           char * final_string;
                           strcpy(arrdummy,dummy.c_str());
                           final_string = arrdummy;
                           fprintf(logout,"%s,",final_string);
                       }

                       fprintf(logout,"\n\n");
                    
                    }
 		  | ID LTHIRD CONST_INT RTHIRD
 		  ;
 		  
statements : statement
             {
                 


                      string tempVar = varStringSum;
                      

                      char * temp3;
                      char arr3[tempVar.size()];
                      strcpy(arr3,tempVar.c_str());
                      temp3 = arr3;

                      fprintf(logout,"At line no : %d statements : statement\n\n%s\n\n",line_count,temp3);

                                       


                 
             }
	   | statements statement
             {
                 fprintf(logout,"At line no: %d statements : statements statement\n\n",line_count);
             }
	   ;
	   
statement : var_declaration
            {
                fprintf(logout,"At line no: %d statement : var_declaration\n\n",line_count);

                
                

            }
	  | expression_statement
            {

            }
	  | compound_statement
            {

            }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
            {

            }
	  | IF LPAREN expression RPAREN statement %prec THEN
            {

            }
	  | IF LPAREN expression RPAREN statement ELSE statement
            {

            }
	  | WHILE LPAREN expression RPAREN statement
            {

            }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
            {

            }
	  | RETURN expression SEMICOLON
            {

                      string tempVar = "return ";
                      tempVar += varStringSum;
                      tempVar += ";";

                      char * temp3;
                      char arr3[tempVar.size()];
                      strcpy(arr3,tempVar.c_str());
                      temp3 = arr3;

                      fprintf(logout,"At line no : %d statement : RETURN expression SEMICOLON\n\n%s\n\n",line_count,temp3);

                      varStringSum = "";
                      varStringSum = tempVar;

            }
	  ;
	  
expression_statement 	: SEMICOLON			
			| expression SEMICOLON
                          {

                          } 
			;
	  
variable : ID 
           {
               string var = $1->getsymbolName();
               varStringCollections->push_back(var);

               char arr[var.size()];
               char * indi;
               strcpy(arr,var.c_str());
               indi = arr;
               fprintf(logout,"At line no : %d variable : ID\n\n%s\n\n",line_count,indi);

               varString = var;
           }		
	 | ID LTHIRD expression RTHIRD 
           {

           }
	 ;
	 
 expression : logic_expression
              {

                      string tempVar = varStringSum;

                      char * temp3;
                      char arr3[tempVar.size()];
                      strcpy(arr3,tempVar.c_str());
                      temp3 = arr3;

                      fprintf(logout,"At line no : %d expression : logic_expression\n\n%s\n\n",line_count,temp3);

              }	
	   | variable ASSIGNOP logic_expression 
             {

             }	
	   ;
			
logic_expression : rel_expression 
                   {

                      string tempVar = varStringSum;

                      char * temp3;
                      char arr3[tempVar.size()];
                      strcpy(arr3,tempVar.c_str());
                      temp3 = arr3;

                      fprintf(logout,"At line no : %d logic_expression : rel_expression \n\n%s\n\n",line_count,temp3);

                   }	
		 | rel_expression LOGICOP rel_expression 
                   {

                   }	
		 ;
			
rel_expression	: simple_expression 
                  {

                      string tempVar = varStringSum;

                      char * temp3;
                      char arr3[tempVar.size()];
                      strcpy(arr3,tempVar.c_str());
                      temp3 = arr3;

                      fprintf(logout,"At line no : %d rel_expression : simple_expression\n\n%s\n\n",line_count,temp3);

                  }
		| simple_expression RELOP simple_expression
                  {

                  }	
		;
				
simple_expression : term
                    {

                        string getVar = varString;//receiving data from global string parameter
                        
                        
                        

                        char * temp1;
                        char arr1[getVar.size()];
                        strcpy(arr1,getVar.c_str());
                        temp1 = arr1;

                        fprintf(logout,"At line no: %d simple_expression : term\n\n%s\n\n",line_count,temp1);

                        

                        

                    } 
		  | simple_expression ADDOP term 
                    {
                        list<string>::iterator it;
                        int i_counter = 0;
                        int i_size = varStringCollections->size()-1;
                        for(it = varStringCollections->begin();it!=varStringCollections->end();it++){
                            if(i_counter < i_size){
                                varStringSum += *it;
                                varStringSum += "+";
                            }
                            else{
                                varStringSum += *it;
                            }
                            i_counter++;
                        }

                        string another_one = varStringSum;

                        char * temp2;
                        char arr2[another_one.size()];
                        strcpy(arr2,another_one.c_str());
                        temp2 = arr2;
                        fprintf(logout,"At line no : %d simple_expression : simple_expression ADDOP term\n\n%s\n\n",line_count,temp2);

                        varStringCollections = new list<string>();

                    }
		  ;
					
term :	unary_expression
        {

              string getVar = varString;//receiving data from global string parameter

              char * temp1;
              char arr1[getVar.size()];
              strcpy(arr1,getVar.c_str());
              temp1 = arr1;

              fprintf(logout,"At line no: %d term : unary_expression\n\n%s\n\n",line_count,temp1);

        }
     |  term MULOP unary_expression
        {

        }
     ;

unary_expression : ADDOP unary_expression 
                   {

                   } 
		 | NOT unary_expression 
                   {

                   }
		 | factor 
                   {

                       string getVar = varString;//receiving data from global string parameter

                       char * temp1;
                       char arr1[getVar.size()];
                       strcpy(arr1,getVar.c_str());
                       temp1 = arr1;

                       fprintf(logout,"At line no: %d unary_expression : factor\n\n%s\n\n",line_count,temp1);
                

                       

                   }
		 ;
	
factor	: variable
          {

              string getVar = varString;//receiving data from global string parameter

              char * temp1;
              char arr1[getVar.size()];
              strcpy(arr1,getVar.c_str());
              temp1 = arr1;

              fprintf(logout,"At line no: %d factor : variable\n\n%s\n\n",line_count,temp1);


          } 
	| ID LPAREN argument_list RPAREN
          {

          }
	| LPAREN expression RPAREN
          {

          }
	| CONST_INT
          {

          } 
	| CONST_FLOAT
          {

          }
	| variable INCOP 
          {

          }
	| variable DECOP
          {

          }
	;
	
argument_list : arguments
			  |
			  ;
	
arguments : arguments COMMA logic_expression
	      | logic_expression
	      ;
 

%%
int main(int argc,char *argv[])
{

        FILE * fp;

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
        
        first_entry = false;

        currentIndex = 0;

        declaredList = new list<SymbolInfo>[1000];
        

        

        parameterList = new list<string>();

        varStringCollections = new list<string>();


        mysymbolTable = new SymbolTable();

        mysymbolTable->enterScope(30);

	logout = fopen(argv[2],"w");
	fclose(logout);
	//errorout = fopen(argv[3],"w");
	//fclose(errorout);
	
	logout= fopen(argv[2],"a");
	//errorout= fopen(argv[3],"a");
	

	yyin=fp;
	yyparse();
	

	fclose(logout);
	//fclose(errorout);
	
	return 0;
}

