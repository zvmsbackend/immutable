///|
test "from_array" {
  let arr = [(1, "a"), (2, "b"), (3, "c")]
  let imap = from_array(arr)
  inspect(
    imap,
    content="@intmap.from_array([(1, \"a\"), (2, \"b\"), (3, \"c\")])",
  )
}

///|
test "from_iter" {
  let iter = [(1, "a"), (2, "b")].iter()
  let imap = from_iter(iter)
  inspect(imap.length(), content="2")
}

///|
test "iter2" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let iter2 = imap.iter2()
  let collected = []
  while iter2.next() is Some((k, v)) {
    collected.push((k, v))
  }
  inspect(collected, content="[(1, \"a\"), (2, \"b\")]")
}

///|
test "is_empty" {
  let imap = from_array([(1, "a")])
  inspect(imap.is_empty(), content="false")
  let empty_map : IntMap[Int] = new()
  inspect(empty_map.is_empty(), content="true")
}

///|
test "length" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  inspect(imap.length(), content="2")
}

///|
test "get" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  inspect(imap.get(1), content="Some(\"a\")")
  inspect(imap.get(3), content="None")
}

///|
test "get_or_default" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  inspect(imap.get_or_default(1, "default"), content="a")
  inspect(imap.get_or_default(3, "default"), content="default")
}

///|
test "get_or_init" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  inspect(imap.get_or_init(1, () => "init"), content="a")
  inspect(imap.get_or_init(3, () => "init"), content="init")
}

///|
test "contains" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  inspect(imap.contains(1), content="true")
  inspect(imap.contains(3), content="false")
}

///|
test "add" {
  let arr = [(1, "a")]
  let imap = from_array(arr)
  let new_imap = imap.add(2, "b")
  inspect(new_imap.get(2), content="Some(\"b\")")
}

///|
test "remove" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let new_imap = imap.remove(1)
  inspect(new_imap.get(1), content="None")
}

///|
test "merge" {
  let empty : IntMap[String] = new()
  let singleton = IntMap::singleton(1, "a")
  let many = from_array([(1, "a"), (2, "b")])
  let many2 = from_array([(2, "b"), (3, "c")])
  inspect(empty.merge(singleton), content="@intmap.from_array([(1, \"a\")])")
  inspect(
    singleton.merge(many),
    content="@intmap.from_array([(1, \"a\"), (2, \"b\")])",
  )
  inspect(
    many.merge(empty),
    content="@intmap.from_array([(1, \"a\"), (2, \"b\")])",
  )
  inspect(
    many.merge(many2),
    content="@intmap.from_array([(1, \"a\"), (2, \"b\"), (3, \"c\")])",
  )
}

///|
test "each" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let collected = []
  imap.each((k, v) => collected.push((k, v)))
  inspect(collected, content="[(1, \"a\"), (2, \"b\")]")
}

///|
test "eachi" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let collected = []
  imap.eachi((i, k, v) => collected.push((i, k, v)))
  inspect(collected, content="[(0, 1, \"a\"), (1, 2, \"b\")]")
}

///|
test "keys" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let keys = imap.keys()
  inspect(keys, content="[1, 2]")
}

///|
test "values" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let values = imap.values()
  inspect(values, content="[\"a\", \"b\"]")
}

///|
test "to_array" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  inspect(imap, content="@intmap.from_array([(1, \"a\"), (2, \"b\")])")
}

///|
test "map" {
  let arr = [(1, 1), (2, 2)]
  let imap = from_array(arr)
  let mapped = imap.map((k, v) => k + v)
  inspect(mapped, content="@intmap.from_array([(1, 2), (2, 4)])")
}

///|
test "filter" {
  let arr = [(1, "a"), (2, "b"), (3, "c")]
  let imap = from_array(arr)
  let filtered = imap.filter((k, v) => k % 2 == 1 && v != "c")
  inspect(filtered, content="@intmap.from_array([(1, \"a\")])")
}

///|
test "fold" {
  let arr = [(1, 10), (2, 20), (3, 30)]
  let imap = from_array(arr)
  let sum = imap.fold(init=0, (acc, k, v) => acc + k + v)
  inspect(sum, content="66")
}

///|
test "singleton" {
  let imap = IntMap::singleton(1, "a")
  inspect(imap.length(), content="1")
}

///|
test "equal" {
  let arr1 = [(1, "a"), (2, "b")]
  let arr2 = [(1, "a"), (2, "b")]
  let imap1 = from_array(arr1)
  let imap2 = from_array(arr2)
  inspect(imap1 == imap2, content="true")
}

///|
test "compare" {
  let arr1 = [(1, "a"), (2, "b")]
  let arr2 = [(1, "a"), (2, "c")]
  let imap1 = from_array(arr1)
  let imap2 = from_array(arr2)
  inspect(imap1.compare(imap2), content="-1")
}

///|
test "to_json" {
  let arr = [(1, "a"), (2, "b")]
  let imap = from_array(arr)
  let json = imap.to_json()
  inspect(json.stringify(), content="{\"1\":\"a\",\"2\":\"b\"}")
}

///|
test "from_json" {
  let json : Json = { "1": "a", "2": "b" }
  let imap : IntMap[String] = @json.from_json(json)
  inspect(imap, content="@intmap.from_array([(1, \"a\"), (2, \"b\")])")
  let v : Result[IntMap[String], _] = try? @json.from_json(Json::array([]))
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@intmap.from_json: expected object\")))",
  )
  let v : Result[IntMap[String], _] = try? @json.from_json(
    Json::object(Map::from_array([("x", Json::string("a"))])),
  )
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@intmap.from_json: key is not a valid integer\")))",
  )
}
