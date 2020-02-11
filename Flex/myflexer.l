%option noyywrap
%option yylineno

%{
#include<iostream>
#include<fstream>
#include<vector>
#include<sstream>
#include<list>
#include<cstring>
#include<string>
using namespace std;

FILE * logout;
FILE * tokenout;
int line_count = 1;

int error_count = 0;



class SymbolInfo{
    private:
        string symbolName;
        string symbolType;
    public:
        SymbolInfo();
        SymbolInfo(string,string);
        string getsymbolName();
        string getsymbolType();
        void setsymbolName(string);
        void setsymbolType(string);
        ~SymbolInfo();

};

SymbolInfo::SymbolInfo(){
    symbolName = "";
    symbolType = "";
}

SymbolInfo::SymbolInfo(string name,string type){
    this->symbolName = name;
    this->symbolType = type;
}

void SymbolInfo::setsymbolName(string name){
    this->symbolName = name;
}

void SymbolInfo::setsymbolType(string type){
    this->symbolType = type;
}

string SymbolInfo::getsymbolName(){
    return symbolName;
}

string SymbolInfo::getsymbolType(){
    return symbolType;
}

SymbolInfo::~SymbolInfo(){

}


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



SymbolTable * mysymbolTable;




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

KEYWORD if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue



MYSTRING ["][^"]*["]

FLOAT [-+]?[0-9]*[.][0-9]*[E]?[-+]?[0-9]*

DIGIT [-+]?[0-9]+

SPACE [ \t\f\r\v]+

IDENTIFIER [A-Za-z_]+[A-Za-z_0-9]*

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

                  fprintf(logout,"Error at line %d: Unterminated string %s\n",line_count,yytext);
              }




{MCOMMENTS} {cout<<"mComments found :"<<yytext<<endl;
                fprintf(logout,"Line No. %d: Token <COMMENT> Lexeme %s found\n",line_count,yytext);
            }

{SCOMMENTS} {cout<<"sinComment: "<<yytext<<endl;
                fprintf(logout,"Line No. %d: Token <COMMENT> Lexeme %s found\n",line_count,yytext);
            }



{KEYWORD} { 
              
              string temp = "";
              for(int i=0;i<yyleng;i++){
                  temp += toupper(yytext[i]);
              }
              char myKey[temp.length()];
              char * final_string;
              strcpy(myKey,temp.c_str());
              final_string = myKey;
              fprintf(tokenout,"<%s> ",final_string);
              cout<<"KEYWORD : "<<final_string<<endl;

              fprintf(logout,"Line No. %d: Token <%s> Lexeme %s found\n",line_count,final_string,yytext);

          }


","     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<COMMA, %s> ",yytext); 
            fprintf(logout,"Line no. %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
             
        }
";"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<SEMICOLON, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
            
        }

"++"    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<INCOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
            
        }
"--"    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<INCOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
        }
"=="    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RELOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }
">="    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RELOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }
"<="    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RELOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }
"!="    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RELOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }
"&&"    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<LOGICOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
        }
"||"    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<LOGICOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
        }
">>"    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<BITOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }
"<<"    {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<BITOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }

"="     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<ASSIGNOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
        }
"+"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<ADDOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
        }
"-"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<ADDOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
        }
"*"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<MULOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
        }
"/"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<MULOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
        }
"%"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<MULOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
        }
">"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RELOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }
"<"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RELOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
        }
"&"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<BITOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }
"|"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<BITOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }
"^"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<BITOP, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
        }
"("     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<LPAREN, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
        }
")"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RPAREN, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
        }
"!"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<NOT, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
        }
"{"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<LCURL, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
        }
"}"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RCURL, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
        }
"["     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<LTHIRD, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <LTHIRD> Lexeme %s found\n",line_count,yytext);
        }
"]"     {cout<<"operator :("<<yytext<<")"<<endl;
            fprintf(tokenout,"<RTHIRD, %s> ",yytext);
            fprintf(logout,"Line no. %d: Token <RTHIRD> Lexeme %s found\n",line_count,yytext);
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

               fprintf(tokenout,"<STRING,%s > ",final_string);
               fprintf(logout,"Line No. %d: Token <STRING> Lexeme %s found\n",line_count,yytext);

           }

{FLOAT}   {
              cout<<"\n("<<atof(yytext)<<") is float."<<endl;
              fprintf(tokenout,"<CONST_FLOAT,%f > ",atof(yytext));
              fprintf(logout,"Line No. %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
              mysymbolTable->insertSymbolInCurrentScope(SymbolInfo(yytext,"CONST_FLOAT"));
              mysymbolTable->printAllScope();
          }

{DIGIT}   {
              cout<<"\n'"<<atoi(yytext)<<"' is an integer."<<endl;
              fprintf(tokenout,"<CONST_INT,%d > ",atoi(yytext));

              int decNum = atoi(yytext);
              
              
              string new_one = to_string(decNum);              

              fprintf(logout,"Line No. %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
              mysymbolTable->insertSymbolInCurrentScope(SymbolInfo(new_one,"CONST_INT"));
              mysymbolTable->printAllScope();
          }
{SPACE}   {
           
          }

{IDENTIFIER} {
                 cout<<"identifier detected ("<<yytext<<")"<<endl;
                 fprintf(tokenout,"<ID,%s > ",yytext);
                 fprintf(logout,"Line No. %d: Token <ID> Lexeme %s found\n",line_count,yytext);
                 mysymbolTable->insertSymbolInCurrentScope(SymbolInfo(yytext,"ID"));
                 mysymbolTable->printAllScope();
             }


{imulchar}  {

               error_count++;

               fprintf(logout,"Error at line %d: Multi character constant error %s\n",line_count,yytext);
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

               fprintf(tokenout,"<CONST_CHAR,%s > ",final_string);
               fprintf(logout,"Line No. %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
               mysymbolTable->insertSymbolInCurrentScope(SymbolInfo(yytext,"CONST_CHAR"));
               mysymbolTable->printAllScope();

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

               fprintf(tokenout,"<CONST_CHAR,%s > ",final_string);
               fprintf(logout,"Line No. %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

               mysymbolTable->insertSymbolInCurrentScope(SymbolInfo(yytext,"CONST_CHAR"));
               mysymbolTable->printAllScope();



            }


{manydec} {
              error_count++;

              fprintf(logout,"Error at line %d: Too many decimal point %s\n",line_count,yytext);
           }


{illnum} {
             error_count++;

             fprintf(logout,"Error at line %d: Ill formed number %s\n",line_count,yytext);
         }

{invalidsuff} {
                  error_count++;
                    fprintf(logout,"Error at line %d: Invalid prefix on ID or invalid suffix on Number %s\n",line_count,yytext);
                }

{empchar} {
                error_count++;
                fprintf(logout,"Error at line %d: Empty character constant error %s\n",line_count,yytext);
          }



{unendchar} {

                error_count++;
                fprintf(logout,"Error at line %d: Unterminated charecter %s\n",line_count,yytext);
            }

{unendchar2} {

                error_count++;

                fprintf(logout,"Error at line %d: Unterminated character %s\n",line_count,yytext);
             }














.        {
              //cout<<"no match!"<<endl;
          }


%%


int main(int argc, char ** argv){

    if(argc != 2){
        printf("no input file found.\n");
        return 0;
    }

    stringVector = new vector<string>();
    intVector = new vector<int>();
    floatVector = new vector<float>();

    FILE * fin = fopen(argv[1],"r");
    if(fin == NULL){
        printf("can't open file\n");
        return 0;
    }

    mysymbolTable = new SymbolTable();

    mysymbolTable->enterScope(7);

    logout = fopen("mylog.txt","w");
    tokenout = fopen("mytoken.txt","w");

    yyin = fin;
    yylex();

    //st.print();

    fprintf(logout,"\ntotal line : %d\n",line_count);
    fprintf(logout,"total error : %d\n",error_count);

    fclose(yyin);
    fclose(logout);
    fclose(tokenout);

    return 0;

}
