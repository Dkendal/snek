defmodule Snek.Snake do
  def new(params) do
    default = %{
      "color" => "",
      "coords" => [],
      "head_url" => "",
      "name" => "",
      "taunt" => "",
      "url" => "",
    }

    Dict.merge default, params
  end
end
