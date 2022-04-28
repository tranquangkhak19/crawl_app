defmodule CrawlappWeb.CrawlController do
  use CrawlappWeb, :controller
  alias Core
  alias Crawlapp.Repo
  alias Crawlapp.Film
  alias Crawlapp.Category
  import Ecto.Query


  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    render conn, "index.html", non: conn
  end

  def post(conn, %{"url" => url}) do
    # data: [%{films: films, category: catetgory}, %{films: films, category: catetgory}, ...]
    data = Core.crawl_categories([url])
    post_data_to_database(data)

    get_films_by_page(conn, %{"page" => 1})
  end

  # params = %{films: films, page: page, num_of_page: num_of_page, directors: directors, nationals: nationals}
  defp render_films(conn, params) do
    categories = Repo.all(from f in Category, select: f.category)
    directors = Repo.all(from f in Film, distinct: true, select: f.director)
    nationals = Repo.all(from f in Film, distinct: true, select: f.national)

    full_params = Map.merge(params, %{directors: directors, nationals: nationals, categories: categories})
    render conn, "download.html", params: full_params
  end


  def get_films_by_page(conn, %{"page" => u_page}) do
    page = if is_integer(u_page), do: u_page, else: String.to_integer(u_page)
    num_of_film = Repo.aggregate(Film, :count, :id)
    chunk = 20
    num_of_page =  ceil(num_of_film/chunk)
    offset = chunk*(page-1)

    films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset)
    filter_by = %{category: false, director: false, national: false}
    params = %{films: films, page: page, num_of_page: num_of_page, category_id: -1, filter_by: filter_by}
    render_films(conn, params)

  end

  def get_films_by_director(conn, %{"director" => director}) do
    if director == "all" do
      redirect(conn, to: "/page/1")
    else
      films = Repo.all(from f in Film, select: f, where: f.director == ^director)
      filter_by = %{category: false, director: true, national: false}
      render_films(conn, %{films: films, page: 1, num_of_page: 1, category_id: -1, filter_by: filter_by})
    end
  end

  def get_films_by_national(conn, %{"national" => national}) do
    if national == "all" do
      redirect(conn, to: "/page/1")
    else
      films = Repo.all(from f in Film, select: f, where: f.national == ^national)
      filter_by = %{category: false, director: false, national: true}
      render_films(conn, %{films: films, page: 1, num_of_page: 1, category_id: -1, filter_by: filter_by})
    end
  end

  def get_films_by_category(conn, %{"category" => category}) do
    if category == "all" do
      redirect(conn, to: "/page/1")
    else
      [category_id] = Repo.all(from c in Category, select: c.id, where: c.category == ^category)
      films = Repo.all(from f in Film, select: f, where: f.category == ^category_id)
      filter_by = %{category: false, director: true, national: true}
      render_films(conn, %{films: films, page: 1, num_of_page: 1, category_id: -1, filter_by: filter_by})
    end
  end

  # def test_upsert() do
  #   category_id = Repo.all(from f in Category, select: f.id, where: f.category == "thanthoai")
  # end

  defp post_data_to_database(data) do
    # data: [%{films: films (list), category: catetgory}, %{films: films, category: catetgory}, ...]
    Enum.each(data, fn cate ->
      Repo.insert!(
        %Category{category: cate.category},
        on_conflict: :nothing
      )

      [category_id] = Repo.all(from f in Category, select: f.id, where: f.category == ^cate.category)

      Enum.each(cate.films, fn film ->
        Repo.insert(
          %Film{category: category_id, title: film.title, link: film.link, full_series: film.full_series, episode_number: film.number_of_episode, thumnail: film.thumbnail, year: film.year, director: film.director, national: film.national},
          on_conflict: :nothing
        )
      end)
    end)



  end


  def postfile(conn, %{"inputfile" => inputfile}) do
    IO.puts("############")
    IO.inspect(inputfile)

    {:ok, content} = File.read(inputfile.path)
    urls = String.split(content, "\r\n")

    # overlap with post function
    data = Core.crawl_categories(urls)
    post_data_to_database(data)

    get_films_by_page(conn, %{"page" => 1})
  end



  def download(conn, _params) do
    path = Application.app_dir(:crawlapp, "priv/static/assets/result1.json")
    send_download(conn, {:file, path})
  end

end
