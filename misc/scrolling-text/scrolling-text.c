/*
 * CSUB for 'scrolling-text.bas' example.
 * Author: "jirsoft"
 * From:   https://www.thebackshed.com/forum/ViewTopic.php?TID=13192#160861
 */

/*
 * FixBytes(scrPage%, x%, y%, w%, h%, newColor%)
 *
 * Sets any non-zero bytes within a bounding box to 'newCol'.
 * Only works for 800 pixel wide, 8-bit modes, i.e. Mode 1, 8
 */
void FixBytes(unsigned int *scrPage, unsigned int *x, unsigned int *y, unsigned int *w, unsigned int *h, unsigned int *newColor)
{
  char *adr;
  for (int yy = 0; yy < *h; yy++)
  {
    adr = (char *)scrPage[0];
    adr += *x + (*y + yy) * 800;
    for (int xx = 0; xx < *w; xx++)
    {
      if (*adr != 0)
      {
        *adr = *newColor;
      }
      adr++;
    }
  }
}
