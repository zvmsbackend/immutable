///|
/// An immutable map from integers to values of type A.
enum IntMap[A] {
  Nil
  Tip(Int, A)
  Node(Int, IntMap[A], Int, IntMap[A])
}
