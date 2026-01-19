///|
test "force" {
  let mut evaluated = false
  let lazy_value = from_thunk(() => {
    evaluated = true
    42
  })
  assert_false(evaluated)
  inspect(lazy_value.force(), content="42")
  assert_true(evaluated)
}

///|
test "map" {
  let eager_value = from_value(10)
  let mut evaluated = false
  let mapped_lazy = eager_value.map(x => {
    evaluated = true
    x * 2
  })
  assert_true(evaluated)
  inspect(mapped_lazy.force(), content="20")
  evaluated = false
  let lazy_value = from_thunk(() => 15)
  let mapped_lazy2 = lazy_value.map(x => {
    evaluated = true
    x + 5
  })
  assert_false(evaluated)
  inspect(mapped_lazy2.force(), content="20")
}

///|
test "map_lazy" {
  let eager_value = from_value(10)
  let mut evaluated = false
  let mapped_lazy = eager_value.map_lazy(x => {
    evaluated = true
    x * 2
  })
  assert_false(evaluated)
  inspect(mapped_lazy.force(), content="20")
  evaluated = false
  let lazy_value = from_thunk(() => 15)
  let mapped_lazy2 = lazy_value.map_lazy(x => {
    evaluated = true
    x + 5
  })
  assert_false(evaluated)
  inspect(mapped_lazy2.force(), content="20")
}

///|
test "flatten" {
  let lazy_inner = from_thunk(() => 30)
  let lazy_outer = from_thunk(() => lazy_inner)
  let flattened = lazy_outer.flatten()
  inspect(flattened.force(), content="30")
}

///|
test "flat_map" {
  let eager_value = from_value(5)
  let flat_mapped = eager_value.flat_map(x => from_value(x * 3))
  inspect(flat_mapped.force(), content="15")
  let lazy_value = from_thunk(() => 7)
  let flat_mapped2 = lazy_value.flat_map(x => from_thunk(() => x + 8))
  inspect(flat_mapped2.force(), content="15")
}

///|
test "flat_map_lazy" {
  let eager_value = from_value(4)
  let flat_mapped = eager_value.flat_map_lazy(x => from_value(x + 6))
  inspect(flat_mapped.force(), content="10")
  let lazy_value = from_thunk(() => 9)
  let flat_mapped2 = lazy_value.flat_map_lazy(x => from_thunk(() => x * 2))
  inspect(flat_mapped2.force(), content="18")
}
