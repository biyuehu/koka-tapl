type term
  TmTrue
  TmFalse
  TmIf(t1: term, t2: term, t3: term)
  TmZero
  TmSucc(t: term)
  TmPred(t: term)
  TmIsZero(t: term)
  TmWrong

type value
  VaTrue
  VaFalse
  VaZero
  VaSucc(v: value)
  VaWrong

fun is-numericval(t: term) : bool
  match t
    TmZero -> True
    TmSucc(t) -> t.is-numericval
    _ -> False

fun is-boolean(t: term) : bool
  match t
    TmTrue -> True
    TmFalse -> True
    _ -> False

fun is-val(t: term): bool
  t.is-numericval || t.is-boolean

fun is-bad-nat(t: term): bool
  match t
    TmWrong -> True
    t -> t.is-boolean

fun is-bad-bool(t: term): bool
  match t
    TmWrong -> True
    t -> t.is-numericval

fun step(t: term): <exn> term
  match t
    TmIf(TmTrue, t2, _) -> t2
    TmIf(TmFalse, _, t3) -> t3
    TmIf(t1, _, _) | t1.is-bad-bool -> TmWrong
    TmIf(t1, t2, t3) -> TmIf(t1.step, t2, t3)
    TmSucc(t') | t'.is-bad-nat -> TmWrong
    TmSucc(t') -> TmSucc(t'.step)
    TmPred(TmZero) -> TmZero
    TmPred(TmSucc(t')) | t'.is-numericval -> t'
    TmPred(t') | t'.is-bad-nat -> TmWrong
    TmPred(t') -> TmPred(t'.step)
    TmIsZero(TmZero) -> TmTrue
    TmIsZero(TmSucc(t')) | t'.is-numericval -> TmFalse
    TmIsZero(t') | t'.is-bad-nat -> TmWrong
    TmIsZero(t') -> TmIsZero(t'.step)
    _ -> Exception("Evaluation error: target term has been a value", ExnError).throw-exn


fun eval-small(t: term): <div> term
  val result =
    with handler
      final ctl throw-exn(_) Nothing
      return (x) Just(x)
    step(t)
  match result
    Just(t') -> t'.eval-small
    Nothing -> t

fun eval-big(t: term): <div> value
  match t
    TmIf(t1, t2, t3) ->
      match t1.eval-big
        VaTrue -> t2.eval-big
        VaFalse -> t3.eval-big
        _ -> VaWrong
    TmSucc(t) ->
      match t.eval-big
        VaZero -> VaSucc(VaZero)
        t' as VaSucc(_) -> VaSucc(t')
        _ -> VaWrong
    TmPred(t) ->
      match t.eval-big
        VaZero -> VaZero
        VaSucc(t') -> t'
        _ -> VaWrong
    TmIsZero(t) ->
      match t.eval-big
        VaZero -> VaTrue
        VaSucc(_) -> VaFalse
        _ -> VaWrong
    TmTrue -> VaTrue
    TmFalse -> VaFalse
    TmZero -> VaZero
    TmWrong -> VaWrong
