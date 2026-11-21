/ tick.pubsub : the kdb-tick pub/sub engine (tick/u.q) as a KDB-X module

/   ps:use`tick.pubsub

/ Ported line for line from KxSystems/kdb-tick tick/u.q (2019.06.17); every
/ change is marked CHANGE. The wire protocol does not change: subscribers still
/ call .u.sub and receive (`upd;t;x) and (`.u.end;d), so the vanilla r.q and
/ chainedtick.q work against it untouched. tickx.q binds these functions to the
/ .u names subscribers call.

/ CHANGE: no \d .u. A module runs in a namespace of its own, so the bare names
/ below (w, t, sel, add, del) are this module's, bound when each function is
/ defined, and nothing leaks into the root or into .u.

/ CHANGE: init returns t, so the caller can keep its own copy of the table list
init:{w::t!(count t::tables`.)#(); t}

del:{w[x]_:w[x;;0]?y};
/ an absolute name: this still sets the process's .z.pc, and the lambda's del
/ and t are this module's, because that is where it was defined
.z.pc:{del[;x]each t};

sel:{$[`~y;x;select from x where sym in y]}

pub:{[t;x]{[t;x;w]if[count x:sel[x]w 1;(neg first w)(`upd;t;x)]}[t;x]each w t}

/ CHANGE: u.q amended `.u.w, a hard-coded absolute name. .z.M.w is the
/ symbolic name of THIS module's w, wherever the module was loaded.
add:{$[(count w x)>i:w[x;;0]?.z.w;.[.z.M.w;(x;i;1);union;y];w[x],:enlist(.z.w;y)];(x;$[99=type v:value x;sel[v]y;@[0#v;`sym;`g#]])}

sub:{if[x~`;:sub[;y]each t];if[not x in t;'x];del[x].z.w;add[x;y]}

end:{(neg union/[w[;;0]])@\:(`.u.end;x)}

/ NEW: the state is private now, so monitoring reads it through functions.
/ .u.w becomes .u.subs[]; .u.t is kept by the caller from init.
subs:{w}
tabs:{t}

export:([init;del;sel;pub;add;sub;end;subs;tabs])
