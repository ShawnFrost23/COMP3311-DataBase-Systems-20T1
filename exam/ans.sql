-- COMP3311 20T1 Exam Answer Template
--
-- * Don't change view names;
-- * Only change the SQL code for view as commented below;
-- * and follow the order of the view arguments as stated in the comments (if any);
-- * and do not remove the ending semicolon of course.
--
-- * You may create additional views, if you wish;
-- * but you are not allowed to create tables.
--


-- Q1 to Q5 --
-- SQL queries
--


drop view if exists Q1;
create view Q1
as
-- replace the SQL code for view Q1(name, total) below:
SELECT dir.name, count(*) total
FROM director dir
LEFT JOIN movie mov ON mov.director_id=dir.id
GROUP BY dir.id, dir.name
ORDER BY count(mov.title) DESC, dir.name ASC
;

drop view if exists Q2;
create view Q2
as
-- replace the SQL code for view Q2(year, title) below:
SELECT mov.year, mov.title
FROM rating rat, movie mov, 
(
    SELECT max(rat.imdb_score) AS imdbScore, rat.movie_id, mov.year 
    FROM rating rat ,movie mov 
    WHERE mov.id = rat.movie_id 
    AND mov.lang = 'English'
    AND rat.num_voted_users >= 100000 
    AND mov.year is not Null
    GROUP BY mov.year
) 
AS tempQ2
WHERE mov.year = tempQ2.year AND rat.imdb_score = tempQ2.imdbScore AND mov.id = rat.movie_id AND rat.num_voted_users >= 100000 
GROUP BY mov.year, mov.id
ORDER BY mov.year ASC, mov.title ASC
;

-- View to count movies done in the particular given genres 
-- by the actors. This view represents the actors who might 
-- have done movies of other genres as well
DROP view IF EXISTS tempQ3a;
CREATE view tempQ3a
AS
SELECT act.id actor_id, act.name name, count(*) movieCount
FROM actor act 
JOIN acting acti ON (act.id = acti.actor_id)
JOIN
(
    SELECT DISTINCT(mov.id)
    FROM movie mov
    JOIN genre gen ON (mov.id = gen.movie_id)
    WHERE gen.genre IN ('Crime', 'Horror', 'Mystery', 'Sci-Fi', 'Thriller')
) 
AS partGenMov ON (partGenMov.id = acti.movie_id) 
GROUP BY act.id
ORDER BY count(*) DESC
;


drop view if exists Q3;
create view Q3
as
-- replace the SQL code for view Q3(name) below:
SELECT act.name
FROM tempQ3a act
JOIN 
(
    SELECT act.id actor_id, act.name name, count(*) movieCount
    FROM actor act
    JOIN acting acti ON (act.id = acti.actor_id)
    GROUP BY act.id
    ORDER BY count(*) DESC
) 
AS totalMovies ON (act.actor_id = totalMovies.actor_id)
WHERE act.movieCount = totalMovies.movieCount
ORDER BY act.movieCount DESC, act.name ASC
;


drop view if exists Q4;
create view Q4
as
-- replace the SQL code for view Q4(name) below:
SELECT act.name 
FROM actor act
WHERE act.id IN 
(
    SELECT id FROM 
    (
        SELECT DISTINCT act2.ID, gen.genre 
        FROM actor act2
        INNER JOIN acting acti ON act2.id = acti.actor_id 
        INNER JOIN movie mov ON mov.id = acti.movie_id 
        INNER JOIN genre gen ON mov.id = gen.movie_id 
    ) 
    AS actorList
    GROUP BY actorList.id 
    HAVING count(*)>17
) 
ORDER BY act.facebook_likes DESC
;


drop view if exists Q5;
create view Q5
as
-- replace the SQL code for view Q5(title, name) below:
SELECT mov.title, act.name
FROM actor act
JOIN acting acti ON acti.actor_id=act.id
JOIN movie mov ON mov.id=acti.movie_id
JOIN director dir ON dir.id = mov.director_id
WHERE act.name=dir.name
ORDER BY mov.title ASC, act.name ASC
;

-- Q6 --
--

drop view if exists Q6a;
create view Q6a
as
-- replace "REPLACE ME" with your answer below (e.g. select "A,BC"):
select "BC"
;

drop view if exists Q6b;
create view Q6b
as
-- replace "REPLACE ME" with your answer below (e.g. select "A,BC"):
select "A"
;

drop view if exists Q6c;
create view Q6c
as
-- replace "REPLACE ME" with your answer below (e.g. select "A,BC"):
select "ACE, DEC"
;



-- Q7 --
--

drop view if exists Q7a;
create view Q7a
as
-- replace "REPLACE ME" with your answer below (e.g. select "AB,BCD,EFG"):
select "CDE,ACD,BA,BCFG"
;

drop view if exists Q7b;
create view Q7b
as
-- replace "REPLACE ME" with your answer below (e.g. select "AB,BCD,EFG"):
select "AC,DEF,BG,ABD"
;

drop view if exists Q7c;
create view Q7c
as
-- replace "REPLACE ME" with your answer below (e.g. select "AB,BCD,EFG"):
select "DE,ABCD,FAG,BCF"
;



-- Q8 --
--

drop view if exists Q8a;
create view Q8a
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "Y"
;

drop view if exists Q8b;
create view Q8b
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "N"
;

drop view if exists Q8c;
create view Q8c
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "Y"
;

drop view if exists Q8d;
create view Q8d
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "N"
;



-- Q9 --
--

drop view if exists Q9;
create view Q9
as
-- replace "REPLACE ME" with your answer below (e.g. select "A" for choice A):
select "A"
;



-- 10 --
--

drop view if exists Q10;
create view Q10
as
-- replace "REPLACE ME" with your answer below (e.g. select "A" for choice A):
select "E"
;



-- END OF EXAM --
--
