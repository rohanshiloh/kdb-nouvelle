/ run from the repository root:  q mod/tick/cfg/test/run.q -q
\c 60 400
t:use`kx.test;
t.runFile`:mod/tick/cfg/test/cfg.q;
r:t.getReport[];
show r;
show select status:count i by status from r;
x:t.junitReport r; `:out/junit-cfg.xml 0: $[10h=type x; enlist x; x];
\\
