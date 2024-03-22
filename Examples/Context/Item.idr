module Examples.Context.Item

import Data.Singleton

import Data.List.Quantifiers

import Decidable.Positive
import Decidable.Positive.Equality
import Decidable.Positive.String
import Decidable.Positive.Nat
import Decidable.Positive.Pair
import Decidable.Positive.List.Assoc
import Decidable.Positive.List.Elem
import Decidable.Positive.List.Quantifier.All
import Decidable.Positive.List.Quantifier.Any

public export
data Item : type -> Type where
  I : String -> Singleton ty -> Item ty


public export
data Holds : {ty : kind}
          -> (pK   : (type : String) -> Decidable)
          -> (pI   : (type : kind)   -> Decidable)
          -> (t    : Decidable -> Type)
          -> (item : Item ty)
                  -> Type
  where
    H : (prfK : t (pK key))
     -> (prfV : t (pV value))
             -> Holds pK pV t (I key (Val value))

public export
data HoldsNot : {ty : kind}
             -> (pK   : (type : String) -> Decidable)
             -> (pI   : (type : kind)   -> Decidable)
             -> (t    : Decidable -> Type)
             -> (item : Item ty)
                     -> Type
  where
    WrongKey :(prfKey : t (pK key))
                     -> HoldsNot pK pV t (I key (Val value))

    WrongItem : {value : ty}
             -> (prfValue : t (pV value))
                         -> HoldsNot pK pV t (I key (Val value))

0
isVoidU : Holds    pK pI Positive item
       -> HoldsNot pK pI Negative item
       -> Void
isVoidU {pK = pK} {item = (I key (Val value))} (H prfK prfV) (WrongKey prfKey) with (pK key)
  isVoidU {pK = pK} {item = (I key (Val value))} (H prfK prfV) (WrongKey prfKey) | (D pos neg cancelled)
    = cancelled prfK prfKey
isVoidU {pI = pI} {item = (I key (Val value))} (H prfK prfV) (WrongItem prfValue) with (pI value)
  isVoidU {pI = pI} {item = (I key (Val value))} (H prfK prfV) (WrongItem prfValue) | (D pos neg cancelled)
    = cancelled prfV prfValue

public export
HOLDS : (pK : (type : String) -> Decidable)
     -> (pI : (type : kind)   -> Decidable)
     -> {ty : kind}
     -> (item : Item ty)
     -> Decidable
HOLDS p k i
  = D (Holds    p k Positive i)
      (HoldsNot p k Negative i)
      isVoidU


export
holds : (f : (x : String) -> Positive.Dec (p x))
     -> (g : (x : typeS) -> Positive.Dec (q x))
     -> (x : Item type)
          -> Positive.Dec (HOLDS p q x)
holds f g (I k (Val v)) with (decideE $ f k)
  holds f g (I k (Val v)) | (Left x)
    = Left (WrongKey x)
  holds f g (I k (Val v)) | (Right x) with (decideE $ g v)
    holds f g (I k (Val v)) | (Right x) | (Left y)
      = Left (WrongItem y)
    holds f g (I k (Val v)) | (Right x) | (Right y)
      = Right (H x y)


-- [ EOF ]
