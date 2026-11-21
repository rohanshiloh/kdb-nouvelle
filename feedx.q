/ feedx.q : replay Datagen's synthetic trades and quotes into a tickerplant
/ usage:  q feedx.q [::5010 | :host:5010]
([getInMemoryTables]):use`kx.datagen.capmkts
(trade;quote;nbbo;master;exnames):getInMemoryTables[]
/ enumerated columns become plain symbols: the plant has no sym domain to resolve them against
fix:{[t] t:@[t;where(abs type each flip t)within 20 76h;value]; `time xasc update time:"n"$time from `time`sym xcols t}
T:fix trade; Q:fix quote;
/ diagnostics: the schema being sent, and any column that will not serialise for IPC
-1"feedx: trade ",.Q.s1 exec c!t from meta T; -1"feedx: quote ",.Q.s1 exec c!t from meta Q;
bad:{[n;t] if[count b:where not {@[{-8!x;1b};x;0b]} each flip 1#t; -2"feedx: ERROR '",n," columns will not serialise: ",.Q.s1 b; exit 1]}
bad["trade";T]; bad["quote";Q];

/ ":5710" is a FILE named 5710 to hopen; a port needs "::5710" or ":host:5710".
/ (A file handle took the sync probe and ignored it, and refused the async send with 'type.)
a:$[count .z.x; first .z.x; "::5010"]; if[(":"=first a)&not":"in 1_a; a:":",a];
h:neg hopen `$a;
/ diagnostics: the same message, empty, sent four ways. Each line says which step
/ raises the error: building it, serialising it, the plant running it (sync
/ returns the plant's own error), or the async send
pr:{[n;f] -1"feedx: probe ",n,": ",.Q.s1 @[f;::;{"ERROR '",x}]};
pr["build";{m::(".u.upd";`trade;value flip 0#T); type each m}];
pr["serialise";{count -8!m}];
pr["sync";{(abs h) m}];
pr["async";{h m; `sent}];
/ time is already a timespan, so the plant keeps it rather than stamping its own
send:{[t;s] if[count s; h(".u.upd";t;value flip s)]}

it:iq:0; b:50;                                         / 50 trades a tick, quotes in proportion
qb:ceiling b*(count Q)%count T;
tick:{ send[`trade;b sublist it _ T]; it+:b;
       send[`quote;qb sublist iq _ Q]; iq+:qb;
       if[it>=count T; -1"feedx: end of data"; system"t 0"] }
/ a timer error would otherwise print only its name: show the stack, and stop
.z.ts:{.Q.trp[tick;x;{-2"feedx: ERROR '",x,"\n",.Q.sbt y; -2"feedx: h=",(.Q.s1 h)," it=",(string it)," iq=",string iq; system"t 0"}]}
system"t 100";
-1"feedx: ",(string count T)," trades, ",(string count Q)," quotes; \\t 0 to pause";
