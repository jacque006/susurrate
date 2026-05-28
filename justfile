mod game-client 'game-client'
mod circuits 'circuits'
mod contracts-client 'contracts-client'
mod contracts 'contracts'

build-all:
    just contracts build
    just client build

test-all:
    just contracts test
    just client test
