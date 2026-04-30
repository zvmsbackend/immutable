///|
/// A lazily evaluated list data structure.
struct LazyList[A](@lazy.Lazy[LazyListCell[A]]) derive(Debug)

///|
priv enum LazyListCell[A] {
  Cons(A, LazyList[A])
  Nil
} derive(Debug)
