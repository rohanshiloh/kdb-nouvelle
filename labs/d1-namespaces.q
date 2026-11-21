/ D1 · where a global name is looked up
mult:4
\d .foo
mult:3
f:{x*mult}
\d .
/ bound when defined: .foo.f reads .foo.mult, whatever namespace calls it
.foo.f 1
/ the open question: a name only the root defines, read from inside .foo
rootOnly:42
\d .foo
g:{rootOnly}
\d .
.foo.g[]
/ the same function written from the root with a qualified name
.foo.h:{rootOnly}
.foo.h[]
/ the q.ns) prefix defines a function in a namespace without \d
.foo.mult2:5
q.foo)k:{x*mult2}
.foo.k 1
/ a namespace can hold namespaces; can \d go two levels deep?
.a.b.c:1
key `.a
\d .a.b
\d
\d .
/ a whole namespace can be deleted (KDB-X 2026.10.15)
delete foo from `
`foo in key `
