defmodule Todo.ListController do
  use Todo.Web, :controller

  alias Todo.List
  alias JaSerializer.PhoenixJsonApiHelper

  plug :scrub_params, "meta" when action in [:create, :update]
  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    lists = List |> PhoenixJsonApiHelper.where_params(params) |> Repo.all
    render(conn, "index.json", data: lists)
  end

  def create(conn, %{"meta" => _meta, "data" => data = %{"type" => "list", "attributes" => list_params}}) do
    changeset = List.changeset(%List{}, PhoenixJsonApiHelper.to_params(list_params, data["relationships"]))

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

  def update(conn, %{"id" => id, "meta" => _meta, "data" => data = %{"type" => "list", "attributes" => list_params}}) do
    list = List |> Ecto.Query.where(id: ^id) |> Repo.one!
    changeset = List.changeset(list, PhoenixJsonApiHelper.to_params(list_params, data["relationships"]))

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
