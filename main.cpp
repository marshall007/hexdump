#include <iostream>
using namespace std;

#define ASM

#ifdef ASM
extern "C" void hexConvert(char* data, char* hexDigits, char* asciiData);
#else
void hexConvert(char* data, char* hexDigits, char* asciiData) {

}
#endif

void main() {
	char* pdata = new char[16];
	char* phexDigits = new char[47];
	char* pasciiData = new char[16];
	hexConvert(pdata, phexDigits, pasciiData);
	phexDigits[32] = '\0';
	cout << "00000000: " << phexDigits << " " << endl;
	cin >> pdata;
}