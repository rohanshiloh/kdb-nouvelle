/ tick.check : filter functions for patterns and parameter lists

/   chk:use`tick.check
/   upd:{[t:chk.table;x] (x:chk.schema t):x; t insert x}
/   (s:chk.sym):"AAPL"

/ Every function here takes a value and either returns it (possibly converted)
/ or signals. Used as a filter in a pattern, it runs BEFORE anything is
/ assigned, so a bad message never reaches a table. Errors name what failed.

/ x names a table that exists in the root
table:{[x:`s] $[x in tables`.; x; '"unknown table: ",string x]}

/ schema[t;x]: x is one row or a batch of columns whose count and types fit table t.
/ Projected as schema t, it is a filter: (x:chk.schema t):x
/ The parameter is tn, not t: inside exec, a column named t would shadow it.
schema:{[tn;x]
  tb:(get `.) tn;                                   / the ROOT table, whatever namespace the caller is in
  m:exec t from 0!meta tb;                          / one type char per column, " " for general
  tx:.Q.t abs type each x;                          / atoms (one row) or vectors (a batch)
  $[(count m)<>count x; '"length: ",string tn;
    any b:(m<>" ") & m<>tx; '"type: ",(string tn)," ",", " sv string (cols tb) where b;
    x] }

/ converts a string, or a list of strings, to symbols; passes symbols through
sym:{$[10h=abs type x; `$x;
       (0h=type x) & all 10h=type each x; `$x;
       11h=abs type x; x;
       '"sym"]}

/ converts timestamps to time of day; passes timespans through
ts:{$[16h=abs type x; x; 12h=abs type x; "n"$x; '"timespan"]}

/ no nulls anywhere in an atom or a vector
nonull:{$[any null x; '"null"; x]}

/ every value strictly positive
positive:{$[all x>0; x; '"positive"]}

/ between[lo;hi]: a filter that keeps values inside [lo;hi]
between:{[lo;hi;x] $[all x within (lo;hi); x; '"range"]}

export:([table;schema;sym;ts;nonull;positive;between])
