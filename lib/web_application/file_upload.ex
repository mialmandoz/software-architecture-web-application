defmodule WebApplication.FileUpload do
  @moduledoc """
  Handles file uploads for images with configurable storage paths.
  """

  @allowed_extensions ~w(.jpg .jpeg .png .gif .webp)
  # 5MB
  @max_file_size 5 * 1024 * 1024

  def upload_image(upload, type) when type in [:book_cover, :author_profile] do
    with :ok <- validate_file(upload),
         {:ok, filename} <- generate_filename(upload, type),
         {:ok, _path} <- save_file(upload, filename, type) do
      {:ok, generate_image_url(filename, type)}
    end
  end

  defp validate_file(%Plug.Upload{} = upload) do
    extension = Path.extname(upload.filename) |> String.downcase()

    cond do
      upload.content_type not in ["image/jpeg", "image/png", "image/gif", "image/webp"] ->
        {:error, "Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed."}

      File.stat!(upload.path).size > @max_file_size ->
        {:error, "File too large. Maximum size is 5MB."}

      extension not in @allowed_extensions ->
        {:error, "Invalid file extension."}

      true ->
        :ok
    end
  end

  defp generate_filename(upload, type) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    random = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    extension = Path.extname(upload.filename) |> String.downcase()
    filename = "#{type}_#{timestamp}_#{random}#{extension}"
    {:ok, filename}
  end

  defp save_file(upload, filename, type) do
    upload_dir = get_upload_directory(type)
    File.mkdir_p!(upload_dir)

    destination = Path.join(upload_dir, filename)

    case File.cp(upload.path, destination) do
      :ok -> {:ok, destination}
      {:error, reason} -> {:error, "Failed to save file: #{reason}"}
    end
  end

  defp get_upload_directory(type) do
    base_path = Application.get_env(:web_application, :uploads_path, "priv/static/uploads")
    Path.join([base_path, to_string(type)])
  end

  defp generate_image_url(filename, type) do
    uploads_path = Application.get_env(:web_application, :uploads_path, "priv/static/uploads")

    # If uploads are in priv/static, use standard /uploads URL
    # If uploads are elsewhere, still use /uploads as the serving path
    url_path =
      if String.starts_with?(uploads_path, "priv/static/") do
        # Extract the path after priv/static/ (e.g., "uploads" from "priv/static/uploads")
        relative_path = String.replace_prefix(uploads_path, "priv/static/", "")
        "/" <> relative_path
      else
        "/uploads"
      end

    Path.join([url_path, to_string(type), filename])
  end

  def delete_image(nil), do: :ok
  def delete_image(""), do: :ok

  def delete_image(image_url) when is_binary(image_url) do
    # Extract filename from URL path like "/uploads/book_cover/filename.jpg"
    case String.split(image_url, "/") do
      [_, "uploads", type, filename] ->
        upload_dir = get_upload_directory(String.to_atom(type))
        file_path = Path.join(upload_dir, filename)
        File.rm(file_path)

      _ ->
        :ok
    end
  end

  def get_image_url(nil), do: nil
  def get_image_url(""), do: nil
  def get_image_url(image_url), do: image_url
end
