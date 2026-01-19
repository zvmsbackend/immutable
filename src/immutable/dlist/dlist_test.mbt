///|
test "push_front" {
  let dlist = new().push_front(1).push_front(2).push_front(3)
  inspect(dlist, content="@dlist.from_array([3, 2, 1])")
}

///|
test "push_back" {
  let dlist = new().push_back(1).push_back(2).push_back(3)
  inspect(dlist, content="@dlist.from_array([1, 2, 3])")
}

///|
test "concat" {
  let dlist1 = @dlist.from_array([1, 2, 3])
  let dlist2 = @dlist.from_array([4, 5, 6])
  let dlist = dlist1.concat(dlist2)
  inspect(dlist, content="@dlist.from_array([1, 2, 3, 4, 5, 6])")
}

///|
test "is_empty" {
  let empty_dlist : DList[Int] = new()
  let non_empty_dlist = @dlist.from_array([1, 2, 3])
  inspect(empty_dlist.is_empty(), content="true")
  inspect(non_empty_dlist.is_empty(), content="false")
}

///|
test "length" {
  let dlist = @dlist.from_array([1, 2, 3, 4, 5])
  inspect(dlist.length(), content="5")
}

///|
test "from_array" {
  let arr = [10, 20, 30, 40]
  let dlist = @dlist.from_array(arr)
  inspect(dlist, content="@dlist.from_array([10, 20, 30, 40])")
}

///|
test "from_iter" {
  let iter = [100, 200, 300].iter()
  let dlist = @dlist.from_iter(iter)
  inspect(dlist, content="@dlist.from_array([100, 200, 300])")
}

///|
test "to_array" {
  let dlist = @dlist.from_array([7, 8, 9])
  let arr = dlist.to_array()
  inspect(arr, content="[7, 8, 9]")
}

///|
test "iter" {
  let dlist = @dlist.from_array([1, 2, 3])
  let collected = dlist.iter().collect()
  inspect(collected, content="[1, 2, 3]")
}

///|
test "iter2" {
  let dlist = @dlist.from_array(["a", "b", "c"])
  let collected = dlist.iter2().to_array()
  inspect(collected, content="[(0, \"a\"), (1, \"b\"), (2, \"c\")]")
}

///|
test "fold" {
  let dlist = @dlist.from_array([1, 2, 3, 4])
  let sum = dlist.iter().fold(init=0, (acc, x) => acc + x)
  inspect(sum, content="10")
}

///|
test "each" {
  let dlist = @dlist.from_array([1, 2, 3])
  let mut sum = 0
  dlist.iter().each(x => sum = sum + x)
  inspect(sum, content="6")
}

///|
test "eachi" {
  let dlist = @dlist.from_array([10, 20, 30])
  let result = []
  dlist.iter2().each((i, x) => result.push((i, x)))
  inspect(result, content="[(0, 10), (1, 20), (2, 30)]")
}

///|
test "map" {
  let dlist = @dlist.from_array([1, 2, 3])
  let mapped = dlist.map(x => x * 2)
  inspect(mapped, content="@dlist.from_array([2, 4, 6])")
}

///|
test "mapi" {
  let dlist = @dlist.from_array([5, 10, 15])
  let mapped = dlist.mapi((i, x) => x + i)
  inspect(mapped, content="@dlist.from_array([5, 11, 17])")
}

///|
test "singleton" {
  let dlist = @dlist.singleton(42)
  inspect(dlist, content="@dlist.from_array([42])")
}

///|
test "equal" {
  let dlist1 = @dlist.from_array([1, 2, 3])
  let dlist2 = @dlist.from_array([1, 2, 3])
  let dlist3 = @dlist.from_array([4, 5, 6])
  inspect(dlist1 == dlist2, content="true")
  inspect(dlist1 == dlist3, content="false")
}

///|
test "compare" {
  let dlist1 = @dlist.from_array([1, 2, 3])
  let dlist2 = @dlist.from_array([1, 2, 4])
  let dlist3 = @dlist.from_array([1, 2, 3])
  inspect(dlist1.compare(dlist2) < 0, content="true")
  inspect(dlist2.compare(dlist1) > 0, content="true")
  inspect(dlist1.compare(dlist3) == 0, content="true")
}

///|
test "hash" {
  let dlist1 = @dlist.from_array([1, 2, 3])
  let dlist2 = @dlist.from_array([1, 2, 3])
  let dlist3 = @dlist.from_array([4, 5, 6])
  inspect(dlist1.hash() == dlist2.hash(), content="true")
  inspect(dlist1.hash() == dlist3.hash(), content="false")
}

///|
test "from_json" {
  let json : Json = [1, 2, 3, 4]
  let dlist : DList[Int] = @json.from_json(json)
  inspect(dlist, content="@dlist.from_array([1, 2, 3, 4])")
  let v : Result[DList[Int], _] = try? @json.from_json({ "a": 1 })
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@dlist.from_json: expected array\")))",
  )
}

///|
test "to_json" {
  let dlist = @dlist.from_array([5, 6, 7, 8])
  let json = dlist.to_json()
  inspect(json, content="Array([Number(5), Number(6), Number(7), Number(8)])")
}
