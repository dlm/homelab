user := "dave"

hosts := "nuc-0 laptop-0"

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

check host:
    @ssh \
      -o ConnectTimeout=5 \
      -o ConnectionAttempts=1 \
      -o BatchMode=yes \
      {{host}} \
      'echo "$(hostname): $(uptime)"' \

check-all:
    @for h in {{hosts}}; do \
        just check "$h"; \
    done
