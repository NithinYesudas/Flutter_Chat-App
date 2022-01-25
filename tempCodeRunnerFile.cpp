include <iostream>
using namespace std;
void Sum(int a, int b, int & c)
   {
       a = b + c;
       b = a + c;
       c = a + b;
   }
   int main()
   {
       int x = 2, y =3;
       Sum(x, y, y);
       cout << x << " " << y;
       return 0;
   }
