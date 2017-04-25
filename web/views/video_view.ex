defmodule CaptainFact.VideoView do
  use CaptainFact.Web, :view

  def render("index.json", %{videos: videos}) do
    render_many(videos, CaptainFact.VideoView, "video.json")
  end

  def render("show.json", %{video: video}) do
    render_one(video, CaptainFact.VideoView, "video.json")
  end

  def render("video.json", %{video: video}) do
    %{
      id: CaptainFact.VideoHashId.encode(video.id),
      url: video.url,
      title: video.title,
      posted_at: video.inserted_at,
      speakers: render_many(video.speakers, CaptainFact.SpeakerView, "speaker.json")
    }
  end
end
