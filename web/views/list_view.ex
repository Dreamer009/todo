defmodule Todo.ListView do
  use Todo.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :inserted_at, :updated_at]
  

end
