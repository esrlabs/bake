#include <iostream>

int i=0;

#ifdef A
i += A;
#endif

#ifdef B
i += B;
#endif

int main()
{
	std::cout << "Sum: " << i << std::endl;
	return 0;
}
