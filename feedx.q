/ feedx.q : replay Datagen's synthetic trades and quotes into a tickerplant
/ usage:  q feedx.q [:host]:5010
([getInMemoryTables]):use`kx.datagen.capmkts
(trade;quote;nbbo;master;exnames):getInMemoryTables[]
fix:{[t] `time xasc update time:"n"$time from `time`sym xcols t}
T:fix trade; Q:fix quote;

h:neg hopen `$$[count .z.x; first .z.x; ":5010"];
/ time is already a timespan, so the plant keeps it rather than stamping its own
send:{[t;s] if[count s; h(".u.upd";t;value flip s)]}

it:iq:0; b:50;                                         / 50 trades a tick, quotes in proportion
qb:ceiling b*(count Q)%count T;
.z.ts:{ send[`trade;b sublist it _ T]; it+:b;
        send[`quote;qb sublist iq _ Q]; iq+:qb;
        if[it>=count T; -1"feedx: end of data"; system"t 0"] }
system"t 100";
-1"feedx: ",(string count T)," trades, ",(string count Q)," quotes; \\t 0 to pause";
