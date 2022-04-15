defmodule CrawlappWeb.CrawlController do
  use CrawlappWeb, :controller
  alias Core

  def index(conn, _params) do
    render conn, "index.html", non: conn
  end

  def post(conn, %{"url" => url}) do
    IO.puts("############")
    IO.puts(url)
    Core.crawl_all(url, "result1")
    render conn, "download.html"
  end

  def postfile(conn, %{"inputfile" => inputfile}) do
    IO.puts("############")
    IO.inspect(inputfile)

    {:ok, content} = File.read(inputfile.path)
    urls = String.split(content, "\r\n")



  end

  def download(conn, _params) do
    path = Application.app_dir(:crawlapp, "priv/static/assets/result1.json")
    send_download(conn, {:file, path})
  end




end
