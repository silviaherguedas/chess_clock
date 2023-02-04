defmodule ChessClockWeb.PageController do
  use ChessClockWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
