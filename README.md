# PostgreSQL Jam DVD Rental
Files to follow the PostgresSQL Jam with the [DVD rental sample database](https://www.postgresqltutorial.com/postgresql-sample-database/). 

- Files necessary to build Containers on .devcontainer directory.
    - Set up so database is restored from /src/db_restore/dvdrental.tar using the /src/db_restore/db_restore.sh script as entry point to db container
    - /src/db_restore/dvdrental.tar contains the restore files downloaded at the [DVD rental sample database](https://www.postgresqltutorial.com/postgresql-sample-database/) (unzipped). Added to the restore db_restore directory for convenience.

- The blog post can be found at /reporting/notes.md or better yet, at [my personal blog]().

- App container from a Python image for future analysis.