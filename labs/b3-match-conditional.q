/ B3 · the pattern conditional :[v;p1;r1;…;rd] (4.1)
a: :[1i;r:`f;"float";r:`i;"int";"other"]
a
/ the first pattern that matches wins; later branches are never evaluated
kind:{:[x;r:`s;"sym";r:`j;"long";r:`F;"floats";"other"]}
kind each (`a;1;1 2f;"x")
/ a dictionary pattern as a branch: route a message by its shape
route:{:[x;([px:p:`f;sz:s:`j]);`trade;([bid:b:`f;ask:k:`f]);`quote;`unknown]}
route ([px:182.4;sz:100])
route ([bid:182.4;ask:182.42])
route ([foo:1])
