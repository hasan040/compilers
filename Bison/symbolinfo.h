#include<iostream>

using namespace std;

class SymbolInfo{
    private:
        string symbolName;
        string symbolType;
    public:
        SymbolInfo(){
            symbolName = "";
            symbolType = "";
        }
        SymbolInfo(string name,string type){
            this->symbolName = name;
            this->symbolType = type;
        }
        string getsymbolName(){
            return symbolName;
        }
        string getsymbolType(){
            return symbolType;
        }

        void setsymbolName(string name){
            this->symbolName = name;
        }
        void setsymbolType(string type){
            this->symbolType = type;
        }
        ~SymbolInfo(){

        }

};


