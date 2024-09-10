Mix.install([
  {:benchee, "~> 1.3"}, 
  {:postgrex, "~> 0.19"}, 
  {:ecto_sparkles, "~> 0.2.1"}
])
postgres_opts = [password: System.get_env("POSTGRES_PASSWORD", "postgres"), username: System.get_env("POSTGRES_USER", "postgres")]

Code.eval_file("schemas.exs")

defmodule Plain.Repo do
  use Ecto.Repo,
    otp_app: :benchmark,
    adapter: Ecto.Adapters.Postgres
end

defmodule Inheritance.Repo do
  use Ecto.Repo,
    otp_app: :benchmark,
    adapter: Ecto.Adapters.Postgres
end

defmodule STI.Repo do
  use Ecto.Repo,
    otp_app: :benchmark,
    adapter: Ecto.Adapters.Postgres
end

{:ok, plain_conn} = Postgrex.start_link(Keyword.put(postgres_opts, :database, "plain_db"))
{:ok, inheritance_conn} = Postgrex.start_link(Keyword.put(postgres_opts, :database, "inheritance"))
{:ok, sti_conn} = Postgrex.start_link(Keyword.put(postgres_opts, :database, "sti"))
{:ok, _} = Plain.Repo.start_link(Keyword.put(postgres_opts, :database, "plain_db"))
{:ok, _} = Inheritance.Repo.start_link(Keyword.put(postgres_opts, :database, "inheritance"))
{:ok, _} = STI.Repo.start_link(Keyword.put(postgres_opts, :database, "sti"))

random_user = fn -> floor(:random.uniform * 1000) + 1 end
random_post = fn -> floor(:random.uniform * 10000) + 1 end

  
Benchee.run(%{

"INHERITANCE 3a select users that like a post" => fn ->
  query = Postgrex.prepare!(inheritance_conn, "", """
    SELECT u.username
    FROM users u
    WHERE u.id in (SELECT user_id from post_likes where content_id = $1)
  """)
  Postgrex.execute(inheritance_conn, query, [random_post.()]) 
  end,

"INHERITANCE 3b (Ecto without assocs) select users that like a post" => fn ->
  Post.query_by_id(random_post.())
  |> Inheritance.Repo.all()
  end,

"INHERITANCE 3c (Ecto postload assocs) select users that like a post" => fn ->
  Post.postload_by_id(random_post.())
  |> Inheritance.Repo.all()
  end,

"INHERITANCE 3d (Ecto proload assocs) select users that like a post" => fn ->
  Post.proload_by_id(random_post.())
  |> Inheritance.Repo.all()
  end,

"PLAIN 3b (Ecto without assocs) select users that like a post" => fn ->
  Post.query_by_id(random_post.())
  |> Plain.Repo.all()
  end,

"PLAIN 3c (Ecto postload assocs) select users that like a post" => fn ->
  Post.postload_by_id(random_post.())
  |> Plain.Repo.all()
  end,

"PLAIN 3d (Ecto proload assocs) select users that like a post" => fn ->
  Post.proload_by_id(random_post.())
  |> Plain.Repo.all()
  end,

"STI 3a select users that like a post" => fn ->
  query = Postgrex.prepare!(sti_conn, "", """
    SELECT u.username
    FROM users u
    WHERE u.id in (SELECT user_id from likes l where l.content_id = $1 and l.content_type = 'posts')
  """)
  Postgrex.execute(sti_conn, query, [random_post.()]) 
  end,

"STI 3b (using view) select users that like a post" => fn ->
  query = Postgrex.prepare!(sti_conn, "", """
    SELECT u.username
    FROM users u
    WHERE u.id in (SELECT user_id from post_likes where content_id = $1)
  """)
  Postgrex.execute(sti_conn, query, [random_post.()]) 
  end,

"STI 3c (using materialized view) select users that like a post" => fn ->
  query = Postgrex.prepare!(sti_conn, "", """
    SELECT u.username
    FROM users u
    WHERE u.id in (SELECT user_id from materialized_post_likes where content_id = $1)
  """)
  Postgrex.execute(sti_conn, query, [random_post.()]) 
  end
}

)



Benchee.run(%{
  "INHERITANCE 2 select all likes for user" => fn -> 
    query = Postgrex.prepare!(inheritance_conn, "", """
SELECT 
  username,
  'Post' AS type,
  p.content AS liked_content,
  l.created_at
FROM 
    users
JOIN 
    post_likes as l ON users.id = l.user_id
JOIN 
    posts p ON l.content_id = p.id
WHERE users.id = $1

UNION ALL

SELECT 
    username,
    'Image' AS type,
    i.url AS liked_content,
    l.created_at
FROM 
    users
JOIN 
    image_likes as l ON users.id = l.user_id
JOIN 
    images i ON l.content_id = i.id
WHERE users.id = $1

UNION ALL

SELECT 
    username,
    'Video' AS type,
    v.url AS liked_content,
    l.created_at
FROM 
    users
JOIN 
    video_likes as l ON users.id = l.user_id
JOIN 
    videos v ON l.content_id = v.id
WHERE users.id = $1
  """)
  Postgrex.execute(inheritance_conn, query, [random_user.()]) 
  end,

"STI 2 select all likes for user" => fn ->
  query = Postgrex.prepare!(sti_conn, "", """
SELECT 
    u.username,
    l.content_type,
    COALESCE(p.content, i.url, v.url) AS liked_content,
    l.created_at
FROM 
    users u
JOIN 
    likes l ON u.id = l.user_id
LEFT JOIN 
    posts p ON l.content_type = 'posts' AND l.content_id = p.id
LEFT JOIN 
    images i ON l.content_type = 'images' AND l.content_id = i.id
LEFT JOIN 
    videos v ON l.content_type = 'videos' AND l.content_id = v.id
where u.id = $1
""")
  Postgrex.execute(sti_conn, query, [random_user.()]) 
  end})


Benchee.run(%{
  "INHERITANCE 1 insert likes for user" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(inheritance_conn, "", """
      INSERT INTO #{type}_likes (user_id, content_id) VALUES   ($1, $2);
      """)
      Postgrex.execute(inheritance_conn, query, [random_user.(), random_post.()])
    end
  end,

  "STI 1a inserting new likes" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(sti_conn, "", """
        INSERT INTO likes (user_id, content_type, content_id) VALUES ($1, '#{type}s', $2);
      """)
      Postgrex.execute(sti_conn, query, [random_user.(), random_post.()])
    end
  end,

  "STI 1b (using view) inserting new likes" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(sti_conn, "", """
        INSERT INTO #{type}_likes (user_id, content_type, content_id) VALUES ($1, '#{type}s', $2);
      """)
      Postgrex.execute(sti_conn, query, [random_user.(), random_post.()])
    end
  end,

  "STI 1c (refresh materialized view concurrently) inserting new likes" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(sti_conn, "", """
        INSERT INTO likes (user_id, content_type, content_id) VALUES ($1, '#{type}s', $2);
      """)
      Postgrex.execute(sti_conn, query, [random_user.(), random_post.()])
      Postgrex.query(sti_conn, "REFRESH MATERIALIZED VIEW CONCURRENTLY materialized_#{type}_likes", [])
    end
  end,

  "STI 1d (refresh materialized view non-concurrently) inserting new likes" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(sti_conn, "", """
        INSERT INTO likes (user_id, content_type, content_id) VALUES ($1, '#{type}s', $2);
      """)
      Postgrex.execute(sti_conn, query, [random_user.(), random_post.()])
      Postgrex.query(sti_conn, "REFRESH MATERIALIZED VIEW materialized_#{type}_likes", [], timeout: 100_000)
    end
  end
  })
