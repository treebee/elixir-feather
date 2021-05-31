defmodule FeathericonsTest do
  use ExUnit.Case, async: true

  test "generated function" do
    meh =
      Path.absname("icons", :code.priv_dir(:feathericons))
      |> Path.join("meh.svg")
      |> File.read!()

    assert Feathericons.meh(class: "feather feather-meh")
           |> Phoenix.HTML.safe_to_string() ==
             meh

    assert Feathericons.menu(class: "h-6 w-6 text-gray-500")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(class="h-6 w-6 text-gray-500")

    assert Feathericons.anchor(class: "<> \" ")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(class="&lt;&gt; &quot; ")

    assert Feathericons.arrow_down(foo: "bar")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(foo="bar")

    assert Feathericons.calendar(multiword_key: "foo")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(multiword-key="foo")

    assert Feathericons.align_left(viewBox: "0 0 12 12")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(viewBox=\"0 0 12 12\")

    refute Feathericons.heart(viewBox: "0 0 12 12")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(viewBox=\"0 0 24 24\")
  end

end
