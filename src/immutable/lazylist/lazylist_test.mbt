///|
test "all" {
  let ls = from_array([2, 4, 6, 8, 10])
  inspect(ls.all(x => x % 2 == 0), content="true")
  let ls2 = from_array([1, 2, 3, 4, 5])
  inspect(ls2.all(x => x % 2 == 0), content="false")
}

///|
test "any" {
  let ls = from_array([1, 3, 5, 7, 8])
  inspect(ls.any(x => x % 2 == 0), content="true")
  let ls2 = from_array([1, 3, 5, 7, 9])
  inspect(ls2.any(x => x % 2 == 0), content="false")
}

///|
test "concat" {
  let ls1 = from_array([1, 2, 3])
  let ls2 = from_array([4, 5, 6])
  inspect(ls1.concat(ls2), content="@lazylist.from_array([1, 2, 3, 4, 5, 6])")
  let mut evaluated = false
  let ls3 = delayed(() => {
    evaluated = true
    ls1
  })
  let _ = ls3.concat(ls2)
  assert_false(evaluated)
}

///|
test "cons" {
  let ls = from_array([2, 3, 4])
  inspect(cons(1, ls), content="@lazylist.from_array([1, 2, 3, 4])")
}

///|
test "cons_delayed" {
  let mut evaluated = false
  let delayed_tail = () => {
    evaluated = true
    from_array([2, 3, 4])
  }
  let result = cons_delayed(1, delayed_tail)
  assert_false(evaluated)
  inspect(result, content="@lazylist.from_array([1, 2, 3, 4])")
  assert_true(evaluated)
}

///|
test "delayed" {
  let mut evaluated = false
  let ls = delayed(() => {
    evaluated = true
    from_array([1, 2, 3])
  })
  assert_false(evaluated)
  inspect(ls, content="@lazylist.from_array([1, 2, 3])")
  assert_true(evaluated)
}

///|
test "drop" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.drop(2), content="@lazylist.from_array([3, 4, 5])")
}

///|
test "drop_while" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.drop_while(x => x < 3), content="@lazylist.from_array([3, 4, 5])")
}

///|
test "each" {
  let ls = from_array([1, 2, 3])
  let mut acc = 0
  ls.each(x => acc = acc + x)
  inspect(acc, content="6")
}

///|
test "eachi" {
  let ls = from_array([10, 20, 30])
  let mut acc = 0
  ls.eachi((i, x) => acc = acc + i * x)
  inspect(acc, content="80")
}

///|
test "filter" {
  let ls = from_array([1, 2, 3, 4, 5, 6])
  inspect(ls.filter(x => x % 2 == 0), content="@lazylist.from_array([2, 4, 6])")
}

///|
test "filter_map" {
  let ls = from_array([1, 2, 3, 4, 5, 6])
  inspect(
    ls.filter_map(x => if x % 2 == 0 { Some(x * 10) } else { None }),
    content="@lazylist.from_array([20, 40, 60])",
  )
}

///|
test "find" {
  let ls = from_array([1, 3, 5, 7, 8, 9])
  inspect(ls.find(x => x % 2 == 0), content="Some(8)")
  let ls2 = from_array([1, 3, 5, 7, 9])
  inspect(ls2.find(x => x % 2 == 0), content="None")
}

///|
test "find_index" {
  let ls = from_array([1, 3, 5, 7, 8, 9])
  inspect(ls.find_index(x => x % 2 == 0), content="Some(4)")
  let ls2 = from_array([1, 3, 5, 7, 9])
  inspect(ls2.find_index(x => x % 2 == 0), content="None")
}

///|
test "findi" {
  let ls = from_array([10, 20, 30, 40, 49])
  inspect(ls.findi((x, i) => x / 10 != i + 1), content="Some(49)")
  inspect(ls.findi((x, i) => x + i > 100), content="None")
}

///|
test "flatten" {
  let ls = from_array([from_array([1, 2]), from_array([3, 4]), from_array([5])])
  inspect(ls.flatten(), content="@lazylist.from_array([1, 2, 3, 4, 5])")
}

///|
test "flat_map" {
  let ls = from_array([1, 2, 3])
  inspect(
    ls.flat_map(x => from_array([x, x * 10])),
    content="@lazylist.from_array([1, 10, 2, 20, 3, 30])",
  )
}

///|
test "fold" {
  let ls = from_array([1, 2, 3, 4])
  inspect(ls.fold(init=0, (acc, x) => acc + x), content="10")
}

///|
test "foldi" {
  let ls = from_array([10, 20, 30, 40])
  inspect(ls.foldi(init=0, (i, acc, x) => acc + x * i), content="200")
}

///|
test "from_array" {
  let xs = [1, 2, 3, 4, 5]
  let ls = from_array(xs)
  inspect(ls, content="@lazylist.from_array([1, 2, 3, 4, 5])")
}

///|
test "from_iter" {
  let xs = [1, 2, 3, 4, 5]
  let ls = from_iter(xs.iter())
  inspect(ls, content="@lazylist.from_array([1, 2, 3, 4, 5])")
  let mut evaluated = false
  let lazy_iter = Iter::new(() => if evaluated {
    None
  } else {
    evaluated = true
    Some(1)
  })
  inspect(from_iter(lazy_iter), content="@lazylist.from_array([1])")
  assert_true(evaluated)
}

///|
test "head" {
  let ls = from_array([10, 20, 30])
  inspect(ls.head(), content="Some(10)")
  let empty_ls : LazyList[Unit] = from_array([])
  inspect(empty_ls.head(), content="None")
}

///|
test "intersperse" {
  let ls = from_array([1, 2, 3])
  inspect(ls.intersperse(0), content="@lazylist.from_array([1, 0, 2, 0, 3])")
  let single_ls = from_array([42])
  inspect(single_ls.intersperse(0), content="@lazylist.from_array([42])")
  let empty_ls : LazyList[Int] = from_array([])
  inspect(empty_ls.intersperse(0), content="@lazylist.from_array([])")
}

///|
test "intercalate" {
  let ls = from_array([from_array([1, 2]), from_array([3, 4]), from_array([5])])
  let sep = from_array([0])
  inspect(
    ls.intercalate(sep),
    content="@lazylist.from_array([1, 2, 0, 3, 4, 0, 5])",
  )
}

///|
test "is_empty" {
  let ls = from_array([1, 2, 3])
  inspect(ls.is_empty(), content="false")
  let empty_ls : LazyList[Int] = from_array([])
  inspect(empty_ls.is_empty(), content="true")
}

///|
test "is_prefix" {
  let ls1 = from_array([1, 2, 3, 4, 5])
  let ls2 = from_array([1, 2, 3])
  inspect(ls1.is_prefix(ls2), content="true")
  let ls3 = from_array([1, 2, 4])
  inspect(ls1.is_prefix(ls3), content="false")
  let ls4 = from_array([1, 2, 3, 4, 5, 6])
  inspect(ls1.is_prefix(ls4), content="false")
  let mut evaluated = false
  let ls5 = ls2.concat(
    delayed(() => {
      evaluated = true
      ls2
    }),
  )
  inspect(ls5.is_prefix(ls2), content="true")
  assert_false(evaluated)
}

///|
test "is_suffix" {
  let ls1 = from_array([1, 2, 3, 4, 5])
  let ls2 = from_array([4, 5])
  inspect(ls1.is_suffix(ls2), content="true")
  let ls3 = from_array([3, 5])
  inspect(ls1.is_suffix(ls3), content="false")
  let ls4 = from_array([0, 1, 2, 3, 4, 5])
  inspect(ls1.is_suffix(ls4), content="false")
}

///|
test "iter" {
  let xs = [1, 2, 3, 4, 5]
  let ls = from_array(xs)
  let iter = ls.iter()
  for x in xs {
    inspect(iter.next(), content="Some(" + x.to_string() + ")")
  }
  inspect(iter.next(), content="None")
}

///|
test "iter2" {
  let ls = from_array([10, 20, 30])
  let indexed_ls = ls.iter2()
  inspect(indexed_ls, content="[(0, 10), (1, 20), (2, 30)]")
}

///|
test "last" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.last(), content="Some(5)")
  let empty_ls : LazyList[Unit] = from_array([])
  inspect(empty_ls.last(), content="None")
}

///|
test "length" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.length(), content="5")
  let empty_ls : LazyList[Unit] = from_array([])
  inspect(empty_ls.length(), content="0")
}

///|
test "lookup" {
  let ls = from_array([("a", 1), ("b", 2), ("c", 3)])
  inspect(ls.lookup("b"), content="Some(2)")
  inspect(ls.lookup("d"), content="None")
}

///|
test "map" {
  let ls = from_array([1, 2, 3])
  inspect(ls.map(x => x * 10), content="@lazylist.from_array([10, 20, 30])")
}

///|
test "mapi" {
  let ls = from_array([10, 20, 30])
  inspect(
    ls.mapi((i, x) => x + i),
    content="@lazylist.from_array([10, 21, 32])",
  )
}

///|
test "maximum" {
  let ls = from_array([3, 1, 4, 1, 5, 9, 2])
  inspect(ls.maximum(), content="Some(9)")
  let empty_ls : LazyList[Int] = from_array([])
  inspect(empty_ls.maximum(), content="None")
}

///|
test "minimum" {
  let ls = from_array([3, 1, 4, 1, 5, 9, 2])
  inspect(ls.minimum(), content="Some(1)")
  let empty_ls : LazyList[Int] = from_array([])
  inspect(empty_ls.minimum(), content="None")
}

///|
test "nth" {
  let ls = from_array([10, 20, 30, 40, 50])
  inspect(ls.nth(2), content="Some(30)")
  inspect(ls.nth(5), content="None")
}

///|
test "remove" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.remove(2), content="@lazylist.from_array([1, 3, 4, 5])")
}

///|
test "remove_at" {
  let ls = from_array([10, 20, 30, 40, 50])
  inspect(ls.remove_at(3), content="@lazylist.from_array([10, 20, 30, 50])")
}

///|
test "repeat" {
  inspect(repeat(3, 42), content="@lazylist.from_array([42, 42, 42])")
}

///|
test "repeat_infinite" {
  let ls = repeat_infinite(99)
  let first_three = ls.take(3)
  inspect(first_three, content="@lazylist.from_array([99, 99, 99])")
}

///|
test "rev" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.rev(), content="@lazylist.from_array([5, 4, 3, 2, 1])")
  assert_eq(ls.rev().rev(), ls)
}

///|
test "scan_left" {
  let ls = from_array([1, 2, 3])
  inspect(
    ls.scan_left(init=0, (acc, x) => acc + x),
    content="@lazylist.from_array([0, 1, 3, 6])",
  )
}

///|
test "singleton" {
  inspect(singleton(7), content="@lazylist.from_array([7])")
}

///|
test "sort" {
  let ls = from_array([3, 1, 4, 1, 5, 9, 2])
  inspect(ls.sort(), content="@lazylist.from_array([1, 1, 2, 3, 4, 5, 9])")
}

///|
test "tail" {
  let ls = from_array([10, 20, 30])
  inspect(ls.tail(), content="Some(@lazylist.from_array([20, 30]))")
  let single_ls = from_array([42])
  inspect(single_ls.tail(), content="Some(@lazylist.from_array([]))")
  let empty_ls : LazyList[Int] = from_array([])
  inspect(empty_ls.tail(), content="None")
}

///|
test "take" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.take(3), content="@lazylist.from_array([1, 2, 3])")
}

///|
test "take_while" {
  let ls = from_array([1, 2, 3, 4, 5])
  inspect(ls.take_while(x => x < 4), content="@lazylist.from_array([1, 2, 3])")
}

///|
test "to_array" {
  let xs = [1, 2, 3, 4, 5]
  let ls = from_array(xs)
  assert_eq(ls.to_array(), xs)
}

///|
test "uncons" {
  let ls = from_array([10, 20, 30])
  inspect(ls.uncons(), content="Some((10, @lazylist.from_array([20, 30])))")
  let empty_ls : LazyList[Int] = from_array([])
  inspect(empty_ls.uncons(), content="None")
}

///|
test "unfold" {
  let ls = unfold(init=0, state => if state < 5 {
    Some((state * 10, state + 1))
  } else {
    None
  })
  inspect(ls, content="@lazylist.from_array([0, 10, 20, 30, 40])")
}

///|
test "zip" {
  let ls1 = from_array([1, 2, 3])
  let ls2 = from_array(["a", "b", "c", "d"])
  inspect(
    ls1.zip(ls2),
    content="@lazylist.from_array([(1, \"a\"), (2, \"b\"), (3, \"c\")])",
  )
}

///|
test "compare" {
  let ls1 = from_array([1, 2, 3])
  let ls2 = from_array([1, 2, 4])
  inspect(ls1.compare(ls2), content="-1")
  let ls3 = from_array([1, 2, 3])
  inspect(ls1.compare(ls3), content="0")
  let ls4 = from_array([1, 2])
  inspect(ls1.compare(ls4), content="1")
}

///|
test "equal" {
  let ls1 = from_array([1, 2, 3])
  let ls2 = from_array([1, 2, 3])
  inspect(ls1 == ls2, content="true")
  let ls3 = from_array([1, 2, 4])
  inspect(ls1 == ls3, content="false")
  let ls4 = from_array([1, 2, 3, 4])
  inspect(ls1 == ls4, content="false")
}

///|
test "hash" {
  let ls1 = from_array([1, 2, 3])
  let ls2 = from_array([1, 2, 3])
  assert_eq(ls1.hash(), ls2.hash())
  let ls3 = from_array([1, 2, 4])
  assert_not_eq(ls1.hash(), ls3.hash())
}

///|
test "to_json" {
  let ls = from_array([1, 2, 3])
  inspect(ls.to_json(), content="Array([Number(1), Number(2), Number(3)])")
}

///|
test "from_json" {
  let json : Json = [1, 2, 3]
  let ls : LazyList[Int] = @json.from_json(json)
  inspect(ls, content="@lazylist.from_array([1, 2, 3])")
  let v : Result[LazyList[Int], _] = try? @json.from_json({ "a": 1 })
  inspect(
    v,
    content="Err(JsonDecodeError((, \"@lazylist.from_json: expected array\")))",
  )
}

///|
test "default" {
  let ls : LazyList[Int] = Default::default()
  inspect(ls, content="@lazylist.from_array([])")
}
