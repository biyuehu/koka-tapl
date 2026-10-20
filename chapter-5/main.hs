{-# LANGUAGE RankNTypes #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use const" #-}
{-# HLINT ignore "Eta reduce" #-}
{-# HLINT ignore "Avoid lambda" #-}

module Church where

import Data.Maybe (fromJust)

newtype CBool = CBool {runBool :: forall a. a -> a -> a}

true, false :: CBool
true = CBool (\a _ -> a)
false = CBool (\_ b -> b)

if' :: CBool -> a -> a -> a
if' c = runBool c

and' :: CBool -> CBool -> CBool
and' p q = runBool p q false

or' :: CBool -> CBool -> CBool
or' p = runBool p true

not' :: CBool -> CBool
not' p = runBool p false true

newtype CNat = CNat {runNat :: forall a. (a -> a) -> a -> a}

zero, one, two :: CNat
zero = CNat (\_ z -> z)
one = CNat (\s z -> s z)
two = CNat (\s z -> s (s z))

succ1, succ2 :: CNat -> CNat
succ1 n = CNat (\s z -> s (runNat n s z))
succ2 n = CNat (\s z -> runNat n s (s z))

add1, add2 :: CNat -> CNat -> CNat
add1 m n = runNat m succ1 n
add2 m n = CNat (\s z -> runNat m s (runNat n s z))

mul1, mul2 :: CNat -> CNat -> CNat
mul1 m n = runNat m (add1 n) zero
mul2 m n = CNat (\s -> runNat m (runNat n s))

pow1, pow2 :: CNat -> CNat -> CNat
pow1 m n = runNat m (mul1 n) one
pow2 m n = CNat (runNat m (runNat n))

isZero :: CNat -> CBool
isZero n = runNat n (\_ -> false) true

isEven :: CNat -> CBool
isEven n = runNat n not' true

newtype CPair a b = CPair {runPair :: forall r. (a -> b -> r) -> r}

pair :: a -> b -> CPair a b
pair x y = CPair (\f -> f x y)

fst' :: CPair a b -> a
fst' p = runPair p (\x _ -> x)

snd' :: CPair a b -> b
snd' p = runPair p (\_ y -> y)

prd :: CNat -> CNat
prd n = fst' $ runNat n (\p -> pair (snd' p) (succ1 $ snd' p)) $ pair zero zero

sub' :: CNat -> CNat -> CNat
sub' m n = runNat n prd m

equal' :: CNat -> CNat -> CBool
equal' m n = and' (isZero (sub' m n)) $ isZero (sub' n m)

newtype CList a = CList {runList :: forall r. (a -> r -> r) -> r -> r}

nil :: CList a
nil = CList (\c n -> n)

cons :: a -> CList a -> CList a
cons x xs = CList (\c n -> c x (runList xs c n))

length :: CList a -> CNat
length l = runList l (\x xs -> succ1 xs) zero

sumList :: CList CNat -> CNat
sumList l = runList l add1 zero

newtype CTree a = CTree {runTree :: forall r. (a -> r -> r -> r) -> r -> r}

leaf :: CTree a
leaf = CTree (\n l -> l)

node :: a -> CTree a -> CTree a -> CTree a
node x a b = CTree (\n l -> n x (runTree a n l) (runTree b n l))

size :: CTree a -> CNat
size t = runTree t (\x a b -> succ1 $ add1 a b) zero

sumTree :: CTree CNat -> CNat
sumTree t = runTree t (\x a b -> add1 x (add1 a b)) zero
