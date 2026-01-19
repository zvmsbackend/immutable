///|
test "from_array" {
  let queue = from_array([1, 2, 3, 4, 5])
  inspect(queue, content="@queue.from_array([1, 2, 3, 4, 5])")
}

///|
test "from_iter" {
  let queue = from_iter([1, 2, 3, 4, 5].iter())
  inspect(queue, content="@queue.from_array([1, 2, 3, 4, 5])")
}

///|
test "peek" {
  let queue = from_array([10, 20, 30])
  inspect(queue.peek(), content="Some(10)")
  let empty_queue : Queue[Int] = new()
  inspect(empty_queue.peek(), content="None")
}

///|
test "push" {
  let queue = new().push(1).push(2).push(3)
  inspect(queue, content="@queue.from_array([1, 2, 3])")
}

///|
test "uncons" {
  let queue = from_array([100, 200, 300])
  guard queue.uncons() is Some((value, rest)) else {
    abort("Queue should not be empty")
  }
  inspect(value, content="100")
  inspect(rest, content="@queue.from_array([200, 300])")
  let empty_queue : Queue[Int] = new()
  inspect(empty_queue.uncons(), content="None")
}

///|
test "pop" {
  let queue = from_array([5, 10, 15])
  guard queue.pop() is Some(rest) else { abort("Queue should not be empty") }
  inspect(rest, content="@queue.from_array([10, 15])")
  let single_element_queue = from_array([42])
  guard single_element_queue.pop() is Some(rest) else {
    abort("Queue should not be empty")
  }
  inspect(rest, content="@queue.from_array([])")
  let empty_queue : Queue[Int] = new()
  inspect(empty_queue.pop(), content="None")
}

///|
test "length" {
  let queue = from_array([1, 2, 3, 4, 5])
  inspect(queue.length(), content="5")
  let empty_queue : Queue[Int] = new()
  inspect(empty_queue.length(), content="0")
}

///|
test "is_empty" {
  let queue = from_array([1])
  inspect(queue.is_empty(), content="false")
  let empty_queue : Queue[Int] = new()
  inspect(empty_queue.is_empty(), content="true")
}

///|
test "iter" {
  let queue = from_array([10, 20, 30])
  let mut collected = []
  for value in queue.iter() {
    collected = collected + [value]
  }
  inspect(collected, content="[10, 20, 30]")
}

///|
test "fold" {
  let queue = from_array([1, 2, 3, 4])
  let sum = queue.fold(init=0, (acc, x) => acc + x)
  inspect(sum, content="10")
}

///|
test "equal" {
  let queue1 = from_array([1, 2, 3])
  let queue2 = from_array([1, 2, 3])
  let queue3 = from_array([4, 5, 6])
  inspect(queue1 == queue2, content="true")
  inspect(queue1 == queue3, content="false")
}

///|
test "compare" {
  let queue1 = from_array([1, 2, 3])
  let queue2 = from_array([1, 2, 4])
  let queue3 = from_array([1, 2, 3])
  inspect(queue1.compare(queue2), content="-1")
  inspect(queue2.compare(queue1), content="1")
  inspect(queue1.compare(queue3), content="0")
}

///|
test "hash" {
  let queue1 = from_array([1, 2, 3])
  let queue2 = from_array([1, 2, 3])
  let queue3 = from_array([4, 5, 6])
  inspect(queue1.hash(), content=queue2.hash().to_string())
  inspect(queue1.hash() == queue3.hash(), content="false")
}

///|
test "default" {
  let default_queue : Queue[Int] = Default::default()
  inspect(default_queue.is_empty(), content="true")
}
