defmodule CrawlappWeb.PageController do
  use CrawlappWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", non: conn
  end
end
