/ A1 · dictionary literals (4.1)
/ the 4.0 way, and the 4.1 way
enlist[`aaa]!enlist 123
([aaa:123])
([aaa:123])~enlist[`aaa]!enlist 123
([a:100;b:200;c:300])
/ bare names take key and value from variables of the same name
a:10
b:20
([a;b])
/ the empty dictionary has symbol keys
([])~(`symbol$())!()
/ an omitted value makes a projection
d:([a:101;b:])
d 102
d each`AA`BB`CC
([k1:;k2:])[1;"a"]
/ edge cases: implicit keys, duplicate keys, non-symbol keys
([0;1;2])
([a:10;b:20;a:40])
([10:`a;20:`b])
/ a file handle as a value needs parentheses: `: reads as the start of an assignment
([log:`:./log])
([log:(`:./log)])
/ order is part of a dictionary
([a:1;b:2])~([b:2;a:1])
