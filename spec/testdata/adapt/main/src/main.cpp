
int i=0;

void foo()
{
#ifdef A
  i += A;
#endif
}

int main()
{
	return 0;
}

extern "C"
{
int __main()
{
	return 0;
}
}
