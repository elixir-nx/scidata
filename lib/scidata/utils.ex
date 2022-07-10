defmodule Scidata.Utils do
  @moduledoc false

  def get!(url, opts \\ []) do
    %Req.Request{
      method: :get,
      url: url,
      options: Enum.into(opts, %{})
    }
    |> Req.Request.append_request_steps(if_modified_since: &if_modified_since/1)
    |> Req.Request.append_response_steps(
      handle_cache: &handle_cache/1,
      decode: &decode/1,
      handle_http_errors: &Req.Steps.handle_http_errors/1
    )
    |> Req.Request.run!()
  end

  defp if_modified_since(request) do
    case File.stat(cache_path(request)) do
      {:ok, stat} ->
        value = stat.mtime |> NaiveDateTime.from_erl!() |> format_http_datetime()
        request |> Req.Request.put_header("if-modified-since", value)

      _ ->
        request
    end
  end

  defp format_http_datetime(datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%m:%S GMT")
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
    cache_dir = request.options[:cache_dir] || System.tmp_dir!()
    File.mkdir_p!(cache_dir)
    Path.join(cache_dir, path)
  end
end
