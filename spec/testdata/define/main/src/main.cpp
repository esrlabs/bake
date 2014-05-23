#include <iostream>

int main()
{
#ifdef GAGA
	std::cout << "GAGA" << std::endl;
#endif
#ifdef GUGU
	std::cout << "GUGU" << std::endl;
#endif
#ifdef GOGO
	std::cout << "GOGO" << std::endl;
#endif
  return 0;
}
