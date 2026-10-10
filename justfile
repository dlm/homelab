user := "dave"

hosts := "nuc-0 laptop-0"

choose:
    just --choose

deploy host:
    nixos-rebuild switch \
        --flake .#{{host}} \
        --target-host {{user}}@{{host}} \
        --sudo \
        --ask-sudo-password

deploy-all:
    @for h in {{hosts}}; do \
        just deploy "$h"; \
    done

status host:
    @ssh \
      -o ConnectTimeout=2 \
      -o ConnectionAttempts=1 \
      -o BatchMode=yes \
      -o LogLevel=ERROR \
      {{user}}@{{host}} \
      'echo "{{host}}: $(uptime)"' \
    || echo "{{host}}: down"

status-all:
    @for h in {{hosts}}; do \
        just status "$h"; \
    done
