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

  defp render_film_list(conn, page) do
    num_of_film = Repo.aggregate(Film, :count, :id)
    chunk = 30
    num_of_page =  ceil(num_of_film/chunk)
    # page = 1
    offset = chunk*(page-1)
    directors = Repo.all(from f in Film, distinct: true, select: f.director)
    nationals = Repo.all(from f in Film, distinct: true, select: f.national)

    films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset)
    render conn, "download.html", params: %{films: films, page: page, num_of_page: num_of_page, directors: directors, nationals: nationals}
  end

  def get_films_by_page(conn, %{"id" => page}) do
    IO.inspect(page, label: "NGUNGOCQUA")
    render_film_list(conn, String.to_integer(page))
  end

  def get_films_by_director(conn, %{"director" => director}) do
    if director == "all" do
      redirect(conn, to: "/page/1")
    else
      films = Repo.all(from f in Film, select: f, where: f.director == ^director)
      render_film_list_filtered(conn, films)
    end
  end

  def get_films_by_national(conn, %{"national" => national}) do
    if national == "all" do
      redirect(conn, to: "/page/1")
    else
      films = Repo.all(from f in Film, select: f, where: f.national == ^national)
      render_film_list_filtered(conn, films)
    end
  end

  def render_film_list_filtered(conn, films) do
    directors = Repo.all(from f in Film, distinct: true, select: f.director)
    nationals = Repo.all(from f in Film, distinct: true, select: f.national)
    render conn, "download.html", params: %{films: films, page: 1, num_of_page: 1, directors: directors, nationals: nationals}
  end


  defp post_data_to_database(data) do
    IO.inspect(data)
    Repo.delete_all(Film)
    Enum.each(data, fn x ->
      Repo.insert(%Film{title: x.title, link: x.link, full_series: x.full_series, episode_number: x.number_of_episode, thumnail: x.thumbnail, year: x.year, director: x.director, national: x.national})
    end)
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
