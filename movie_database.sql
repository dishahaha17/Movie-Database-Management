CREATE DATABASE IF NOT EXISTS movie_database;
USE movie_database;

-- 1. DIRECTOR
CREATE TABLE IF NOT EXISTS Directors (
    director_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR(60),
    bio TEXT
) ENGINE=InnoDB;

-- 2. GENRE
CREATE TABLE IF NOT EXISTS Genres (
    genre_id INT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

-- 3. LANGUAGE
CREATE TABLE IF NOT EXISTS Languages (
    language_id INT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 4. ACTOR
CREATE TABLE IF NOT EXISTS Actors (
    actor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR(60),
    gender VARCHAR(20),
    bio TEXT
) ENGINE=InnoDB;

-- 5. MOVIE
-- Each movie has one director and one language.
CREATE TABLE IF NOT EXISTS Movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    release_year YEAR,
    duration SMALLINT UNSIGNED,
    language_id INT NOT NULL,
    director_id INT NOT NULL,
    description TEXT,
    imdb_rating DECIMAL(3,1),
    budget DECIMAL(15,2),
    CONSTRAINT chk_movie_duration CHECK (duration IS NULL OR duration > 0),
    CONSTRAINT chk_movie_rating CHECK (imdb_rating IS NULL OR imdb_rating BETWEEN 0 AND 10),
    CONSTRAINT fk_movie_language
        FOREIGN KEY (language_id) REFERENCES Languages(language_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movie_director
        FOREIGN KEY (director_id) REFERENCES Directors(director_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movie_language (language_id),
    INDEX idx_movie_director (director_id)
) ENGINE=InnoDB;

-- 6. MOVIE_GENRE
-- Junction table for the M:N relationship between Movies and Genres.
-- A movie can have multiple genres; a genre can belong to multiple movies.
CREATE TABLE IF NOT EXISTS Movie_Genre (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_moviegenre_movie
        FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_moviegenre_genre
        FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_moviegenre_genre (genre_id)
) ENGINE=InnoDB;

-- 7. MOVIE_ACTOR
-- Junction table for the M:N relationship between Movies and Actors.
CREATE TABLE IF NOT EXISTS Movie_Actor (
    movie_id INT NOT NULL,
    actor_id INT NOT NULL,
    role VARCHAR(100),
    PRIMARY KEY (movie_id, actor_id),
    CONSTRAINT fk_movieactor_movie
        FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_movieactor_actor
        FOREIGN KEY (actor_id) REFERENCES Actors(actor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movieactor_actor (actor_id)
) ENGINE=InnoDB;
-- 8. USERS
-- "Users" is used instead of "User" to avoid SQL keyword/name conflicts.
CREATE TABLE IF NOT EXISTS Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20)
) ENGINE=InnoDB;

-- 9. REVIEWS
-- Each review belongs to exactly one user and one movie.
CREATE TABLE IF NOT EXISTS Reviews (
    review_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    review_date DATE NOT NULL,
    comment TEXT,
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_review_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_review_movie
        FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_review_user (user_id),
    INDEX idx_review_movie (movie_id)
) ENGINE=InnoDB;

-- -------------------------
-- SAMPLE DATA
-- Insert parent records before records that reference them.
-- -------------------------

INSERT INTO Directors (director_id, name, date_of_birth, nationality, bio) VALUES
(1, 'Christopher Nolan', '1970-07-30', 'British', 'Film director and screenwriter'),
(2, 'Steven Spielberg', '1946-12-18', 'American', 'Film director and producer');

INSERT INTO Genres (genre_id, name, description) VALUES
(1, 'Action', 'Action films'),
(2, 'Drama', 'Drama films'),
(3, 'Comedy', 'Comedy films');

INSERT INTO Languages (language_id, name) VALUES
(1, 'English'),
(2, 'Hindi'),
(3, 'French');

INSERT INTO Actors (actor_id, name, date_of_birth, nationality, gender, bio) VALUES
(301, 'Leonardo DiCaprio', '1974-11-11', 'American', 'Male', 'Actor'),
(302, 'Tom Hanks', '1956-07-09', 'American', 'Male', 'Actor'),
(303, 'Aamir Khan', '1965-03-14', 'Indian', 'Male', 'Actor');

INSERT INTO Movies
(movie_id, title, release_year, duration, language_id, director_id, description, imdb_rating, budget)
VALUES
(101, 'Inception', 2010, 148, 1, 1, 'A science-fiction thriller', 8.8, 160000000.00),
(102, 'Interstellar', 2014, 169, 1, 1, 'A science-fiction film about space exploration', 8.7, 165000000.00),
(103, '3 Idiots', 2009, 170, 2, 2, 'A comedy-drama about student life', 8.4, 55000000.00);

-- Genre mappings corresponding to the sample Movies table in the diagram.
INSERT INTO Movie_Genre (movie_id, genre_id) VALUES
(101, 1),
(102, 1),
(103, 3);

-- Illustrative movie-actor links; add or change rows to match your chosen cast.
INSERT INTO Movie_Actor (movie_id, actor_id, role) VALUES
(101, 301, 'Lead role'),
(103, 303, 'Lead role');

INSERT INTO Users (user_id, name, email, password, phone) VALUES
(501, 'Disha', 'disha@xyz.com', 'replace_with_hashed_password', '9876543210'),
(502, 'Rohan', 'rohan@xyz.com', 'replace_with_hashed_password', '9876501234');

INSERT INTO Reviews (review_id, user_id, movie_id, rating, review_date, comment) VALUES
(701, 501, 101, 5, '2026-10-01', 'Amazing movie!'),
(702, 502, 102, 4, '2026-10-02', 'Great visuals!');

-- -------------------------
-- CHECK THE TABLES AND DATA
-- -------------------------
SHOW TABLES;

SELECT * FROM Directors;
SELECT * FROM Genres;
SELECT * FROM Languages;
SELECT * FROM Actors;
SELECT * FROM Movies;
SELECT * FROM Movie_Genre;
SELECT * FROM Movie_Actor;
SELECT * FROM Users;
SELECT * FROM Reviews;

-- Example: view movies with their directors, languages and genres.
SELECT
    m.movie_id,
    m.title,
    d.name AS director_name,
    l.name AS language_name,
    g.name AS genre_name
FROM Movies AS m
JOIN Directors AS d ON m.director_id = d.director_id
JOIN Languages AS l ON m.language_id = l.language_id
LEFT JOIN Movie_Genre AS mg ON m.movie_id = mg.movie_id
LEFT JOIN Genres AS g ON mg.genre_id = g.genre_id
ORDER BY m.movie_id;

-- Example: view actors in each movie.
SELECT
    m.title,
    a.name AS actor_name,
    ma.role
FROM Movies AS m
JOIN Movie_Actor AS ma ON m.movie_id = ma.movie_id
JOIN Actors AS a ON ma.actor_id = a.actor_id
ORDER BY m.movie_id, a.name;

-- Example: view reviews with user and movie details.
SELECT
    r.review_id,
    u.name AS user_name,
    m.title AS movie_title,
    r.rating,
    r.review_date,
    r.comment
FROM Reviews AS r
JOIN Users AS u
    ON r.user_id = u.user_id
JOIN Movies AS m
    ON r.movie_id = m.movie_id;