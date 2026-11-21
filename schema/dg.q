/ schema/dg.q : the tickerplant's schema, taken from Datagen's own tables
/ tickx.q loads this as its SRC. Datagen decides the columns; this file only
/ enforces the tickerplant contract: time then sym first, time a timespan.
([getInMemoryTables]):use`kx.datagen.capmkts         / a dictionary pattern on a module's export
(trade;quote;nbbo;master;exnames):getInMemoryTables[]  / a list pattern on its result
fix:{[t] t:`time`sym xcols t; update time:"n"$time from t}
trade:0#fix trade;
quote:0#fix quote;
/ only trade and quote are streamed; anything else in the root would become a table the plant serves
delete nbbo, master, exnames, fix, getInMemoryTables from `.;
