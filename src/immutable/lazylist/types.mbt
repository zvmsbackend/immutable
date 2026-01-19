///|
/// A lazily evaluated list data structure.
struct LazyList[A](@lazy.Lazy[LazyListCell[A]])

///|
priv enum LazyListCell[A] {
  Cons(A, LazyList[A])
  Nil
}
