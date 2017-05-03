#include <stdio.h>

extern int calc_div(int x, int k);

int main(int argc, char **argv)
{
  fflush(stdout);
  int x, k;
  scanf("%d", &x);
  scanf("%d", &k);
  calc_div(x, k);

  return 0;
}

int check(int x, int k)
{
  if (x < 0 || k > 31 || k <= 0)
  {
    return 0;
  }
  return 1;
}
