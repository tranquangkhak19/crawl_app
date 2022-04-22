defmodule CrawlappWeb.CrawlController do
  use CrawlappWeb, :controller
  alias Core
  alias Crawlapp.Repo
  alias Crawlapp.Film
  import Ecto.Query


  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    render conn, "index.html", non: conn
  end

  def post(conn, %{"url" => url}) do
    IO.puts("###############################")
    IO.puts(url)
    data = Core.crawl_all(url, "result1")
    post_data_to_database(data)

    render_film_list(conn, 1)
  end

  defp render_film_list(conn, page \\ 2) do
    num_of_film = Repo.aggregate(Film, :count, :id)
    chunk = 8
    num_of_page =  ceil(num_of_film/chunk)
    # page = 1
    offset = chunk*(page-1)

    query = from(c in Film, select: c, limit: ^chunk, offset: ^offset)
    films = Repo.all(query)
    render conn, "download.html", params: %{films: films, page: page, num_of_page: num_of_page}
  end

  def get_films_by_page(conn, %{"id" => page}) do
    IO.inspect(page, label: "NGUNGOCQUA")
    render_film_list(conn, String.to_integer(page))
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
