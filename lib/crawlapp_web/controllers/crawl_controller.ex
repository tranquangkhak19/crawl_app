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
    data = Core.crawl_categories([url])
    post_data_to_database(data)

    # render_film_list(conn, 1)
    get_films_by_page(conn, %{"page" => 1})
  end

  # params = %{films: films, page: page, num_of_page: num_of_page, directors: directors, nationals: nationals}
  defp render_films(conn, params) do
    directors = Repo.all(from f in Film, distinct: true, select: f.director)
    nationals = Repo.all(from f in Film, distinct: true, select: f.national)

    full_params = Map.merge(params, %{directors: directors, nationals: nationals})

    render conn, "download.html", params: full_params
  end


  def get_films_by_page(conn, %{"page" => u_page}) do
    page = if is_integer(u_page), do: u_page, else: String.to_integer(u_page)

    num_of_film = Repo.aggregate(Film, :count, :id)
    chunk = 20
    num_of_page =  ceil(num_of_film/chunk)

    offset = chunk*(page-1)

    films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset)

    params = %{films: films, page: page, num_of_page: num_of_page}

    render_films(conn, params)

  end

  def get_films_by_director(conn, %{"director" => director}) do
    if director == "all" do
      redirect(conn, to: "/page/1")
    else
      films = Repo.all(from f in Film, select: f, where: f.director == ^director)
      render_films(conn, %{films: films, page: 1, num_of_page: 1})
    end
  end

  def get_films_by_national(conn, %{"national" => national}) do
    if national == "all" do
      redirect(conn, to: "/page/1")
    else
      films = Repo.all(from f in Film, select: f, where: f.national == ^national)
      render_films(conn, %{films: films, page: 1, num_of_page: 1})
    end
  end

  defp post_data_to_database(data) do
    # use upsert
    IO.inspect(data)
    # Repo.delete_all(Film)
    # Enum.each(data, fn x ->
    #   Repo.insert(%Film{title: x.title, link: x.link, full_series: x.full_series, episode_number: x.number_of_episode, thumnail: x.thumbnail, year: x.year, director: x.director, national: x.national})
    # end)
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
