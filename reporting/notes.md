# PostgreSQL Jam - DVD rental 1
For this first code jam, I decided to move away from Python, my true love, to revisit good ol' SQL. Often we just want to train the newest model or draw the fanciest plot and forget that data always has to come first and reliably getting this data, which might not always (I would even say, most often won't) come from humble *.csv*s, it is important to hone those basic SQL querying skills.

If you want to follow along, you can visit [this link](https://github.com/maticalderini/postgresql_jam_dvdrental) to access the repo containing the necessary Dockerfiles to get started quickly.

Everything you'll see from the "Getting to know your database" section was written and coded as part of an informal, friendly jam with a simple rule: you put yourself a timer and play with the data as much as possible before your time runs out. With this format, you might not always get the cleanest, most efficient code, but it is really useful to get your hands dirty and practice often. Just like you would if you were training for any sport, learning a new language or any other skill.

As I've mainly written tutorials in the past, at the beginning I took some instructional detours in terms of queries and text, but quickly moved to a more "to the point" style. If you would like for me to build a full-fleged SQL tuorial to explain the container set up and query syntax, please let me know and I'll get to it!

With all of that in mind, let's jump right into it.

## The Database
The database chosen for this Jam is the freely available [PostgreSQL tutorial sample database](https://www.postgresqltutorial.com/postgresql-sample-database/). It consists of data of a dvd rental service (for those of you who still remember those) with info on films, rentals and customers. The whole thing looks like this:

![db_diagram](dvd-rental-sample-database-diagram.png)

But so far we only barely used the actor, film_actor and film tables. Also, most of the queries actually return a lot of rows, to avoid having long data tables, I chose to only show some of the first few rows. If you run the queries yourself, you'll be able to see all of the returned data.

## Getting to know the database
This is the first time I worked with this database so let's first explore what it has to offer. A good start is to first find the tables that appear on the diagram
```SQL
SELECT 
    * 
FROM 
    information_schema.TABLES 
WHERE
    "table_schema" = 'public'
    AND "table_type" = 'BASE TABLE'
;
```
*Note the use of double-quotes vs single quotes. **Double quotes** are for tables or fields, **single quotes** for strings.

| table_catalog | table_schema | table_name    | table_type |
| :------------ | :----------- | :------------ | :--------- |
| dvdrental     | public       | city          | BASE TABLE |
| dvdrental     | public       | country       | BASE TABLE |
| dvdrental     | public       | customer      | BASE TABLE |
| dvdrental     | public       | film_actor    | BASE TABLE |
| dvdrental     | public       | film_category | BASE TABLE |
| dvdrental     | public       | inventory     | BASE TABLE |
| dvdrental     | public       | language      | BASE TABLE |
| dvdrental     | public       | rental        | BASE TABLE |
| dvdrental     | public       | staff         | BASE TABLE |
| dvdrental     | public       | payment       | BASE TABLE |
| dvdrental     | public       | film          | BASE TABLE |

More info on the different columns in the [official documentation](https://www.postgresql.org/docs/9.1/infoschema-tables.html).

The same query but without conditions:

```SQL
SELECT 
    * 
FROM 
    information_schema.TABLES
;
```

| table_catalog | table_schema | table_name                 | table_type |
| :------------ | :----------- | :------------------------- | :--------- |
| dvdrental     | public       | actor                      | BASE TABLE |     
| dvdrental     | public       | actor_info                 | VIEW       |     
| dvdrental     | public       | customer_list              | VIEW       |     
| dvdrental     | public       | film_list                  | VIEW       |     
| dvdrental     | public       | nicer_but_slower_film_list | VIEW       |     
| dvdrental     | public       | sales_by_film_category     | VIEW       |     
| dvdrental     | public       | store                      | BASE TABLE |     
| dvdrental     | pg_catalog   | pg_statistic               | BASE TABLE |     

To see all the different types of table:

```SQL
SELECT 
    DISTINCT "table_type" 
FROM 
    information_schema.TABLES 
;
```
VIEW and BASE TABLE are the only table types. Compared to the documentation above, we don't have any foreign tables or temporary tables. We can look at the table schemas:

```SQL
SELECT 
    DISTINCT "table_schema"
FROM 
    information_schema.TABLES
;
```
There are 3 schemas: public, pg_catalog, information_schema.

Since we were interested in the actual tables (not views) of our dataset (not database info), earlier we chose to filter on the condition ```WHERE "table_schema" = 'public' AND "table_type" = 'BASE TABLE'```.

We will forget about views for now since we don't want to take any shortcuts to querying the data ourselves.

## Getting to know the tables
We will start looking at the tables one by one. We first get the list of tables in alphabetical order:

```SQL
SELECT 
    "table_name"
FROM 
    information_schema.TABLES 
WHERE
    "table_schema" = 'public' AND "table_type" = 'BASE TABLE'
ORDER BY
    "table_name" ASC
;
```

Since we are repeating the name "table_name" twice, we could use an alias on the column name (not particularly useful here, but good opportunity to show it):

```SQL
SELECT 
    "table_name" AS tn
FROM 
    information_schema.TABLES 
WHERE 
    "table_schema" = 'public' AND
     "table_type" = 'BASE TABLE'
ORDER BY
  tn ASC
;
```
Remember, aliases are only good for the query where they are defined.

Arbirarily, we will start with the (alphabetically) first table "actor". First, some info on the columns (a lot more available in other columns, but name and data type are a good start):

```SQL
SELECT 
    "column_name",
    "data_type"
FROM 
   information_schema.columns
WHERE 
   table_name = 'actor'
;
```

| column_name | data_type                   |
| :---------- | :-------------------------- |
| actor_id    | integer                     |	
| last_update | timestamp without time zone |	
| first_name  | character varying           |	
| last_name   | character varying           |

of course, a glimpse of the table itself:
```SQL
SELECT 
    *
FROM
    actor
LIMIT
    3
;
```
| actor_id | first_name | last_name | last_update            |     |
| :------- | :--------- | :-------- | :--------------------- | :-- |
| 1        | Penelope   | Guiness   | 2013-05-26 14:47:57.62 |     |
| 2        | Nick       | Wahlberg  | 2013-05-26 14:47:57.62 |     |
| 3        | Ed         | Chase     | 2013-05-26 14:47:57.62 |     |

and the total number of rows:

```SQL
SELECT 
    COUNT("actor_id")
FROM 
   actor
;
```
Which gives 200.

### Actors
Of these, 200, we can look how many unique first names and last names there exist:

```SQL
SELECT 
    COUNT(DISTINCT "first_name") AS "first_name_distinct_count",
    COUNT(DISTINCT "last_name") AS "last_name_distinct_count"
FROM 
   actor
;
```
Which gives 128 unique first names and 121 unique last names.

Of course, what about full names:
```SQL
SELECT 
    COUNT(DISTINCT "full_name")
FROM (
    SELECT 
        "first_name" || ' ' || "last_name" AS "full_name"
    FROM
        actor
) AS sub
;
```
Which gives 199 unique full names (one repeated full name).

We can look at the top ten first names (by frequency):
```SQL
SELECT 
    "first_name",
    COUNT("first_name") AS "counts"
FROM
    actor
GROUP BY
    "first_name"
ORDER BY
    "counts" DESC,
    "first_name" ASC
LIMIT 10
;
```

| first_name | counts |
| :--------- | :----- |
| Julia     | 4   |
| Kenneth   | 4   |
| Penelope  | 4   |
| Burt      | 3   |
| Cameron   | 3   |
| Christian | 3   |
| Cuba      | 3   |
| Dan       | 3   |
| Ed        | 3   |
| Fay       | 3   |



There might be other names with a count of 3 that didn't make it because of the alphabetical order. Instead, we can look at all the non-unique (count > 1) names:

```SQL
SELECT 
    "first_name",
    COUNT("first_name") AS "counts"
FROM
    actor
GROUP BY
    "first_name"
HAVING
    COUNT("first_name") > 1
ORDER BY
    "counts" DESC,
    "first_name" ASC
;
```
While we use ```COUNT("first_name")```, twice, it is actualy only calculated once. For a solution that can explicitely use the "counts" alias (which I tend to prefer for readability), we can instead use a subquery (check out [this stackoverflow link](https://stackoverflow.com/questions/2102373/referring-to-dynamic-columns-in-a-postgres-query/2102391) for more info):

```SQL
SELECT
    sub.* 
FROM
(
    SELECT
        "first_name",
        COUNT("first_name") AS "counts"
    FROM
        actor
    GROUP BY
        "first_name"
) AS sub
WHERE "counts" > 1
ORDER BY
    "counts" DESC,
    "first_name" ASC
;
```

We can use these subqueries to get only the data about actors with repeated names:

```SQL
SELECT
    *
FROM
    actor
WHERE
    "first_name" IN 
    (
        SELECT
            "first_name"
        FROM
            actor
        GROUP BY
            "first_name"
        HAVING
            COUNT("first_name") > 1
    )
ORDER BY
    "first_name" ASC
;
```

| actor_id | first_name | last_name   | last_update            |     |
| :------- | :--------- | :---------- | :--------------------- | :-- |
| 132      | Adam       | Hopper      | 2013-05-26 14:47:57.62 |     |
| 71       | Adam       | Grant       | 2013-05-26 14:47:57.62 |     |
| 146      | Albert     | Johansson   | 2013-05-26 14:47:57.62 |     |
| 125      | Albert     | Nolte       | 2013-05-26 14:47:57.62 |     |
| 65       | Angela     | Hudson      | 2013-05-26 14:47:57.62 |     |
| 144      | Angela     | Witherspoon | 2013-05-26 14:47:57.62 |     |

We can also get those actors with repeated full name (same first and last names):

```SQL
SELECT
    "first_name" || "last_name" AS "full_name",
    COUNT("first_name" || "last_name")
FROM
    actor
GROUP BY
    "first_name",
    "last_name"
HAVING
    COUNT("first_name" || "last_name") > 1
;
```

You can avoid the repetition of the double vertical bars with something like:
```SQL
SELECT
    "full_name",
    COUNT("full_name")
FROM
(
    SELECT
        "first_name" || "last_name" AS "full_name"
    FROM
        actor
) AS sub
GROUP BY
    "full_name"
HAVING
    COUNT("full_name") > 1
;
```
Either way, we get only one repeated name, that of Susan Davis (twice).

## Actors and their movies
We can check how many movies each actor made:
```SQL
SELECT
    "first_name"|| ' ' || "last_name" AS full_name,
    "movies_count"
FROM
    actor
NATURAL JOIN
(
    SELECT
        "actor_id",
        COUNT("actor_id") AS "movies_count"
    FROM
        film_actor
    GROUP BY
        "actor_id"
) AS movies_per_actor
ORDER BY
    "movies_count" DESC,
    "first_name" || "last_name" ASC
;
```
| full_name      | movies_count |
| :------------- | :----------- |
| Gina Degeneres | 42           |	
| Walter Torn    | 41           |	
| Mary Keitel    | 40           |	
| Matthew Carrey | 39           |	
| Sandra Kilmer  | 37           |


And to compare the two Susan Davis:

```SQL
SELECT
    *
FROM
(
    SELECT
        "first_name",
        "last_name",
        "movies_count"
    FROM
        actor
    NATURAL JOIN
    (
        SELECT
            "actor_id",
            COUNT("actor_id") AS "movies_count"
        FROM
            film_actor
        GROUP BY
            "actor_id"
    ) AS movies_per_actor
    ORDER BY
        "movies_count" DESC
) AS joint
WHERE
    "first_name" || "last_name" = 'SusanDavis'
;
```
Which gives:

| first_name | last_name | movies_count | 
| :------- | :--------- | :---------- |
| Susan | Davis | 33  |
| Susan | Davis | 21  |

So we know that they were indeed two different people and not just a double entry.

Similarly, we can ask the movies with the most actors:

```SQL
SELECT
    "film_id",
    COUNT("film_id") AS "actor_counts"
FROM
    film_actor
NATURAL JOIN
(
    SELECT
        "actor_id",
        "first_name",
        "last_name"
    FROM
        actor
) sub
GROUP BY
    "film_id"
ORDER BY
    "actor_counts" DESC
;
```
| film_id | actor_counts |
| :------ | :----------- |
| 508     | 15           |	
| 714     | 13           |	
| 87      | 13           |	
| 188     | 13           |	
| 146     | 13           |


We can use that to look at the distribution of actor counts (are there many ensemble casts or mainly one lead star movies):
```SQL
SELECT
    "actor_counts", 
    COUNT("actor_counts") AS "actor_count_frequency"
FROM
(
    SELECT
        "film_id",
        COUNT("film_id") AS "actor_counts"
    FROM
        film_actor
    NATURAL JOIN
    (
        SELECT
            "actor_id",
            "first_name",
            "last_name"
        FROM
            actor
    ) sub_join
    GROUP BY
        "film_id"
    ORDER BY
        "actor_counts" DESC
) AS sub_group
GROUP BY
    "actor_counts"
ORDER BY
    "actor_count_frequency" DESC
;
```
| actor_counts | actor_count_frequency |
| :----------- | :-------------------- |
| 5            | 195                   |	
| 6            | 150                   |	
| 4            | 137                   |	
| 7            | 119                   |	
| 3            | 119                   |	
| 8            | 90                    |	
| 2            | 69                    |	
| 9            | 49                    |	
| 10           | 21                    |	
| 1            | 21                    |	
| 11           | 14                    |	
| 12           | 6                     |	
| 13           | 6                     |	
| 15           | 1                     |

> Note for clarity added after time run out: This table essentially means that there were 195 movies with 5 actors, 150 movies with 6 actors and so on.

We can also see if different actors often play together. For that we will use WITH to alleviate the main query a bit:
```SQL
WITH
sub_actor AS
(
    SELECT
        "actor_id",
        "first_name" || ' ' || "last_name" AS "full_name"
    FROM
        actor
),

coocurrence AS
(
    SELECT
        "actor_A",
        "actor_B",
        COUNT(*)
    FROM
        (
            SELECT
                A.actor_id AS "actor_A",
                B.actor_id AS "actor_B"
            FROM
                film_actor AS A
            INNER JOIN film_actor AS B
                ON A.film_id = B.film_id
                AND A.actor_id < B.actor_id
        ) AS sub_self_join
    GROUP BY
        "actor_A",
        "actor_B"
)

SELECT
    sub1.full_name AS "full_name_A",
    sub2.full_name AS "full_name_B",
    "count"
FROM
    coocurrence
INNER JOIN
    sub_actor AS sub1
    ON "actor_A" = sub1.actor_id
INNER JOIN
    sub_actor AS sub2
    ON "actor_B" = sub2.actor_id
ORDER BY
    "count" DESC,
    "full_name_A" ASC,
    "full_name_B" DESC
;
```
| full_name_A      | full_name_B  | cooccurrence |
| :--------------- | :----------- | :---- |
| Julia Mcqueen    | Henry Berry  | 7     |	
| Ben Willis       | Harvey Hope  | 6     |	
| Cuba Olivier     | Mary Keitel  | 6     |	
| Kirsten Paltrow  | Warren Nolte | 6     |	
| Morgan Mcdormand | Will Wilson  | 6     |


We can ask if having more actors leads to a longer movie. For that, we also need the "film" table:

```SQL
SELECT
    "actor_counts",
    COUNT("actor_counts"),
    AVG("length"),
    MAX("length"),
    MIN("length")
FROM
(
    SELECT
        "film_id",
        COUNT("film_id") AS "actor_counts"
    FROM
        film_actor
    NATURAL JOIN
    (
        SELECT
            "actor_id",
            "first_name",
            "last_name"
        FROM
            actor
    ) AS sub_join
    GROUP BY
        "film_id"
    ORDER BY
        "actor_counts" DESC
) AS actor_film_actor_join
NATURAL JOIN
(
    SELECT
        "film_id",
        "length"
    FROM
        film
) AS film_join
GROUP BY
    "actor_counts"
ORDER BY
    "avg" DESC
;
```
| actor_counts | count | avg    | max | min |
| :----------- | :---- | :----- | :-- | :-- |
| 15           | 1     | 144.00 | 144 | 144 |	
| 13           | 6     | 121.33 | 176 | 73  |	
| 9            | 49    | 120.67 | 185 | 49  |	
| 2            | 69    | 120.45 | 184 | 48  |	
| 5            | 195   | 119.63 | 185 | 46  |

## Conclusion
Unfortunately, that is when I ran out of time for this jam! (actually 90% through the next query, but only complete queries count). If this is your first time seeing SQL I hope it piqued your curiosity to go out and learn from more through sources.

If you are more experienced with SQL (or any other language really) I cannot recommend enough that you try the timed jam format by yourself: setup your environment to make sure you won't have unexpected and unrelated troubles, grab yourself a timer and just let the code flow through you, raw and without judgement. You'll see how little it takes to learn and enjoy so much. 