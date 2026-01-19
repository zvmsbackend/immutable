///|
priv enum Node[A] {
  Nil
  Unit(A)
  Concat(Node[A], Node[A])
}

///|
/// A immutable linear data structure.
struct DList[A] {
  length : Int
  root : Node[A]
}
