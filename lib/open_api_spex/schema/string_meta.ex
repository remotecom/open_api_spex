defmodule OpenApiSpex.Schema.StringMeta do
  @moduledoc false

  defstruct [
    :maxLength,
    :minLength,
    :pattern
  ]

  @type t :: %__MODULE__{
          maxLength: integer | nil,
          minLength: integer | nil,
          pattern: String.t() | Regex.t() | nil
        }
end
