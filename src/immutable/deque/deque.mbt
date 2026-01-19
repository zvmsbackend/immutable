///|
fn[A] List::split_in_two(self : List[A]) -> (List[A], List[A]) {
  loop (@list.empty(), self, self) {
    (acc, More(x, tail=slow_tail), More(_, tail=More(_, tail=fast_tail))) =>
      continue (acc.prepend(x), slow_tail, fast_tail)
    (acc, slow, _fast) => break (acc.rev(), slow)
  }
}

///|
/// Creates a new empty Deque.
pub fn[A] new() -> Deque[A] {
  { front: @list.empty(), back: @list.empty() }
}

///|
/// Creates a Deque from a List.
pub fn[A] from_list(list : List[A]) -> Deque[A] {
  { front: list, back: @list.empty() }
}

///|
/// Sames as `from_list(front, back.rev())`, but more efficient.
pub fn[A] from_cat_lists(front : List[A], back : List[A]) -> Deque[A] {
  { front, back: back.rev() }
}

///|
/// Creates a Deque from an ArrayView.
pub fn[A] from_array(array : ArrayView[A]) -> Deque[A] {
  from_list(@list.from_array(array))
}

///|
/// Creates a Deque from an Iter.
pub fn[A] from_iter(iter : Iter[A]) -> Deque[A] {
  from_list(@list.from_iter(iter))
}

///|
/// Sames as `from_list(front, back.rev())`, but more efficient.
pub fn[A] from_iter_rev(iter : Iter[A]) -> Deque[A] {
  from_list(@list.from_iter_rev(iter))
}

///|
/// Adds an element to the front of the Deque.
pub fn[A] Deque::push_front(self : Deque[A], value : A) -> Deque[A] {
  { front: @list.cons(value, self.front), back: self.back }
}

///|
/// Adds an element to the back of the Deque.
pub fn[A] Deque::push_back(self : Deque[A], value : A) -> Deque[A] {
  { front: self.front, back: @list.cons(value, self.back) }
}

///|
/// Removes and returns the element at the front of the Deque, if it exists.
pub fn[A] Deque::uncons_front(self : Deque[A]) -> (A, Deque[A])? {
  match self.front {
    More(x, tail~) => Some((x, { ..self, front: tail }))
    Empty => {
      let (new_back, new_front_rev) = self.back.split_in_two()
      guard new_front_rev.rev() is More(x, tail=new_front) else { return None }
      Some((x, { front: new_front, back: new_back }))
    }
  }
}

///|
/// Removes and returns the element at the back of the Deque, if it exists.
pub fn[A] Deque::uncons_back(self : Deque[A]) -> (A, Deque[A])? {
  match self.back {
    More(x, tail~) => Some((x, { ..self, back: tail }))
    Empty => {
      let (new_front, new_back_rev) = self.front.split_in_two()
      guard new_back_rev.rev() is More(x, tail=new_back) else { return None }
      Some((x, { front: new_front, back: new_back }))
    }
  }
}

///|
/// Returns the element at the front of the Deque, if it exists.
pub fn[A] Deque::front(self : Deque[A]) -> A? {
  match self.front {
    More(x, ..) => Some(x)
    Empty => self.back.rev().head()
  }
}

///|
/// Removes and the element at the front of the Deque and returns the updated deque, if it exists.
pub fn[A] Deque::pop_front(self : Deque[A]) -> Deque[A]? {
  self.uncons_front().map(pair => pair.1)
}

///|
/// Returns the element at the back of the Deque, if it exists.
pub fn[A] Deque::back(self : Deque[A]) -> A? {
  match self.back {
    More(x, ..) => Some(x)
    Empty => self.front.rev().head()
  }
}

///|
/// Removes and the element at the back of the Deque and returns the updated deque, if it exists.
pub fn[A] Deque::pop_back(self : Deque[A]) -> Deque[A]? {
  self.uncons_back().map(pair => pair.1)
}

///|
/// Applies a function to each element of the Deque.
pub fn[A] Deque::each(self : Deque[A], f : (A) -> Unit) -> Unit {
  self.front.each(f)
  self.back.rev().each(f)
}

///|
/// Applies a function to each element of the Deque, along with its index.
pub fn[A] Deque::eachi(self : Deque[A], f : (Int, A) -> Unit) -> Unit {
  let mut index = 0
  self.front.each(value => {
    f(index, value)
    index = index + 1
  })
  self.back
  .rev()
  .each(value => {
    f(index, value)
    index = index + 1
  })
}

///|
/// Returns true if the Deque is empty.
pub fn[A] Deque::is_empty(self : Deque[A]) -> Bool {
  self.front.is_empty() && self.back.is_empty()
}

///|
/// Reverses the Deque. Takes O(1) time.
pub fn[A] Deque::rev(self : Deque[A]) -> Deque[A] {
  { front: self.back, back: self.front }
}

///|
/// Creates a Deque with a single element.
pub fn[A] Deque::singleton(value : A) -> Deque[A] {
  { front: @list.singleton(value), back: @list.empty() }
}

///|
/// Returns the number of elements in the Deque.
pub fn[A] Deque::length(self : Deque[A]) -> Int {
  self.front.length() + self.back.length()
}

///|
/// Returns an iterator over the elements of the Deque.
pub fn[A] Deque::iter(self : Deque[A]) -> Iter[A] {
  self.front.iter() + self.back.rev().iter()
}

///|
/// Returns an iterator over the indices and elements of the Deque.
pub fn[A] Deque::iter2(self : Deque[A]) -> Iter2[Int, A] {
  self.front.iter2().concat(self.back.rev().iter2())
}

///|
/// Converts the Deque to a List.
pub fn[A] Deque::to_list(self : Deque[A]) -> List[A] {
  self.front + self.back.rev()
}

///|
/// Converts the Deque to an Array.
pub fn[A] Deque::to_array(self : Deque[A]) -> Array[A] {
  self.to_list().to_array()
}

///|
/// Removes and returns the element at the front of the Deque, aborting if it is empty.
pub fn[A] Deque::unsafe_uncons_front(self : Deque[A]) -> (A, Deque[A]) {
  guard self.uncons_front() is Some(result) else { abort("Deque is empty") }
  result
}

///|
/// Removes and returns the element at the back of the Deque, aborting if it is empty.
pub fn[A] Deque::unsafe_uncons_back(self : Deque[A]) -> (A, Deque[A]) {
  guard self.uncons_back() is Some(result) else { abort("Deque is empty") }
  result
}

///|
/// Returns the element at the front of the Deque, aborting if it is empty.
pub fn[A] Deque::unsafe_front(self : Deque[A]) -> A {
  guard self.front() is Some(result) else { abort("Deque is empty") }
  result
}

///|
/// Returns the element at the back of the Deque, aborting if it is empty.
pub fn[A] Deque::unsafe_back(self : Deque[A]) -> A {
  guard self.back() is Some(result) else { abort("Deque is empty") }
  result
}

///|
pub impl[A : Show] Show for Deque[A] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@deque.from_array([", suffix="])")
}

///|
pub impl[A : Eq] Eq for Deque[A] with equal(self, other) {
  self.length() == other.length() &&
  @utils.iter_all2(self.iter(), other.iter(), Eq::equal)
}

///|
pub impl[A : Compare] Compare for Deque[A] with compare(self, other) {
  @utils.iter_compare(self.iter(), other.iter())
}

///|
pub impl[A : Hash] Hash for Deque[A] with hash_combine(self, hasher) {
  self.each(hasher.combine(_))
}

///|
using @quickcheck {trait Arbitrary}

///|
pub impl[A : Arbitrary] Arbitrary for Deque[A] with arbitrary(size, rs) {
  List::arbitrary(size, rs) |> from_list
}

///|
pub impl[A : ToJson] ToJson for Deque[A] with to_json(self) {
  self.to_list().to_json()
}

///|
pub impl[A : FromJson] FromJson for Deque[A] with from_json(json, path) {
  guard json is Array(arr) else {
    raise JsonDecodeError((path, "@deque.from_json: expected array"))
  }
  arr.mapi((i, v) => A::from_json(v, path.add_index(i))) |> from_array
}

///|
pub impl[A] Default for Deque[A] with default() {
  new()
}
