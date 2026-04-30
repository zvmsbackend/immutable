///|
priv enum Status[A] {
  Forced(A)
  Delayed(() -> A)
} derive(Debug)

///|
/// A lazily evaluated value wrapper.
struct Lazy[A] {
  mut status : Status[A]
} derive(Debug)
