/ M4 · the tickerplant on modules (run by labs/m4-pubsub.sh)
tp:hopen 5710
rdb:hopen 5711
/ the plant: what it serves, and who subscribes (was count each .u.w)
tp".u.t"
tp"count each .u.subs[]"
/ the vanilla RDB filled itself through the module's .u.sub
rdb"tables[]!count each value each tables[]"
rdb"select n:count i by sym from trade"
/ the filter on upd: a table the plant does not carry is refused, by name
tp".u.upd[`trades;()]"
/ .z.pc was set from inside the module, and closes over the module's names
tp".z.pc"
