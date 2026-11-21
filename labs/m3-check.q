/ M3 · filters as a library: tick.check (KDB-X)
chk:use`tick.check
trade:([]time:`timespan$();sym:`symbol$();px:`float$();size:`long$())
chk.table`trade
chk.table`nope
chk.schema[`trade;(0D10:00;`AAPL;182.4;100)]
chk.schema[`trade;(0D10:00;`AAPL;182.4;100f)]
/ an upd that refuses bad messages before anything is inserted
upd:{[t:chk.table;x] (x:chk.schema t):x; t insert x}
upd[`trade;(0D10:00;`AAPL;182.4;100)]
upd[`trade;(0D10:00;`AAPL;182.4;100f)]
upd[`trades;(0D10:00;`AAPL;182.4;100)]
count trade
/ filters that convert
(s:chk.sym):"AAPL"
s
chk.ts 2026.11.21D10:00:00
