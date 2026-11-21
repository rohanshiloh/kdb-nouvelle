/ run from the repository root:  q mod/tick/check/test/run.q -q
/ (run-labs.sh puts mod/ on QPATH so `use` finds tick.check)
\c 60 400
t:use`kx.test;
t.runFile`:mod/tick/check/test/check.q;
r:t.getReport[];
show r;
show select n:count i by status from r;   / not status:count i by status: a 4.0 NUC
x:t.junitReport r; (hsym`$"out/junit-check.xml") 0: $[10h=type x; enlist x; x];
/ not `:out/junit-check.xml: a symbol literal stops at "-", leaving -check.xml as a minus
\\
