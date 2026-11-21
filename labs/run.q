/ kdb-nouvelle : lab runner
/ usage:  q labs/run.q labs/a1-dict-literals.q -q </dev/null
/ Reads a lab file and runs it line by line, printing each line as the console
/ would show it ("q)" then the result, or "'" then the error). Comment lines
/ starting "/ " are printed as they are.
/ Written in pre-4.1 syntax on purpose: the same runner has to work on 4.0, 4.1
/ and KDB-X, and a lab line that only parses on a newer version must fail as
/ that line, not take the runner down with it.

\c 40 160
-1 "/ ",(string .z.K)," ",(string .z.k)," ",string .z.o;

/ an assignment prints nothing at the console; neither does it here
.lab.isAsg:{@[{(:)~first parse x};x;0b]}

/ \cmd lines go through system so their output (e.g. \d) is shown
.lab.eval:{$["\\"=first x; system 1_x; value x]}

.lab.run:{[s]
  -1 "q)",s;
  r:@[{(1b;.lab.eval x)};s;{(0b;x)}];
  if[not r 0; :-1 "'",r 1];
  if[(.lab.isAsg s)|(";"=last s)|(::)~r 1; :()];
  1 .Q.s r 1; }

.lab.L:read0 hsym `$first .z.x;
.lab.L:.lab.L where 0<count each .lab.L;
{$["/"=first x; -1 x; .lab.run x]} each .lab.L;
\\
