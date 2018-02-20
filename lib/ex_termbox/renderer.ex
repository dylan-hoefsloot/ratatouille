defmodule ExTermbox.Renderer do
  @moduledoc """
  Logic to render a view tree.

  This API is still under development.
  """

  alias ExTermbox.Renderer.{
    Element,
    Canvas,
    ColumnedLayout,
    Panel,
    Sparkline,
    StatusBar,
    Table,
    Text
  }

  require Logger

  def render(%Canvas{} = canvas, %Element{tag: :view, children: children}) do
    render_tree(canvas, children)
  end

  defp render_tree(%Canvas{} = canvas, elements) when is_list(elements) do
    elements
    |> Enum.reduce(canvas, fn el, new_canvas -> render_tree(new_canvas, el) end)
  end

  defp render_tree(%Canvas{box: box} = canvas, %Element{
         tag: tag,
         attributes: attrs,
         children: children
       }) do
    Logger.debug(fn ->
      "***#{tag}*** #{inspect(box)}"
    end)

    case tag do
      :columned_layout ->
        canvas
        |> ColumnedLayout.render(children, &render_tree/2)

      :panel ->
        canvas
        |> Panel.render(attrs, &render_tree(&1, children))

      :table ->
        canvas
        |> Table.render(children)

      :sparkline ->
        canvas
        |> Sparkline.render(children)

      :status_bar ->
        canvas
        |> StatusBar.render(&render_tree(&1, children))

      :text ->
        canvas
        |> Text.render(canvas.box.top_left, Enum.at(children, 0), attrs)

      :text_group ->
        canvas
        |> Text.render_group(children)
    end
  end
end
