# Likes Database Schema: Inheritance vs. Polymorphic Setup

This repository contains two database schema setups for handling likes in a social media application. The schemas store likes for different content types (posts, images, and videos) and are designed to handle large datasets efficiently. This README provides an overview of both schema setups and includes benchmarking results comparing their performance under various loads.

## Schemas Overview

### 1. Inheritance-Based Setup (Separate Likes Tables)

In this schema, each content type (posts, images, and videos) has its own dedicated likes table, inheriting from a common base table. The advantage of this approach is that each table maintains strict referential integrity and is directly tied to its corresponding content table.

#### Table Structure

- **Users Table** (`users`)
  - `user_id`: Primary key
  - `username`: The username of the user
- **Posts Table** (`posts`)
  - `post_id`: Primary key
  - `content`: Content of the post
- **Images Table** (`images`)
  - `image_id`: Primary key
  - `url`: URL of the image
- **Videos Table** (`videos`)
  - `video_id`: Primary key
  - `url`: URL of the video
- **Likes Tables**:
  - **Post Likes Table** (`post_likes`)
    - `user_id`: Foreign key to `users`
    - `post_id`: Foreign key to `posts`
  - **Image Likes Table** (`image_likes`)
    - `user_id`: Foreign key to `users`
    - `image_id`: Foreign key to `images`
  - **Video Likes Table** (`video_likes`)
    - `user_id`: Foreign key to `users`
    - `video_id`: Foreign key to `videos`

#### Advantages:

- **Efficient Queries**: Each like type has its own table with direct foreign keys, making queries and indexing straightforward.
- **Referential Integrity**: Strong referential integrity is enforced at the database level for each like type.
- **Performance**: Queries for a specific content type are faster due to targeted indexes.

#### Disadvantages:

- **Schema Complexity**: Adding new content types requires creating new tables and maintaining separate queries.
- **Cross-Type Queries**: Queries across multiple content types (e.g., all likes for a user) require `UNION` operations.

---

### 2. Polymorphic Setup (Single Likes Table with Type Field)

In this schema, a single `likes` table is used for all content types. The `likes` table stores a `content_type` column to identify the type of content being liked (post, image, or video) and a `content_id` column to point to the specific content in its respective table.

#### Table Structure

- **Users Table** (`users`)
  - `user_id`: Primary key
  - `username`: The username of the user
- **Posts Table** (`posts`)
  - `post_id`: Primary key
  - `content`: Content of the post
- **Images Table** (`images`)
  - `image_id`: Primary key
  - `url`: URL of the image
- **Videos Table** (`videos`)
  - `video_id`: Primary key
  - `url`: URL of the video
- **Likes Table** (`likes`)
  - `user_id`: Foreign key to `users`
  - `content_type`: Specifies the type of content (`'post'`, `'image'`, `'video'`)
  - `content_id`: ID of the content in the respective table

#### Advantages:

- **Simplicity**: Only one `likes` table is used for all content types, reducing schema complexity.
- **Flexibility**: Easily extendable to support additional content types without altering the schema.

#### Disadvantages:

- **Referential Integrity**: Referential integrity cannot be easily enforced across different content types.
- **Query Complexity**: Queries for likes require checking the `content_type` and joining multiple content tables, which can degrade performance for large datasets.

---

## Benchmarking Results

### Benchmarking Setup

The following benchmarks were performed using PostgreSQL on a dataset containing:

- 1500 likes for each user spread evenly across posts, images, and videos
- 10,000 users
- 10,000 posts, images, and videos each

The performance was measured for the following operations:

- Querying all likes for a specific user
- Querying all users who liked a specific post
- Inserting likes

### Results

| **Operation**                         | **Inheritance (Separate Tables)** | **Polymorphic (Single Table)** |
|---------------------------------------|-----------------------------------|--------------------------------|
| **Query all likes for a user**        | 7.85ms                            | 50.08ms                        |
| **Query all users who liked a post**  | 0.82ms                            | 1.57ms                         |
| **Insert a like**                     | 6.71ms                            | 7.51ms                         |

### Key Insights:

- **Query Performance**: The inheritance-based setup performed better in most queries, especially when querying a specific type of content (e.g., posts). This is due to the simplicity of joins and more efficient indexing.
- **Insert Performance**: The polymorphic setup had slightly better insertion times since all likes are stored in a single table, and the database doesn't need to maintain multiple indexes.
- **Scalability**: As the number of likes grows, the inheritance-based setup continues to scale better for content-specific queries, while the polymorphic setup starts to slow down for queries that require joining different content types.

---

## Conclusion

- **Inheritance-Based Setup**: Best suited for large-scale applications with many likes and frequent content-specific queries. It offers better performance for querying specific content types but requires more complex schema maintenance.
- **Polymorphic Setup**: Ideal for smaller applications or those that need flexibility in content types. It simplifies the schema but can degrade in performance with large datasets.

---

## How to Run

1. Clone this repository.
2. Run either of these: 
    - `elixir prepare.exs LIKES_PER_USER AMOUNT_OF_USERS` (eg. `elixir prepare.exs 1500 10000`) followed by `elixir benchee.exs`
    - `benchmark.sh LIKES_PER_USER AMOUNT_OF_USERS`

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

### Future Work

- Explore advanced indexing strategies (e.g., partial indexes, BRIN indexes) to further optimize the polymorphic setup.
- Experiment with horizontal scaling and sharding strategies for both schemas.

---

This README outlines the two schema approaches, their performance trade-offs, and the results of benchmarking. Adjust the `benchmark_queries.sql` to match your environment for more specific insights.

This README and schemas has largely been created by an LLM, then edited by a human to fix mistakes and optimize the insertion of data at setup.
