#include "ARMCFunctions.h"

void mandelbrot(int *itermax,MMFLOAT *magnify, MMFLOAT *xcenter, MMFLOAT *ycenter)
{
   double xsqr,ysqr,x,y,cx,cy;
   int iteration,hx,hy;
   unsigned char* page = (unsigned char*)GetPageAddress(0);

   int hxres = HRes;        /* horizonal resolution        */
   int hyres = VRes;        /* vertical resolution        */

   for (hy=hyres;hy>=1;hy--)
     {
       cy = (((float)hy)/((float)hyres)-0.5) / *magnify * 3.0 - *ycenter;

       for (hx=hxres;hx>=1;hx--)
          {
           if (!(hx % 64))
             RoutineChecks();

           cx = (((float)hx)/((float)hxres)-0.5) / *magnify * 3.0 + *xcenter;

           x = 0.0; y = 0.0;

           for (iteration=1;iteration<*itermax;iteration++)
             {
               xsqr = x*x;
               ysqr = y*y;

               if (xsqr+ysqr > 4.0)
                  break;

               y = 2.0*x*y+cy;
               x = xsqr-ysqr+cx;
             }

           if (iteration == *itermax)
               *(page + hxres*(hy-1) + hx-1) = 0x00;
//             DrawPixel(hx-1,hy-1,0x00);
           else
               *(page + hxres*(hy-1) + hx-1) = iteration % 64;
//             DrawPixel(hx-1,hy-1,map(iteration % 64));
          }
     }
}
