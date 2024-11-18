defmodule OpenApiSpex.Schema.PropertiesSize do
  @moduledoc false

  defstruct [
    :min,
    :max
  ]

  @type t :: %__MODULE__{
          min: integer | nil,
          max: integer | nil
        }
end
