///|
using @list {type List}

///|
/// A double-ended queue (deque) data structure.
pub struct Deque[A] {
  front : List[A]
  back : List[A]
}
