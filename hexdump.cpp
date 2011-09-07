//
//  Hexdump.cpp
//
//  Auth: Marshall Cottrell
//        Daniel Sabastian
//  Date: 09/06/11
//  Desc: C++ hexdump implementation.
//

#include <iostream>
#include <fstream>
#include <iomanip>

using namespace std;

int main(int argc, char *argv[])
{
    const int length = 16;
    unsigned char* buf;
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
        
        // while able to read
        while (fin.good()) {
            
            // prints address
            fout << setw(8) << setfill('0') << fin.tellg() << ": [ ";
            
            // reads 16 bytes from file
            buf = new unsigned char[length];
            fin.read((char*)buf, length);
            
            /* TODO:
                Only iterate over buffer once by combining for loops.
             */
            
            // prints hex value of each byte
            for (int i=0; i<length; i++)
                fout << hex << setw(2) << setfill('0') << (int) buf[i] << " ";
            
            fout << "] ";
            
            // prints ASCII value of each byte
            for (int i=0; i<length; i++) {
                if (isprint(buf[i])) fout << buf[i];
                else                 fout << ".";
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