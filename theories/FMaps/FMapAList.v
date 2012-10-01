Require Import ExtLib.FMaps.FMaps.
Require Import List.
Require Import Decidables.Decidable.
Require Import ExtLib.Monad.Monad.

Set Implicit Arguments.
Set Strict Implicit.

Section keyed.
  Variable K : Type.
  Variable RD_K : RelDec (@eq K).

  Definition alist (T : Type) : Type := list (K * T).

  Definition alist_add V (k : K) (v : V) (m : alist V) : alist V :=
    (k, v) :: m.

  Definition alist_remove V (k : K) (m : alist V) : alist V :=
    filter (fun x => negb (eq_dec k (fst x))) m.

  Fixpoint alist_find V (k : K) (m : alist V) : option V :=
    match m with
      | nil => None
      | (k',v) :: ms =>
        if eq_dec k k' then
          Some v
        else
          alist_find k ms
    end.

  Global Instance Map_alist : Map K alist :=
  { empty  := fun _ => @nil _
  ; add    := alist_add
  ; remove := alist_remove
  ; find   := alist_find
  ; keys   := fun _ => List.map (@fst _ _)
  }.

  Section fold.
    Import MonadNotation.
    Local Open Scope monad_scope.

    Variable m : Type -> Type.
    Variable Monad_m : Monad m.
    Variables V T : Type.
    Variable f : K -> V -> T -> m T.
    
    Fixpoint fold_alist (acc : T) (map : alist V) : m T :=
      match map with
        | nil => ret acc
        | (k,v) :: m =>
          acc <- f k v acc ;;
          fold_alist acc m
      end.
  End fold.

  Global Instance FMap_alist : FMap K alist :=
  { fmap_foldM := fold_alist }.

End keyed.