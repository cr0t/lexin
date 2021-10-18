ARG MIX_ENV="prod"

FROM docker.io/hexpm/elixir:1.12.3-erlang-24.1.2-alpine-3.14.2 AS build

# install build dependencies
RUN apk add --no-cache build-base git python3 curl

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/$MIX_ENV.exs config/
COPY priv priv
COPY assets assets
COPY lib lib

RUN mix deps.compile && \
    mix assets.deploy && \
    mix compile

# changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM docker.io/alpine:3.14.2 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

# creates an unprivileged user to be used exclusively to run the Phoenix app
RUN addgroup -g 1000 -S "${USER}" && \
    adduser -s /bin/sh -u 1000 -G "${USER}" -h "/home/${USER}" -D "${USER}"

# everything from this line onwards will run in the context of the unprivileged user
USER "${USER}"

WORKDIR "/home/${USER}/app"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/lexin ./

ENTRYPOINT ["bin/lexin"]

# Usage:
#
#  * build: sudo docker image build -t elixir/lexin .
#  * shell: sudo docker container run --rm -it --entrypoint "" -p 127.0.0.1:4000:4000 elixir/lexin sh
#  * run:   sudo docker container run --rm -it -p 127.0.0.1:4000:4000 --name lexin elixir/lexin
#  * exec:  sudo docker container exec -it lexin sh
#  * logs:  sudo docker container logs --follow --tail 100 lexin

CMD ["start"]
