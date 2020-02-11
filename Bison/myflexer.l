%{
#include<iostream>
#include<stdlib.h>
#include<fstream>
#include<vector>
#include<sstream>
#include<list>
#include<cstring>
#include<string>

#include "symbolinfo.h"


#include "y.tab.h"

using namespace std;



extern YYSTYPE yylval;

void yyerror(char *);


int line_count = 1;

int error_count = 0;






//extern SymbolTable * mysymbolTable;





list<int> convertString(char * temp,int length){

    list<int> tempList;
    list<int>::iterator myIter;

    int ascii_code;
    int k_code = 0;

    for(int i=0;i<length;i++){
        ascii_code = (int) temp[i];
        if(ascii_code == 34){

            continue;

        }

        else if(ascii_code == 92){
            int check_tab = (int) temp[i+1];
            if(check_tab == 116){

               tempList.push_back(9);

                

            }
            else if(check_tab == 110 || check_tab == 10){

                tempList.push_back(10);

            }

            
            i++;
        }

        

        else{
            tempList.push_back(ascii_code);
        }

    }

   
  
    return tempList;
}

list<int> convertChar(char * temp,int length){

    list<int> tempList;
    list<int>::iterator myIter;

    int ascii_code;
    int k_code = 0;

    for(int i=0;i<length;i++){
        ascii_code = (int) temp[i];
        if(ascii_code == 39){

            continue;

        }

        else if(ascii_code == 92){
            int check_tab = (int) temp[i+1];
            if(check_tab == 116){

               tempList.push_back(9);

                

            }
            else if(check_tab == 110 || check_tab == 10){

                tempList.push_back(10);

            }

            
            i++;
        }

        

        else{
            tempList.push_back(ascii_code);
        }

    }

   
  
    return tempList;
}

vector<string> *stringVector;
vector<int> * intVector;
vector<float> * floatVector;

%}

NEWLINE \n

MCOMMENTS "/*"([^*]|(\*+[^*/]))*\*+\/

SCOMMENTS \/\/(.*)


digit [0-9]
letter [A-Za-z]

integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?






MYSTRING ["][^"]*["]



ADDOP [+-]
MULOP [*/%]

SPACE [ \t\f\r\v]+

IDENTIFIER (_|{letter})(_|{letter}|{digit})*

imulchar ['][A-Za-z][A-Za-z ]+[']

CHARLIT '([^'\\\n]|\\.)'

EMPCHARLIT ''

LCHARLIT '([^'\\\n]|\\.)+'




manydec [0-9]*[.][0-9]*[.][0-9.]*

illnum [0-9]+[Ee][0-9]+[.][0-9.]+

invalidsuff [0-9]+[A-Za-z]+

empchar (')(')



unendchar (')[A-Za-z]*

unendchar2 (')(\\)(')



unendstring ["](\\.|[^"\\])*[^"]





UNTERMCHARLIT '




%%

{NEWLINE} {line_count++;}


{unendstring} {
                  error_count++;              
              }




{MCOMMENTS} {cout<<"mComments found :"<<yytext<<endl;
                
            }

{SCOMMENTS} {cout<<"sinComment: "<<yytext<<endl;
                
            }



"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"do" {return DO;}
"break" {return BREAK;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"switch" {return SWITCH;}
"case" {return CASE;}
"default" {return DEFAULT;}
"continue" {return CONTINUE;}
"void" {return VOID;}
"main" {return MAIN;}
"println" {return PRINTLN;}


{ADDOP} {

            SymbolInfo *s = new SymbolInfo(yytext,"ADDOP");
            yylval = (YYSTYPE)s;
            return ADDOP;

        }


{MULOP} {

            SymbolInfo *s = new SymbolInfo(yytext,"MULOP");
            yylval = (YYSTYPE)s;
            return MULOP;

        }




","     {return COMMA;}
";"     {return SEMICOLON;}

"++"    {return INCOP;}
"--"    {return DECOP;}



">"     |       
"<"     |
"=="    |
">="    |
"<="    |
"!="    {
            SymbolInfo *s = new SymbolInfo(yytext,"RELOP");
            yylval = (YYSTYPE)s;
            return RELOP;
        }

"="     {return ASSIGNOP;}

"&&"    |
"||"    {
            SymbolInfo *s = new SymbolInfo(yytext,"LOGICOP");
            yylval = (YYSTYPE)s;
            return LOGICOP;

        }

">>"    |
"<<"    |
"&"     |        
"|"     |        
"^"     {
            SymbolInfo *s = new SymbolInfo(yytext,"BITOP");
            yylval = (YYSTYPE)s;
            return BITOP;
        }

"("     {return LPAREN;}
")"     {return RPAREN;}
"!"     {return NOT;}
"{"     {return LCURL;}
"}"     {return RCURL;}
"["     {return LTHIRD;}
"]"     {return RTHIRD;}


{integer}    {
                 SymbolInfo *s = new SymbolInfo(yytext,"CONST_INT");
                 yylval = (YYSTYPE)s;
                 return CONST_INT;
             }


{number}    {
                SymbolInfo *s = new SymbolInfo(yytext,"CONST_FLOAT");
                yylval = (YYSTYPE)s;
                return CONST_FLOAT;
            }





{MYSTRING} {
               list<int> asciiList = convertString(yytext,yyleng);
               list<int>::iterator myiter;
               string mysummation = "\"";

               int getAsciiCode;
               
               
               for(myiter = asciiList.begin();myiter!=asciiList.end();myiter++){

                   getAsciiCode = *myiter;

                   if(getAsciiCode != 10){
                       mysummation += (char) getAsciiCode;

                   }


               }

               mysummation += "\"";

               char * final_string;
               char int_string[mysummation.size()];
               strcpy(int_string,mysummation.c_str());
               final_string = int_string;

               

           }


{SPACE}   {
           
          }

{IDENTIFIER} {

                 SymbolInfo *s;
                 //s = NULL;

                /*
                 if(mysymbolTable->lookUpHere(yytext) == NULL){
                     s = new SymbolInfo(yytext,"ID");
                 }

                 */
                 s = new SymbolInfo(yytext,"ID");
                 yylval = (YYSTYPE)s;
                 return ID;
                 
             }


{imulchar}  {
               error_count++;
           }




{CHARLIT}  {

               list<int> asciiList = convertChar(yytext,yyleng);
               list<int>::iterator myiter;
               string mysummation = "";

               int getAsciiCode;
               
               
               for(myiter = asciiList.begin();myiter!=asciiList.end();myiter++){

                   getAsciiCode = *myiter;

                   if(getAsciiCode != 10){
                       mysummation += (char) getAsciiCode;

                   }


               }

               

               char * final_string;
               char int_string[mysummation.size()];
               strcpy(int_string,mysummation.c_str());
               final_string = int_string;

                

               SymbolInfo *s;
               //s = NULL;
               s = new SymbolInfo(yytext,"CONST_CHAR");

               /*
               if(mysymbolTable->lookUpHere(yytext) == NULL){
                   s = new SymbolInfo(yytext,"CONST_CHAR");
               }
               */
               yylval = (YYSTYPE)s;
               return CONST_CHAR;             


           }


{LCHARLIT}  {


               list<int> asciiList = convertChar(yytext,yyleng);
               list<int>::iterator myiter;
               string mysummation = "";

               int getAsciiCode;
               
               
               for(myiter = asciiList.begin();myiter!=asciiList.end();myiter++){

                   getAsciiCode = *myiter;

                   if(getAsciiCode != 10){
                       mysummation += (char) getAsciiCode;

                   }


               }

               

               char * final_string;
               char int_string[mysummation.size()];
               strcpy(int_string,mysummation.c_str());
               final_string = int_string;              

               SymbolInfo *s;
               //s = NULL;
               s = new SymbolInfo(yytext,"CONST_CHAR");
               /*
               if(mysymbolTable->lookUpHere(yytext) == NULL){
                   s = new SymbolInfo(yytext,"CONST_CHAR");
               }
               */
               yylval = (YYSTYPE)s;
               return CONST_CHAR;


            }


{manydec} {
              error_count++;

           }


{illnum} {
             error_count++;

         }

{invalidsuff} {
                  error_count++;
              }

{empchar} {
                error_count++;
          }



{unendchar} {
                error_count++;  
            }

{unendchar2} {
                error_count++;
             }



.        {
              
         }


%%


int yywrap(void){

    return 1;
}



