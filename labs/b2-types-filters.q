/ B2 · type checks and filter functions (4.1)
/<< Pattern matching, type checks, filter functions and the pattern
/<< conditional are new in 4.1 (Changes in 4.1, "Pattern matching";
/<< release notes 2024.02.02). Before 4.1 none of these lines parse as shown.
/ a type check: lower case for an atom, upper case for a list
(name:`s;age:`h):(`homer;38h)
(name:`s;age:`h):(`marge;36.5)
(:`f):3f
(:`f):3e
/ patterns in a parameter list
fluxCapacitor:{[(src:`j;dst:`j);speed:`f]$[speed<88;src;dst]}
fluxCapacitor[1955 1985]87.9
fluxCapacitor[1955 1985]88
fluxCapacitor[1955 1985]88.1
/ a null pattern marks an unused parameter
g:{[x;]x}
g[3;4]
/ a filter function runs before the assignment, and can refuse it
tempCheck:{$[x<0;'"too cold";x>40;'"too hot";x]}
c2f:{[x:tempCheck]32+1.8*x}
c2f 20
c2f -4.5
/ or transform the value on the way in
(a;b:10+;c:100+):1 2 3
a,b,c
addv:{([v:(;:x+;:(x*10)+)]):y}
addv[10;([k:`hello;v:1 2 3])]
/ a filter can change the type: the parameter arrives as a string, the body sees longs
chkVals:{$[any null x:"J"$","vs x;'`badData;x]}
sumVals:{[x:chkVals]sum x}
sumVals "1,1,2,3,5,8"
sumVals "8,4,2,1,0.5"
/ the trap: inside a dictionary pattern, k:`s is a constant, not a type check
([k:k:`s]):([k:`hello])
([k:`s]):([k:`hello])
([k:`s]):([k:`s])
