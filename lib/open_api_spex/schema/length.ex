defmodule OpenApiSpex.Schema.Length do
  @moduledoc false

  defstruct [
    :max,
    :min
  ]

  @type t :: %__MODULE__{
          max: integer | nil,
          min: integer | nil
        }
end
