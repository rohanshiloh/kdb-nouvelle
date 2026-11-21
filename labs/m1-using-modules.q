/ M1 · using modules (KDB-X)
/ use returns the module's export; you name it
os:use`kx.os
key os
type os.env[]
os.sleep 00:00:00.2
os.proc.start["sort";([stdin:("bbb";"ccc";"aaa");stdout:`text])]
/ a dictionary pattern on an export, then a list pattern on a result
([getInMemoryTables]):use`kx.datagen.capmkts
(trade;quote;nbbo;master;exnames):getInMemoryTables[]
count each ([trade;quote;nbbo;master;exnames])
cols trade
/ a module loads once; a second use returns the cached export
(use`kx.os)~os
/ where use looks
.Q.m.SP
/ outside a module, .z.M is the default namespace
.z.M
