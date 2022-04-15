defmodule CrawlappWeb.CrawlController do
  use CrawlappWeb, :controller

  def post(conn, %{"url" => url}) do
    IO.puts("############")
    IO.puts(url)
    render conn, "download.html"
  end


end
