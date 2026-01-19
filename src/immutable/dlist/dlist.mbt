///|
/// Prepends an element to the front of the DList, returning a new DList.
pub fn[A] DList::push_front(self : DList[A], value : A) -> DList[A] {
  match self.root {
    Nil => { length: 1, root: Unit(value) }
    _ => { length: self.length + 1, root: Concat(Unit(value), self.root) }
  }
}

///|
/// Appends an element to the back of the DList, returning a new DList.
pub fn[A] DList::push_back(self : DList[A], value : A) -> DList[A] {
  match self.root {
    Nil => { length: 1, root: Unit(value) }
    _ => { length: self.length + 1, root: Concat(self.root, Unit(value)) }
  }
}

///|
/// Concatenates two DLists, returning a new DList. Takes O(1) time.
pub fn[A] DList::concat(self : DList[A], other : DList[A]) -> DList[A] {
  match self.root {
    Nil => other
    _ =>
      match other.root {
        Nil => self
        _ =>
          {
            length: self.length + other.length,
            root: Concat(self.root, other.root),
          }
      }
  }
}

///|
/// Checks if the DList is empty.
pub fn[A] DList::is_empty(self : DList[A]) -> Bool {
  self.length == 0
}

///|
/// Returns the number of elements in the DList. Takes O(1) time.
pub fn[A] DList::length(self : DList[A]) -> Int {
  self.length
}

///|
/// Creates a new empty DList.
pub fn[A] new() -> DList[A] {
  { length: 0, root: Nil }
}

///|
/// Creates a DList from an ArrayView.
pub fn[A] from_array(arr : ArrayView[A]) -> DList[A] {
  arr.fold(init=new(), (dlist, item) => dlist.push_back(item))
}

///|
/// Creates a DList from an Iter.
pub fn[A] from_iter(iter : Iter[A]) -> DList[A] {
  iter.fold(init=new(), (dlist, item) => dlist.push_back(item))
}

///|
/// Converts the DList to an Array.
pub fn[A] DList::to_array(self : DList[A]) -> Array[A] {
  let result = []
  fn walk(node : Node[A]) {
    match node {
      Nil => ()
      Unit(value) => result.push(value)
      Concat(left, right) => {
        walk(left)
        walk(right)
      }
    }
  }

  walk(self.root)
  result
}

///|
/// Returns an iterator over the elements of the DList.
pub fn[A] DList::iter(self : DList[A]) -> Iter[A] {
  fn walk(current : Node[A], rights : @list.List[Node[A]]) {
    match current {
      Nil => Iter::empty()
      Unit(value) =>
        match rights {
          Empty => Iter::singleton(value)
          More(next, tail=rest) =>
            Iter::singleton(value).concat(walk(next, rest))
        }
      Concat(left, right) => walk(left, @list.cons(right, rights))
    }
  }

  walk(self.root, @list.empty())
}

///|
/// Returns an iterator over the indices and elements of the DList.
pub fn[A] DList::iter2(self : DList[A]) -> Iter2[Int, A] {
  self.iter().iter2()
}

///|
/// Folds over the DList, accumulating a result using a provided function.
pub fn[A, B] DList::fold(
  self : DList[A],
  init~ : B,
  f : (B, A) -> B raise?,
) -> B raise? {
  fn walk(current : Node[A], acc : B) -> B raise? {
    match current {
      Nil => acc
      Unit(value) => f(acc, value)
      Concat(left, right) => {
        let acc2 = walk(left, acc)
        walk(right, acc2)
      }
    }
  }

  walk(self.root, init)
}

///|
/// Applies a function to each element of the DList.
pub fn[A] DList::each(self : DList[A], f : (A) -> Unit raise?) -> Unit raise? {
  fn walk(current : Node[A]) -> Unit raise? {
    match current {
      Nil => ()
      Unit(value) => f(value)
      Concat(left, right) => {
        walk(left)
        walk(right)
      }
    }
  }

  walk(self.root)
}

///|
/// Applies a function to each element of the DList, along with its index.
pub fn[A] DList::eachi(
  self : DList[A],
  f : (Int, A) -> Unit raise?,
) -> Unit raise? {
  let mut index = 0
  fn walk(current : Node[A]) -> Unit raise? {
    match current {
      Nil => ()
      Unit(value) => {
        f(index, value)
        index += 1
      }
      Concat(left, right) => {
        walk(left)
        walk(right)
      }
    }
  }

  walk(self.root)
}

///|
/// Maps a function over the DList, producing a new DList.
pub fn[A, B] DList::map(
  self : DList[A],
  f : (A) -> B raise?,
) -> DList[B] raise? {
  fn walk(node : Node[A]) -> Node[B] raise? {
    match node {
      Nil => Nil
      Unit(value) => Unit(f(value))
      Concat(left, right) => Concat(walk(left), walk(right))
    }
  }

  { length: self.length, root: walk(self.root) }
}

///|
/// Maps a function over the DList with indices, producing a new DList.
pub fn[A, B] DList::mapi(
  self : DList[A],
  f : (Int, A) -> B raise?,
) -> DList[B] raise? {
  let mut index = 0
  fn walk(node : Node[A]) -> Node[B] raise? {
    match node {
      Nil => Nil
      Unit(value) => {
        let result = Unit(f(index, value))
        index += 1
        result
      }
      Concat(left, right) => Concat(walk(left), walk(right))
    }
  }

  { length: self.length, root: walk(self.root) }
}

///|
/// Creates a DList with a single element.
pub fn[A] singleton(value : A) -> DList[A] {
  { length: 1, root: Unit(value) }
}

///|
pub impl[A : Show] Show for DList[A] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@dlist.from_array([", suffix="])")
}

///|
pub impl[A : Eq] Eq for DList[A] with equal(self, other) {
  self.length == other.length &&
  @utils.iter_all2(self.iter(), other.iter(), Eq::equal)
}

///|
pub impl[A : Compare] Compare for DList[A] with compare(self, other) {
  @utils.iter_compare(self.iter(), other.iter())
}

///|
pub impl[A : Hash] Hash for DList[A] with hash_combine(self, hasher) {
  self.each(hasher.combine(_))
}

///|
pub impl[A] Add for DList[A] with add(self, other) {
  self.concat(other)
}

///|
using @quickcheck {trait Arbitrary}

///|
pub impl[A : Arbitrary] Arbitrary for DList[A] with arbitrary(size, rs) {
  Arbitrary::arbitrary(size, rs) |> from_array
}

///|
pub impl[A : FromJson] FromJson for DList[A] with from_json(json, path) {
  guard json is Array(arr) else {
    raise JsonDecodeError((path, "@dlist.from_json: expected array"))
  }
  arr.mapi((i, v) => A::from_json(v, path.add_index(i))) |> from_array
}

///|
pub impl[A : ToJson] ToJson for DList[A] with to_json(self) {
  self.to_array().to_json()
}

///|
pub impl[A] Default for DList[A] with default() {
  new()
}
