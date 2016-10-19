# Build it yourself
Fist we need an application, the commands below uses a rails container to create a scaffold application called todo
```
docker run -it  -v "$PWD":/usr/src/app -w /usr/src/app rails:4 rails new --skip-bundle todo
```
In this application we will use postgreSQL insteed of sqlLite, we will also be using [unicorn](https://unicorn.bogomips.org), a Rack HTTP server, to run the application. Last but not lest we use [Redis](http://redis.io) for lightning fast cache.
Add the following lines to the bottom of your Gemfile:
```
gem 'pg', '~> 0.18.3'
gem 'unicorn', '~> 4.9'
gem 'redis-rails', '~> 4.0.0'
```
Also, make sure to remove the sqlite gem near the top.
### Making the configuration DRY
We will be using environment variables to configure our application.
Change your config/database.yml to look like this:
```
development:
  url: <%= ENV['DATABASE_URL'].gsub('?', '_development?') %>

test:
  url: <%= ENV['DATABASE_URL'].gsub('?', '_test?') %>

staging:
  url: <%= ENV['DATABASE_URL'].gsub('?', '_staging?') %>

production:
  url: <%= ENV['DATABASE_URL'].gsub('?', '_production?') %>
```
The above file allows us to use the DATABASE_URL, while also allowing us to name our databases based on the environment in which they are being run.

Change your config/secrets.yml to look like this:
```
development: &default
  secret_key_base: <%= ENV['SECRET_TOKEN'] %>

test:
  <<: *default

staging:
  <<: *default

production:
  <<: *default
```
YAML is a markup language. If you've never seen this syntax before, it involves setting each environment to use the same SECRET_TOKEN environment variable.

This is fine, since the value will be different in each environment.

### Application Configuration

Add the following lines to your config/application.rb:
```
module Todo
  class Application < Rails::Application
    # We want to set up a custom logger which logs to STDOUT.
    # Docker expects your application to log to STDOUT/STDERR and to be ran
    # in the foreground.
    config.log_level = :debug
    config.log_tags  = [:subdomain, :uuid]
    config.logger    = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    # Since we're using Redis to back our cache store.
    # This keeps our application stateless as well.
    config.cache_store = :redis_store, ENV['CACHE_URL'],
                         { namespace: 'todo::cache' }
  end
end
```

### Creating the Unicorn Config
Next, create the config/unicorn.rb file and add the following content to it:
```
# Heavily inspired by GitLab:
# https://github.com/gitlabhq/gitlabhq/blob/master/config/unicorn.rb.example

# Go with at least 1 per CPU core, a higher amount will usually help for fast
# responses such as reading from a cache.
worker_processes ENV['WORKER_PROCESSES'].to_i

# Listen on a tcp port or unix socket.
listen ENV['LISTEN_ON']

# Use a shorter timeout instead of the 60s default. If you are handling large
# uploads you may want to increase this.
timeout 30

# Combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings:
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application. This
# prevents calling the application for connections that have disconnected
# while queued. This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

before_fork do |server, worker|
  # Don't bother having the master process hang onto older connections.
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  # The following is only recommended for memory/DB-constrained
  # installations. It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade. The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  # Throttle the master from forking too quickly by sleeping. Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |server, worker|
  # Per-process listener ports for debugging, admin, migrations, etc..
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, tries: -1, delay: 5, tcp_nopush: true)

  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection

  # If preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis. TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls).
end
```

### Creating the Environment Variable File

Last but not least, you need to create the .todo.env file and add the following code to it:
```
# You would typically use `rake secret` to generate a secure token. It is
# critical that you keep this value private in production.
SECRET_TOKEN=thisshouldbeaverysecuretoken

# Unicorn is more than capable of spawning multiple workers, and in production
# you would want to increase this value but in development you should keep it
# set to 1.
#
# It becomes difficult to properly debug code if there's multiple copies of
# your application running via workers and/or threads.
WORKER_PROCESSES=1


# This will be the address and port that Unicorn binds to. The only real
# reason you would ever change this is if you have another service running
# that must be on port 8000.
LISTEN_ON=0.0.0.0:8000


# This is how we'll connect to PostgreSQL. It's good practice to keep the
# username lined up with your application's name but it's not necessary.
#
# Since we're dealing with development mode, it's ok to have a weak password
# such as `yourpassword` but in production you'll definitely want a better one.
#
# Eventually we'll be running everything in Docker containers, and you can set
# the host to be equal to `postgres` thanks to how Docker allows you to link
# containers.
#
# Everything else is standard Rails configuration for a PostgreSQL database.
DATABASE_URL=postgresql://todo:yourpassword@postgres:5432/todo?encoding=utf8&pool=5&timeout=5000


# We'll be using the same Docker link trick for Redis which is how we can
# reference the Redis hostname as `redis`.
CACHE_URL=redis://redis:6379/0
```
The above file allows us to configure the application without having to dive into the application code. This is a very important step to making your application production ready.

This file would also hold information like mail login credentials or API keys. You should also add this file to your .gitignore, so go ahead and do that now.

### Making a Docker file for the application
You'll need a Docker container for your application.
Create the Dockerfile file and add the following code to it:
```
# Use the barebones version of Ruby 2.2.3.
FROM ruby:2.2.3-slim

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - libpq-dev: Communicate with postgres through the postgres gem
# - postgresql-client-9.4: In case you want to talk directly to postgres
RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /todo
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when your gems do not change.
COPY Gemfile Gemfile
RUN bundle install

# Copy in the application code from your work station at the current directory
# over to the working directory.
COPY . .

# Provide dummy data to Rails so it can pre-compile assets.
RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=pickasecuretoken assets:precompile

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# The default command that gets ran will be to start the Unicorn server.
CMD bundle exec unicorn -c config/unicorn.rb
```
### Creating a dockerignore File
Next, create the .dockerignore file and add the following content to it:
```
.git
.dockerignore
Gemfile.lock
```
This file is similar to .gitgnore. It will exclude matching files and folders from being built into your Docker image.
