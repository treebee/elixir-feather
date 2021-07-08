defmodule Feathericons.Compiler do
  @default_attrs [
    xmlns: "http://www.w3.org/2000/svg",
    width: "24",
    height: "24",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    stroke_width: "2",
    stroke_linecap: "round",
    stroke_linejoin: "round"
  ]

  @doc false
  defmacro __before_compile__(%Macro.Env{}) do
    icon_paths =
      Path.absname("icons", :code.priv_dir(:feathericons))
      |> Path.join("*.svg")
      |> Path.wildcard()

    for path <- icon_paths do
      generate_function(path, @default_attrs)
    end
  end

  @doc false
  def generate_function(path, default_attrs) do
    name =
      Path.basename(path, ".svg")
      |> String.replace("-", "_")
      |> String.to_atom()

    icon = File.read!(path)
    {i, _} = :binary.match(icon, ">")
    {_, body} = String.split_at(icon, i)

    doc = """
    ![](assets/#{Path.relative_to(path, :code.priv_dir(:feathericons))}) {: width=24px}
    ## Examples
        iex> #{name}()
        iex> #{name}(class: "h-6 w-6 text-gray-500")
    """

    quote do
      @doc unquote(doc)
      @spec unquote(name)(keyword()) :: {:safe, list()}
      def unquote(name)(opts \\ []) do
        opts = Keyword.merge(unquote(default_attrs), opts)

        attrs =
          for {k, v} <- opts do
            safe_k =
              k |> Atom.to_string() |> String.replace("_", "-") |> Phoenix.HTML.Safe.to_iodata()

            safe_v = v |> Phoenix.HTML.Safe.to_iodata()

            {:safe, [?\s, safe_k, ?=, ?", safe_v, ?"]}
          end

        {:safe, ["<svg", Phoenix.HTML.Safe.to_iodata(attrs), unquote(body)]}
      end
    end
  end
end

defmodule Feathericons do
  @moduledoc """
  Provides functions for every [Feathericon](https://feathericons.com/).

  Credits go to https://github.com/mveytsman/heroicons_elixir, which was simply adapted for
  serving Feather icons instead of Heroicons.

  ## Examples

      iex> Feathericons.loader(class: "w-4 h-4")
      {:safe,
      [
        "<svg",
        [
          [32, "xmlns", 61, 34, "http://www.w3.org/2000/svg", 34],
          [32, "viewBox", 61, 34, "0 0 20 20", 34],
          [32, "fill", 61, 34, "currentColor", 34],
          [32, "class", 61, 34, "w-4 h-4", 34]
        ],
        "><line x1=\"12\" y1=\"2\" x2=\"12\" y2=\"6\"></line><line x1=\"12\" y1=\"18\" x2=\"12\" y2=\"22\"></line><line x1=\"4.93\" y1=\"4.93\" x2=\"7.76\" y2=\"7.76\"></line><line x1=\"16.24\" y1=\"16.24\" x2=\"19.07\" y2=\"19.07\"></line><line x1=\"2\" y1=\"12\" x2=\"6\" y2=\"12\"></line><line x1=\"18\" y1=\"12\" x2=\"22\" y2=\"12\"></line><line x1=\"4.93\" y1=\"19.07\" x2=\"7.76\" y2=\"16.24\"></line><line x1=\"16.24\" y1=\"7.76\" x2=\"19.07\" y2=\"4.93\"></line></svg>"
      ]}

  """
  @before_compile Feathericons.Compiler
end
