/ tests for tick.check, written for KX's Unit Test module (kx.test)
t:use`kx.test;
/ kx.test runs tests in a namespace of its own: shared state goes in setup, as in KX's own tests
t.setup[{chk::use`tick.check; @[`.;`trade;:;([]time:`timespan$();sym:`symbol$();px:`float$();size:`long$())]}]

t.feature`table
t.assertMatch[{chk.table`trade};`trade;([name:"a known table passes"])]
t.assertError[{chk.table`nope};"unknown table: nope";([name:"an unknown table is named"])]
t.assertError[{chk.table"trade"};"type";([name:"a string is not a table name"])]

t.feature`schema
t.assertMatch[{chk.schema[`trade;(0D10:00;`AAPL;182.4;100)]};(0D10:00;`AAPL;182.4;100);([name:"one good row passes"])]
t.assertMatch[{chk.schema[`trade;(2#0D10:00;`AAPL`MSFT;1 2f;3 4)]};(2#0D10:00;`AAPL`MSFT;1 2f;3 4);([name:"a good batch passes"])]
t.assertError[{chk.schema[`trade;(0D10:00;`AAPL;182.4;100f)]};"type: trade size";([name:"a float size is named"])]
t.assertError[{chk.schema[`trade;(0D10:00;`AAPL;182.4)]};"length: trade";([name:"a short row is refused"])]

t.feature`pattern
t.assertMatch[{(x:chk.sym):"AAPL";x};`AAPL;([name:"a filter converts on assignment"])]
t.assertMatch[{(x:chk.schema`trade):(0D10:00;`AAPL;1f;1);x 1};`AAPL;([name:"a projected filter in a pattern"])]
t.assertError[{(x:chk.positive):1 0 2;x};"positive";([name:"a failed filter assigns nothing"])]

t.feature`filters
t.assertMatch[{chk.sym("AAPL";"MSFT")};`AAPL`MSFT;([name:"strings become symbols"])]
t.assertType[{chk.ts 2026.11.21D10:00:00};"n";([name:"a timestamp becomes a timespan"])]
t.assertError[{chk.nonull 1 0N 3};"null";([name:"a null is refused"])]
t.assertMatch[{chk.between[0;10] 3 7};3 7;([name:"inside the range passes"])]
t.assertError[{chk.between[0;10] 3 11};"range";([name:"outside the range is refused"])]
