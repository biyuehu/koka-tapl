type term
  Var(x: string, k: int)
  Abs(x: string, t: term)
  App(a: term, b: term)

effect no-rule-emit
  final ctl no-rule-emit(): a

fun show(t: term): string
  match t
    Var(x, _) -> x
    Abs(x, t') -> "(λ " ++ x ++ ". " ++ t'.show ++ ")"
    App(a, b) -> "(" ++ a.show ++ " " ++ b.show ++ ")"

fun term-shift(d: int, c: int, t: term): term
  match t
    Var(x, k) -> if k < c then Var(x, k) else Var(x, k + d)
    Abs(x, t') -> Abs(x, term-shift(d, c + 1, t'))
    App(a, b) -> App(term-shift(d, c, a), term-shift(d, c, b))

fun term-subst(j: int, s: term, t: term): term
  match t
    Var(x, k) -> if k == j then s else Var(x, k)
    Abs(x, t') -> Abs(x, term-subst(j + 1, term-shift(1, 0, s), t'))
    App(a, b) -> App(term-subst(j, s, a), term-subst(j, s, b))

fun term-subst-top(s: term, t: term): term
  term-shift(-1, 0, term-subst(0, term-shift(1, 0, s), t))

fun term-shift'(d: int, t: term): term
  fun walk(c: int, t': term): term
    match t'
      Var(x, k) -> if k < c then Var(x, k) else Var(x, k + d)
      Abs(x, t'') -> Abs(x, walk(c + 1, t''))
      App(a, b) -> App(walk(c, a), walk(c, b))
  walk(0, t)

fun term-subst'(j: int, s: term, t: term): term
  fun walk(c: int, t': term): term
    match t'
      Var(x, k) -> if k == j + c then term-shift'(c, s) else Var(x, k)
      Abs(x, t'') -> Abs(x, walk(c + 1, t''))
      App(a, b) -> App(walk(c, a), walk(c, b))
  walk(0, t)

fun term-subst-top'(s: term, t: term): term
  term-shift'(-1, term-subst'(0, term-shift'(1, s), t))

fun is-val(t: term): bool
  match t
    Abs(_,_) -> True
    _ -> False

fun step(t: term): <no-rule-emit> term
  match t
    App(Abs(_, t'), v) | v.is-val -> term-subst-top'(v, t')
    App(v, t') | v.is-val -> App(v, t'.step)
    App(t1, t2) -> App(t1.step, t2)
    _ -> no-rule-emit()

fun eval-small(t: term): <div> term
  with handler
    final ctl no-rule-emit() t
    return (x) eval-small(x)
  t.step

fun eval-big(t: term): <div> term
  match t
    App(Abs(_, t'), v) | v.is-val -> term-subst-top'(v, t').eval-big
    App(v, t') | v.is-val && !t'.is-val -> App(v, t'.eval-big).eval-big
    App(t1, t2) | !t1.is-val -> App(t1.eval-big, t2).eval-big
    _ -> t
