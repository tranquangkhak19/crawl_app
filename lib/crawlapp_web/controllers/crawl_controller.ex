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

    get_films_by_page(conn, %{"page" => "1"})
  end

  def postfile(conn, %{"inputfile" => inputfile}) do
    {:ok, content} = File.read(inputfile.path)
    urls = String.split(content, "\r\n")
    # overlap with post function
    data = Core.crawl_categories(urls)
    post_data_to_database(data)

    get_films_by_page(conn, %{"page" => "1"})
  end

  defp render_films(conn, params) do
    categories = Repo.all(from f in Category, select: f.category)
    directors = Repo.all(from f in Film, distinct: true, select: f.director)
    nationals = Repo.all(from f in Film, distinct: true, select: f.national)

    chunk = 20
    num_of_page =  ceil(params.num_of_film/chunk)
    offset = chunk*(params.page-1)

    # get prefix of href and list of films for each page
    {pre_href, films} =
      cond do
        params.filter_by.by_category ->
          pre_href = "/category/" <> params.filter_by.category
          films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset, where: f.category == ^params.filter_by.category_id)
          {pre_href, films}
        params.filter_by.by_director ->
          pre_href = "/director/" <> params.filter_by.director
          films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset, where: f.director == ^params.filter_by.director)
          {pre_href, films}
        params.filter_by.by_national ->
          pre_href = "/national/" <> params.filter_by.national
          films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset, where: f.national == ^params.filter_by.national)
          {pre_href, films}
        true ->
          pre_href = ""
          films = Repo.all(from f in Film, select: f, limit: ^chunk, offset: ^offset)
          {pre_href, films}
      end

    full_params = Map.merge(params, %{films: films, num_of_page: num_of_page, directors: directors, nationals: nationals, categories: categories, pre_href: pre_href})
    render conn, "download.html", params: full_params
  end


  def get_films_by_page(conn, %{"page" => page}) do
    num_of_film = from(f in Film, select: f.id) |> Repo.aggregate(:count, :id)
    filter_by = %{by_category: false, by_director: false, by_national: false}
    render_films(conn, %{page: String.to_integer(page), num_of_film: num_of_film, filter_by: filter_by})
  end

  def get_films_by_director(conn, %{"director" => director}) do
    get_films_by_director_with_page(conn, %{"director" => director, "page" => "1"})
  end

  def get_films_by_director_with_page(conn, %{"director" => director, "page" => page}) do
    if director == "all" do
      redirect(conn, to: "/page/1")
    else
      num_of_film = from(f in Film, select: f.id, where: f.director == ^director) |> Repo.aggregate(:count, :id)
      filter_by = %{by_category: false, by_director: true, by_national: false, director: director}
      render_films(conn, %{page: String.to_integer(page), num_of_film: num_of_film, filter_by: filter_by})
    end
  end

  def get_films_by_national(conn, %{"national" => national}) do
    get_films_by_national_with_page(conn, %{"national" => national, "page" => "1"})
  end

  def get_films_by_national_with_page(conn, %{"national" => national, "page" => page}) do
    if national == "all" do
      redirect(conn, to: "/page/1")
    else
      num_of_film = from(f in Film, select: f.id, where: f.national == ^national) |> Repo.aggregate(:count, :id)
      filter_by = %{by_category: false, by_director: false, by_national: true, national: national}
      render_films(conn, %{page: String.to_integer(page), num_of_film: num_of_film, filter_by: filter_by})
    end
  end

  def get_films_by_category_with_page(conn, %{"category" => category, "page" => page}) do
    if category == "all" do
      redirect(conn, to: "/page/1")
    else
      [category_id] = Repo.all(from c in Category, select: c.id, where: c.category == ^category)
      num_of_film = from(f in Film, select: f.id, where: f.category == ^category_id) |> Repo.aggregate(:count, :id)
      filter_by = %{by_category: true, by_director: false, by_national: false, category_id: category_id, category: category}
      render_films(conn, %{page: String.to_integer(page), num_of_film: num_of_film, filter_by: filter_by})
    end
  end

  def get_films_by_category(conn, %{"category" => category}) do
    get_films_by_category_with_page(conn, %{"category" => category, "page" => "1"})
  end

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





  def download(conn, _params) do
    path = Application.app_dir(:crawlapp, "priv/static/assets/result1.json")
    send_download(conn, {:file, path})
  end

end
