/* Make an OpendScad file from a kicad_pcb file */
/* (c) 2021 Adrian Kennard Andrews & Arnold Ltd */

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <popt.h>
#include <err.h>
#include <math.h>

#include "models.h"             /* the 3D models */

int             debug = 0;
double          casethickness = 3;
double          casewidth = 0;
double          caselength = 0;
double          casebase = 10;
double          casetop = 10;

int
main(int argc, const char *argv[])
{
   const char     *pcbfile = NULL;
   char           *scadfile = NULL;
   {                            /* POPT */
      poptContext     optCon;   /* context for parsing  command - line options */
      const struct poptOption optionsTable[] = {
         {"pcb-file", 'f', POPT_ARG_STRING, &pcbfile, 0, "PCB file", "filename"},
         {"scad-file", 'o', POPT_ARG_STRING, &scadfile, 0, "Openscad file", "filename"},
         {"width", 0, POPT_ARG_DOUBLE, &casewidth, 0, "Case width", "mm"},
         {"length", 0, POPT_ARG_DOUBLE, &caselength, 0, "Case length", "mm"},
         {"base", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &casebase, 0, "Case base", "mm"},
         {"top", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &casetop, 0, "Case top", "mm"},
         {"thickness", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &casethickness, 0, "Case thickness", "mm"},
         {"debug", 'v', POPT_ARG_NONE, &debug, 0, "Debug"},
         POPT_AUTOHELP {}
      };

      optCon = poptGetContext(NULL, argc, argv, optionsTable, 0);
      /* poptSetOtherOptionHelp(optCon, ""); */

      int             c;
      if ((c = poptGetNextOpt(optCon)) < -1)
         errx(1, "%s: %s\n", poptBadOption(optCon, POPT_BADOPTION_NOALIAS), poptStrerror(c));

      if (poptPeekArg(optCon) && !pcbfile)
         pcbfile = poptGetArg(optCon);

      if (poptPeekArg(optCon) || !pcbfile)
      {
         poptPrintUsage(optCon, stderr, 0);
         return -1;
      }
      poptFreeContext(optCon);
   }
   if (!scadfile)
   {
      const char     *f = strrchr(pcbfile, '/');
      if (f)
         f++;
      else
         f = pcbfile;
      const char     *e = strrchr(f, '.');
      if (!e || !strcmp(e, ".scad"))
         e = f + strlen(f);
      if (asprintf(&scadfile, "%.*s.scad", (int)(e - pcbfile), pcbfile) < 0)
         errx(1, "malloc");
   }

   /* parsing the pcb file */
   FILE *f=fopen(pcbfile,"r");
   if(!f)err(1,"Cannot open %s",pcbfile);

   fclose(f);

   /* making scad file */
   f=fopen(scadfile,"w");
   if(!f)err(1,"Cannot open %s",scadfile);

   fclose(f);

   return 0;
}
