# exercise-docker-compse-ror-dev
In the previous exercise you created a docker container. In this exercise you will use docker compose to create multiple docker containers and linking them all together to create an development environment for a Ruby on Rails application.

We have created the base RoR application and a Dockerfile to get you started although we **strongly recommend** building this yourself to get familiar with the different steps. If you choose to build it yourself you'll find the [instructions here](build-it-yourself.md). If you want to use this pre-created repo you will have tor use this command:
```
#First navigate to your exercise repository
git remote add docker-compose-ror-dev https://github.com/1dv032/exercise-docker-compose-ror-dev.git
git subtree add --prefix=docker-compose-ror-dev --squash docker-compose-ror-dev master
```

## Your assignment
You should create a `docker-compose.yml` file that should define the following containers:
### Database
Our app uses a Postgres database, it should use `postgres:9.4.5`. We have already defied the username and password in the  `.todo.env`for the database so you must define the `POSTGRES_USER` and `POSTGRES_PASSWORD` environment variables in this container. Our app needs to able to contact the database so don't forget to expose the port `5432`. We want to be able to take backups of the database so you should put hte database files in an volume, the files are located here `/var/lib/postgresql/data`

### Redis
We use Redis as a cache server and the image `redis:3.0.5` should work fine. We want the cache data to be in its own volume, the location of the data is `/var/lib/redis/data`. Lastly, don't forget to expose the port `6379`

### The application
This container should use the Dockerfile you already have and need links to both the database and the redis containers. We want to be able to continue development once the containers are running. Here we have an predefined environment file we want to use `.todo.env`.

## Continue development
Once you are done with the compose file you should be able to run `docker-compose up`
The first time you will probably get en error that the database stoped, we need to create the database.
```
docker-compose run todo rake db:reset
docker-compose run todo rake db:migrate
docker-compose up
```
Now that the containers are up you should be able to go to http://localhost:8000

We can now continue development of our RoR app:
```
# We want to be able to create tasks in our Todo app, so lets scaffold that.
# You should have the containers running so open a new terminal and run.
docker-compose run todo rails generate scaffold Task name:string completed:boolean created:datetime
# We want the change to be reflected in the database so we need to do a migrate.
docker-compose run todo rake db:migrate
```
Now you cant create tasks http://localhost:8000/tasks

If you want to get the tasks page as the mail page for the app you need to edit the Routes File `config/routes.rb`.<br />
After the `resources :tasks` line near the top add the following line:
`root 'tasks#index'`

## Resources
[Docker Compose](https://docs.docker.com/compose/)
[Quickstart: Docker Compose and Rails](https://docs.docker.com/compose/rails/)
