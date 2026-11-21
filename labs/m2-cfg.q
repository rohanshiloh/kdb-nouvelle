/ M2 · writing a module: tick.cfg (KDB-X)
cfg:use`tick.cfg
key cfg
spec:([port:5010;logdir:(`:./log);tables:`trade`quote;pubMs:100])
cfg.load spec
/ the environment overrides a default, and is parsed to the default's type
setenv[`TICK_PORT;"6010"]
cfg.load spec
/ take only what you need with a dictionary pattern
([port;tables]):cfg.load spec
port
/ a value that does not parse is refused by name
setenv[`TICK_PORT;"oops"]
cfg.load spec
/ setenv with :: unsets (KDB-X 2026.10.15)
setenv[`TICK_PORT;::]
cfg.load[spec]`port
/ load's parameter filter refuses anything that is not a spec
cfg.load 1 2 3
/ load is a keyword: a plain load:{…} is refused, so the module defines .z.m.load
load:{x}
