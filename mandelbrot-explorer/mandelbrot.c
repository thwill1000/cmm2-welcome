/*
 * Mandelbrot CSUB
 * Author: The Sasquatch
 *         based on original CSUB by "matherp"
 * From:   https://www.thebackshed.com/forum/ViewTopic.php?TID=12685&PID=157748
 */

#include "ARMCFunctions.h"
#include <math.h>

void mandelbrot(int *itermax,MMFLOAT *magnify, MMFLOAT *xcenter, MMFLOAT *ycenter)
{
   double xsqr,ysqr,x,y,cx,cy;
   int hx,hy,iteration;

   unsigned char* page = (unsigned char*)GetPageAddress(0);

   double hxres = HRes;  /* horizonal resolution */
   double hyres = VRes;  /* vertical resolution  */

   int maxiter = *itermax;
   double yc = *ycenter;
   double xc = *xcenter;
   double mag = *magnify;

   if (yc == 0)
   {
     for (hy=(int)hyres;hy > (hyres / 2);hy--)
       {
         cy = ((double)hy / hyres - 0.5) / mag * 3.0 - yc;

         for (hx=hxres;hx > 0;hx--)
            {
             if (!(hx % 64))
               RoutineChecks();

             cx = ((double)hx / hxres - 0.5) / mag * 3.0 + xc;

             x = 0.0; y = 0.0;

             for (iteration=1;iteration < maxiter;iteration++)
               {
                 xsqr = x * x;
                 ysqr = y * y;

                 if (xsqr+ysqr > 4.0)
                    break;

                 //y = 2.0 * x * y + cy;
                 y = fma(2.0 * x,y,cy);
                 x = xsqr - ysqr + cx;
               }

             if (iteration == maxiter)
               {
               *(page + (int)hxres*(hy-1) + hx-1) = 0x00;
               *(page + (int)hxres*((int)hyres-hy) + hx-1) = 0x00;
//               DrawPixel(hx-1,hy-1,0x00);
               }
             else
               {
               *(page + (int)hxres*(hy-1) + hx-1) = iteration % 64;
               *(page + (int)hxres*((int)hyres-hy) + hx-1) = iteration % 64;
//               DrawPixel(hx-1,hy-1,map(iteration % 64));
               }
            }
       }

   }
   else
   {
     for (hy=(int)hyres;hy > 0;hy--)
       {
         cy = ((double)hy / hyres - 0.5) / mag * 3.0 - yc;

         for (hx=hxres;hx > 0;hx--)
          {
             if (!(hx % 64))
               RoutineChecks();

             cx = ((double)hx / hxres - 0.5) / mag * 3.0 + xc;

             x = 0.0; y = 0.0;

             for (iteration=1;iteration < maxiter;iteration++)
               {
                 xsqr = x * x;
                 ysqr = y * y;

                 if (xsqr+ysqr > 4.0)
                   break;

                 //y = 2.0 * x * y + cy;
                 y = fma(2.0 * x,y,cy);
                 x = xsqr - ysqr + cx;
               }

             if (iteration == maxiter)
               *(page + (int)hxres*(hy-1) + hx-1) = 0x00;
//               DrawPixel(hx-1,hy-1,0x00);
             else
               *(page + (int)hxres*(hy-1) + hx-1) = iteration % 64;
//               DrawPixel(hx-1,hy-1,map(iteration % 64));
            }
        }
     }
}
