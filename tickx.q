/ tickx.q : KxSystems/kdb-tick tick.q (2014.03.12), brought forward to KDB-X.
/ Diff it against vendor/tick.q: every change is marked CHANGE.
/q tickx.q SRC [DST] [-p 5010]
"tickx 2026.11 (kdb-tick 2.8 2014.03.12)"

/ CHANGE: the schema lives in schema/, not tick/, because tick/ is KX's code
system"l schema/",(src:first .z.x,enlist"dg"),".q"

if[not system"p";system"p 5010"]

/ CHANGE: the pub/sub engine is a module, not a script loaded into .u.
/ Bound from the ROOT with qualified names: after \d .u, a bare ps would be
/ read as .u.ps (a global is looked up in the namespace it is defined in).
ps:use`tick.pubsub
.u.init:ps.init; .u.del:ps.del; .u.sel:ps.sel; .u.pub:ps.pub; .u.add:ps.add;
.u.sub:ps.sub;   .u.end:ps.end; .u.subs:ps.subs
/ CHANGE: upd's table argument is checked by a filter before upd runs
.u.chk:use`tick.check

\d .u
ld:{if[not type key L::`$(-10_string L),string x;.[L;();:;()]];i::j::-11!(-2;L);if[0<=type i;-2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";exit 1];hopen L};
/ CHANGE: init returns the table list; u.q set .u.t itself
tick:{t::init[];if[not min(`time`sym~2#key flip value@)each t;'`timesym];@[;`sym;`g#]each t;d::.z.D;if[l::count y;L::`$":",y,"/",x,10#".";l::ld d]};

endofday:{end d;d+:1;if[l;hclose l;l::0(`.u.ld;d)]};
ts:{if[d<x;if[d<x-1;system"t 0";'"more than one day?"];endofday[]]};

/ CHANGE: [t:chk.table;x] - a message for a table this plant does not carry is
/ refused with 'unknown table: <name> before it is logged or published
if[system"t";
 .z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;ts .z.D};
 upd:{[t:chk.table;x]
 if[not -16=type first first x;if[d<"d"$a:.z.P;.z.ts[]];a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 t insert x;if[l;l enlist (`upd;t;x);j+:1];}];

if[not system"t";system"t 1000";
 .z.ts:{ts .z.D};
 upd:{[t:chk.table;x]ts"d"$a:.z.P;
 if[not -16=type first first x;a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 f:key flip value t;pub[t;$[0>type first x;enlist f!x;flip f!x]];if[l;l enlist (`upd;t;x);i+:1];}];

\d .
.u.tick[src;.z.x 1];

\
 globals used
 .u.subs[] - dictionary of tables->(handle;syms)   CHANGE: was the variable .u.w
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./dg2026.11.21
 .u.l - handle to tp log file
 .u.d - date

/run
>q tickx.q dg ./log -p 5010           /tick
>q vendor/tick/r.q :5010 -p 5011      /rdb
>q feedx.q :5010                      /feed (Datagen)
