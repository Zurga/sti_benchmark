
-- Create the users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL
);

-- Create the base likes table
CREATE TABLE likes (
    like_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create the posts, images, and videos tables
CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    content TEXT NOT NULL
);

CREATE TABLE images (
    image_id SERIAL PRIMARY KEY,
    url TEXT NOT NULL
);

CREATE TABLE videos (
    video_id SERIAL PRIMARY KEY,
    url TEXT NOT NULL
);

-- Create post_likes table that inherits from likes
CREATE TABLE post_likes (
    post_id INT REFERENCES posts(post_id)
) INHERITS (likes);

-- Create image_likes table that inherits from likes
CREATE TABLE image_likes (
    image_id INT REFERENCES images(image_id)
) INHERITS (likes);

-- Create video_likes table that inherits from likes
CREATE TABLE video_likes (
    video_id INT REFERENCES videos(video_id)
) INHERITS (likes);


-- Insert 1000 users
-- DO $$
-- BEGIN
--     FOR i IN 1..1000 LOOP
--         INSERT INTO users (username) VALUES (concat('user_', i));
--     END LOOP;
-- END $$;

-- Insert 100000 posts
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO posts (content) VALUES (concat('Post content ', i));
    END LOOP;
END $$;

-- Insert 100000 images
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO images (url) VALUES (concat('http://example.com/image', i, '.jpg'));
    END LOOP;
END $$;

-- Insert 100000 videos
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO videos (url) VALUES (concat('http://example.com/video', i, '.mp4'));
    END LOOP;
END $$;

-- Insert random likes for posts
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
            posts_id := (SELECT floor(random() * 10000) + 1 );
            images_id := (SELECT floor(random() * 10000) + 1 );
            videos_id := (SELECT floor(random() * 10000) + 1 );
            INSERT INTO post_likes (user_id, post_id) VALUES (users_id, posts_id);
            INSERT INTO image_likes (user_id, image_id) VALUES (users_id, images_id);
            INSERT INTO video_likes (user_id, video_id) VALUES (users_id, videos_id);
        END LOOP;
    END LOOP;
END $$;

-- -- Insert random likes for images
-- DO $$
-- DECLARE
--     users_id INT;
--     images_id INT;
-- BEGIN
--     FOR i IN 1..100000 LOOP
--         users_id := (SELECT user_id FROM users ORDER BY RANDOM() LIMIT 1);
--         images_id := (SELECT image_id FROM images ORDER BY RANDOM() LIMIT 1);
--         INSERT INTO image_likes (user_id, image_id) VALUES (users_id, images_id);
--     END LOOP;
-- END $$;

-- Insert random likes for videos
-- DO $$
-- DECLARE
--     users_id INT;
--     videos_id INT;
-- BEGIN
--     FOR i IN 1..100000 LOOP
--         users_id := (SELECT user_id FROM users ORDER BY RANDOM() LIMIT 1);
--         videos_id := (SELECT video_id FROM videos ORDER BY RANDOM() LIMIT 1);
--         INSERT INTO video_likes (user_id, video_id) VALUES (users_id, videos_id);
--     END LOOP;
-- END $$;
-- Indexes on post_likes table
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);

CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);

-- Indexes on image_likes table
CREATE INDEX idx_image_likes_user_id ON image_likes(user_id);

CREATE INDEX idx_image_likes_image_id ON image_likes(image_id);

-- Indexes on video_likes table
CREATE INDEX idx_video_likes_user_id ON video_likes(user_id);

CREATE INDEX idx_video_likes_video_id ON video_likes(video_id);
