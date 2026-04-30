///|
fn mask_u(i : UInt, m : UInt) -> Int {
  (i & ((m - 1).lnot() ^ m)).reinterpret_as_int()
}

///|
fn mask(i : Int, m : Int) -> Int {
  mask_u(i.reinterpret_as_uint(), m.reinterpret_as_uint())
}

///|
fn no_match(i : Int, p : Int, m : Int) -> Bool {
  mask(i, m) != p
}

///|
fn zero(i : Int, m : Int) -> Bool {
  (i.reinterpret_as_uint() & m.reinterpret_as_uint()) == 0
}

///|
fn shorter(m1 : Int, m2 : Int) -> Bool {
  m1.reinterpret_as_uint() > m2.reinterpret_as_uint()
}

///|
fn highest_bit_mask(x0 : UInt) -> UInt {
  let mut x = x0
  x = x | (x >> 1)
  x = x | (x >> 2)
  x = x | (x >> 4)
  x = x | (x >> 8)
  x = x | (x >> 16)
  x = x | (x >> 32)
  x ^ (x >> 1)
}

///|
fn branch_mask(i1 : Int, i2 : Int) -> Int {
  highest_bit_mask(i1.reinterpret_as_uint() ^ i2.reinterpret_as_uint()).reinterpret_as_int()
}

///|
fn[A] join(p1 : Int, t1 : IntMap[A], p2 : Int, t2 : IntMap[A]) -> IntMap[A] {
  let m = branch_mask(p1, p2)
  let p = mask(p1, m)
  if zero(p1, m) {
    Node(p, t1, m, t2)
  } else {
    Node(p, t2, m, t1)
  }
}

///|
fn[A] node(p : Int, l : IntMap[A], m : Int, r : IntMap[A]) -> IntMap[A] {
  match (l, r) {
    (l, Nil) => l
    (Nil, r) => r
    _ => Node(p, l, m, r)
  }
}

///|
/// Returns true if the IntMap is empty.
pub fn[A] IntMap::is_empty(self : IntMap[A]) -> Bool {
  self is Nil
}

///|
/// Returns the number of key-value pairs in the IntMap.
pub fn[A] IntMap::length(self : IntMap[A]) -> Int {
  match self {
    Nil => 0
    Tip(_) => 1
    Node(_, left, _, right) => left.length() + right.length()
  }
}

///|
/// Returns the value associated with the given key, if it exists.
pub fn[A] IntMap::get(self : IntMap[A], k : Int) -> A? {
  match self {
    Nil => None
    Tip(pk, v) if pk == k => Some(v)
    Tip(_) => None
    Node(p, _, m, _) if no_match(k, p, m) => None
    Node(_, l, m, _) if zero(k, m) => l.get(k)
    Node(_, _, _, r) => r.get(k)
  }
}

///|
/// Returns the value associated with the given key, or a default value if the key is not found.
pub fn[A] IntMap::get_or_default(self : IntMap[A], k : Int, default : A) -> A {
  match self {
    Nil => default
    Tip(pk, v) if pk == k => v
    Tip(_) => default
    Node(p, _, m, _) if no_match(k, p, m) => default
    Node(_, l, m, _) if zero(k, m) => l.get_or_default(k, default)
    Node(_, _, _, r) => r.get_or_default(k, default)
  }
}

///|
/// Returns the value associated with the given key,
/// or initializes it using the provided thunk if the key is not found.
pub fn[A] IntMap::get_or_init(self : IntMap[A], k : Int, init : () -> A) -> A {
  match self {
    Nil => init()
    Tip(pk, v) if pk == k => v
    Tip(_) => init()
    Node(p, _, m, _) if no_match(k, p, m) => init()
    Node(_, l, m, _) if zero(k, m) => l.get_or_init(k, init)
    Node(_, _, _, r) => r.get_or_init(k, init)
  }
}

///|
/// Returns true if the IntMap contains the given key.
pub fn[A] IntMap::contains(self : IntMap[A], k : Int) -> Bool {
  match self {
    Nil => false
    Tip(pk, _) if pk == k => true
    Tip(_) => false
    Node(p, _, m, _) if no_match(k, p, m) => false
    Node(_, left, m, _) if zero(k, m) => left.contains(k)
    Node(_, _, _, right) => right.contains(k)
  }
}

///|
/// Returns the value associated with the given key, aborting if the key is not found.
#alias("_[_]")
pub fn[A] IntMap::at(self : IntMap[A], k : Int) -> A {
  guard self.get(k) is Some(v) else { abort("Key not found in IntMap") }
  v
}

///|
/// Applies a function to each key-value pair in the IntMap.
pub fn[A] IntMap::each(
  self : IntMap[A],
  f : (Int, A) -> Unit raise?,
) -> Unit raise? {
  match self {
    Nil => ()
    Tip(pk, pv) => f(pk, pv)
    Node(_, left, _, right) => {
      left.each(f)
      right.each(f)
    }
  }
}

///|
/// Applies a function to each key-value pair in the IntMap, along with its index.
pub fn[A] IntMap::eachi(
  self : IntMap[A],
  f : (Int, Int, A) -> Unit raise?,
) -> Unit raise? {
  let mut index = 0
  fn walk(map : IntMap[A]) -> Unit raise? {
    match map {
      Nil => ()
      Tip(pk, pv) => {
        f(index, pk, pv)
        index += 1
      }
      Node(_, left, _, right) => {
        walk(left)
        walk(right)
      }
    }
  }

  walk(self)
}

///|
/// Creates a new, empty IntMap.
pub fn[A] new() -> IntMap[A] {
  Nil
}

///|
/// Creates an IntMap from an array of key-value pairs.
pub fn[A] from_array(arr : ArrayView[(Int, A)]) -> IntMap[A] {
  arr.fold(init=new(), (m, kv) => m.add(kv.0, kv.1))
}

///|
/// Creates an IntMap from an iterator of key-value pairs.
pub fn[A] from_iter(iter : Iter[(Int, A)]) -> IntMap[A] {
  iter.fold(init=new(), (m, kv) => m.add(kv.0, kv.1))
}

///|
/// Returns an iterator over the key-value pairs in the IntMap.
pub fn[A] IntMap::iter(self : IntMap[A]) -> Iter[(Int, A)] {
  match self {
    Nil => Iter::empty()
    Tip(pk, pv) => Iter::singleton((pk, pv))
    Node(_, left, _, right) => left.iter().concat(right.iter())
  }
}

///|
/// Returns an iterator over the key-value pairs in the IntMap.
pub fn[A] IntMap::iter2(self : IntMap[A]) -> Iter2[Int, A] {
  let iter = self.iter()
  Iter2::new(() => iter.next())
}

///|
/// Returns an iterator over the keys in the IntMap.
pub fn[A] IntMap::keys(self : IntMap[A]) -> Iter[Int] {
  self.iter().map(kv => kv.0)
}

///|
/// Returns an iterator over the values in the IntMap.
pub fn[A] IntMap::values(self : IntMap[A]) -> Iter[A] {
  self.iter().map(kv => kv.1)
}

///|
/// Converts the IntMap to an array of key-value pairs.
pub fn[A] IntMap::to_array(self : IntMap[A]) -> Array[(Int, A)] {
  let result = []
  fn walk(map : IntMap[A]) {
    match map {
      Nil => ()
      Tip(pk, pv) => result.push((pk, pv))
      Node(_, left, _, right) => {
        walk(left)
        walk(right)
      }
    }
  }

  walk(self)
  result
}

///|
/// Maps a function over the IntMap, producing a new IntMap.
pub fn[A, B] IntMap::map(
  self : IntMap[A],
  f : (Int, A) -> B raise?,
) -> IntMap[B] raise? {
  match self {
    Nil => Nil
    Tip(pk, pv) => Tip(pk, f(pk, pv))
    Node(p, left, m, right) => Node(p, left.map(f), m, right.map(f))
  }
}

///|
/// Filters the IntMap based on a predicate function, producing a new IntMap.
pub fn[A] IntMap::filter(
  self : IntMap[A],
  f : (Int, A) -> Bool raise?,
) -> IntMap[A] raise? {
  match self {
    Nil => Nil
    Tip(pk, pv) if f(pk, pv) => Tip(pk, pv)
    Tip(_) => Nil
    Node(p, left, m, right) => node(p, left.filter(f), m, right.filter(f))
  }
}

///|
/// Folds over the IntMap, accumulating a result using a provided function.
pub fn[A, B] IntMap::fold(
  self : IntMap[A],
  init~ : B,
  f : (B, Int, A) -> B raise?,
) -> B raise? {
  match self {
    Nil => init
    Tip(pk, pv) => f(init, pk, pv)
    Node(_, left, _, right) => {
      let acc = left.fold(init~, f)
      right.fold(init=acc, f)
    }
  }
}

///|
fn[A] maybe_join(
  p1 : Int,
  t1 : IntMap[A],
  p2 : Int,
  t2 : IntMap[A],
) -> IntMap[A] {
  match (t1, t2) {
    (Nil, t2) => t2
    (t1, Nil) => t1
    _ => join(p1, t1, p2, t2)
  }
}

///|
fn[A] merge1(
  p1 : Int,
  m1 : Int,
  t1 : IntMap[A],
  l1 : IntMap[A],
  r1 : IntMap[A],
  p2 : Int,
  t2 : IntMap[A],
) -> IntMap[A] {
  if no_match(p2, p1, m1) {
    maybe_join(p1, t1, p2, t2)
  } else if zero(p2, m1) {
    Node(p1, l1.merge(t2), m1, r1)
  } else {
    Node(p1, l1, m1, r1.merge(t2))
  }
}

///|
fn[A] merge2(
  p1 : Int,
  t1 : IntMap[A],
  p2 : Int,
  m2 : Int,
  t2 : IntMap[A],
  l2 : IntMap[A],
  r2 : IntMap[A],
) -> IntMap[A] {
  if no_match(p1, p2, m2) {
    maybe_join(p1, t1, p2, t2)
  } else if zero(p1, m2) {
    Node(p2, t1.merge(l2), m2, r2)
  } else {
    Node(p2, l2, m2, t1.merge(r2))
  }
}

///|
/// Merges two IntMaps, combining their key-value pairs.
pub fn[A] IntMap::merge(self : IntMap[A], other : IntMap[A]) -> IntMap[A] {
  match (self, other) {
    (Nil, _) => other
    (_, Nil) => self
    (Tip(k, v), _) => other.add(k, v)
    (_, Tip(k, v)) => self.add(k, v)
    (Node(p1, l1, m1, r1), Node(p2, l2, m2, r2)) =>
      if shorter(m1, m2) {
        merge1(p1, m1, self, l1, r1, p2, other)
      } else if shorter(m2, m1) {
        merge2(p1, self, p2, m2, other, l2, r2)
      } else if p1 == p2 {
        Node(p1, l1.merge(l2), m1, r1.merge(r2))
      } else {
        maybe_join(p1, self, p2, other)
      }
  }
}

///|
/// Adds a key-value pair to the IntMap, returning a new IntMap.
pub fn[A] IntMap::add(self : IntMap[A], k : Int, v : A) -> IntMap[A] {
  match self {
    Nil => Tip(k, v)
    Tip(pk, _) if pk == k => Tip(k, v)
    Tip(pk, _) => join(k, Tip(k, v), pk, self)
    Node(p, _, m, _) if no_match(k, p, m) => join(k, Tip(k, v), p, self)
    Node(p, left, m, right) if zero(k, m) => node(p, left.add(k, v), m, right)
    Node(p, left, m, right) => node(p, left, m, right.add(k, v))
  }
}

///|
/// Removes a key-value pair from the IntMap, returning a new IntMap.
pub fn[A] IntMap::remove(self : IntMap[A], k : Int) -> IntMap[A] {
  match self {
    Nil => Nil
    Tip(pk, _) if pk == k => Nil
    Tip(_) => self
    Node(p, _, m, _) if no_match(k, p, m) => self
    Node(p, left, m, right) if zero(k, m) => node(p, left.remove(k), m, right)
    Node(p, left, m, right) => node(p, left, m, right.remove(k))
  }
}

///|
/// Creates an IntMap with a single key-value pair.
pub fn[A] IntMap::singleton(k : Int, v : A) -> IntMap[A] {
  Tip(k, v)
}

///|
pub impl[A : Eq] Eq for IntMap[A] with equal(self, other) {
  self.length() == other.length() &&
  @utils.iter_all2(self.iter(), other.iter(), Eq::equal)
}

///|
pub impl[A : Compare] Compare for IntMap[A] with compare(self, other) {
  @utils.iter_compare(self.iter(), other.iter())
}

///|
pub impl[A : Show] Show for IntMap[A] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@intmap.from_array([", suffix="])")
}

///|
pub impl[A] Add for IntMap[A] with add(self, other) {
  self.merge(other)
}

///|
using @quickcheck {trait Arbitrary}

///|
pub impl[A : Arbitrary] Arbitrary for IntMap[A] with arbitrary(size, rs) {
  Arbitrary::arbitrary(size, rs) |> from_array
}

///|
pub impl[A : ToJson] ToJson for IntMap[A] with to_json(self) {
  let capacity = self.length()
  let map = Map::new(capacity~)
  self.each((k, v) => map.set(k.to_string(), v.to_json()))
  Json::object(map)
}

///|
pub impl[A : FromJson] FromJson for IntMap[A] with from_json(json, path) {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "@intmap.from_json: expected object"))
  }
  obj
  .iter()
  .fold(init=new(), (m, kv) => {
    let key_int = @string.parse_int(kv.0) catch {
      _ =>
        raise @json.JsonDecodeError(
          (path, "@intmap.from_json: key is not a valid integer"),
        )
    }
    let value = A::from_json(kv.1, path.add_key(kv.0))
    m.add(key_int, value)
  })
}

///|
pub impl[A] Default for IntMap[A] with default() {
  new()
}
