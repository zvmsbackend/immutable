///|
using @list {type List}

///|
/// A zipper data structure for lists, allowing efficient navigation and modification.
struct ListZipper[A] {
  left : List[A]
  right : List[A]
} derive(Show, Eq, Compare, Hash)
