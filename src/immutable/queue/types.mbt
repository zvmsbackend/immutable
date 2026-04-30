///|
using @list {type List}

///|
priv enum Status[A] {
  Idle
  Rev(Int, List[A], List[A], List[A], List[A])
  App(Int, List[A], List[A])
  Done(List[A])
} derive(Debug)

///|
/// A purely functional queue data structure.
struct Queue[A] {
  frontLen : Int
  front : List[A]
  status : Status[A]
  rear : List[A]
  rearLen : Int
} derive(Debug)
