ARG ELIXIR_VERSION=1.16.0
ARG ERLANG_VERSION=26.2.1
ARG DEBIAN_VERSION=bullseye-20231009-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMG="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force \
    && mix local.rebar --force


ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./

RUN mix deps.get --only $MIX_ENV

RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY assets assets
COPY lib lib

RUN mix assets.deploy
RUN mix compile

COPY config/runtime.exs config

COPY rel rel

RUN mix release


FROM ${RUNNER_IMG} as runner

RUN apt-get update -y \
    && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

WORKDIR "/app"
RUN chown nobody /app
# set the runner ENV
ENV MIX_ENV="prod"
# only copy the final release from the build stage
COPY --from=builder \
    --chown=nobody:root /app/_build/${MIX_ENV}/rel/kanban ./
USER nobody
CMD ["/app/bin/server"]