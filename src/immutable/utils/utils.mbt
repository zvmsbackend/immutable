///|
pub fn[A, B] iter_all2(
  iter1 : Iter[A],
  iter2 : Iter[B],
  f : (A, B) -> Bool,
) -> Bool {
  for {
    guard iter1.next() is Some(value1) else { return true }
    guard iter2.next() is Some(value2) else { return true }
    if !f(value1, value2) {
      return false
    }
  }
}

///|
pub fn[A : Compare] iter_compare(iter1 : Iter[A], iter2 : Iter[A]) -> Int {
  for {
    match (iter1.next(), iter2.next()) {
      (Some(value1), Some(value2)) => {
        let cmp = value1.compare(value2)
        if cmp != 0 {
          return cmp
        }
      }
      (Some(_), None) => return 1
      (None, Some(_)) => return -1
      (None, None) => return 0
    }
  }
}
