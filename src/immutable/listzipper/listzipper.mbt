///|
/// Creates a ListZipper from a List.
pub fn[A] from_list(lst : List[A]) -> ListZipper[A] {
  { left: @list.empty(), right: lst }
}

///|
/// Converts a ListZipper back to a List.
pub fn[A] ListZipper::to_list(zipper : ListZipper[A]) -> List[A] {
  zipper.left.rev_concat(zipper.right)
}

///|
/// Moves the focus one element to the left in the ListZipper.
pub fn[A] ListZipper::move_left(zipper : ListZipper[A]) -> ListZipper[A]? {
  guard zipper.left is More(head, tail~) else { return None }
  Some({ left: tail, right: zipper.right.prepend(head) })
}

///|
/// Moves the focus one element to the right in the ListZipper.
pub fn[A] ListZipper::move_right(zipper : ListZipper[A]) -> ListZipper[A]? {
  guard zipper.right is More(head, tail~) else { return None }
  Some({ left: zipper.left.prepend(head), right: tail })
}

///|
/// Peeks at the current focused element in the ListZipper.
pub fn[A] ListZipper::peek(zipper : ListZipper[A]) -> A? {
  guard zipper.right is More(head, ..) else { return None }
  Some(head)
}

///|
/// Moves the focus one element to the left in the ListZipper, aborting if not possible.
pub fn[A] ListZipper::unsafe_move_left(zipper : ListZipper[A]) -> ListZipper[A] {
  guard zipper.move_left() is Some(result) else {
    abort("Cannot move left on an empty left list")
  }
  result
}

///|
/// Moves the focus one element to the right in the ListZipper, aborting if not possible.
pub fn[A] ListZipper::unsafe_move_right(
  zipper : ListZipper[A],
) -> ListZipper[A] {
  guard zipper.move_right() is Some(result) else {
    abort("Cannot move right on an empty right list")
  }
  result
}

///|
/// Peeks at the current focused element in the ListZipper, aborting if not possible.
pub fn[A] ListZipper::unsafe_peek(zipper : ListZipper[A]) -> A {
  guard zipper.peek() is Some(value) else {
    abort("Cannot peek on an empty right list")
  }
  value
}

///|
/// Replaces the current focused element in the ListZipper with a new value.
pub fn[A] ListZipper::put(
  zipper : ListZipper[A],
  new_value : A,
) -> ListZipper[A] {
  guard zipper.right is More(_, tail~) else { return zipper }
  { left: zipper.left, right: tail.prepend(new_value) }
}

///|
/// Modifies the current focused element in the ListZipper using a provided function.
pub fn[A] ListZipper::modify(
  zipper : ListZipper[A],
  f : (A) -> A raise?,
) -> ListZipper[A] raise? {
  guard zipper.right is More(head, tail~) else {
    return { left: zipper.left.map(f), right: @list.empty() }
  }
  { left: zipper.left, right: tail.prepend(f(head)) }
}
