defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JaSerializer.Deserializer
  end

  scope "/", Todo do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Todo do
    pipe_through :api # Use the default browser stack
    resources "/lists", ListController do
      get "/checkboxes", CheckboxController, :index
    end
    resources "/checkboxes", CheckboxController
  end

end
