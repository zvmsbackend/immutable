///|
/// Force the lazy computation and retrieve the value.
pub fn[A] Lazy::force(self : Lazy[A]) -> A {
  match self.status {
    Forced(value) => value
    Delayed(thunk) => {
      let value = thunk()
      self.status = Forced(value)
      value
    }
  }
}

///|
/// Creates a Lazy from a thunk (a zero-argument function).
pub fn[A] from_thunk(thunk : () -> A) -> Lazy[A] {
  { status: Delayed(thunk) }
}

///|
/// Creates a Lazy from an already computed value.
pub fn[A] from_value(value : A) -> Lazy[A] {
  { status: Forced(value) }
}

///|
/// Maps a function over the Lazy value, producing a new Lazy.
/// If the original Lazy is already forced, the function is applied immediately.
pub fn[A, B] Lazy::map(self : Lazy[A], f : (A) -> B) -> Lazy[B] {
  match self.status {
    Forced(value) => from_value(f(value))
    Delayed(thunk) => from_thunk(() => f(thunk()))
  }
}

///|
/// Maps a function over the Lazy value, producing a new Lazy.
pub fn[A, B] Lazy::map_lazy(self : Lazy[A], f : (A) -> B) -> Lazy[B] {
  from_thunk(() => f(self.force()))
}

///|
/// Flattens a nested Lazy structure.
pub fn[A] Lazy::flatten(self : Lazy[Lazy[A]]) -> Lazy[A] {
  from_thunk(() => self.force().force())
}

///|
/// Flat maps a function over the Lazy value, producing a new Lazy.
/// If the original Lazy is already forced, the function is applied immediately.
pub fn[A, B] Lazy::flat_map(self : Lazy[A], f : (A) -> Lazy[B]) -> Lazy[B] {
  match self.status {
    Forced(value) => f(value)
    Delayed(thunk) => from_thunk(() => f(thunk()).force())
  }
}

///|
/// Flat maps a function over the Lazy value, producing a new Lazy.
pub fn[A, B] Lazy::flat_map_lazy(self : Lazy[A], f : (A) -> Lazy[B]) -> Lazy[B] {
  from_thunk(() => f(self.force()).force())
}
