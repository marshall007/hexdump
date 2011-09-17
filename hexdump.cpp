//
//  Hexdump.cpp
//
//  Auth: Marshall Cottrell
//        Daniel Sebastian
//  Date: 09/06/11
//  Desc: C++ hexdump implementation.
//

#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

extern "C" void hexConvert(char data[], char hexDigits[], char asciiData[]);

int main(int argc, char *argv[])
{
    const int length = 16;
    int pos = 52;
    unsigned char* fbuf;
    string fname;
    
    // read file name from user
    cout << "File name: ";
    cin >> fname;
    
    // attempt to open I/O streams
    ifstream fin (fname.c_str(), ios::binary);
    ofstream fout ((fname.substr(0, fname.find('.'))+".dmp").c_str());
    
    // check if streams opened properly
    if (fin && fout) {
        
        // write header line
        fout << "HEX DUMP FOR FILE \""<< fname << "\":\n\n";
        
        fin.seekg(0, ios::end);
        int fbuflen = (int) fin.tellg();
        fbuf = new unsigned char[fbuflen];
        
        fin.seekg(0, ios::beg);
        fin.read((char*)fbuf, fbuflen);
        fin.close();
        
        // while able to read
        // while (fin.good()) {
        for (int j=0; j<fbuflen; j+=length) {
            
            // prints address
            fout << hex << setw(8) << setfill('0') << j << ": [                                                 ] ";
            pos = 52;
            
            // prints hex value of each byte
            for (int i=0; i<length; i++) {
                fout.seekp(-(pos-=2), ios::end);
                fout << hex << setw(2) << setfill('0') << (int) fbuf[j+i];
                
                fout.seekp(0, ios::end);
                if (isprint(fbuf[j+i])) fout << fbuf[j+i];
                else                    fout << ".";
            }
            
            fout << "\n";
            cout << ".";
        }
        cout << "done.";
        // if unable to open streams, prints error
    } else {
        cout << "Error: could not locate file.";
    }
}