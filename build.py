#!/usr/bin/env python3
"""kdb-nouvelle : build index.html from src/ and the lab outputs in out/.

    python3 build.py

src/body.html holds the prose. These markers are replaced:
  <!--LAB:name-->    a syntax lab: kdb+ 4.x and KDB-X transcripts side by side
  <!--MLAB:name-->   a module lab: the KDB-X transcript alone
  <!--FILE:path-->   a source file, in a copyable pane
  <!--DIFF:a|b-->    a unified diff of two files (skipped if a is missing)
  <!--TEST:name-->   a unit-test report from out/test-<name>.x.txt
A lab file carries its own Before column: under a line of q, "/< text" says what
that line did before the change, per KX's release notes; "/<< text" is a note
about the whole lab. The runner skips both.
Transcripts come from labs/run.q via run-labs.sh. Where the two versions give
a different result for the same line, both results are highlighted.
"""
import hashlib
import difflib, html, os, re

ROOT = os.path.dirname(os.path.abspath(__file__))
P = lambda *a: os.path.join(ROOT, *a)
esc = html.escape


def read(path):
    try:
        with open(P(path), encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return None


def blocks(text):
    """Split a transcript into (header, [(prompt, [result lines])])."""
    lines = text.rstrip("\n").split("\n")
    head = lines[0][2:] if lines and lines[0].startswith("/ ") else ""
    body = lines[1:] if head else lines
    out, cur = [], None
    for ln in body:
        if ln.startswith("q)") or ln.startswith("/ "):        # a prompt, or a comment from the lab file
            cur = (ln, [])
            out.append(cur)
        elif cur is None:
            cur = ("", [ln])
            out.append(cur)
        else:
            cur[1].append(ln)
    return head, out


def render(bl, other):
    """HTML for one transcript; results that differ from the other version are marked."""
    keyed = {}
    if other is not None:
        for p, r in other:
            keyed.setdefault(p, []).append(r)
    seen, rows = {}, []
    for p, r in bl:
        n = seen.get(p, 0)
        seen[p] = n + 1
        if p.startswith("/ "):
            rows.append('<span class="pc">%s</span>' % esc(p))
            continue
        rows.append('<span class="pq">%s</span>' % esc(p))
        alt = keyed.get(p, [])
        differs = n < len(alt) and alt[n] != r          # same line, different result
        if differs and any(ln.startswith("— new") for ln in alt[n] + r):
            differs = False                               # "new" is not a behaviour change
        for ln in r:
            cls = "er" if ln.startswith("'") else ""
            if differs:
                cls = (cls + " dl").strip()
            rows.append('<span class="%s">%s</span>' % (cls, esc(ln)) if cls else esc(ln))
    return "\n".join(rows)


STALE = []


def stale(name, out):
    """A transcript made from a different version of its lab no longer shows what the lab says.
    run.q writes "lab <md5>" in the header; transcripts without it fall back to file times."""
    src, o = P("labs/%s.q" % name), P(out)
    if not (os.path.exists(src) and os.path.exists(o)):
        return False
    with open(o, encoding="utf-8", errors="replace") as f:
        m = re.search(r"· lab ([0-9a-f]{8})", f.readline())
    if m:
        with open(src, "rb") as f:
            old = hashlib.md5(f.read()).hexdigest()[:8] != m.group(1)
    else:
        old = os.path.getmtime(src) > os.path.getmtime(o)
    if old:
        STALE.append(out)
    return old


def pane(cls, label, text, other_bl, how="./run-labs.sh", old=False):
    if text is None:
        return ('<div class="out %s"><div class="vh"><b>%s</b><span>not yet run</span></div>'
                '<div class="pend">Run <code>%s</code> to fill this column.</div></div>' % (cls, label, how))
    head, bl = blocks(text)
    head = '<span class="stale">stale: rerun the lab</span>' if old else esc(head)
    return ('<div class="out %s"><div class="vh"><b>%s</b><span>%s</span></div><pre>%s</pre></div>'
            % (cls, label, head, render(bl, other_bl)))


def labsrc(name):
    src = read("labs/%s.q" % name) or ""
    return ('<details class="labsrc"><summary>Show labs/%s.q</summary><div class="code"><pre>%s</pre></div></details>'
            % (name, esc(src.rstrip("\n"))))


def before(name):
    """The documented behaviour before each change, from the lab's own /< lines."""
    src = read("labs/%s.q" % name)
    if src is None or "\n/<" not in src:
        return None
    rows, last = ["/ not run"], None
    for ln in src.split("\n"):
        if ln.startswith("/<< "):
            rows.append("/ " + ln[4:])
        elif ln.startswith("/< "):
            if last is not None:
                rows.append("q)" + last)
                last = None
            rows.append(ln[3:])
        elif ln and not ln.startswith("/"):
            last = ln
    return "\n".join(rows) + "\n"


def lab(name):
    """Left: a kdb+ 4.x transcript if one was run, else the documented behaviour
    before each change, from the lab's own /< lines (KX's release notes)."""
    t4, tx = read("out/%s.4x.txt" % name), read("out/%s.x.txt" % name)
    if t4 is None and before(name) is not None:
        t4, label = before(name), "Previous behaviour · documented"
    else:
        label = "kdb+ 4.x"
    b4 = blocks(t4)[1] if t4 else None
    bx = blocks(tx)[1] if tx else None
    return ('<div class="cmds"><div class="outs">%s%s</div>%s</div>'
            % (pane("v4", label, t4, bx), pane("vx", "KDB-X", tx, b4, old=stale(name, "out/%s.x.txt" % name)), labsrc(name)))


def mlab(name):
    tx = read("out/%s.x.txt" % name)
    how = "labs/m4-pubsub.sh" if name == "m4-pubsub" else "./run-labs.sh"
    return '<div class="cmds"><div class="outs one">%s</div>%s</div>' % (pane("vx", "KDB-X", tx, None, how, old=stale(name, "out/%s.x.txt" % name)), labsrc(name))


def filepane(path):
    src = read(path)
    if src is None:
        return '<p class="warn">%s is missing.</p>' % esc(path)
    n = src.count("\n")
    return ('<details class="srcfile"><summary><span class="fn">%s</span><span class="lc">%d lines</span></summary>'
            '<div class="body"><div class="code"><pre>%s</pre></div></div></details>' % (esc(path), n, esc(src.rstrip("\n"))))


def diffpane(spec):
    a, b = spec.split("|")
    sa, sb = read(a), read(b)
    if sa is None or sb is None:
        return '<p class="notice">Run <code>./setup.sh</code> to fetch %s; the diff against %s appears here.</p>' % (esc(a), esc(b))
    d = difflib.unified_diff(sa.splitlines(), sb.splitlines(), a, b, lineterm="", n=1)
    rows = []
    for ln in d:
        c = "dh" if ln.startswith("@@") else "da" if ln.startswith("+") else "dd" if ln.startswith("-") else ""
        rows.append('<span class="%s">%s</span>' % (c, esc(ln)) if c else esc(ln))
    return ('<details class="srcfile"><summary><span class="fn">diff %s %s</span><span class="lc">what changed</span></summary>'
            '<div class="body"><div class="code"><pre class="diff">%s</pre></div></div></details>' % (esc(a), esc(b), "\n".join(rows)))


def testpane(name):
    t = read("out/test-%s.x.txt" % name)
    if t is None:
        return '<div class="out vx"><div class="vh"><b>KDB-X · kx.test</b><span>not yet run</span></div><div class="pend">Run <code>./run-labs.sh test</code>.</div></div>'
    return '<div class="out vx"><div class="vh"><b>KDB-X · kx.test</b><span>%s</span></div><pre>%s</pre></div>' % ("mod/tick/%s/test" % name, esc(t.rstrip()))


def main():
    body = read("src/body.html")
    rep = {"LAB": lab, "MLAB": mlab, "FILE": filepane, "DIFF": diffpane, "TEST": testpane}
    # an error named in the prose, <code>'type</code>, gets the same red box as in a transcript
    body = re.sub(r"<code>('[^<\s][^<]{0,60})</code>", r'<code class="errtag">\1</code>', body)
    body = re.sub(r"<!--(LAB|MLAB|FILE|DIFF|TEST):([^>]+?)-->", lambda m: rep[m.group(1)](m.group(2).strip()), body)
    page = (read("src/_head.html") + read("src/_style.html") + "\n" + read("src/_extra.css") + "\n"
            + body + "\n" + read("src/_script.html").replace("aof-theme", "b3x-theme") + "\n</body></html>\n")
    with open(P("index.html"), "w", encoding="utf-8") as f:
        f.write(page)
    ran = sorted(f for f in os.listdir(P("out")) if f.endswith(".txt")) if os.path.isdir(P("out")) else []
    print("wrote index.html (%d transcripts in out/)" % len(ran))
    for o in STALE:
        print("  stale: %s was made from an older version of its lab; rerun it" % o)


if __name__ == "__main__":
    main()
