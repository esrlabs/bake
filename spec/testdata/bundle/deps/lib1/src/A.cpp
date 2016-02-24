#include "A.h"
#include "B.h"

int A::getReturnValue()
{
	B b;
	return b.getReturnValue();
}
