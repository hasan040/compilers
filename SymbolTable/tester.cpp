#include<iostream>
#include<fstream>
#include<vector>
#include <sstream>
#include<list>

using namespace std;




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

    for(int i=0;i<total_bucket;i++){
        cout<<i<<"-->";
        for(iter=keySets[i].begin();iter!=keySets[i].end();iter++){
            SymbolInfo sinfo = *iter;

            cout<<"<"<< sinfo.getsymbolName()<<":"<<sinfo.getsymbolType()<<"> ";
        }
        cout<<endl;
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

    cout<<nameScope<<" has been created!"<<endl;

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

    int counter = 0;

    cout<<"all_scope_table:"<<endl;

    for(i = mySymbolTable->begin();i!=mySymbolTable->end();i++){

        counter++;
        //cout<<"elements of scopeTable_"<<counter<<":"<<endl;

        cout<<(*i).getscopeTableName()<<endl;

        (*i).display_key();
        cout<<endl;
    }

    cout<<"end_of_all_scope_tables.\n"<<endl;

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







int main(){

    SymbolTable * mysymbolTable;
    mysymbolTable = new SymbolTable();

    string path = "input.txt";

    ifstream file(path);



    list<vector<string>> mylist;


    if(file.is_open()){
        string line2 = "";
        while(getline(file,line2)){

            vector<string> internal;

            string line = line2.substr(0,line2.length()-1);

            if(line.length() == 1){
                string tempo = "";
                tempo += line.at(0);
                internal.push_back(tempo);
            }

            else{

                stringstream ss(line);
                string tok;

                while(getline(ss, tok, ' ')) {
                    internal.push_back(tok);
                }


            }

            mylist.push_back(internal);

        }

    }

    list<vector<string>>::iterator it;
    list<vector<string>>::iterator it2;
    int buckets_number = 0;

    it2 = mylist.begin();



    stringstream converted((*it2)[0]);
    converted >> buckets_number;


    mysymbolTable->enterScope(buckets_number);


    for(it=next(mylist.begin());it!=mylist.end();it++){

        vector<string>row_command = *it;



        if(!row_command[0].compare("I")){

            cout<<row_command[0]<<" "<<row_command[1]<<" "<<row_command[2]<<endl;



            mysymbolTable->insertSymbolInCurrentScope(SymbolInfo(row_command[1],row_command[2]));


        }

        else if(!row_command[0].compare("L")){

            cout<<row_command[0]<<" "<<row_command[1]<<endl;



            mysymbolTable->lookUpHere(row_command[1]);


        }

        else if(!row_command[0].compare("P")){

            cout<<row_command[0]<<" "<<row_command[1]<<endl;



            if(!row_command[1].compare("A")){
                mysymbolTable->printAllScopeReverse();

            }
            else{
                mysymbolTable->printCurrentScope();
            }


        }

        else if(!row_command[0].compare("D")){

            cout<<row_command[0]<<" "<<row_command[1]<<endl;


            mysymbolTable->deleteElement(row_command[1]);


        }
        else if(!row_command[0].compare("S")){

            cout<<row_command[0]<<endl;


            mysymbolTable->enterScope(buckets_number);

        }
        else if(!row_command[0].compare("E")){

            cout<<row_command[0]<<endl;

            mysymbolTable->exitScope();

        }

    }

    file.close();

    return 0;
}

