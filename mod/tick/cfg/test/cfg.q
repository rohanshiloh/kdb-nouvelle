/ tests for tick.cfg, written for KX's Unit Test module (kx.test)
t:use`kx.test;
/ kx.test runs tests in a namespace of its own: shared state goes in setup, as in KX's own tests
t.setup[{cfg::use`tick.cfg; spec::([port:5010;logdir:`:./log;tabs:`trade`quote;name:"tp"])}]

t.feature`cast
t.assertMatch[{cfg.cast[5010;"6010"]};6010;([name:"a long"])]
t.assertMatch[{cfg.cast[`trade`quote;"trade quote nbbo"]};`trade`quote`nbbo;([name:"a symbol list"])]
t.assertMatch[{cfg.cast["tp";"tp2"]};"tp2";([name:"a string stays a string"])]
t.assertNull[{cfg.cast[5010;"oops"]};([name:"a bad long is null"])]

t.feature`load
t.beforeEach[{setenv[`TICK_PORT;::]}]            / every test starts with TICK_PORT unset
t.assertMatch[{cfg.load spec};([port:5010;logdir:`:./log;tabs:`trade`quote;name:"tp"]);([name:"defaults when nothing is set"])]
t.assertMatch[{setenv[`TICK_PORT;"6010"]; cfg.load[spec]`port};6010;([name:"the environment overrides a default"])]
t.assertError[{setenv[`TICK_PORT;"oops"]; cfg.load spec};"cfg: cannot parse port";([name:"a bad value is named"])]
t.assertError[{cfg.load 1 2 3};"cfg: a spec is a dictionary of defaults";([name:"the parameter filter refuses a list"])]
t.assertMatch[{([port;tabs]):cfg.load spec; (port;tabs)};(5010;`trade`quote);([name:"a dictionary pattern takes what it needs"])]
