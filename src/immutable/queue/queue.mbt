///|
fn[A] Status::execute(self : Status[A]) -> Status[A] {
  match self {
    Rev(ok, More(x, tail=front), front2, More(y, tail=rear), rear2) =>
      Rev(ok + 1, front, @list.cons(x, front2), rear, @list.cons(y, rear2))
    Rev(ok, Empty, front2, More(y, tail=Empty), rear2) =>
      App(ok, front2, @list.cons(y, rear2))
    App(0, _, rear) => Done(rear)
    App(ok, More(x, tail=front), rear) =>
      App(ok - 1, front, @list.cons(x, rear))
    _ => self
  }
}

///|
fn[A] Status::invalidate(self : Status[A]) -> Status[A] {
  match self {
    Rev(ok, front, front2, rear, rear2) =>
      Rev(ok - 1, front, front2, rear, rear2)
    App(0, _, More(_, tail=rear)) => Done(rear)
    App(ok, front, rear) => App(ok - 1, front, rear)
    _ => self
  }
}

///|
fn[A] Queue::execute2(self : Queue[A]) -> Queue[A] {
  match self.status.execute().execute() {
    Done(fr) => { ..self, status: Idle, front: fr }
    new_status => { ..self, status: new_status }
  }
}

///|
fn[A] Queue::check(self : Queue[A]) -> Queue[A] {
  if self.rearLen <= self.frontLen {
    self.execute2()
  } else {
    let new_status = Rev(0, self.front, @list.empty(), self.rear, @list.empty())
    {
      ..self,
      frontLen: self.frontLen + self.rearLen,
      status: new_status,
      rear: @list.empty(),
      rearLen: 0,
    }.execute2()
  }
}

///|
/// Creates a new empty Queue.
pub fn[A] new() -> Queue[A] {
  {
    frontLen: 0,
    front: @list.empty(),
    status: Idle,
    rear: @list.empty(),
    rearLen: 0,
  }
}

///|
/// Creates a Queue from an array of values.
pub fn[A] from_array(values : ArrayView[A]) -> Queue[A] {
  values.fold(init=new(), (acc, x) => acc.push(x))
}

///|
/// Creates a Queue from an iterator of values.
pub fn[A] from_iter(values : Iter[A]) -> Queue[A] {
  values.fold(init=new(), (acc, x) => acc.push(x))
}

///|
/// Returns the value at the front of the Queue.
pub fn[A] Queue::peek(self : Queue[A]) -> A? {
  self.front.head()
}

///|
/// Adds a value to the back of the Queue.
pub fn[A] Queue::push(self : Queue[A], value : A) -> Queue[A] {
  { ..self, rear: @list.cons(value, self.rear), rearLen: self.rearLen + 1 }.check()
}

///|
/// Removes and returns the value at the front of the Queue, along with the
/// updated Queue.
pub fn[A] Queue::uncons(self : Queue[A]) -> (A, Queue[A])? {
  match self.front {
    More(head, tail~) => {
      let tail = {
        ..self,
        frontLen: self.frontLen - 1,
        front: tail,
        status: self.status.invalidate(),
      }.check()
      Some((head, tail))
    }
    Empty => None
  }
}

///|
/// Removes and returns the value at the front of the Queue.
pub fn[A] Queue::pop(self : Queue[A]) -> Queue[A]? {
  self.uncons().map(pair => pair.1)
}

///|
/// Returns the value at the front of the Queue, aborting if the Queue is empty.
pub fn[A] Queue::unsafe_peek(self : Queue[A]) -> A {
  guard self.peek() is Some(result) else { abort("Queue is empty") }
  result
}

///|
/// Removes and returns the value at the front of the Queue, aborting if the Queue is empty.
pub fn[A] Queue::unsafe_pop(self : Queue[A]) -> Queue[A] {
  guard self.pop() is Some(result) else { abort("Queue is empty") }
  result
}

///|
/// Removes and returns the value at the front of the Queue, along with
/// the updated Queue, aborting if the Queue is empty.
pub fn[A] Queue::unsafe_uncons(self : Queue[A]) -> (A, Queue[A]) {
  guard self.uncons() is Some(result) else { abort("Queue is empty") }
  result
}

///|
/// Returns the number of elements in the Queue. Takes O(1) time.
pub fn[A] Queue::length(self : Queue[A]) -> Int {
  self.frontLen + self.rearLen
}

///|
/// Returns true if the Queue is empty.
pub fn[A] Queue::is_empty(self : Queue[A]) -> Bool {
  self.length() == 0
}

///|
/// Returns an iterator over the elements of the Queue.
pub fn[A] Queue::iter(self : Queue[A]) -> Iter[A] {
  (match self.status {
    Idle => self.front.iter()
    Done(_) => abort("unreachable")
    App(ok, front, rear) => front.take(ok).rev().iter() + rear.iter()
    Rev(ok, front, front2, rear, rear2) =>
      front2.take(ok).rev().iter() +
      front.iter() +
      rear.rev().iter() +
      rear2.iter()
  }) +
  self.rear.rev().iter()
}

///|
/// Applies a function to each element of the Queue.
pub fn[A] Queue::each(self : Queue[A], f : (A) -> Unit raise?) -> Unit raise? {
  self.iter().each(f)
}

///|
/// Applies a function to each element of the Queue, along with its index.
pub fn[A] Queue::eachi(
  self : Queue[A],
  f : (Int, A) -> Unit raise?,
) -> Unit raise? {
  self.iter().eachi(f)
}

///|
/// Folds the elements of the Queue from left to right.
pub fn[A, B] Queue::fold(
  self : Queue[A],
  init~ : B,
  f : (B, A) -> B raise?,
) -> B raise? {
  self.iter().fold(init~, f)
}

///|
pub impl[A : Show] Show for Queue[A] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@queue.from_array([", suffix="])")
}

///|
pub impl[A : Eq] Eq for Queue[A] with equal(self, other) {
  for self = self, other = other {
    match (self.uncons(), other.uncons()) {
      (Some((x, xs)), Some((y, ys))) => {
        if x != y {
          break false
        }
        continue xs, ys
      }
      (None, None) => break true
      _ => break false
    }
  }
}

///|
pub impl[A : Compare] Compare for Queue[A] with compare(self, other) {
  for self = self, other = other {
    match (self.uncons(), other.uncons()) {
      (Some((x, xs)), Some((y, ys))) => {
        let ord = x.compare(y)
        if ord != 0 {
          break ord
        }
        continue xs, ys
      }
      (None, None) => break 0
      (None, Some(_)) => break -1
      (Some(_), None) => break 1
    }
  }
}

///|
pub impl[A : Hash] Hash for Queue[A] with hash_combine(self, hasher) {
  for item in self {
    hasher.combine(item)
  }
}

///|
pub impl[A] Default for Queue[A] with default() {
  new()
}

///|
using @quickcheck {trait Arbitrary}

///|
pub impl[A : Arbitrary] Arbitrary for Queue[A] with arbitrary(size, rs) {
  Arbitrary::arbitrary(size, rs) |> from_array
}
