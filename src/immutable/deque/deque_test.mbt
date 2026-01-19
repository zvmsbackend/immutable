///|
test "from_list" {
  let deque = from_list(@list.from_array([1, 2, 3, 4]))
  inspect(deque, content="@deque.from_array([1, 2, 3, 4])")
}

///|
test "from_cat_lists" {
  let deque = from_cat_lists(@list.from_array([1, 2]), @list.from_array([3, 4]))
  inspect(deque, content="@deque.from_array([1, 2, 3, 4])")
}

///|
test "from_array" {
  let deque = from_array([1, 2, 3, 4])
  inspect(deque, content="@deque.from_array([1, 2, 3, 4])")
}

///|
test "from_iter" {
  let deque = from_iter([1, 2, 3, 4].iter())
  inspect(deque, content="@deque.from_array([1, 2, 3, 4])")
}

///|
test "from_iter_rev" {
  let deque = from_iter_rev([4, 3, 2, 1].iter())
  inspect(deque, content="@deque.from_array([1, 2, 3, 4])")
}

///|
test "push_front" {
  let deque = from_array([2, 3]).push_front(1)
  inspect(deque, content="@deque.from_array([1, 2, 3])")
}

///|
test "push_back" {
  let deque = from_array([1, 2]).push_back(3)
  inspect(deque, content="@deque.from_array([1, 2, 3])")
}

///|
test "uncons_front" {
  guard from_array([1, 2, 3]).uncons_front() is Some((value, deque)) else {
    abort("uncons_front returned None")
  }
  inspect(value, content="1")
  inspect(deque, content="@deque.from_array([2, 3])")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.uncons_front(), content="None")
}

///|
test "uncons_back" {
  guard from_array([1, 2, 3]).uncons_back() is Some((value, deque)) else {
    abort("uncons_back returned None")
  }
  inspect(value, content="3")
  inspect(deque, content="@deque.from_array([1, 2])")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.uncons_back(), content="None")
}

///|
test "pop_front" {
  guard from_array([1, 2, 3]).pop_front() is Some(deque) else {
    abort("pop_front returned None")
  }
  inspect(deque, content="@deque.from_array([2, 3])")
  let single_element_deque = from_array([42])
  guard single_element_deque.pop_front() is Some(deque) else {
    abort("pop_front returned None")
  }
  inspect(deque, content="@deque.from_array([])")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.pop_front(), content="None")
}

///|
test "pop_back" {
  guard from_array([1, 2, 3]).pop_back() is Some(deque) else {
    abort("pop_back returned None")
  }
  inspect(deque, content="@deque.from_array([1, 2])")
  let single_element_deque = from_array([42])
  guard single_element_deque.pop_back() is Some(deque) else {
    abort("pop_back returned None")
  }
  inspect(deque, content="@deque.from_array([])")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.pop_back(), content="None")
}

///|
test "front" {
  let deque = from_array([10, 20, 30])
  inspect(deque.front(), content="Some(10)")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.front(), content="None")
}

///|
test "back" {
  let deque = from_array([10, 20, 30])
  inspect(deque.back(), content="Some(30)")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.back(), content="None")
}

///|
test "each" {
  let deque = from_array([1, 2, 3])
  let mut result = 0
  deque.each(value => result = result + value)
  inspect(result, content="6")
}

///|
test "eachi" {
  let deque = from_array([10, 20, 30])
  let mut result = 0
  deque.eachi((index, value) => result = result + index * value)
  inspect(result, content="80")
}

///|
test "is_empty" {
  let deque = from_array([1])
  inspect(deque.is_empty(), content="false")
  let empty_deque : Deque[Int] = from_array([])
  inspect(empty_deque.is_empty(), content="true")
}

///|
test "rev" {
  let deque = from_array([1, 2, 3])
  let rev_deque = deque.rev()
  inspect(rev_deque, content="@deque.from_array([3, 2, 1])")
  assert_eq(deque.rev().rev(), deque)
}

///|
test "singleton" {
  let deque = Deque::singleton(42)
  inspect(deque, content="@deque.from_array([42])")
}

///|
test "iter" {
  let deque = from_array([1, 2, 3])
  let mut collected = []
  for value in deque.iter() {
    collected = collected + [value]
  }
  inspect(collected, content="[1, 2, 3]")
}

///|
test "iter2" {
  let deque = from_array([10, 20, 30])
  let mut collected = []
  for index, value in deque.iter2() {
    collected = collected + [(index, value)]
  }
  inspect(collected, content="[(0, 10), (1, 20), (2, 30)]")
}

///|
test "to_list" {
  let deque = from_array([1, 2, 3])
  let list = deque.to_list()
  inspect(list, content="@list.from_array([1, 2, 3])")
}

///|
test "to_array" {
  let deque = from_array([1, 2, 3])
  let array = deque.to_array()
  inspect(array, content="[1, 2, 3]")
}

///|
test "equal" {
  let deque1 = from_array([1, 2, 3])
  let deque2 = from_array([1, 2, 3])
  let deque3 = from_array([4, 5, 6])
  inspect(deque1 == deque2, content="true")
  inspect(deque1 == deque3, content="false")
}

///|
test "compare" {
  let deque1 = from_array([1, 2, 3])
  let deque2 = from_array([1, 2, 4])
  let deque3 = from_array([1, 2, 3])
  inspect(deque1.compare(deque2), content="-1")
  inspect(deque2.compare(deque1), content="1")
  inspect(deque1.compare(deque3), content="0")
}

///|
test "hash" {
  let deque1 = from_array([1, 2, 3])
  let deque2 = from_array([1, 2, 3])
  let deque3 = from_array([4, 5, 6])
  inspect(deque1.hash(), content=deque2.hash().to_string())
  inspect(deque1.hash() == deque3.hash(), content="false")
}

///|
test "to_json" {
  let deque = from_array([1, 2, 3])
  let json = deque.to_json()
  inspect(json, content="Array([Number(1), Number(2), Number(3)])")
}

///|
test "from_json" {
  let json : Json = [1, 2, 3]
  let deque : Deque[Int] = @json.from_json(json)
  inspect(deque, content="@deque.from_array([1, 2, 3])")
  let v : Result[Deque[Int], _] = try? @json.from_json({ "a": 1 })
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@deque.from_json: expected array\")))",
  )
}
