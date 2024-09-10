-- Create the users table
CREATE TABLE users (
 id SERIAL PRIMARY KEY,
 username VARCHAR(50) NOT NULL
);

-- Create the posts, images, and videos tables
CREATE TABLE posts (
 id SERIAL PRIMARY KEY,
 content TEXT NOT NULL
);

CREATE TABLE images (
 id SERIAL PRIMARY KEY,
 url TEXT NOT NULL
);

CREATE TABLE videos (
 id SERIAL PRIMARY KEY,
 url TEXT NOT NULL
);

-- Create likes tables for posts, images, and videos
CREATE TABLE post_likes (
 id SERIAL PRIMARY KEY,
 user_id INT REFERENCES users(id),
 content_id INT REFERENCES posts(id),
 created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE image_likes (
 id SERIAL PRIMARY KEY,
 user_id INT REFERENCES users(id),
 content_id INT REFERENCES images(id),
 created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE video_likes (
 id SERIAL PRIMARY KEY,
 user_id INT REFERENCES users(id),
 content_id INT REFERENCES videos(id),
 created_at TIMESTAMP DEFAULT NOW()
);


CREATE VIEW likes AS
  SELECT 'post' AS content_type, user_id, content_id, created_at FROM post_likes
  UNION ALL
  SELECT 'image' AS content_type, user_id, content_id, created_at FROM image_likes
  UNION ALL
  SELECT 'video' AS content_type, user_id, content_id, created_at FROM video_likes;


-- Insert 100000 posts
DO $$
BEGIN
  FOR i IN 1..100000 LOOP
    INSERT INTO posts (content) VALUES (concat('Post content ', i));
  END LOOP;
END $$;

-- Insert 100000 images
DO $$
BEGIN
  FOR i IN 1..100000 LOOP
    INSERT INTO images (url) VALUES (concat('http://example.com/image', i, '.jpg'));
  END LOOP;
END $$;

-- Insert 100000 videos
DO $$
BEGIN
  FOR i IN 1..100000 LOOP
    INSERT INTO videos (url) VALUES (concat('http://example.com/video', i, '.mp4'));
  END LOOP;
END $$;

-- Insert random likes for posts, images, and videos
DO $$
DECLARE
  users_id INT;
  posts_id INT;
  images_id INT;
  videos_id INT;
BEGIN
  FOR users_id IN 1..USER_AMOUNT LOOP
    INSERT INTO users (username) VALUES (concat('user_', users_id));
    FOR i IN 1..LIKE_AMOUNT LOOP
      posts_id := (SELECT floor(random() * 100000) + 1);
      images_id := (SELECT floor(random() * 100000) + 1);
      videos_id := (SELECT floor(random() * 100000) + 1);
      
      INSERT INTO post_likes (user_id, content_id) VALUES (users_id, posts_id);
      INSERT INTO image_likes (user_id, content_id) VALUES (users_id, images_id);
      INSERT INTO video_likes (user_id, content_id) VALUES (users_id, videos_id);
    END LOOP;
  END LOOP;
END $$;

-- Indexes on post_likes table
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);

CREATE INDEX idx_post_likes_post_id ON post_likes(content_id);

CREATE INDEX idx_post_likes_both ON post_likes(user_id, content_id);

-- Indexes on image_likes table
CREATE INDEX idx_image_likes_user_id ON image_likes(user_id);

CREATE INDEX idx_image_likes_image_id ON image_likes(content_id);

CREATE INDEX idx_image_likes_both ON image_likes(user_id, content_id);

-- Indexes on video_likes table
CREATE INDEX idx_video_likes_user_id ON video_likes(user_id);

CREATE INDEX idx_video_likes_video_id ON video_likes(content_id);

CREATE INDEX idx_video_likes_both ON video_likes(user_id, content_id);
