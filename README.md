<h1>Likes Database Schema: Inheritance vs. Polymorphic Setup</h1>
<p>This repository contains two database schema setups for handling likes in a social media application. The schemas store likes for different content types (posts, images, and videos) and are designed to handle large datasets efficiently. This README provides an overview of both schema setups and includes benchmarking results comparing their performance under various loads.</p>
<h2>Schemas Overview</h2>
<h3>1. Inheritance-Based Setup (Separate Likes Tables)</h3>
<p>In this schema, each content type (posts, images, and videos) has its own dedicated likes table, inheriting from a common base table. The advantage of this approach is that each table maintains strict referential integrity and is directly tied to its corresponding content table.</p>
<h4>Table Structure</h4>
<ul>
    <li><strong>Users Table</strong> (<code>users</code>)
        <ul>
            <li><code>user_id</code>: Primary key</li>
            <li><code>username</code>: The username of the user</li>
        </ul>
    </li>
    <li><strong>Posts Table</strong> (<code>posts</code>)
        <ul>
            <li><code>post_id</code>: Primary key</li>
            <li><code>content</code>: Content of the post</li>
        </ul>
    </li>
    <li><strong>Images Table</strong> (<code>images</code>)
        <ul>
            <li><code>image_id</code>: Primary key</li>
            <li><code>url</code>: URL of the image</li>
        </ul>
    </li>
    <li><strong>Videos Table</strong> (<code>videos</code>)
        <ul>
            <li><code>video_id</code>: Primary key</li>
            <li><code>url</code>: URL of the video</li>
        </ul>
    </li>
    <li><strong>Likes Tables</strong>:
        <ul>
            <li><strong>Post Likes Table</strong> (<code>post_likes</code>)
                <ul>
                    <li><code>user_id</code>: Foreign key to <code>users</code></li>
                    <li><code>post_id</code>: Foreign key to <code>posts</code></li>
                </ul>
            </li>
            <li><strong>Image Likes Table</strong> (<code>image_likes</code>)
                <ul>
                    <li><code>user_id</code>: Foreign key to <code>users</code></li>
                    <li><code>image_id</code>: Foreign key to <code>images</code></li>
                </ul>
            </li>
            <li><strong>Video Likes Table</strong> (<code>video_likes</code>)
                <ul>
                    <li><code>user_id</code>: Foreign key to <code>users</code></li>
                    <li><code>video_id</code>: Foreign key to <code>videos</code></li>
                </ul>
            </li>
        </ul>
    </li>
</ul>
<h4>Advantages:</h4>
<ul>
    <li><strong>Efficient Queries</strong>: Each like type has its own table with direct foreign keys, making queries and indexing straightforward.</li>
    <li><strong>Referential Integrity</strong>: Strong referential integrity is enforced at the database level for each like type.</li>
    <li><strong>Performance</strong>: Queries for a specific content type are faster due to targeted indexes.</li>
</ul>
<h4>Disadvantages:</h4>
<ul>
    <li><strong>Schema Complexity</strong>: Adding new content types requires creating new tables and maintaining separate queries.</li>
    <li><strong>Cross-Type Queries</strong>: Queries across multiple content types (e.g., all likes for a user) require <code>UNION</code> operations.</li>
</ul>
<hr>
<h3>2. Polymorphic Setup (Single Likes Table with Type Field)</h3>
<p>In this schema, a single <code>likes</code> table is used for all content types. The <code>likes</code> table stores a <code>content_type</code> column to identify the type of content being liked (post, image, or video) and a <code>content_id</code> column to point to the specific content in its respective table.</p>
<h4>Table Structure</h4>
<ul>
    <li><strong>Users Table</strong> (<code>users</code>)
        <ul>
            <li><code>user_id</code>: Primary key</li>
            <li><code>username</code>: The username of the user</li>
        </ul>
    </li>
    <li><strong>Posts Table</strong> (<code>posts</code>)
        <ul>
            <li><code>post_id</code>: Primary key</li>
            <li><code>content</code>: Content of the post</li>
        </ul>
    </li>
    <li><strong>Images Table</strong> (<code>images</code>)
        <ul>
            <li><code>image_id</code>: Primary key</li>
            <li><code>url</code>: URL of the image</li>
        </ul>
    </li>
    <li><strong>Videos Table</strong> (<code>videos</code>)
        <ul>
            <li><code>video_id</code>: Primary key</li>
            <li><code>url</code>: URL of the video</li>
        </ul>
    </li>
    <li><strong>Likes Table</strong> (<code>likes</code>)
        <ul>
            <li><code>user_id</code>: Foreign key to <code>users</code></li>
            <li><code>content_type</code>: Specifies the type of content (<code>'post'</code>, <code>'image'</code>, <code>'video'</code>)</li>
            <li><code>content_id</code>: ID of the content in the respective table</li>
        </ul>
    </li>
</ul>
<h4>Advantages:</h4>
<ul>
    <li><strong>Simplicity</strong>: Only one <code>likes</code> table is used for all content types, reducing schema complexity.</li>
    <li><strong>Flexibility</strong>: Easily extendable to support additional content types without altering the schema.</li>
</ul>
<h4>Disadvantages:</h4>
<ul>
    <li><strong>Referential Integrity</strong>: Referential integrity cannot be easily enforced across different content types.</li>
    <li><strong>Query Complexity</strong>: Queries for likes require checking the <code>content_type</code> and joining multiple content tables, which can degrade performance for large datasets.</li>
</ul>
<hr>
<h2>Benchmarking Results</h2>
<h3>Benchmarking Setup</h3>
<p>The following benchmarks were performed using PostgreSQL on a dataset containing:</p>
<ul>
    <li>1500 likes for each user spread evenly across posts, images, and videos</li>
    <li>10,000 users</li>
    <li>10,000 posts, images, and videos each</li>
</ul>
<p>The performance was measured for the following operations:</p>
<ul>
    <li>Querying all likes for a specific user</li>
    <li>Querying all users who liked a specific post</li>
    <li>Inserting likes</li>
</ul>
<h3>Results</h3>
<table>
    <thead>
        <tr>
            <th><strong>Operation</strong></th>
            <th><strong>Inheritance (Separate Tables)</strong></th>
            <th><strong>Polymorphic (Single Table)</strong></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><strong>Query all likes for a user</strong></td>
            <td>7.85ms</td>
            <td>50.08ms</td>
        </tr>
        <tr>
            <td><strong>Query all users who liked a post</strong></td>
            <td>0.82ms</td>
            <td>1.57ms</td>
        </tr>
        <tr>
            <td><strong>Insert a like</strong></td>
            <td>6.71ms</td>
            <td>7.51ms</td>
        </tr>
    </tbody>
</table>
<h3>Key Insights:</h3>
<ul>
    <li><strong>Query Performance</strong>: The inheritance-based setup performed better in most queries, especially when querying a specific type of content (e.g., posts). This is due to the simplicity of joins and more efficient indexing.</li>
    <li><strong>Insert Performance</strong>: The polymorphic setup had slightly better insertion times since all likes are stored in a single table, and the database doesn't need to maintain multiple indexes.</li>
    <li><strong>Scalability</strong>: As the number of likes grows, the inheritance-based setup continues to scale better for content-specific queries, while the polymorphic setup starts to slow down for queries that require joining different content types.</li>
</ul>
<hr>
<h2>Conclusion</h2>
<ul>
    <li><strong>Inheritance-Based Setup</strong>: Best suited for large-scale applications with many likes and frequent content-specific queries. It offers better performance for querying specific content types but requires more complex schema maintenance.</li>
    <li><strong>Polymorphic Setup</strong>: Ideal for smaller applications or those that need flexibility in content types. It simplifies the schema but can degrade in performance with large datasets.</li>
</ul>
<hr>
<h2>How to Run</h2>
<ol>
    <li>Clone this repository.</li>
    <li>run <code>benchmark.sh</code></li>
</ol>
<hr>
<h2>License</h2>
<p>This project is licensed under the MIT License. See the <code>LICENSE</code> file for details.</p>
<hr>
<h3>Future Work</h3>
<ul>
    <li>Explore advanced indexing strategies (e.g., partial indexes, BRIN indexes) to further optimize the polymorphic setup.</li>
    <li>Experiment with horizontal scaling and sharding strategies for both schemas.</li>
</ul>
<hr>
<p>This README outlines the two schema approaches, their performance trade-offs, and the results of benchmarking. Adjust the <code>benchmark_queries.sql</code> to match your environment for more specific insights.</p>
<p>This README and schemas has largely been created by an LLM, then edited by a human to fix mistakes and optimize the insertion of data at setup.</p>
