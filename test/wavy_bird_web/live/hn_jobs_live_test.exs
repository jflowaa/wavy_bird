defmodule WavyBirdWeb.HnJobsLiveTest do
  use WavyBirdWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Index" do
    test "no jobs", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/hn/jobs")

      assert html =~ "No job data - try again later"
    end
  end
end
