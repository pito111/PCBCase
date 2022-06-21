/* Report KiCad track l;engths */
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

const char *pcbfile = NULL;
int debug=0;

/* strings from file, lots of common, so make a table */
int strn = 0;
const char **strs = NULL;       /* the object tags */
const char *add_string(const char *s, const char *e)
{                               /* allocates a string */
   /* simplistic */
   int n;
   for (n = 0; n < strn; n++)
      if (strlen(strs[n]) == (int) (e - s) && !memcmp(strs[n], s, (int) (e - s)))
         return strs[n];
   strs = realloc(strs, (++strn) * sizeof(*strs));
   if (!strs)
      errx(1, "malloc");
   strs[n] = strndup(s, (int) (e - s));
   return strs[n];
}

typedef struct obj_s obj_t;
typedef struct value_s value_t;

struct value_s {                /* value */
   /* only one set */
   unsigned char isobj:1;       /* object */
   unsigned char isnum:1;       /* number */
   unsigned char isbool:1;      /* boolean */
   unsigned char istxt:1;       /* text */
   union {                      /* the value */
      obj_t *obj;
      double num;
      const char *txt;
      unsigned char bool:1;
   };
};

obj_t *pcb = NULL;

struct obj_s {                  /* an object */
   const char *tag;             /* object tag */
   int valuen;                  /* number of values */
   value_t *values;             /* the values */
};

obj_t *parse_obj(const char **pp, const char *e)
{                               /* Scan an object */
   const char *p = *pp;
   obj_t *pcb = malloc(sizeof(*pcb));
   if (p >= e)
      errx(1, "EOF");
   memset(pcb, 0, sizeof(*pcb));
   if (*p != '(')
      errx(1, "Expecting (\n%.20s\n", p);
   p++;
   if (p >= e)
      errx(1, "EOF");
   /* tag */
   const char *t = p;
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
      value_t *value = pcb->values + pcb->valuen - 1;
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
      if ((p - t) == 4 && !memcmp(t, "true", (int) (p - t)))
      {
         value->isbool = 1;
         value->bool = 1;
         continue;;
      }
      if ((p - t) == 5 && !memcmp(t, "false", (int) (p - t)))
      {
         value->isbool = 1;
         continue;;
      }
      /* does it look like a value number */
      const char *q = t;
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
         char *val = strndup(t, q - t);
         double v = 0;
         if (sscanf(val, "%lf", &v) == 1)
         {                      /* safe as we know followed by space or close bracket and not EOF */
            value->isnum = 1;
            value->num = v;
            free(val);
            continue;
         }
         free(val);
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

void dump_obj(obj_t * o)
{
   printf("(%s", o->tag);
   for (int n = 0; n < o->valuen; n++)
   {
      value_t *v = &o->values[n];
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

obj_t *find_obj(obj_t * o, const char *tag, obj_t * prev)
{
   int n = 0;
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

void load_pcb(void)
{
   int f = open(pcbfile, O_RDONLY);
   if (f < 0)
      err(1, "Cannot open %s", pcbfile);
   struct stat s;
   if (fstat(f, &s))
      err(1, "Cannot stat %s", pcbfile);
   char *data = mmap(NULL, s.st_size, PROT_READ, MAP_PRIVATE, f, 0);
   if (!data)
      errx(1, "Cannot access %s", pcbfile);
   const char *p = data;
   pcb = parse_obj(&p, data + s.st_size);
   munmap(data, s.st_size);
   close(f);
}

void report_len(void)
{
}

int main(int argc, const char *argv[])
{
   {
      poptContext optCon;       /* context for parsing  command - line options */
      const struct poptOption optionsTable[] = {
         { "pcb-file", 'i', POPT_ARG_STRING, &pcbfile, 0, "PCB file", "filename" },
         { "debug", 'v', POPT_ARG_NONE, &debug, 0, "Debug" },
         POPT_AUTOHELP { }
      };

      optCon = poptGetContext(NULL, argc, argv, optionsTable, 0);
      /* poptSetOtherOptionHelp(optCon, ""); */

      int c;
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

   load_pcb();
   report_len();

   return 0;
}
