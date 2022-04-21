defmodule CrawlappWeb.CrawlController do
  use CrawlappWeb, :controller
  alias Core
  alias Crawlapp.Repo
  alias Crawlapp.Film


  def index(conn, _params) do
    render conn, "index.html", non: conn
  end

  def post(conn, %{"url" => url}) do
    IO.puts("###############################")
    IO.puts(url)
    data = Core.crawl_all(url, "result1")
    post_data_to_database(data)

    render_film_list(conn)
  end

  defp render_film_list(conn) do
    films = Repo.all(Film)
    render conn, "download.html", films: films
  end

  defp post_data_to_database(data) do
    IO.inspect(data)
    Repo.delete_all(Film)
    Enum.each(data, fn x -> Repo.insert(%Film{title: x.title, link: x.link, full_series: x.full_series, episode_number: x.number_of_episode, thumnail: x.thumbnail, year: x.year}) end)
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
