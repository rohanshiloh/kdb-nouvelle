/ M4 diagnostics (run by labs/m4-pubsub.sh after the feed has finished).
/ Counts every row three ways (what the feed sent, what the plant logged,
/ what the RDB holds) and says whether they agree. Exits 1 if they do not.
/ usage:  q labs/inc/m4-verify.q <trades sent> <quotes sent> -q
sent:`trade`quote!"J"$2#.z.x
tp:hopen 5710; rdb:hopen 5711

/ the plant's log, replayed here with an upd that only counts
L:tp".u.L"
logged:`trade`quote!0 0
upd:{[t;x] if[t in key logged; logged[t]+:count first x]}
msgs:-11!L

held:`trade`quote!rdb each ("count trade";"count quote")
r:([] tab:`trade`quote; sent:sent`trade`quote; logged:logged`trade`quote; rdb:held`trade`quote)
r:update ok:(sent=logged)&logged=rdb from r
-1 "plant log ",(1_string L),": ",(string msgs)," messages";
show r
-1 $[all r`ok; "m4 verify: OK, every row sent reached the log and the RDB";
              "m4 verify: MISMATCH, rows were lost between feed, log and RDB"];
exit `int$not all r`ok
