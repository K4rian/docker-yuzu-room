yuzu Multiplayer Dedicated Lobby using Docker Compose
=====
This example defines a basic set up for a yuzu Multiplayer Dedicated Lobby using Docker Compose. 

## Project structure
```shell
.
├── docker-compose.yml
├── yuzu-room.env
├── secret.txt
└── README.md
```

## [Compose file](docker-compose.yml)
```yaml
services:
  yuzu-room:
    image: k4rian/yuzu-room:latest
    container_name: yuzu-room
    hostname: yuzu-room
    volumes:
      - data:/home/yuzu
      - /etc/localtime:/etc/localtime:ro
    env_file:
      - yuzu-room.env
    secrets:
      - yuzuroom
    ports:
      - 24872:24872/tcp
      - 24872:24872/udp
    restart: unless-stopped

volumes:
  data:

secrets:
  yuzuroom:
    file: ./secret.txt
```
* The environment file *[yuzu-room.env](yuzu-room.env)* holds the server environment variables.

* The server password is defined in the *[secret.txt](secret.txt)* file.<br>
Compose will mount it to `/run/secrets/yuzuroom` within the container.

* The secret name must be `yuzuroom`.

* To make the server public, omit the `secrets` definitions in the Compose file.

## Deployment
```bash
docker compose -p yuzu-room up -d
```
> The project is using a volume in order to store the server data that can be recovered if the container is removed and restarted.

## Expected result
Check that the container is running properly:
```bash
docker ps | grep "yuzu"
```

To see the server log output:
```bash
docker compose -p yuzu-room logs
```

## Stop the container
Stop and remove the container:
```bash
docker compose -p yuzu-room down
```

Both the container and its volume can be removed by providing the `-v` argument:
```bash
docker compose -p yuzu-room down -v
```