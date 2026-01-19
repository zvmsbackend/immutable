///|
fn[A] LazyList::force(self : LazyList[A]) -> LazyListCell[A] {
  self.0.force()
}

///|
fn[A] from_thunk(thunk : () -> LazyListCell[A]) -> LazyList[A] {
  LazyList(@lazy.from_thunk(thunk))
}

///|
fn[A] not_lazy(cell : LazyListCell[A]) -> LazyList[A] {
  LazyList(@lazy.from_value(cell))
}

///|
/// Returns true if all elements in the LazyList satisfy the predicate.
pub fn[A] LazyList::all(self : LazyList[A], f : (A) -> Bool) -> Bool {
  for list = self {
    match list.force() {
      Cons(hd, _) if !f(hd) => break false
      Cons(_, tl) => continue tl
      Nil => break true
    }
  }
}

///|
/// Returns true if any element in the LazyList satisfies the predicate.
pub fn[A] LazyList::any(self : LazyList[A], f : (A) -> Bool) -> Bool {
  for list = self {
    match list.force() {
      Cons(hd, _) if f(hd) => break true
      Cons(_, tl) => continue tl
      Nil => break false
    }
  }
}

///|
/// Concatenates two LazyLists.
pub fn[A] LazyList::concat(
  self : LazyList[A],
  other : LazyList[A],
) -> LazyList[A] {
  from_thunk(() => match self.force() {
    Cons(hd, tl) => Cons(hd, tl.concat(other))
    Nil => other.force()
  })
}

///|
/// Constructs a LazyList by prepending an element to an existing LazyList.
pub fn[A] cons(hd : A, tl : LazyList[A]) -> LazyList[A] {
  not_lazy(Cons(hd, tl))
}

///|
/// Constructs a LazyList by prepending an element to an existing LazyList, with the tail being delayed.
pub fn[A] cons_delayed(hd : A, tl : () -> LazyList[A]) -> LazyList[A] {
  from_thunk(() => Cons(hd, tl()))
}

///|
/// Checks if the LazyList contains a specific value.
pub fn[A : Eq] LazyList::contains(self : LazyList[A], value : A) -> Bool {
  self.any(value.equal(_))
}

///|
/// Creates a LazyList from a delayed computation. The thunk is only evaluated when the LazyList is forced.
pub fn[A] delayed(thunk : () -> LazyList[A]) -> LazyList[A] {
  from_thunk(() => thunk().force())
}

///|
/// Drops the first n elements from the LazyList.
pub fn[A] LazyList::drop(self : LazyList[A], n : Int) -> LazyList[A] {
  from_thunk(() => for list = self, n = n {
    match list.force() {
      Cons(_, tl) if n > 0 => continue tl, n - 1
      cell => break cell
    }
  })
}

///|
/// Drops elements from the LazyList while the predicate holds true.
pub fn[A] LazyList::drop_while(
  self : LazyList[A],
  f : (A) -> Bool,
) -> LazyList[A] {
  from_thunk(() => for list = self {
    match list.force() {
      Cons(hd, tl) if f(hd) => continue tl
      cell => break cell
    }
  })
}

///|
/// Applies a function to each element of the LazyList. This forces the entire list.
pub fn[A] LazyList::each(
  self : LazyList[A],
  f : (A) -> Unit raise?,
) -> Unit raise? {
  for list = self {
    match list.force() {
      Cons(hd, tl) => {
        f(hd)
        continue tl
      }
      Nil => break ()
    }
  }
}

///|
/// Applies a function to each element of the LazyList along with its index. This forces the entire list.
pub fn[A] LazyList::eachi(
  self : LazyList[A],
  f : (Int, A) -> Unit raise?,
) -> Unit raise? {
  for list = self, index = 0 {
    match list.force() {
      Cons(hd, tl) => {
        f(index, hd)
        continue tl, index + 1
      }
      Nil => break ()
    }
  }
}

///|
/// Filters elements of the LazyList based on a predicate.
pub fn[A] LazyList::filter(self : LazyList[A], f : (A) -> Bool) -> LazyList[A] {
  from_thunk(() => for list = self {
    match list.force() {
      Cons(hd, tl) if f(hd) => break Cons(hd, tl.filter(f))
      Cons(_, tl) => continue tl
      Nil => break Nil
    }
  })
}

///|
/// Maps each element of the LazyList to an optional value and filters out the None values.
pub fn[A, B] LazyList::filter_map(
  self : LazyList[A],
  f : (A) -> B?,
) -> LazyList[B] {
  from_thunk(() => for list = self {
    match list.force() {
      Cons(hd, tl) =>
        match f(hd) {
          Some(value) => break Cons(value, tl.filter_map(f))
          None => continue tl
        }
      Nil => break Nil
    }
  })
}

///|
/// Finds the first element in the LazyList that satisfies the predicate.
/// This forces elements until a match is found or the list ends.
pub fn[A] LazyList::find(
  self : LazyList[A],
  f : (A) -> Bool raise?,
) -> A? raise? {
  for list = self {
    match list.force() {
      Cons(hd, _) if f(hd) => break Some(hd)
      Cons(_, tl) => continue tl
      Nil => break None
    }
  }
}

///|
/// Finds the index of the first element in the LazyList that satisfies the predicate.
/// This forces elements until a match is found or the list ends.
pub fn[A] LazyList::find_index(
  self : LazyList[A],
  f : (A) -> Bool raise?,
) -> Int? raise? {
  for list = self, index = 0 {
    match list.force() {
      Cons(hd, _) if f(hd) => break Some(index)
      Cons(_, tl) => continue tl, index + 1
      Nil => break None
    }
  }
}

///|
/// Finds the first element and its index in the LazyList that satisfies the predicate.
/// This forces elements until a match is found or the list ends.
pub fn[A] LazyList::findi(
  self : LazyList[A],
  f : (A, Int) -> Bool raise?,
) -> A? raise? {
  for list = self, index = 0 {
    match list.force() {
      Cons(hd, _) if f(hd, index) => break Some(hd)
      Cons(_, tl) => continue tl, index + 1
      Nil => break None
    }
  }
}

///|
/// Flattens a LazyList of LazyLists into a single LazyList.
pub fn[A] LazyList::flatten(self : LazyList[LazyList[A]]) -> LazyList[A] {
  from_thunk(() => for outer = self {
    match outer.force() {
      Cons(inner, tl_outer) =>
        match inner.force() {
          Cons(hd, tl_inner) =>
            break Cons(hd, not_lazy(Cons(tl_inner, tl_outer)).flatten())
          Nil => continue tl_outer
        }
      Nil => break Nil
    }
  })
}

///|
/// Applies a function to each element of the LazyList and flattens the result.
pub fn[A] LazyList::flat_map(
  self : LazyList[A],
  f : (A) -> LazyList[A],
) -> LazyList[A] {
  self.map(f).flatten()
}

///|
/// Folds the elements of the LazyList from left to right. This forces the entire list.
pub fn[A, B] LazyList::fold(
  self : LazyList[A],
  init~ : B,
  f : (B, A) -> B raise?,
) -> B raise? {
  for state = init, list = self {
    match list.force() {
      Cons(hd, tl) => continue f(state, hd), tl
      Nil => break state
    }
  }
}

///|
/// Folds the elements of the LazyList from left to right, providing the index of each element.
/// This forces the entire list.
pub fn[A, B] LazyList::foldi(
  self : LazyList[A],
  init~ : B,
  f : (Int, B, A) -> B raise?,
) -> B raise? {
  for state = init, list = self, index = 0 {
    match list.force() {
      Cons(hd, tl) => continue f(index, state, hd), tl, index + 1
      Nil => break state
    }
  }
}

///|
/// Creates a LazyList from an array.
pub fn[A] from_array(arr : ArrayView[A]) -> LazyList[A] {
  unfold(init=0, i => if i < arr.length() {
    Some((arr[i], i + 1))
  } else {
    None
  })
}

///|
/// Creates a LazyList from an iterator.
pub fn[A] from_iter(iter : Iter[A]) -> LazyList[A] {
  from_thunk(() => match iter.next() {
    Some(item) => Cons(item, from_iter(iter))
    None => Nil
  })
}

///|
/// Gets the head element of the LazyList, if it exists.
pub fn[A] LazyList::head(self : LazyList[A]) -> A? {
  match self.force() {
    Cons(hd, _) => Some(hd)
    Nil => None
  }
}

///|
priv enum IntercalationStep[A] {
  Initial(LazyList[LazyList[A]])
  YieldElem(LazyList[A], LazyList[LazyList[A]])
  YieldSep(LazyList[A], LazyList[LazyList[A]])
}

///|
/// Intercalates a separator LazyList between the LazyLists in the original LazyList.
pub fn[A] LazyList::intercalate(
  self : LazyList[LazyList[A]],
  sep : LazyList[A],
) -> LazyList[A] {
  fn go(step : IntercalationStep[A]) -> LazyListCell[A] {
    match step {
      Initial(lists) =>
        match lists.force() {
          Cons(hd, tl) => go(YieldElem(hd, tl))
          Nil => Nil
        }
      YieldElem(current, lists) =>
        match current.force() {
          Cons(hd, tl) => Cons(hd, from_thunk(() => go(YieldElem(tl, lists))))
          Nil =>
            match lists.force() {
              Cons(_) => go(YieldSep(sep, lists))
              Nil => Nil
            }
        }
      YieldSep(sep_list, lists) =>
        match sep_list.force() {
          Cons(hd, tl) => Cons(hd, from_thunk(() => go(YieldSep(tl, lists))))
          Nil =>
            match lists.force() {
              Cons(next, tl_lists) => go(YieldElem(next, tl_lists))
              Nil => Nil
            }
        }
    }
  }

  from_thunk(() => go(Initial(self)))
}

///|
/// Intersperse a separator value between each element of the LazyList.
pub fn[A] LazyList::intersperse(self : LazyList[A], sep : A) -> LazyList[A] {
  from_thunk(() => match self.force() {
    Cons(hd, tl) =>
      match tl.force() {
        Cons(_) => Cons(hd, cons_delayed(sep, () => tl.intersperse(sep)))
        Nil => Cons(hd, tl.intersperse(sep))
      }
    Nil => Nil
  })
}

///|
/// Checks if the LazyList is empty.
pub fn[A] LazyList::is_empty(self : LazyList[A]) -> Bool {
  self.force() is Nil
}

///|
/// Checks if `other` is a prefix of the LazyList. This forces only as much of the list as needed.
pub fn[A : Eq] LazyList::is_prefix(
  self : LazyList[A],
  other : LazyList[A],
) -> Bool {
  for self = self, other = other {
    match other.force() {
      Cons(hd2, tl2) =>
        match self.force() {
          Cons(hd1, tl1) if hd1 == hd2 => continue tl1, tl2
          _ => break false
        }
      Nil => break true
    }
  }
}

///|
/// Checks if `other` is a suffix of the LazyList. This forces the entire list.
pub fn[A : Eq] LazyList::is_suffix(
  self : LazyList[A],
  other : LazyList[A],
) -> Bool {
  self.rev().is_prefix(other.rev())
}

///|
/// Returns an iterator over the elements of the LazyList.
pub fn[A] LazyList::iter(self : LazyList[A]) -> Iter[A] {
  let mut self = self
  Iter::new(() => self
    .uncons()
    .map(pair => {
      self = pair.1
      pair.0
    }))
}

///|
/// Returns an iterator over the elements of the LazyList along with their indices.
pub fn[A] LazyList::iter2(self : LazyList[A]) -> Iter2[Int, A] {
  let mut index = 0
  let mut self = self
  Iter2::new(() => self
    .uncons()
    .map(pair => {
      let result = (index, pair.0)
      index += 1
      self = pair.1
      result
    }))
}

///|
/// Gets the last element of the LazyList, if it exists. This forces the entire list.
pub fn[A] LazyList::last(self : LazyList[A]) -> A? {
  self.fold(init=None, (_, item) => Some(item))
}

///|
/// Calculates the length of the LazyList. This forces the entire list.
pub fn[A] LazyList::length(self : LazyList[A]) -> Int {
  self.fold(init=0, (acc, _) => acc + 1)
}

///|
/// Looks up a value by key in a LazyList of key-value pairs.
pub fn[A : Eq, B] LazyList::lookup(self : LazyList[(A, B)], key : A) -> B? {
  self.find(pair => pair.0 == key).map(pair => pair.1)
}

///|
/// Maps each element of the LazyList using a provided function.
pub fn[A, B] LazyList::map(self : LazyList[A], f : (A) -> B) -> LazyList[B] {
  from_thunk(() => match self.force() {
    Cons(hd, tl) => Cons(f(hd), tl.map(f))
    Nil => Nil
  })
}

///|
/// Maps each element of the LazyList along with its index using a provided function.
pub fn[A, B] LazyList::mapi(
  self : LazyList[A],
  f : (Int, A) -> B,
) -> LazyList[B] {
  fn go(list : LazyList[A], index : Int) -> LazyList[B] {
    from_thunk(() => match list.force() {
      Cons(hd, tl) => Cons(f(index, hd), go(tl, index + 1))
      Nil => Nil
    })
  }

  go(self, 0)
}

///|
/// Returns the maximum element in the LazyList, if it exists. This forces the entire list.
pub fn[A : Compare] LazyList::maximum(self : LazyList[A]) -> A? {
  self.fold(init=None, (current_max, item) => Some(
    match current_max {
      Some(max) if item > max => item
      Some(max) => max
      None => item
    },
  ))
}

///|
/// Returns the minimum element in the LazyList, if it exists. This forces the entire list.
pub fn[A : Compare] LazyList::minimum(self : LazyList[A]) -> A? {
  self.fold(init=None, (current_min, item) => Some(
    match current_min {
      Some(min) if item < min => item
      Some(min) => min
      None => item
    },
  ))
}

///|
/// Gets the nth element of the LazyList, if it exists. This forces elements up to the nth index.
pub fn[A] LazyList::nth(self : LazyList[A], n : Int) -> A? {
  self.findi((_, index) => index == n)
}

///|
/// Creates a new empty LazyList.
pub fn[A] new() -> LazyList[A] {
  not_lazy(Nil)
}

///|
/// Prepends an element to the LazyList.
pub fn[A] LazyList::prepend(self : LazyList[A], head : A) -> LazyList[A] {
  cons(head, self)
}

///|
/// Removes the first occurrence of a specific value from the LazyList.
pub fn[A : Eq] LazyList::remove(self : LazyList[A], value : A) -> LazyList[A] {
  from_thunk(() => for list = self {
    match list.force() {
      Cons(hd, tl) if hd == value => continue tl
      Cons(hd, tl) => break Cons(hd, tl.remove(value))
      Nil => break Nil
    }
  })
}

///|
/// Removes the element at the specified index from the LazyList.
pub fn[A] LazyList::remove_at(self : LazyList[A], n : Int) -> LazyList[A] {
  from_thunk(() => match self.force() {
    Cons(_, tl) if n == 0 => tl.force()
    Cons(hd, tl) => Cons(hd, tl.remove_at(n - 1))
    Nil => Nil
  })
}

///|
/// Creates a LazyList by repeating a value n times.
pub fn[A] repeat(n : Int, x : A) -> LazyList[A] {
  if n == 0 {
    return new()
  }
  from_thunk(() => Cons(x, repeat(n - 1, x)))
}

///|
/// Creates an infinite LazyList by repeating a value indefinitely.
pub fn[A] repeat_infinite(x : A) -> LazyList[A] {
  from_thunk(() => Cons(x, repeat_infinite(x)))
}

///|
/// Reverses the LazyList. This forces the entire list.
pub fn[A] LazyList::rev(self : LazyList[A]) -> LazyList[A] {
  self.fold(init=new(), (acc, item) => cons(item, acc))
}

///|
/// Performs a scan (prefix sum) over the LazyList from left to right.
pub fn[A, B] LazyList::scan_left(
  self : LazyList[A],
  f : (B, A) -> B,
  init~ : B,
) -> LazyList[B] {
  from_thunk(() => match self.force() {
    Cons(hd, tl) => {
      let new_acc = f(init, hd)
      Cons(init, tl.scan_left(f, init=new_acc))
    }
    Nil => Cons(init, new())
  })
}

///|
/// Creates a LazyList with a single element.
pub fn[A] singleton(value : A) -> LazyList[A] {
  cons(value, new())
}

///|
/// Sorts the LazyList using the natural ordering of its elements. This forces the entire list.
pub fn[A : Compare] LazyList::sort(self : LazyList[A]) -> LazyList[A] {
  let array = self.to_array()
  array.sort()
  from_array(array)
}

///|
/// Gets the tail of the LazyList, if it exists. This forces only the head of the list.
pub fn[A] LazyList::tail(self : LazyList[A]) -> LazyList[A]? {
  match self.force() {
    Cons(_, tl) => Some(tl)
    Nil => None
  }
}

///|
/// Takes the first n elements from the LazyList.
pub fn[A] LazyList::take(self : LazyList[A], n : Int) -> LazyList[A] {
  from_thunk(() => match self.force() {
    Cons(_) if n == 0 => Nil
    Cons(hd, tl) => Cons(hd, tl.take(n - 1))
    Nil => Nil
  })
}

///|
/// Takes elements from the LazyList while the predicate holds true.
pub fn[A] LazyList::take_while(
  self : LazyList[A],
  f : (A) -> Bool,
) -> LazyList[A] {
  from_thunk(() => match self.force() {
    Cons(hd, tl) if f(hd) => Cons(hd, tl.take_while(f))
    _ => Nil
  })
}

///|
/// Converts the LazyList to an array. This forces the entire list.
pub fn[A] LazyList::to_array(self : LazyList[A]) -> Array[A] {
  let result = []
  self.each(result.push(_))
  result
}

///|
/// Removes and returns the value at the front of the LazyList, along with the updated LazyList.
/// This forces only the head of the list.
pub fn[A] LazyList::uncons(self : LazyList[A]) -> (A, LazyList[A])? {
  match self.force() {
    Cons(hd, tl) => Some((hd, tl))
    Nil => None
  }
}

///|
/// Creates a LazyList by unfolding a function over an initial state.
pub fn[A, B] unfold(init~ : B, f : (B) -> (A, B)?) -> LazyList[A] {
  from_thunk(() => match f(init) {
    Some((value, next)) => Cons(value, unfold(init=next, f))
    None => Nil
  })
}

///|
/// Returns the head element of the LazyList, aborting if the list is empty.
pub fn[A] LazyList::unsafe_head(self : LazyList[A]) -> A {
  guard self.force() is Cons(hd, _) else { abort("List is empty") }
  hd
}

///|
/// Returns the last element of the LazyList, aborting if the list is empty.
pub fn[A] LazyList::unsafe_last(self : LazyList[A]) -> A {
  guard self.last() is Some(result) else { abort("List is empty") }
  result
}

///|
/// Returns the maximum element of the LazyList, aborting if the list is empty.
pub fn[A : Compare] LazyList::unsafe_maximum(self : LazyList[A]) -> A {
  guard self.maximum() is Some(result) else { abort("List is empty") }
  result
}

///|
/// Returns the minimum element of the LazyList, aborting if the list is empty.
pub fn[A : Compare] LazyList::unsafe_minimum(self : LazyList[A]) -> A {
  guard self.minimum() is Some(result) else { abort("List is empty") }
  result
}

///|
/// Returns the nth element of the LazyList, aborting if the index is out of bounds.
pub fn[A] LazyList::unsafe_nth(self : LazyList[A], n : Int) -> A {
  guard self.nth(n) is Some(result) else { abort("Index out of bounds") }
  result
}

///|
/// Returns the tail of the LazyList, aborting if the list is empty.
pub fn[A] LazyList::unsafe_tail(self : LazyList[A]) -> LazyList[A] {
  guard self.force() is Cons(_, tl) else { abort("List is empty") }
  tl
}

///|
/// Removes and returns the value at the front of the LazyList, along with the updated LazyList,
/// aborting if the list is empty.
pub fn[A] LazyList::unsafe_uncons(self : LazyList[A]) -> (A, LazyList[A]) {
  guard self.force() is Cons(hd, tl) else { abort("List is empty") }
  (hd, tl)
}

///|
/// Zips two LazyLists into a LazyList of pairs.
/// The resulting LazyList is as long as the shorter of the two input lists.
pub fn[A, B] LazyList::zip(
  self : LazyList[A],
  other : LazyList[B],
) -> LazyList[(A, B)] {
  from_thunk(() => match (self.force(), other.force()) {
    (Cons(hd1, tl1), Cons(hd2, tl2)) => Cons((hd1, hd2), tl1.zip(tl2))
    _ => Nil
  })
}

///|
pub impl[A] Add for LazyList[A] with add(self, other) {
  self.concat(other)
}

///|
pub impl[A : Compare] Compare for LazyList[A] with compare(self, other) {
  for self = self, other = other {
    match (self.force(), other.force()) {
      (Cons(hd1, tl1), Cons(hd2, tl2)) => {
        let cmp = hd1.compare(hd2)
        if cmp != 0 {
          break cmp
        } else {
          continue tl1, tl2
        }
      }
      (Nil, Nil) => break 0
      (Nil, _) => break -1
      (_, Nil) => break 1
    }
  }
}

///|
pub impl[A : Eq] Eq for LazyList[A] with equal(self, other) {
  for self = self, other = other {
    match (self.force(), other.force()) {
      (Cons(hd1, tl1), Cons(hd2, tl2)) if hd1 == hd2 => continue tl1, tl2
      (Nil, Nil) => break true
      _ => break false
    }
  }
}

///|
pub impl[A : Hash] Hash for LazyList[A] with hash_combine(self, hasher) {
  for i in self {
    hasher.combine(i)
  }
}

///|
pub impl[A : Show] Show for LazyList[A] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@lazylist.from_array([", suffix="])")
}

///|
pub impl[A : ToJson] ToJson for LazyList[A] with to_json(self) {
  self.map(item => item.to_json()).to_array().to_json()
}

///|
pub impl[A : FromJson] FromJson for LazyList[A] with from_json(json, path) {
  guard json is Array(arr) else {
    raise JsonDecodeError((path, "@lazylist.from_json: expected array"))
  }
  arr.mapi((i, v) => A::from_json(v, path.add_index(i))) |> from_array
}

///|
using @quickcheck {trait Arbitrary}

///|
pub impl[A : Arbitrary] Arbitrary for LazyList[A] with arbitrary(size, rs) {
  Arbitrary::arbitrary(size, rs) |> from_array
}

///|
pub impl[A] Default for LazyList[A] with default() {
  new()
}
