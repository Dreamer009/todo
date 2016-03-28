defmodule Todo.ListView do
  use Todo.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :inserted_at, :updated_at]

  has_many :checkboxes, link: "/api/lists/:id/checkboxes"

end
