///|
using @list {type List}

///|
/// A non-empty list data structure.
struct NonEmptyList[A] {
  head : A
  tail : List[A]
} derive(Eq, Hash, Default)
