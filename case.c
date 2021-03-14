/* Make an OpendScad file from a kicad_pcb file */
/* (c) 2021 Adrian Kennard Andrews & Arnold Ltd */

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

/* yet, all globals, what the hell */
int             debug = 0;
const char     *pcbfile = NULL;
char           *scadfile = NULL;
const char     *modeldir = "PCBCase/models";
double          pcbthickness = 0;
double          pcbwidth = 0;
double          pcblength = 0;
double          casebase = 5;
double          casetop = 5;
double          casewall = 3;
double          fit = 0.2;
double          edge = 2;
double          margin = 0.8;

/* strings from file, lots of common, so make a table */
int             strn = 0;
const char    **strs = NULL;    /* the object tags */
const char     *
add_string(const char *s, const char *e)
{                               /* allocates a string */
   /* simplistic */
   int             n;
   for (n = 0; n < strn; n++)
      if (strlen(strs[n]) == (int)(e - s) && !memcmp(strs[n], s, (int)(e - s)))
         return strs[n];
   strs = realloc(strs, (++strn) * sizeof(*strs));
   if (!strs)
      errx(1, "malloc");
   strs[n] = strndup(s, (int)(e - s));
   return strs[n];
}

typedef struct obj_s obj_t;
typedef struct value_s value_t;

struct value_s
{                               /* value */
   /* only one set */
   unsigned char   isobj:1;     /* object */
   unsigned char   isnum:1;     /* number */
   unsigned char   isbool:1;    /* boolean */
   unsigned char   istxt:1;     /* text */
   union
   {                            /* the value */
      obj_t          *obj;
      double          num;
      const char     *txt;
      unsigned char   bool:1;
   };
};

obj_t          *pcb = NULL;

struct obj_s
{                               /* an object */
   const char     *tag;         /* object tag */
   int             valuen;      /* number of values */
   value_t        *values;      /* the values */
};

obj_t          *
parse_obj(const char **pp, const char *e)
{                               /* Scan an object */
   const char     *p = *pp;
   obj_t          *pcb = malloc(sizeof(*pcb));
   if (p >= e)
      errx(1, "EOF");
   memset(pcb, 0, sizeof(*pcb));
   if (*p != '(')
      errx(1, "Expecting (\n%.20s\n", p);
   p++;
   if (p >= e)
      errx(1, "EOF");
   /* tag */
   const char     *t = p;
   while (p < e && (isalnum(*p) || *p == '_'))
      p++;
   if (p == t)
      errx(1, "Expecting tag\n%.20s\n", t);
   pcb->tag = add_string(t, p);
   /* values */
   while (p < e)
   {
      while (p < e && isspace(*p))
         p++;
      if (*p == ')')
         break;
      pcb->values = realloc(pcb->values, (++(pcb->valuen)) * sizeof(*pcb->values));
      if (!pcb->values)
         errx(1, "malloc");
      value_t        *value = pcb->values + pcb->valuen - 1;
      memset(value, 0, sizeof(*value));
      /* value */
      if (*p == '(')
      {
         value->isobj = 1;
         value->obj = parse_obj(&p, e);
         continue;
      }
      if (*p == '"')
      {                         /* quoted text */
         p++;
         t = p;
         while (p < e && *p != '"')
            p++;
         if (p == e)
            errx(1, "EOF");
         value->istxt = 1;
         value->txt = add_string(t, p);
         p++;
         continue;
      }
      t = p;
      while (p < e && *p != ')' && *p != ' ')
         p++;
      if (p == e)
         errx(1, "EOF");
      /* work out some basic types */
      if ((p - t) == 4 && !memcmp(t, "true", (int)(p - t)))
      {
         value->isbool = 1;
         value->bool = 1;
         continue;;
      }
      if ((p - t) == 5 && !memcmp(t, "false", (int)(p - t)))
      {
         value->isbool = 1;
         continue;;
      }
      /* does it look like a value number */
      const char     *q = t;
      if (q < p && *q == '-')
         q++;
      while (q < p && isdigit(*q))
         q++;
      if (q < p && *q == '.')
      {
         q++;
         while (q < p && isdigit(*q))
            q++;
      }
      if (q == p)
      {                         /* seems legit */
         double          v = 0;
         if (sscanf(t, "%lf", &v) == 1)
         {                      /* safe as we know followed by space or close bracket and not EOF */
            value->isnum = 1;
            value->num = v;
            continue;
         }
      }
      /* assume string */
      value->istxt = 1;
      value->txt = add_string(t, p);
   }
   if (p >= e)
      errx(1, "EOF");
   if (*p != ')')
      errx(1, "Expecting )\n%.20s\n", p);
   p++;
   while (p < e && isspace(*p))
      p++;
   *pp = p;
   return pcb;
}

void
dump_obj(obj_t * o)
{
   printf("(%s", o->tag);
   for (int n = 0; n < o->valuen; n++)
   {
      value_t        *v = &o->values[n];
      if (v->isobj)
         dump_obj(v->obj);
      else if (v->istxt)
         printf(" \"%s\"", v->txt);
      else if (v->isnum)
         printf(" %lf", v->num);
      else if (v->isbool)
         printf(" %s", v->bool ? "true" : "false");
   }
   printf(")\n");
}

obj_t          *
find_obj(obj_t * o, const char *tag, obj_t * prev)
{
   int             n = 0;
   if (prev)
      for (; n < o->valuen; n++)
         if (o->values[n].isobj && o->values[n].obj == prev)
         {
            n++;
            break;
         }
   for (; n < o->valuen; n++)
      if (o->values[n].isobj && !strcmp(o->values[n].obj->tag, tag))
         return o->values[n].obj;
   return NULL;
}

void
load_pcb(void)
{
   int             f = open(pcbfile, O_RDONLY);
   if (f < 0)
      err(1, "Cannot open %s", pcbfile);
   struct stat     s;
   if (fstat(f, &s))
      err(1, "Cannot stat %s", pcbfile);
   char           *data = mmap(NULL, s.st_size, PROT_READ, MAP_PRIVATE, f, 0);
   if (!data)
      errx(1, "Cannot access %s", pcbfile);
   const char     *p = data;
   pcb = parse_obj(&p, data + s.st_size);
   munmap(data, s.st_size);
   close(f);
}

void
copy_file(FILE * o, const char *fn)
{
   int             f = open(fn, O_RDONLY);
   if (f < 0)
      err(1, "Cannot open %s", fn);
   struct stat     s;
   if (fstat(f, &s))
      err(1, "Cannot stat %s", fn);
   char           *data = mmap(NULL, s.st_size, PROT_READ, MAP_PRIVATE, f, 0);
   if (!data)
      errx(1, "Cannot access %s", fn);
   fwrite(data, s.st_size, 1, o);
   munmap(data, s.st_size);
   close(f);
}

void
write_scad(void)
{
   obj_t          *o,
                  *o2,
                  *o3;
   /* making scad file */
   FILE           *f = stdout;
   if (strcmp(scadfile, "-"))
      f = fopen(scadfile, "w");
   if (!f)
      err(1, "Cannot open %s", scadfile);

   if (chdir(modeldir))
      errx(1, "Cannot access model dir %s", modeldir);

   if (strcmp(pcb->tag, "kicad_pcb"))
      errx(1, "Not a kicad_pcb (%s)", pcb->tag);
   obj_t          *general = find_obj(pcb, "general", NULL);
   if (general)
   {
      if ((o = find_obj(general, "thickness", NULL)) && o->valuen == 1 && o->values[0].isnum)
         pcbthickness = o->values[0].num;
   }
   fprintf(f, "// Generated case design for %s\n", pcbfile);
   fprintf(f, "// By https://github.com/revk/PCBCase\n");
   if ((o = find_obj(pcb, "title_block", NULL)))
      for (int n = 0; n < o->valuen; n++)
         if (o->values[n].isobj && (o2 = o->values[n].obj)->valuen >= 1)
         {
            if (o2->values[o2->valuen - 1].istxt)
               fprintf(f, "// %s:\t%s\n", o2->tag, o2->values[o2->valuen - 1].txt);
            else if (o2->values[0].isnum)
               fprintf(f, "// %s:\t%lf\n", o2->tag, o2->values[0].num);
         }
   fprintf(f, "//\n\n");
   fprintf(f, "// Globals\n");
   fprintf(f, "margin=%lf;\n", margin);
   fprintf(f, "casebase=%lf;\n", casebase);
   fprintf(f, "casetop=%lf;\n", casetop);
   fprintf(f, "casewall=%lf;\n", casewall);
   fprintf(f, "fit=%lf;\n", fit);
   fprintf(f, "edge=%lf;\n", edge);
   fprintf(f, "pcbthickness=%lf;\n", pcbthickness);

   double          lx = DBL_MAX,
                   hx = -DBL_MAX,
                   ly = DBL_MAX,
                   hy = -DBL_MAX;
   double          ry;          /* reference for Y, as it is flipped! */
   /* sanity */
   if (!pcbthickness)
      errx(1, "Specify pcb thickness");
   {                            /* Edge cuts */
      struct
      {
         double          x1,
                         y1;
         double          x2,
                         y2;
         unsigned char   used:1;
      }              *cuts = NULL;
      int             cutn = 0;
      o = NULL;
      while ((o = find_obj(pcb, "gr_line", o)))
         if ((o2 = find_obj(o, "layer", NULL)) && o2->valuen == 1 && o2->values[0].istxt && !strcmp(o2->values[0].txt, "Edge.Cuts"))
         {                      /* scan the edge cuts */
            if (!(o2 = find_obj(o, "start", NULL)) || !o2->values[0].isnum || !o2->values[1].isnum)
               continue;
            double          x1 = o2->values[0].num,
                            y1 = o2->values[1].num;
            if (!(o2 = find_obj(o, "end", NULL)) || !o2->values[0].isnum || !o2->values[1].isnum)
               continue;
            double          x2 = o2->values[0].num,
                            y2 = o2->values[1].num;
            if (x1 < lx)
               lx = x1;
            if (x1 > hx)
               hx = x1;
            if (y1 < ly)
               ly = y1;
            if (y1 > hy)
               hy = y1;
            if (x2 < lx)
               lx = x2;
            if (x2 > hx)
               hx = x2;
            if (y2 < ly)
               ly = y2;
            if (y2 > hy)
               hy = y2;
            cuts = realloc(cuts, (cutn + 1) * sizeof(*cuts));
            if (!cuts)
               errx(1, "malloc");
            cuts[cutn].used = 0;
            cuts[cutn].x1 = x1;
            cuts[cutn].y1 = y1;
            cuts[cutn].x2 = x2;
            cuts[cutn].y2 = y2;
            cutn++;
         }
      if (lx < DBL_MAX)
         pcbwidth = hx - lx;
      if (ly < DBL_MAX)
         pcblength = hy - ly;
      ry = hy;
      fprintf(f, "pcbwidth=%lf;\n", pcbwidth);
      fprintf(f, "pcblength=%lf;\n", pcblength);
      fprintf(f, "\n");
      fprintf(f, "// PCB\nmodule pcb(){");
      if (cutn)
      {                         /* Edge cut */
         double          x = cuts[0].x2,
                         y = cuts[0].y2;
         fprintf(f, "linear_extrude(height=%lf)polygon([", pcbthickness);
         int             todo = cutn;
         while (todo--)
         {
            int             n;
            for (n = 0; n < cutn; n++)
               if (!cuts[n].used && cuts[n].x1 == x && cuts[n].y1 == y)
                  break;
            if (n < cutn)
            {
               x = cuts[n].x2;
               y = cuts[n].y2;
            } else
            {
               for (n = 0; n < cutn; n++)
                  if (!cuts[n].used && cuts[n].x2 == x && cuts[n].y2 == y)
                     break;
               if (n == cutn)
                  break;
               x = cuts[n].x1;
               y = cuts[n].y1;
            }
            cuts[n].used = 1;
            fprintf(f, "[%lf,%lf]", x - lx, ry - y);
            if (todo)
               fprintf(f, ",");
         }
         fprintf(f, "]);");

      } else if (pcbwidth && pcblength)
         fprintf(f, "cube([%lf,%lf,%lf]);", pcbwidth, pcblength, pcbthickness); /* cuboid */
      fprintf(f, "}\n\n");
      free(cuts);
   }
   if (!pcbwidth || !pcblength)
      errx(1, "Specify pcb size");

   struct
   {
      char           *filename;
      char           *desc;
      unsigned char   ok:1;
   }              *modules = NULL;
   int             modulen = 0;

   /* The main PCB */
   fprintf(f, "// Populated PCB\nmodule board(){\n	pcb();\n");
   o = NULL;
   while ((o = find_obj(pcb, "module", o)))
   {
      char            back = 0; /* back of board */
      if (!(o2 = find_obj(o, "layer", NULL)) || o2->valuen != 1 || !o2->values[0].istxt)
         continue;
      if (!strcmp(o2->values[0].txt, "B.Cu"))
         back = 1;
      else if (strcmp(o2->values[0].txt, "F.Cu"))
         continue;
      o2 = NULL;
      while ((o2 = find_obj(o, "model", o2)))
      {
         if (o2->valuen < 1 || !o2->values[0].istxt)
            continue;           /* Not 3D model */
         char           *model = strdup(o2->values[0].txt);
         if (!model)
            errx(1, "malloc");
         char           *leaf = strrchr(model, '/');
         if (leaf)
            leaf++;
         else
            leaf = model;
         char           *e = strrchr(model, '.');
         if (e)
            *e = 0;
         char           *fn;
         if (asprintf(&fn, "%s.scad", leaf) < 0)
            errx(1, "malloc");
         int             n;
         for (n = 0; n < modulen; n++)
            if (!strcmp(modules[n].filename, fn))
               break;
         if (n == modulen)
         {
            modules = realloc(modules, (++modulen) * sizeof(*modules));
            if (!modules)
               errx(1, "malloc");
            memset(modules + n, 0, sizeof(*modules));
            modules[n].filename = fn;
            if (o->valuen >= 1 && o->values[0].istxt)
               modules[n].desc = strdup(o->values[0].txt);
            else
               modules[n].desc = strdup(leaf);
            if (access(modules[n].filename, R_OK))
               warnx("Cannot find model for %s", leaf);
            else
               modules[n].ok = 1;
         } else
            free(fn);
         if (modules[n].ok)
         {
            if ((o3 = find_obj(o, "at", NULL)) && o3->valuen >= 2 && o3->values[0].isnum && o3->values[1].isnum)
            {
               fprintf(f, "translate([%lf,%lf,%lf])", o3->values[0].num - lx, ry - o3->values[1].num, back ? 0 : pcbthickness);
               if (o3->valuen >= 3 && o2->values[2].num)
                  fprintf(f, "rotate([0,0,%lf])", o3->values[2].num);
            }
            if (back)
               fprintf(f, "rotate([180,0,0])");
            /* we assume 3D model is aligned, not using the offset/scale/etc of the footprint model */
            /* if we do pick up offset, remember y is negative */
            fprintf(f, "m%d(); // %s\n", n, modules[n].desc);
         } else
            fprintf(f, "// Missing %s\n", modules[n].desc);
         free(model);
      }
   }
   fprintf(f, "}\n\n");

   /* Used models */
   for (int n = 0; n < modulen; n++)
      if (modules[n].ok)
      {
         fprintf(f, "module m%d()\n{ // %s\n", n, modules[n].desc);
         copy_file(f, modules[n].filename);
         fprintf(f, "}\n\n");
      }
   /* Final SCAD */
   copy_file(f, "final.scad");

   if (f != stdout)
      fclose(f);
}

int
main(int argc, const char *argv[])
{
   {                            /* POPT */
      poptContext     optCon;   /* context for parsing  command - line options */
      const struct poptOption optionsTable[] = {
         {"pcb-file", 'f', POPT_ARG_STRING, &pcbfile, 0, "PCB file", "filename"},
         {"scad-file", 'o', POPT_ARG_STRING, &scadfile, 0, "Openscad file", "filename"},
         {"model-dir", 'm', POPT_ARG_STRING | POPT_ARGFLAG_SHOW_DEFAULT, &modeldir, 0, "Model directory", "dir"},
         {"width", 0, POPT_ARG_DOUBLE, &pcbwidth, 0, "PCB width (default: auto)", "mm"},
         {"length", 0, POPT_ARG_DOUBLE, &pcblength, 0, "PCB length (default: auto)", "mm"},
         {"pcb-thickness", 0, POPT_ARG_DOUBLE, &pcbthickness, 0, "PCB thickness (default: auto)", "mm"},
         {"base", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &casebase, 0, "Case base", "mm"},
         {"top", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &casetop, 0, "Case top", "mm"},
         {"wall", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &casewall, 0, "Case wall", "mm"},
         {"fit", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &fit, 0, "Case fit", "mm"},
         {"edge", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &edge, 0, "Case edge", "mm"},
         {"margin", 0, POPT_ARG_DOUBLE | POPT_ARGFLAG_SHOW_DEFAULT, &margin, 0, "margin", "mm"},
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
   load_pcb();
   write_scad();

   return 0;
}
