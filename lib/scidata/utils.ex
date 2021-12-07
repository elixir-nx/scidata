defmodule Scidata.Utils do
  @moduledoc false

  def get!(url) do
    request = %{
      url: url,
      headers: []
    }

    request
    |> if_modified_since()
    |> run!()
    |> raise_errors()
    |> handle_cache()
    |> decode()
    |> elem(1)
  end

  defp if_modified_since(request) do
    case File.stat(cache_path(request)) do
      {:ok, stat} ->
        value = stat.mtime |> NaiveDateTime.from_erl!() |> format_http_datetime()
        update_in(request.headers, &[{'if-modified-since', String.to_charlist(value)} | &1])

      _ ->
        request
    end
  end

  defp format_http_datetime(datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%m:%S GMT")
  end

  defp run!(request) do
    http_opts = []
    opts = [body_format: :binary]
    arg = {request.url, request.headers}

    case :httpc.request(:get, arg, http_opts, opts) do
      {:ok, {{_, status, _}, headers, body}} ->
        response = %{status: status, headers: headers, body: body}
        {request, response}

      {:error, reason} ->
        raise inspect(reason)
    end
  end

  defp raise_errors({request, response}) do
    if response.status >= 400 do
      raise "HTTP #{response.status} #{inspect(response.body)}"
    else
      {request, response}
    end
  end

  defp decode({request, response}) do
    cond do
      String.ends_with?(request.url, ".tar.gz") or String.ends_with?(request.url, ".tgz") ->
        {:ok, files} = :erl_tar.extract({:binary, response.body}, [:memory, :compressed])
        response = %{response | body: files}
        {request, response}

      Path.extname(request.url) == ".gz" ->
        body = :zlib.gunzip(response.body)
        response = %{response | body: body}
        {request, response}

      true ->
        {request, response}
    end
  end

  defp handle_cache({request, response}) do
    path = cache_path(request)

    if response.status == 304 do
      # Logger.debug(["loading cached ", path])
      response = %{response | body: File.read!(path)}
      {request, response}
    else
      # Logger.debug(["writing cache ", path])
      File.write!(path, response.body)
      {request, response}
    end
  end

  defp cache_path(request) do
    uri = URI.parse(request.url)
    path = Enum.join([uri.host, String.replace(uri.path, "/", "-")], "-")
    Path.join(System.tmp_dir!(), path)
  end
end
