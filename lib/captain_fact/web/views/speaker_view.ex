defmodule CaptainFact.Web.SpeakerView do
  use CaptainFact.Web, :view

  def render("show.json", %{speaker: speaker}) do
    render_one(speaker, CaptainFact.Web.SpeakerView, "speaker.json")
  end

  def render("speaker.json", %{speaker: speaker}) do
    %{
      id: speaker.id,
      full_name: speaker.full_name,
      title: speaker.title,
      picture: CaptainFact.Web.SpeakerPicture.url({speaker.picture, speaker}, :thumb),
      is_user_defined: speaker.is_user_defined,
      country: speaker.country
    }
  end
end
