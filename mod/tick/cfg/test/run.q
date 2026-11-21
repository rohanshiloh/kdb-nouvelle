/ run from the repository root:  q mod/tick/cfg/test/run.q -q
\c 60 400
t:use`kx.test;
t.runFile`:mod/tick/cfg/test/cfg.q;
r:t.getReport[];
show r;
show select n:count i by status from r;   / not status:count i by status: a 4.0 NUC
x:t.junitReport r; (hsym`$"out/junit-cfg.xml") 0: $[10h=type x; enlist x; x];
/ not `:out/junit-cfg.xml: a symbol literal stops at "-", leaving -cfg.xml as a minus
\\
