defmodule Core do
  def crawl_all(base_url) do
    res = handle_url(base_url)
    case res do
      {:error, error_message} ->
        IO.puts(error_message)

      {:ok, ok_url} ->
        crawled_at = crawled_at(ok_url)
        pages = get_pages_url(ok_url)
        all_items_list = pages
        |>  Enum.map(fn page ->
              get_items(page)
            end)
        |> List.flatten

        total = Enum.count(all_items_list)
        ret = %{
          crawled_at: crawled_at,
          total: total,
          items: all_items_list
        }

        encode_json(ret)
    end
  end

  def encode_json(input, path \\ "E:/TQ_KHA/crawl_phimmoi-master/result2") do
    {_status, result} = JSON.encode(input)
    File.write("#{path}.json", result)
  end

  def handle_url(base_url) do
    ret = HTTPoison.get!(base_url)
    case ret.status_code do
      200 -> {:ok, base_url}
      301 ->
        re_url = ret.headers
        |>  Enum.map(fn x ->
              case x do
                {"Location", url} -> url
                _ -> nil
              end
            end)
        |>  Enum.filter(fn x -> x !== nil end)
        |>  List.to_string
        {:ok, re_url}
      _ ->
        {:error, "CHECK YOUR URL AGAIN!"}
    end
  end

  #get all pages based on category url
  def get_pages_url(base_url) do
    page_number = get_page_number(base_url)

    _pages = Enum.map(1..page_number, fn x ->
      if x==1 do
        base_url
      else
        base_url <> "page/" <> Integer.to_string(x) <>"/"
      end
    end)

  end


  #get page number based on category url
  def get_page_number(base_url) do
    html = HTTPoison.get!(base_url).body
    {:ok, doc} = Floki.parse_document(html)
    end_page = doc
    |> Floki.find("ul.pagination")
    |> Floki.find("a")
    |> Enum.at(-2)
    {_a, _body, [page_number]} = end_page
    String.to_integer(page_number)
  end


  #get all items based on url
  def get_items(base_url) do
    html = HTTPoison.get!(base_url).body
    {:ok, doc} = Floki.parse_document(html)

    elements = Floki.find(doc, "a.movie-item")

    _items = Enum.map(elements, fn element ->
      #title
      title_div = Floki.find(element, "div.movie-title-1")
      title = Floki.text(title_div)

      #link
      link = Floki.text(Floki.attribute(element, "href"))

      #episode
      ribbon = Floki.text(Floki.find(element, "span.ribbon"))
      [curr_ep, full_ep] = ribbon_to_episode(ribbon)

      #thumbnail image
      thumb_div =  Floki.find(element, "div.public-film-item-thumb")
      [{_div, thumb_style_list, _nillist}] = thumb_div
      thumbnail_url = thumb_style_list
      |>  Enum.map(fn x ->
            {_first, second} = x
            if String.contains?(second, "http") and String.contains?(second, "//") do
              second
            else
              nil
            end
          end)
      |>  Enum.filter(fn x -> x !== nil end)
      |>  List.to_string

      #return
      %{
        title: title,
        link: link,
        full_series: curr_ep == full_ep,
        number_of_episode: String.to_integer(curr_ep),
        thumbnail: thumbnail_url,
        year: 2022
      }
    end)
  end


  #parse from ribbon to episode info
  def ribbon_to_episode(ribbon) do
    ribbon_trim = String.replace(ribbon, ["(", ")"], " ")
    str_arr = String.split(ribbon_trim)
    flat_list = List.flatten(Enum.map(str_arr, fn x -> String.split(x, "/") end))

    #a list of strings contains 2 members, the first and second are current and full episode, respectively
    episode = Enum.filter(flat_list, fn x -> (Regex.match?(~r/^\d+$/, x) or x=="??") end)

    cond do
      length(episode) == 0 ->
        episode ++ ["1", "1"]
      length(episode) == 1 ->
        episode ++ ["none"]
      length(episode) == 4 ->
        [_one, _two, three, four] =  episode
        [three, four]
      true -> episode
    end

  end


  def crawled_at(base_url) do
    res_headers = HTTPoison.get!(base_url).headers
    _date = res_headers
    |>  Enum.map(fn x ->
          case x do
            {"Date", date_time} -> date_time
            _ -> nil
          end
        end)
    |>  Enum.filter(fn x -> x !== nil end)
    |>  List.to_string

  end

end
