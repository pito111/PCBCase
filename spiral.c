/* General spiral track */
/* (c) 2021 Adrian Kennard Andrews & Arnold Ltd */

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <popt.h>
#include <err.h>
#include <float.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <math.h>

int
main(int argc, const char *argv[])
{
   const char     *name = "PN532-Antenna6";
   double          startr = 22.69;
   double          width = 0.5;
   double          step = 1.0;
   double          starta = -2.5;
   double          enda = 360 * 2 - 6;
   double          stepa = 30;
   double          endhole = 1;
   int             debug = 0;
   {
      poptContext     optCon;   /* context for parsing  command - line options */
      const struct poptOption optionsTable[] = {
         {"name", 0, POPT_ARG_STRING | POPT_ARGFLAG_SHOW_DEFAULT, &name, 0, "Name"},
         {"startr", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &startr, 0, "Start (outer) radius"},
         {"width", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &width, 0, "Track width"},
         {"step", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &step, 0, "Step per turn"},
         {"starta", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &starta, 0, "Start angle"},
         {"enda", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &enda, 0, "End angle"},
         {"stepa", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &stepa, 0, "Step angle"},
         {"endhole", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &endhole, 0, "End pad back"},
         {"debug", 'v', POPT_ARG_NONE, &debug, 0, "Debug"},
         POPT_AUTOHELP {}
      };

      optCon = poptGetContext(NULL, argc, argv, optionsTable, 0);
      /* poptSetOtherOptionHelp(optCon, ""); */

      int             c;
      if ((c = poptGetNextOpt(optCon)) < -1)
         errx(1, "%s: %s\n", poptBadOption(optCon, POPT_BADOPTION_NOALIAS), poptStrerror(c));

      poptFreeContext(optCon);
   }

   double          basex = 0,
                   basey = 0;

   double          x(double a)
   {
      double          r = startr - step * a / 360;
      if              (a < 0)
                         r = startr;
                      return r * sin(a * M_PI / 180.0) - basex;
   }
   double          y(double a)
   {
      double          r = startr - step * a / 360;
      if              (a < 0)
                         r = startr;
                      return -r * cos(a * M_PI / 180.0) - basey;
   }

                   printf("(footprint \"%s\" (layer \"F.Cu\") (version 20211014) ", name);
   printf("(attr smd exclude_from_pos_files exclude_from_bom)");
   printf("(pad \"\" thru_hole circle (at %lf %lf) (size %lf %lf) (drill %lf) (layers *.Cu))", -x(enda - endhole), y(enda - endhole), width, width, width / 2);
   void            pad(const char *layer, double flip)
   {
      basex = basey = 0;
      printf("(pad \"\" thru_hole circle (at %lf %lf) (size %lf %lf) (drill %lf) (layers *.Cu))", flip * x(starta), y(starta), width, width, width / 2);
      printf("(pad \"\" smd custom (at %lf %lf) (size %lf %lf) (layers \"%s\") (options (clearance outline) (anchor circle)) (primitives ", basex = x(0), basey = y(0), width, width, layer);
      void            arc(double s, double e)
      {
         double          m = (s + e) / 2;
                         printf("(gr_arc (start %lf %lf) (mid %lf %lf) (end %lf %lf) (width %lf))", flip * x(s), y(s), flip * x(m), y(m), flip * x(e), y(e), width);
      }
      if              (starta < 0)
                         arc(starta, 0);
      else if         (starta > 0 && starta < stepa)
                         arc(starta, stepa);
      double          a;
      for             (a = 0; a + stepa < enda; a += stepa)
                         arc(a, a + stepa);
      if              (a < enda)
                         arc(a, enda);
                      printf("))");
   }
                   pad("F.Cu", 1);
   pad("B.Cu", -1);

   printf(")");
   return 0;
}
