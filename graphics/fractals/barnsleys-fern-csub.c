// Barnsley's Fern CSUB

#include "ARMCFunctions.h"
void Fern(long long int *Iter,MMFLOAT *Zoom,int *Seed)
{
  int i;
  unsigned int StateA,StateB,StateC,StateD,Temp,StateS;
  double X,Y,NextX,NextY;

  int It = *Iter;
  double hcenter = HRes/2;
  double vcenter = VRes/2;
  double Z = *Zoom;

  X = 1;
  Y = 1;

  // Seed the 128bits for the PSRG
  StateA = *Seed;
  StateB = *Seed;
  StateC = *Seed;
  StateD = *Seed;

// Loop through the specified number of iterations
  for(i = 0;i < It;i++)
  {
       //let MMBasic do some processing every 1ms
       if (!(i % 2048))
         RoutineChecks();

       // inline version of XorShift128 PSRG
       Temp = StateD;
       StateS = StateA;
       StateD = StateC;
       StateC = StateB;
       StateB = StateS;

       Temp ^= Temp << 11;
       Temp ^= Temp >> 8;
       StateA = Temp ^ StateA ^ (StateA >> 19);

       // Now let's draw some fern
       if (StateA >= 0x26666666)
       {
         NextX = (0.85 * X) + (0.04 * Y);
         NextY = (-0.04 * X) + (0.85 * Y) + 1.6;
       }
       else if ((StateA >= 0x147AE148) && (StateA < 0x26666666))
       {
         NextX = (-0.15 * X) + (0.28 * Y);
         NextY = (0.26 * X) + (0.24 * Y) + 0.44;
       }
       else if ((StateA >= 0x28F5C29) && (StateA < 0x147AE148))
       {
         NextX = (0.2 * X) - (0.26 * Y);
         NextY = (0.23 * X) + (0.22 * Y) + 1.6;
       }
       else
       {
         NextX = 0.0;
         NextY = 0.16 * Y;
       }

       X = NextX;
       Y = NextY;

       // Draw a green pixel at the current coordinates
       DrawPixel((X * 100.0 * Z) + hcenter,vcenter - ((Y - 5.0) * 50.0 * Z),0x006400);
   }

  // save the state in the Seed on exit in case we are called again
  *Seed = StateA;
}
