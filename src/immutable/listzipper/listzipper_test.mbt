///|
test "from_list" {
  let zipper = from_list(@list.from_array([1, 2, 3]))
  debug_inspect(
    zipper,
    content="{left: @list.from_array([]), right: @list.from_array([1, 2, 3])}",
  )
}

///|
test "to_list" {
  let lst = @list.from_array([1, 2, 3, 4, 5, 6])
  let zipper = from_list(lst)
  inspect(zipper.to_list(), content=lst.to_string())
}

///|
test "peek" {
  let zipper = from_list(@list.from_array([10, 20, 30]))
  inspect(zipper.peek(), content="Some(10)")
  let empty_zipper : ListZipper[Int] = from_list(@list.empty())
  inspect(empty_zipper.peek(), content="None")
}

///|
test "move_left and move_right" {
  let zipper = from_list(@list.from_array([1, 2, 3]))
  debug_inspect(zipper.move_left(), content="None")
  let moved = zipper.move_right().unwrap()
  debug_inspect(
    moved,
    content="{left: @list.from_array([1]), right: @list.from_array([2, 3])}",
  )
}

///|
test "put and modify" {
  let zipper = from_list(@list.from_array([5, 10, 15]))
  let updated_zipper = zipper.put(20)
  inspect(updated_zipper.to_list(), content="@list.from_array([20, 10, 15])")
  let modified_zipper = zipper.modify(x => x * 2)
  inspect(modified_zipper.to_list(), content="@list.from_array([10, 10, 15])")
}
