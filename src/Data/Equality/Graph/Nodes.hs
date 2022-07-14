{-# LANGUAGE TypeFamilies #-}
module Data.Equality.Graph.Nodes where

import Data.Hashable
import Data.Hashable.Lifted
import Data.Functor.Classes
import Data.Foldable

import Control.Monad (void)

import Data.Equality.Graph.Classes.Id

-- | E-node
--
-- An E-node is a function symbol paired with a list of children e-classes.
-- 
-- We define an e-node to be the base functor of some recursive data type
-- parametrized over ClassId, i.e. all recursive fields are rather e-class ids.
--
-- When @l@ is an expression-like data type, @ENode l = l ClassId@ means every
-- recursive field (so, every argument passed to this expr) is a 'ClassId'
-- rather than an explicit expression
newtype ENode l = Node { unNode :: l ClassId }

-- | Operator
--
-- An operator is solely the function symbol part of the e-node, that is, there
-- are no children e-classes.
newtype Operator l = Operator { unOperator :: l () }

-- | Get the children class ids of an e-node
children :: Language l => ENode l -> [ClassId]
children = toList . unNode

-- | Get the operator (function symbol) of an e-node
operator :: Language l => ENode l -> Operator l
operator = Operator . void . unNode

-- | A language is a recursive data type written in its functor \"form\"
--
-- Must satisfy all other class constraints
class (Hashable1 l, Eq1 l, Ord1 l, Traversable l) => Language l

instance Eq1 l => (Eq (ENode l)) where
    (==) (Node a) (Node b) = liftEq (==) a b

instance Ord1 l => (Ord (ENode l)) where
    compare (Node a) (Node b) = liftCompare compare a b

instance Hashable1 l => (Hashable (ENode l)) where
    hashWithSalt a (Node l) = liftHashWithSalt hashWithSalt a l

instance Show1 l => (Show (ENode l)) where
    showsPrec p (Node l) = liftShowsPrec showsPrec showList p l

instance Eq1 l => (Eq (Operator l)) where
    (==) (Operator a) (Operator b) = liftEq (==) a b

instance Ord1 l => (Ord (Operator l)) where
    compare (Operator a) (Operator b) = liftCompare compare a b

instance Hashable1 l => (Hashable (Operator l)) where
    hashWithSalt a (Operator l) = liftHashWithSalt hashWithSalt a l

instance Show1 l => (Show (Operator l)) where
    showsPrec p (Operator l) = liftShowsPrec (const . const $ showString "") (const $ showString "") p l
