
-- Create the users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL
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

-- Create the likes table with polymorphic association
CREATE TABLE likes (
    like_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    content_type VARCHAR(50) NOT NULL,  -- Stores the table name (e.g., 'posts', 'images', 'videos')
    content_id INT NOT NULL,  -- Stores the ID of the liked item
    created_at TIMESTAMP DEFAULT NOW()
    -- CONSTRAINT fk_content FOREIGN KEY (content_type, content_id) 
    -- REFERENCES posts(post_id) -- Add a placeholder reference constraint to posts (we'll add dynamic triggers to handle others)
);

-- Insert 1000 users
-- DO $$
-- BEGIN
--     FOR i IN 1..1000 LOOP
--         INSERT INTO users (username) VALUES (concat('user_', i));
--     END LOOP;
-- END $$;

-- Insert 10000 posts
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO posts (content) VALUES (concat('Post content ', i));
    END LOOP;
END $$;

-- Insert 10000 images
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO images (url) VALUES (concat('http://example.com/image', i, '.jpg'));
    END LOOP;
END $$;

-- Insert 10000 videos
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
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
            posts_id := (SELECT floor(random() * 10000) + 1 );
            images_id := (SELECT floor(random() * 10000) + 1 );
            videos_id := (SELECT floor(random() * 10000) + 1 );
            INSERT INTO likes (user_id, content_type, content_id) VALUES (users_id, 'posts', posts_id);
            INSERT INTO likes (user_id, content_type, content_id) VALUES (users_id, 'images', images_id);
            INSERT INTO likes (user_id, content_type, content_id) VALUES (users_id, 'videos', videos_id);
        END LOOP;
    END LOOP;
END $$;

CREATE INDEX idx_item_id on likes(content_id);

CREATE INDEX idx_item_type on likes(content_type);

-- Function to enforce referential integrity in the likes table
CREATE OR REPLACE FUNCTION check_content_fk()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if content_type is 'posts'
    IF NEW.content_type = 'posts' THEN
        IF NOT EXISTS (SELECT 1 FROM posts WHERE post_id = NEW.content_id) THEN
            RAISE EXCEPTION 'Post ID % does not exist', NEW.content_id;
        END IF;
    -- Check if content_type is 'images'
    ELSIF NEW.content_type = 'images' THEN
        IF NOT EXISTS (SELECT 1 FROM images WHERE image_id = NEW.content_id) THEN
            RAISE EXCEPTION 'Image ID % does not exist', NEW.content_id;
        END IF;
    -- Check if content_type is 'videos'
    ELSIF NEW.content_type = 'videos' THEN
        IF NOT EXISTS (SELECT 1 FROM videos WHERE video_id = NEW.content_id) THEN
            RAISE EXCEPTION 'Video ID % does not exist', NEW.content_id;
        END IF;
    ELSE
        RAISE EXCEPTION 'Invalid content_type %', NEW.content_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce the referential integrity on the likes table
CREATE TRIGGER trg_check_content_fk
BEFORE INSERT OR UPDATE ON likes
FOR EACH ROW
EXECUTE FUNCTION check_content_fk();

