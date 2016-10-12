#include "A.h"

extern unsigned int l;
extern unsigned int m;
extern unsigned int g;

int main()
{
	A a;
	return a.calc(1) + l + m + g;
}
