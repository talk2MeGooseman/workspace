defmodule StreamClosedCaptionerPhoenixWeb.ActivePresence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """

  # alias StreamClosedCaptionerPhoenix.Accounts

  use Phoenix.Presence,
    otp_app: :stream_closed_captioner_phoenix,
    pubsub_server: StreamClosedCaptionerPhoenix.PubSub

  # def fetch(_topic, presences) do
  #   users = presences |> Map.keys() |> Accounts.get_users_map()

  #   for {key, %{metas: metas}} <- presences, into: %{} do
  #     {key, %{metas: metas, user: users[String.to_integer(key)]}}
  #   end
  # end

  def recently_active_channels do
    StreamClosedCaptionerPhoenixWeb.ActivePresence.list("active_channels")
    |> Enum.reduce([], &reduced_user_list/2)
  end

  def is_channel_active?(channel_id) do
    StreamClosedCaptionerPhoenixWeb.ActivePresence.get_by_key("active_channels", channel_id)
    |> channel_recently_published?()
  end

  defp reduced_user_list({uid, %{metas: metas}}, acc) when is_binary(uid) do
    last_publish = metas |> List.first() |> Map.get(:last_publish, 0)
    elapased_time = current_timestamp() - last_publish

    cond do
      elapased_time <= 300 -> [uid | acc]
      true -> acc
    end
  end

  defp reduced_user_list(_, acc), do: acc

  defp channel_recently_published?(%{metas: metas}) do
    last_publish = metas |> List.first() |> Map.get(:last_publish, 0)
    elapased_time = current_timestamp() - last_publish
    elapased_time <= 300
  end

  defp channel_recently_published?([]), do: false

  defp current_timestamp, do: System.system_time(:second)
end
