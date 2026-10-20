type c-bool
  Bool(run: forall <a> a -> (a -> a))

val true: c-bool = (fn(a) fn(b) a).Bool
val false: c-bool = (fn(a) fn(b) b).Bool

val if': forall <a> c-bool -> (a -> (a -> a)) = fn(cond) cond.run
val and': c-bool -> (c-bool -> c-bool) = fn(a) fn(b) (a.run)(b)(false)
val or': c-bool -> (c-bool -> c-bool) = fn(a) (a.run)(true)
val not': c-bool -> c-bool = fn(a) (a.run)(false)(true)

type c-nat
  Nat(run: forall <a> (a -> a) -> (a -> a))

val zero: c-nat = (fn(s) fn(z) z).Nat
val one: c-nat = (fn(s) fn(z) s(z)).Nat
val two: c-nat = (fn(s) fn(z) s(s(z))).Nat

val succ: c-nat -> c-nat = fn(n) (fn(s) fn(z) s((n.run)(s)(z))).Nat
val succ2: c-nat -> c-nat = fn (n) (fn(s) fn(z) (n.run)(s)(s(z))).Nat

val add: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) (fn(s) fn(z) (m.run)(s)((n.run)(s)(z))).Nat
val add2: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) (m.run)(succ)(n)

val mul: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) (fn(s) (m.run)((n.run)(s))).Nat
val mul2: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) (m.run)(add(n))(zero)

val pow: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) ((m.run)(n.run)).Nat
val pow2: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) (m.run)(mul(n))(one)

val is-zero: c-nat -> c-bool = fn(n) (n.run)(fn(x) false)(true)

val is-even: c-nat -> c-bool = fn(n) (n.run)(not')(true)

type c-pair<a, b>
  Pair(run: forall <r> (a -> (b -> r)) -> r)

val pair: forall <a, b> a -> (b -> c-pair<a, b>) = fn(x) fn(y) Pair(fn(f) f(x)(y))

val fst': forall <a, b> c-pair<a, b> -> a = fn(p) (p.run)(fn(x) fn(y) x)

val snd': forall <a, b> c-pair<a, b> -> b = fn(p) (p.run)(fn(x) fn(y) y)

val prd: c-nat -> c-nat = fn(n) fst'((n.run) (fn(p) pair(snd'(p))(succ(fst'(p)))) (pair(zero)(zero)))

val sub: c-nat -> (c-nat -> c-nat) = fn(m) fn(n) (n.run)(prd)(m)

val equal: c-nat -> (c-nat -> c-bool) = fn(m) fn (n) and'(is-zero(sub(m)(n)))(is-zero(sub(n)(m)))
