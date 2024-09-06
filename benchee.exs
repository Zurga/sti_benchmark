Mix.install([{:benchee, "~> 1.3"}, {:postgrex, "~> 0.19"}])
postgres_opts = [password: "postgres", username: "postgres"]
{:ok, inheritance_conn} = Postgrex.start_link(Keyword.put(postgres_opts, :database, "normal_inherits"))
{:ok, sti_conn} = Postgrex.start_link(Keyword.put(postgres_opts, :database, "sti"))
random_user = fn -> floor(:random.uniform * 1000) + 1 end
random_post = fn -> floor(:random.uniform * 10000) + 1 end

Benchee.run(%{
  "INHERITANCE 1 insert likes for user" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(inheritance_conn, "", """
      INSERT INTO #{type}_likes (user_id, #{type}_id) VALUES   ($1, $2);
      """)
      Postgrex.execute(inheritance_conn, query, [random_user.(), random_post.()])
    end
  end,
  "STI 1 inserting new likes" => fn ->
    for type <- ~w/post image video/ do
      query = Postgrex.prepare!(sti_conn, "", """
        INSERT INTO likes (user_id, content_type, content_id) VALUES ($1, '#{type}s', $2);
      """)
      Postgrex.execute(sti_conn, query, [random_user.(), random_post.()])
    end
  end,
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
    post_likes as l ON users.user_id = l.user_id
JOIN 
    posts p ON l.post_id = p.post_id
WHERE users.user_id = $1

UNION ALL

SELECT 
    username,
    'Image' AS type,
    i.url AS liked_content,
    l.created_at
FROM 
    users
JOIN 
    image_likes as l ON users.user_id = l.user_id
JOIN 
    images i ON l.image_id = i.image_id
WHERE users.user_id = $1

UNION ALL

SELECT 
    username,
    'Video' AS type,
    v.url AS liked_content,
    l.created_at
FROM 
    users
JOIN 
    video_likes as l ON users.user_id = l.user_id
JOIN 
    videos v ON l.video_id = v.video_id
WHERE users.user_id = $1
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
    likes l ON u.user_id = l.user_id
LEFT JOIN 
    posts p ON l.content_type = 'posts' AND l.content_id = p.post_id
LEFT JOIN 
    images i ON l.content_type = 'images' AND l.content_id = i.image_id
LEFT JOIN 
    videos v ON l.content_type = 'videos' AND l.content_id = v.video_id
where u.user_id = $1
""")
  Postgrex.execute(sti_conn, query, [random_user.()]) 
  end,
"INHERITANCE 3 select users that like a post" => fn ->
  query = Postgrex.prepare!(inheritance_conn, "", """
    SELECT u.username
    FROM users u
    WHERE u.user_id in (SELECT user_id from post_likes where post_id = $1)
  """)
  Postgrex.execute(inheritance_conn, query, [random_post.()]) 
  end,
"STI 3 select users that like a post" => fn ->
  query = Postgrex.prepare!(sti_conn, "", """
    SELECT u.username
    FROM users u
    WHERE u.user_id in (SELECT user_id from likes l where l.content_id = $1 and l.content_type = 'posts')
  """)
  Postgrex.execute(sti_conn, query, [random_post.()]) 
  end
})
