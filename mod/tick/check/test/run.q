/ run from the repository root:  q mod/tick/check/test/run.q -q
/ (run-labs.sh puts mod/ on QPATH so `use` finds tick.check)
\c 60 400
t:use`kx.test;
t.runFile`:mod/tick/check/test/check.q;
r:t.getReport[];
show r;
show select status:count i by status from r;
x:t.junitReport r; `:out/junit-check.xml 0: $[10h=type x; enlist x; x];
\\
