///|
test "from_array" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls, content="Some(@nonemptylist.from_array([1, 2, 3, 4, 5]))")
  let ls : NonEmptyList[Unit]? = from_array([])
  inspect(ls, content="None")
}

///|
test "pipe" {
  inspect(cons_list(1, @list.empty()), content="@nonemptylist.from_array([1])")
}

///|
test "length" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.length(), content="5")
  inspect(singleton(11), content="@nonemptylist.from_array([11])")
}

///|
test "iter" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  let mut failed = false
  for i, x in ls {
    if i + 1 != x {
      failed = true
    }
  }
  inspect(failed, content="false")
}

///|
test "map" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(
    ls.map(x => x * 2),
    content="@nonemptylist.from_array([2, 4, 6, 8, 10])",
  )
}

///|
test "mapi" {
  let ls = unsafe_from_array([10, 20, 30, 40, 50])
  inspect(
    ls.mapi((i, x) => x * i),
    content="@nonemptylist.from_array([0, 20, 60, 120, 200])",
  )
}

///|
test "rev_map" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(
    ls.rev_map(x => x * 3),
    content="@nonemptylist.from_array([15, 12, 9, 6, 3])",
  )
}

///|
test "to_array" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.to_array(), content="[1, 2, 3, 4, 5]")
}

///|
test "all" {
  let ls = unsafe_from_array([2, 4, 6, 8, 10])
  inspect(ls.all(x => x % 2 == 0), content="true")
  let ls2 = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls2.all(x => x % 2 == 0), content="false")
}

///|
test "any" {
  let ls = unsafe_from_array([1, 3, 5, 7, 8])
  inspect(ls.any(x => x % 2 == 0), content="true")
  let ls2 = unsafe_from_array([1, 3, 5, 7, 9])
  inspect(ls2.any(x => x % 2 == 0), content="false")
}

///|
test "tail" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.tail(), content="Some(@nonemptylist.from_array([2, 3, 4, 5]))")
  let ls2 = unsafe_from_array([42])
  inspect(ls2.tail(), content="None")
  inspect(ls.unsafe_tail(), content="@nonemptylist.from_array([2, 3, 4, 5])")
}

///|
test "tail_list" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.tail_list(), content="@list.from_array([2, 3, 4, 5])")
}

///|
test "head" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.head(), content="1")
}

///|
test "last" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.last(), content="5")
}

///|
test "concat" {
  let ls1 = unsafe_from_array([1, 2, 3])
  let ls2 = unsafe_from_array([4, 5, 6])
  inspect(
    ls1.concat(ls2),
    content="@nonemptylist.from_array([1, 2, 3, 4, 5, 6])",
  )
}

///|
test "rev_concat" {
  let ls1 = unsafe_from_array([1, 2, 3])
  let ls2 = unsafe_from_array([4, 5, 6])
  inspect(
    ls1.rev_concat(ls2),
    content="@nonemptylist.from_array([3, 2, 1, 4, 5, 6])",
  )
}

///|
test "rev" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.rev(), content="@nonemptylist.from_array([5, 4, 3, 2, 1])")
  assert_eq(ls.rev().rev(), ls)
}

///|
test "fold" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.fold(init=0, (acc, x) => acc + x), content="15")
}

///|
test "foldi" {
  let ls = unsafe_from_array([10, 20, 30, 40, 50])
  inspect(ls.foldi(init=0, (i, acc, x) => acc + x * i), content="400")
}

///|
test "zip" {
  let ls1 = unsafe_from_array([1, 2, 3])
  let ls2 = unsafe_from_array(["a", "b", "c"])
  inspect(
    ls1.zip(ls2),
    content="@nonemptylist.from_array([(1, \"a\"), (2, \"b\"), (3, \"c\")])",
  )
}

///|
test "flat_map" {
  let ls = unsafe_from_array([1, 2, 3])
  inspect(
    ls.flat_map(x => unsafe_from_array([x, x * 10])),
    content="@nonemptylist.from_array([1, 10, 2, 20, 3, 30])",
  )
}

///|
test "flat_map single element" {
  let ls = unsafe_from_array([42])
  inspect(
    ls.flat_map(x => singleton(x * 2)),
    content="@nonemptylist.from_array([84])",
  )
}

///|
test "nth" {
  let ls = unsafe_from_array([10, 20, 30, 40, 50])
  inspect(ls.nth(2), content="Some(30)")
  inspect(ls.nth(5), content="None")
}

///|
test "repeat" {
  inspect(
    repeat(3, "x"),
    content="@nonemptylist.from_array([\"x\", \"x\", \"x\"])",
  )
}

///|
test "intersperse" {
  let ls = unsafe_from_array([1, 2, 3])
  inspect(
    ls.intersperse(0),
    content="@nonemptylist.from_array([1, 0, 2, 0, 3])",
  )
}

///|
test "unzip" {
  let ls = unsafe_from_array([(1, "a"), (2, "b"), (3, "c")])
  let (ls1, ls2) = ls.unzip()
  inspect(ls1, content="@nonemptylist.from_array([1, 2, 3])")
  inspect(ls2, content="@nonemptylist.from_array([\"a\", \"b\", \"c\"])")
}

///|
test "flatten" {
  let ls = unsafe_from_array([
    unsafe_from_array([1, 2]),
    unsafe_from_array([3, 4]),
    unsafe_from_array([5]),
  ])
  inspect(ls.flatten(), content="@nonemptylist.from_array([1, 2, 3, 4, 5])")
}

///|
test "flatten single list" {
  let ls = singleton(unsafe_from_array([42, 43, 44]))
  inspect(ls.flatten(), content="@nonemptylist.from_array([42, 43, 44])")
}

///|
test "maximum" {
  let ls = unsafe_from_array([3, 1, 4, 1, 5, 9, 2, 6, 5])
  inspect(ls.maximum(), content="9")
}

///|
test "minimum" {
  let ls = unsafe_from_array([3, 1, 4, 1, 5, 9, 2, 6, 5])
  inspect(ls.minimum(), content="1")
}

///|
test "sort" {
  let ls = unsafe_from_array([5, 3, 1, 4, 2])
  inspect(ls.sort(), content="@nonemptylist.from_array([1, 2, 3, 4, 5])")
}

///|
test "contains" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(ls.contains(3), content="true")
  inspect(ls.contains(6), content="false")
}

///|
test "scan_left" {
  let ls = unsafe_from_array([1, 2, 3, 4])
  inspect(
    ls.scan_left(init=0, (acc, x) => acc + x),
    content="@nonemptylist.from_array([0, 1, 3, 6, 10])",
  )
}

///|
test "scan_right" {
  let ls = unsafe_from_array([1, 2, 3, 4])
  inspect(
    ls.scan_right(init=0, (x, acc) => x + acc),
    content="@nonemptylist.from_array([10, 9, 7, 4, 0])",
  )
}

///|
test "lookup" {
  let ls = unsafe_from_array([(1, "a"), (2, "b"), (3, "c")])
  inspect(ls.lookup(2), content="Some(\"b\")")
  inspect(ls.lookup(4), content="None")
}

///|
test "find" {
  let ls = unsafe_from_array([1, 3, 5, 7, 8, 9])
  inspect(ls.find(x => x % 2 == 0), content="Some(8)")
  inspect(ls.find(x => x > 10), content="None")
}

///|
test "findi" {
  let ls = unsafe_from_array([10, 20, 30, 40, 49])
  inspect(ls.findi((x, i) => x / 10 != i + 1), content="Some(49)")
  inspect(ls.findi((x, i) => x + i > 100), content="None")
}

///|
test "is_prefix" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  let prefix1 = unsafe_from_array([1, 2, 3])
  let prefix2 = unsafe_from_array([2, 3])
  inspect(ls.is_prefix(prefix1), content="true")
  inspect(ls.is_prefix(prefix2), content="false")
}

///|
test "equal" {
  let ls1 = unsafe_from_array([1, 2, 3])
  let ls2 = unsafe_from_array([1, 2, 3])
  let ls3 = unsafe_from_array([4, 5, 6])
  inspect(ls2 == ls2, content="true")
  inspect(ls1 == ls3, content="false")
}

///|
test "is_suffix" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  let suffix1 = unsafe_from_array([3, 4, 5])
  let suffix2 = unsafe_from_array([4, 5, 6])
  inspect(ls.is_suffix(suffix1), content="true")
  inspect(ls.is_suffix(suffix2), content="false")
}

///|
test "intercalate" {
  let ls = unsafe_from_array([
    unsafe_from_array([1, 2]),
    unsafe_from_array([3, 4]),
    unsafe_from_array([5]),
  ])
  let sep = unsafe_from_array([0])
  inspect(
    ls.intercalate(sep),
    content="@nonemptylist.from_array([1, 2, 0, 3, 4, 0, 5])",
  )
}

///|
test "default" {
  let ls : NonEmptyList[Int] = NonEmptyList::default()
  inspect(ls, content="@nonemptylist.from_array([0])")
}

///|
test "to_json" {
  let ls = unsafe_from_array([1, 2, 3, 4, 5])
  inspect(
    ls.to_json(),
    content="Array([Number(1), Number(2), Number(3), Number(4), Number(5)])",
  )
}

///|
test "from_json" {
  for xs in (@quickcheck.samples(20) : Array[NonEmptyList[Int]]) {
    assert_eq(xs, @json.from_json(xs.to_json()))
  }
  let v : Result[NonEmptyList[Int], _] = try? @json.from_json({ "a": 1 })
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@nonemptylist.from_json: expected array\")))",
  )
  let v : Result[NonEmptyList[Int], _] = try? @json.from_json([])
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@nonemptylist.from_json: expected non-empty array\")))",
  )
}

///|
test "eachi" {
  let ls = unsafe_from_array(["a", "b", "c"])
  let mut result = ""
  ls.eachi((i, v) => result += v + i.to_string())
  inspect(result, content="a0b1c2")
}

///|
test "from_iter_rev" {
  let ls = from_iter_rev((1).until(6))
  inspect(ls, content="Some(@nonemptylist.from_array([5, 4, 3, 2, 1]))")
}

///|
test "hash" {
  let ls1 = unsafe_from_array([1, 2, 3])
  let ls2 = unsafe_from_array([1, 2, 3])
  let ls3 = unsafe_from_array([4, 5, 6])
  inspect(ls1.hash(), content=ls2.hash().to_string())
  inspect(ls1.hash() == ls3.hash(), content="false")
}
