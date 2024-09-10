
defmodule User do
  use Ecto.Schema
  import Ecto.Query

  schema "users" do
    field :username, :string
    has_many :likes, Like
  end

  def query_by_id(id), do: from(u in __MODULE__, where: u.id == ^id)
  def query_by_username(username), do: from(u in __MODULE__, where: u.username == ^username)
  def query_all, do: from(u in __MODULE__)

  def list_by_id(id), do: query_by_id(id) 
  def list_by_username(username), do: query_by_username(username) 
  def list_all, do: query_all() 

  def postload_by_id(id), do: query_by_id(id) |> preload(:likes) 
  def postload_by_username(username), do: query_by_username(username) |> preload(:likes) 
  def postload_all, do: query_all() |> preload(:likes) 
end

defmodule Like do
  use Ecto.Schema
  import Ecto.Query

  schema "likes" do
    belongs_to :user, User
    field :created_at, :utc_datetime
  end

  def query_by_id(id), do: from(l in __MODULE__, where: l.id == ^id)
  def query_by_user(user_id), do: from(l in __MODULE__, where: l.user_id == ^user_id)
  def query_all, do: from(l in __MODULE__)

  def postload_by_id(id), do: query_by_id(id) |> preload(:user) 
  def postload_by_user(user_id), do: query_by_user(user_id) |> preload(:user) 
  def postload_all, do: query_all() |> preload(:user) 
end

defmodule Post do
  use Ecto.Schema
  import Ecto.Query
  import EctoSparkles

  schema "posts" do
    field :content, :string
    has_many :post_likes, PostLike, foreign_key: :content_id
  end

  def query_by_id(id), do: from(p in __MODULE__, where: p.id == ^id)
  def query_all, do: from(p in __MODULE__)

  def postload_by_id(id), do: query_by_id(id) |> preload(post_likes: :user) 
  def postload_all, do: query_all() |> preload(post_likes: :user) 

  def proload_by_id(id), do: query_by_id(id) |> proload(post_likes: :user) 
  def proload_all, do: query_all() |> proload(post_likes: :user) 
end

defmodule Image do
  use Ecto.Schema
  import Ecto.Query

  schema "images" do
    field :url, :string
    has_many :image_likes, ImageLike
  end

  def query_by_id(id), do: from(i in __MODULE__, where: i.id == ^id)
  def query_all, do: from(i in __MODULE__)

  def postload_by_id(id), do: query_by_id(id) |> preload(image_likes: :user) 
  def postload_all, do: query_all() |> preload(image_likes: :user) 
end

defmodule Video do
  use Ecto.Schema
  import Ecto.Query

  schema "videos" do
    field :url, :string
    has_many :video_likes, VideoLike
  end

  def query_by_id(id), do: from(v in __MODULE__, where: v.id == ^id)
  def query_all, do: from(v in __MODULE__)


  def postload_by_id(id), do: query_by_id(id) |> preload(video_likes: :user) 
  def postload_all, do: query_all() |> preload(video_likes: :user) 
end

defmodule PostLike do
  use Ecto.Schema
  import Ecto.Query

  schema "post_likes" do
    belongs_to :user, User
    belongs_to :content, Post, foreign_key: :content_id
    field :created_at, :utc_datetime
  end

  def query_by_id(id), do: from(pl in __MODULE__, where: pl.id == ^id)
  def query_by_post(post_id), do: from(pl in __MODULE__, where: pl.content_id == ^post_id)
  def query_by_user(user_id), do: from(pl in __MODULE__, where: pl.user_id == ^user_id)
  def query_all, do: from(pl in __MODULE__)

  def postload_by_id(id), do: query_by_id(id) |> preload([:user, :content]) 
  def postload_by_post(post_id), do: query_by_post(post_id) |> preload([:user, :content]) 
  def postload_by_user(user_id), do: query_by_user(user_id) |> preload([:user, :content]) 
  def postload_all, do: query_all() |> preload([:user, :content]) 
end

defmodule ImageLike do
  use Ecto.Schema
  import Ecto.Query

  schema "image_likes" do
    belongs_to :user, User
    belongs_to :content, Image, foreign_key: :content_id
    field :created_at, :utc_datetime
  end

  def query_by_id(id), do: from(il in __MODULE__, where: il.id == ^id)
  def query_by_image(image_id), do: from(il in __MODULE__, where: il.content_id == ^image_id)
  def query_by_user(user_id), do: from(il in __MODULE__, where: il.user_id == ^user_id)
  def query_all, do: from(il in __MODULE__)

  def postload_by_id(id), do: query_by_id(id) |> preload([:user, :content]) 
  def postload_by_image(image_id), do: query_by_image(image_id) |> preload([:user, :content]) 
  def postload_by_user(user_id), do: query_by_user(user_id) |> preload([:user, :content]) 
  def postload_all, do: query_all() |> preload([:user, :content]) 
end

defmodule VideoLike do
  use Ecto.Schema
  import Ecto.Query

  schema "video_likes" do
    belongs_to :user, User
    belongs_to :content, Video, foreign_key: :content_id
    field :created_at, :utc_datetime
  end

  def query_by_id(id), do: from(vl in __MODULE__, where: vl.id == ^id)
  def query_by_video(video_id), do: from(vl in __MODULE__, where: vl.content_id == ^video_id)
  def query_by_user(user_id), do: from(vl in __MODULE__, where: vl.user_id == ^user_id)
  def query_all, do: from(vl in __MODULE__)


  def postload_by_id(id), do: query_by_id(id) |> preload([:user, :content]) 
  def postload_by_video(video_id), do: query_by_video(video_id) |> preload([:user, :content]) 
  def postload_by_user(user_id), do: query_by_user(user_id) |> preload([:user, :content]) 
  def postload_all, do: query_all() |> preload([:user, :content]) 
end