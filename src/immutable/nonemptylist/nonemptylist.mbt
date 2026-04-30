///|
/// Returns true if all elements in the NonEmptyList satisfy the predicate f.
pub fn[A] NonEmptyList::all(
  self : NonEmptyList[A],
  f : (A) -> Bool raise?,
) -> Bool raise? {
  f(self.head) && self.tail.all(f)
}

///|
/// Returns true if any element in the NonEmptyList satisfies the predicate f.
pub fn[A] NonEmptyList::any(
  self : NonEmptyList[A],
  f : (A) -> Bool raise?,
) -> Bool raise? {
  f(self.head) || self.tail.any(f)
}

///|
/// Concatenates two NonEmptyLists.
pub fn[A] NonEmptyList::concat(
  self : NonEmptyList[A],
  other : NonEmptyList[A],
) -> NonEmptyList[A] {
  cons_list(self.head, self.tail + @list.cons(other.head, other.tail))
}

///|
/// Concatenates a NonEmptyList with a List.
pub fn[A] NonEmptyList::concat_list(
  self : NonEmptyList[A],
  other : List[A],
) -> NonEmptyList[A] {
  cons_list(self.head, self.tail + other)
}

///|
/// Prepends an element to a NonEmptyList.
pub fn[A] cons(head : A, tail : NonEmptyList[A]) -> NonEmptyList[A] {
  cons_list(head, @list.cons(tail.head, tail.tail))
}

///|
/// Creates a NonEmptyList from a head element and a List tail.
pub fn[A] cons_list(head : A, tail : List[A]) -> NonEmptyList[A] {
  { head, tail }
}

///|
/// Checks if the NonEmptyList contains a specific value.
pub fn[A : Eq] NonEmptyList::contains(
  self : NonEmptyList[A],
  value : A,
) -> Bool {
  self.head == value || self.tail.contains(value)
}

///|
/// Applies a function to each element of the NonEmptyList.
pub fn[A] NonEmptyList::each(
  self : NonEmptyList[A],
  f : (A) -> Unit raise?,
) -> Unit raise? {
  f(self.head)
  self.tail.each(f)
}

///|
/// Applies a function to each element of the NonEmptyList with its index.
pub fn[A] NonEmptyList::eachi(
  self : NonEmptyList[A],
  f : (Int, A) -> Unit raise?,
) -> Unit raise? {
  f(0, self.head)
  self.tail.eachi((i, v) => f(i + 1, v))
}

///|
/// Finds the first element in the NonEmptyList that satisfies the predicate f.
pub fn[A] NonEmptyList::find(
  self : NonEmptyList[A],
  f : (A) -> Bool raise?,
) -> A? raise? {
  if f(self.head) {
    Some(self.head)
  } else {
    self.tail.find(f)
  }
}

///|
/// Finds the index of the first element in the NonEmptyList that satisfies the predicate f.
pub fn[A] NonEmptyList::find_index(
  self : NonEmptyList[A],
  f : (A) -> Bool raise?,
) -> Int? raise? {
  if f(self.head) {
    Some(0)
  } else {
    self.tail.find_index(f).map(i => i + 1)
  }
}

///|
/// Finds the first element in the NonEmptyList that satisfies the predicate f, along with its index.
pub fn[A] NonEmptyList::findi(
  self : NonEmptyList[A],
  f : (A, Int) -> Bool raise?,
) -> A? raise? {
  if f(self.head, 0) {
    Some(self.head)
  } else {
    self.tail.findi((v, i) => f(v, i + 1))
  }
}

///|
/// Flattens a NonEmptyList of NonEmptyLists into a single NonEmptyList.
pub fn[A] NonEmptyList::flatten(
  self : NonEmptyList[NonEmptyList[A]],
) -> NonEmptyList[A] {
  self.tail.fold(init=cons_list(self.head.head, self.head.tail), (acc, nel) => {
    acc.concat_list(nel.to_list())
  })
}

///|
/// Applies a function to each element of the NonEmptyList and flattens the result.
pub fn[A] NonEmptyList::flat_map(
  self : NonEmptyList[A],
  f : (A) -> NonEmptyList[A] raise?,
) -> NonEmptyList[A] raise? {
  self.map(f).flatten()
}

///|
/// Folds the NonEmptyList from the left with an initial accumulator value.
pub fn[A, B] NonEmptyList::fold(
  self : NonEmptyList[A],
  init~ : B,
  f : (B, A) -> B raise?,
) -> B raise? {
  self.tail.fold(init=f(init, self.head), f)
}

///|
/// Folds the NonEmptyList from the left with an initial accumulator value and index.
pub fn[A, B] NonEmptyList::foldi(
  self : NonEmptyList[A],
  init~ : B,
  f : (Int, B, A) -> B raise?,
) -> B raise? {
  let acc = f(0, init, self.head)
  self.tail.foldi(init=acc, (i, b, a) => f(i + 1, b, a))
}

///|
/// Creates a NonEmptyList from an array, returning None if the array is empty.
pub fn[A] from_array(arr : ArrayView[A]) -> NonEmptyList[A]? {
  if arr.length() == 0 {
    None
  } else {
    Some(cons_list(arr[0], @list.from_array(arr[1:])))
  }
}

///|
/// Creates a NonEmptyList from an iterator, returning None if the iterator is empty.
pub fn[A] from_iter(iter : Iter[A]) -> NonEmptyList[A]? {
  guard iter.next() is Some(head) else { return None }
  Some(cons_list(head, @list.from_iter(iter)))
}

///|
/// Creates a NonEmptyList from an iterator in reverse order, returning None if the iterator is empty.
pub fn[A] from_iter_rev(iter : Iter[A]) -> NonEmptyList[A]? {
  guard @list.from_iter_rev(iter) is More(head, tail~) else { return None }
  Some(cons_list(head, tail))
}

///|
/// Returns the head element of the NonEmptyList.
pub fn[A] NonEmptyList::head(self : NonEmptyList[A]) -> A {
  self.head
}

///|
/// Intercalates a NonEmptyList of NonEmptyLists with a separator NonEmptyList.
pub fn[A] NonEmptyList::intercalate(
  self : NonEmptyList[NonEmptyList[A]],
  sep : NonEmptyList[A],
) -> NonEmptyList[A] {
  self.tail.fold(init=self.head, (acc, nel) => {
    acc
    .concat_list(@list.cons(sep.head, sep.tail))
    .concat_list(@list.cons(nel.head, nel.tail))
  })
}

///|
/// Intersperse a separator element between each element of the NonEmptyList.
pub fn[A] NonEmptyList::intersperse(
  self : NonEmptyList[A],
  sep : A,
) -> NonEmptyList[A] {
  self.tail.fold(init=singleton(self.head), (acc, v) => {
    acc
    .concat_list(@list.cons(sep, @list.empty()))
    .concat_list(@list.cons(v, @list.empty()))
  })
}

///|
/// Checks if the NonEmptyList is a prefix of another NonEmptyList.
pub fn[A : Eq] NonEmptyList::is_prefix(
  self : NonEmptyList[A],
  other : NonEmptyList[A],
) -> Bool {
  self.head == other.head && self.tail.is_prefix(other.tail)
}

///|
/// Checks if the NonEmptyList is a suffix of another NonEmptyList.
pub fn[A : Eq] NonEmptyList::is_suffix(
  self : NonEmptyList[A],
  other : NonEmptyList[A],
) -> Bool {
  let self_len = self.length()
  let other_len = other.length()
  if self_len < other_len {
    return false
  }
  let self_rev = self.rev()
  let other_rev = other.rev()
  self_rev.is_prefix(other_rev)
}

///|
/// Returns an iterator over the elements of the NonEmptyList.
pub fn[A] NonEmptyList::iter(self : NonEmptyList[A]) -> Iter[A] {
  self.to_list().iter()
}

///|
/// Returns an iterator over the indices and elements of the NonEmptyList.
pub fn[A] NonEmptyList::iter2(self : NonEmptyList[A]) -> Iter2[Int, A] {
  self.to_list().iter2()
}

///|
/// Returns the last element of the NonEmptyList.
pub fn[A] NonEmptyList::last(self : NonEmptyList[A]) -> A {
  self.tail.last().unwrap_or(self.head)
}

///|
/// Returns the length of the NonEmptyList. 
pub fn[A] NonEmptyList::length(self : NonEmptyList[A]) -> Int {
  1 + self.tail.length()
}

///|
/// Looks up a value by key in a NonEmptyList of key-value pairs.
pub fn[A : Eq, B] NonEmptyList::lookup(
  self : NonEmptyList[(A, B)],
  key : A,
) -> B? {
  if self.head.0 == key {
    Some(self.head.1)
  } else {
    self.tail.lookup(key)
  }
}

///|
/// Maps a function over each element of the NonEmptyList.
pub fn[A, B] NonEmptyList::map(
  self : NonEmptyList[A],
  f : (A) -> B raise?,
) -> NonEmptyList[B] raise? {
  cons_list(f(self.head), self.tail.map(f))
}

///|
/// Maps a function over each element of the NonEmptyList with its index.
pub fn[A, B] NonEmptyList::mapi(
  self : NonEmptyList[A],
  f : (Int, A) -> B raise?,
) -> NonEmptyList[B] raise? {
  cons_list(f(0, self.head), self.tail.mapi((i, v) => f(i + 1, v)))
}

///|
/// Returns the maximum element in the NonEmptyList.
pub fn[A : Compare] NonEmptyList::maximum(self : NonEmptyList[A]) -> A {
  self.tail.fold(init=self.head, (acc, v) => if v > acc { v } else { acc })
}

///|
/// Returns the minimum element in the NonEmptyList.
pub fn[A : Compare] NonEmptyList::minimum(self : NonEmptyList[A]) -> A {
  self.tail.fold(init=self.head, (acc, v) => if v < acc { v } else { acc })
}

///|
/// Returns the nth element of the NonEmptyList, or None if out of bounds.
pub fn[A] NonEmptyList::nth(self : NonEmptyList[A], n : Int) -> A? {
  if n == 0 {
    Some(self.head)
  } else {
    self.tail.nth(n - 1)
  }
}

///|
/// Prepends a value to the NonEmptyList.
pub fn[A] NonEmptyList::prepend(
  self : NonEmptyList[A],
  value : A,
) -> NonEmptyList[A] {
  cons(value, self)
}

///|
/// Creates a NonEmptyList by repeating a value n times (n must be greater than 1).
pub fn[A] repeat(n : Int, x : A) -> NonEmptyList[A] {
  guard n > 1 else { abort("n must be greater than 1") }
  cons_list(x, @list.repeat(n - 1, x))
}

///|
/// Reverses the NonEmptyList.
pub fn[A] NonEmptyList::rev(self : NonEmptyList[A]) -> NonEmptyList[A] {
  self.to_list().rev() |> unsafe_from_list
}

///|
/// Same as `self.rev().concat(other)`, but more efficient.
pub fn[A] NonEmptyList::rev_concat(
  self : NonEmptyList[A],
  other : NonEmptyList[A],
) -> NonEmptyList[A] {
  self.to_list().rev_concat(other.to_list()) |> unsafe_from_list
}

///|
/// Smae as `self.rev().concat_list(other)`, but more efficient.
pub fn[A] NonEmptyList::rev_map(
  self : NonEmptyList[A],
  f : (A) -> A raise?,
) -> NonEmptyList[A] raise? {
  self.to_list().rev_map(f) |> unsafe_from_list
}

///|
/// Scans the NonEmptyList from the left with an initial accumulator value.
pub fn[A, B] NonEmptyList::scan_left(
  self : NonEmptyList[A],
  init~ : B,
  f : (B, A) -> B raise?,
) -> NonEmptyList[B] raise? {
  let first = f(init, self.head)
  let scanned_tail = self.tail.scan_left(init=first, f)
  cons_list(init, scanned_tail)
}

///|
/// Scans the NonEmptyList from the right with an initial accumulator value.
pub fn[A, B] NonEmptyList::scan_right(
  self : NonEmptyList[A],
  init~ : B,
  f : (A, B) -> B raise?,
) -> NonEmptyList[B] raise? {
  self.rev().scan_left(init~, (b, a) => f(a, b)).rev()
}

///|
/// Creates a NonEmptyList with a single element.
pub fn[A] singleton(value : A) -> NonEmptyList[A] {
  cons_list(value, @list.empty())
}

///|
/// Sorts the NonEmptyList.
pub fn[A : Compare] NonEmptyList::sort(
  self : NonEmptyList[A],
) -> NonEmptyList[A] {
  self.to_list().sort() |> unsafe_from_list
}

///|
/// Returns the tail of the NonEmptyList as another NonEmptyList, or None if the tail is empty.
pub fn[A] NonEmptyList::tail(self : NonEmptyList[A]) -> NonEmptyList[A]? {
  guard self.tail is More(head, tail~) else { return None }
  Some(cons_list(head, tail))
}

///|
/// Returns the tail of the NonEmptyList as a List.
pub fn[A] NonEmptyList::tail_list(self : NonEmptyList[A]) -> List[A] {
  self.tail
}

///|
/// Converts the NonEmptyList to an array.
pub fn[A] NonEmptyList::to_array(self : NonEmptyList[A]) -> Array[A] {
  let arr = [self.head]
  self.tail.each(value => arr.push(value))
  arr
}

///|
/// Converts the NonEmptyList to a List.
pub fn[A] NonEmptyList::to_list(self : NonEmptyList[A]) -> List[A] {
  @list.cons(self.head, self.tail)
}

///|
/// Splits the NonEmptyList into its head and tail.
pub fn[A] NonEmptyList::uncons(self : NonEmptyList[A]) -> (A, List[A]) {
  (self.head, self.tail)
}

///|
/// Creates a NonEmptyList from an array, aborting if the array is empty.
pub fn[A] unsafe_from_array(arr : ArrayView[A]) -> NonEmptyList[A] {
  guard from_array(arr) is Some(nel) else {
    abort("Cannot create NonEmptyList from empty array")
  }
  nel
}

///|
/// Creates a NonEmptyList from a List, aborting if the List is empty.
pub fn[A] unsafe_from_list(values : List[A]) -> NonEmptyList[A] {
  guard values is More(head, tail~) else {
    abort("Cannot create NonEmptyList from empty List")
  }
  cons_list(head, tail)
}

///|
/// Returns the nth element of the NonEmptyList, aborting if out of bounds.
pub fn[A] NonEmptyList::unsafe_nth(self : NonEmptyList[A], n : Int) -> A {
  guard self.nth(n) is Some(result) else { abort("Index out of bounds") }
  result
}

///|
/// Returns the tail of the NonEmptyList as another NonEmptyList, aborting if the tail is empty.
pub fn[A] NonEmptyList::unsafe_tail(self : NonEmptyList[A]) -> NonEmptyList[A] {
  guard self.tail() is Some(result) else { abort("No tail available") }
  result
}

///|
/// Splits a NonEmptyList of pairs into two NonEmptyLists.
pub fn[A, B] NonEmptyList::unzip(
  self : NonEmptyList[(A, B)],
) -> (NonEmptyList[A], NonEmptyList[B]) {
  let head_pair = self.head
  let (tail_a, tail_b) = self.tail.unzip()
  (cons_list(head_pair.0, tail_a), cons_list(head_pair.1, tail_b))
}

///|
/// Zips two NonEmptyLists into a NonEmptyList of pairs.
pub fn[A, B] NonEmptyList::zip(
  self : NonEmptyList[A],
  other : NonEmptyList[B],
) -> NonEmptyList[(A, B)] {
  cons_list((self.head, other.head), self.tail.zip(other.tail))
}

///|
pub impl[A : Show] Show for NonEmptyList[A] with output(self, logger) {
  logger.write_iter(
    self.iter(),
    prefix="@nonemptylist.from_array([",
    suffix="])",
  )
}

///|
pub impl[A] Add for NonEmptyList[A] with add(self, other) {
  self.concat(other)
}

///|
using @quickcheck {trait Arbitrary}

///|
pub impl[A : Arbitrary] Arbitrary for NonEmptyList[A] with arbitrary(size, rs) {
  guard size >= 0 else { abort("Size must be non-negative") }
  let head = Arbitrary::arbitrary(0, rs)
  let tail = @list.List::arbitrary(size, rs)
  cons_list(head, tail)
}

///|
pub impl[A : ToJson] ToJson for NonEmptyList[A] with to_json(self) {
  self.to_list().to_json()
}

///|
pub impl[A : FromJson] FromJson for NonEmptyList[A] with from_json(value, path) {
  match value {
    Array(arr) => {
      guard from_array(arr) is Some(result) else {
        raise JsonDecodeError(
          (path, "@nonemptylist.from_json: expected non-empty array"),
        )
      }
      result.mapi((i, v) => A::from_json(v, path.add_index(i)))
    }
    _ =>
      raise JsonDecodeError((path, "@nonemptylist.from_json: expected array"))
  }
}
