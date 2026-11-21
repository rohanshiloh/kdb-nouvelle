/ tick.cfg : typed configuration from defaults, the environment and the command line

/   cfg:use`tick.cfg
/   c:cfg.load ([port:5010;logdir:`:./log;tabs:`trade`quote])
/   ([port;tabs]):cfg.load spec                  / take just what you need

/ A spec is a dictionary literal of defaults. The TYPE of each default is the type
/ the setting must have: strings from the environment or the command line are
/ parsed to it, and anything that does not parse is refused by name.
/ Precedence, lowest to highest:  default  <  TICK_<NAME> in the environment  <  -name on the command line

/ parse one string to the type of its default
cast:{[d;s] t:type d;
  $[10h=t; s;                                      / a string stays a string
    0h>t;  (upper .Q.t abs t)$s;                   / an atom: "J"$"5010"
    11h=t; `$" " vs s;                             / a symbol list: space separated
           (upper .Q.t t)$" " vs s] }              / any other vector

/ a value is missing if it is a null atom or an empty list
missing:{$[0>type x; null x; 0=count x]}

/ settings named in the environment, as TICK_PORT, TICK_LOGDIR, ...
env:{[spec] n:key spec; v:getenv each `$"TICK_",/:upper string n;
  n[w]!v w:where 0<count each v }

/ settings named on the command line, as -port 6010 -tables trade quote
cli:{[spec] o:.Q.opt .z.x; o:(key[o] inter key spec)#o; {" " sv x} each o }

/ a filter for load's parameter: a dictionary keyed by symbols, or a 'cfg error.
/ Defined before load, so the name exists when load's parameter list is read.
isSpec:{$[(99h=type x) & 11h=type key x; x; '"cfg: a spec is a dictionary of defaults"]}

/ load is a q keyword, so a module can only define it under .z.m
.z.m.load:{[spec:isSpec]
  s:(env spec),cli spec;                           / later keys win: the command line beats the environment
  k:key s; v:cast'[spec k;value s];
  if[count b:k where missing'[v] & not missing'[spec k]; '"cfg: cannot parse ",", " sv string b];
  spec,k!v }

export:([.z.m.load;cast;env;cli])
