#include <iostream>

int i=0;

void foo()
{
#ifdef A
  i += A;
#endif
}

#ifdef B
i += B;
#endif

int main()
{
	foo();
	std::cout << "Sum: " << i << std::endl;
	return 0;
}
