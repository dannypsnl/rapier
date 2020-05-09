module list-thms where

open import Level using (Level)
open import Function
open import Agda.Builtin.Unit
open import Data.Empty
open import Data.List
open import Data.Nat.Properties
open import Data.Nat
open import Data.Bool using (Bool; true; false)
open import Relation.Unary
open import Relation.Nullary
open import Relation.Nullary.Negation
open import Relation.Binary.PropositionalEquality

length-++ : ∀ {A : Set} (l₁ l₂ : List A)
  → length (l₁ ++ l₂) ≡ (length l₁) + (length l₂)
length-++ [] l₂ = refl
length-++ (h ∷ t) l₂ rewrite length-++ t l₂ = refl

++-assoc : ∀ {A : Set} (l₁ : List A) (l₂ : List A) (l₃ : List A)
           → (l₁ ++ l₂) ++ l₃ ≡ l₁ ++ (l₂ ++ l₃)
++-assoc [] l₂ l₃ = refl
++-assoc (h ∷ t) l₂ l₃ rewrite ++-assoc t l₂ l₃ = refl

≤-suc : ∀ (n : ℕ) → n ≤ suc n
≤-suc zero = z≤n
≤-suc (suc n) = s≤s (≤-suc n)

length-filter : ∀ {level} {A : Set} {P : Pred A level} (P? : Decidable P) (xs : List A)
                → (length (filter P? xs)) ≤ length xs
length-filter P? [] = z≤n
length-filter P? (h ∷ t) with does (P? h)
-- when P? returns true, value would be keep
... | true = s≤s (length-filter P? t)
-- when P? returns false, value would be drop
-- then we proof transitivity: (length (filter P? t)) ≤ (length t) ≤ suc (length t)
... | false = ≤-trans (length-filter P? t) (≤-suc (length t))

private
  variable
    a  p : Level
    A : Set a
module _ {P : Pred A p} (P? : Decidable P) where

  filter-idempotent : filter P? ∘ filter P? ≗ filter P?
  filter-idempotent [] = refl
  filter-idempotent (x ∷ xs) with does (P? x) | inspect does (P? x)
  -- in this branch `P?` removes head, so have to check rest list follow the rule
  ... | false | _ = filter-idempotent xs
  ... | true | [ eq ] rewrite eq = cong (x ∷_) (filter-idempotent xs)
