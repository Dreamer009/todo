defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.List
  alias JaSerializer.Params

  plug :scrub_params, "meta" when action in [:create, :update]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    lists = Repo.all(List)
    render(conn, "index.json", data: lists)
  end

  def create(conn, %{"meta" => _meta, "data" => data = %{"type" => "list", "attributes" => _list_params}}) do
    changeset = List.changeset(%List{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, list} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", list_path(conn, :show, list))
        |> render("show.json", data: list)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Todo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    list = List |> Ecto.Query.where(id: ^id) |> Repo.one!
    render(conn, "show.json", data: list)
  end

  def update(conn, %{"id" => id, "meta" => _meta, "data" => data = %{"type" => "list", "attributes" => _list_params}}) do
    list = List |> Ecto.Query.where(id: ^id) |> Repo.one!
    changeset = List.changeset(list, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, list} ->
        render(conn, "show.json", data: list)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Todo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = List |> Ecto.Query.where(id: ^id) |> Repo.one!

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(list)

    send_resp(conn, :no_content, "")
  end

end
