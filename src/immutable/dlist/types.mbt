///|
priv enum Node[A] {
  Nil
  Unit(A)
  Concat(Node[A], Node[A])
} derive(Debug)

///|
/// A immutable linear data structure.
struct DList[A] {
  length : Int
  root : Node[A]
} derive(Debug)
