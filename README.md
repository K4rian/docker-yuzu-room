<p align="center">
 <img alt="docker-yuzu-room logo" src="https://raw.githubusercontent.com/K4rian/docker-yuzu-room/assets/icons/logo-docker-yuzu-room.svg" width="25%" align="center">
</p>

A Docker image for the [yuzu][1] multiplayer server based on the official [Alpine Linux][2] [image][3].<br>
The server allows you to play many [supported local wireless games][4] via netplay using the [yuzu][1] emulator.

---
<div align="center">

Docker Tag  | Version | Platform     | Description
---         | ---     | ---          | ---
[latest][5] | 1.3     | amd64, arm64 | Latest release (Mainline 1734)
</div>
<p align="center"><a href="#environment-variables">Environment variables</a> &bull; <a href="#password-protection">Password protection</a> &bull; <a href="#usage">Usage</a> &bull; <a href="#using-compose">Using Compose</a> &bull; <a href="#manual-build">Manual build</a> <!-- &bull; <a href="#see-also">See also</a> --> &bull; <a href="#license">License</a></p>

---
## Environment variables
Some environment variables can be tweaked when creating a container to define the server configuration:

<details>
<summary>Click to expand</summary>

Variable         | Default value  | Description 
---              | ---            | ---
YUZU_BINDADDR    | 0.0.0.0        | Host to bind to.
YUZU_PORT        | 24872          | Port to listen on (TCP/UDP).
YUZU_ROOMNAME    | yuzu Room      | Name of the room.
YUZU_PREFGAME    | Any            | Name of the preferred game.
YUZU_MAXMEMBERS  | 4              | Maximum number of members (2-16).
YUZU_BANLISTFILE | bannedlist.ybl | File which yuzu will store ban records in.
YUZU_LOGFILE     | yuzu-room.log  | File path to store the logs.
YUZU_ROOMDESC    |                | (Optional) Description of the room.
YUZU_PREFGAMEID  | 0              | (Optional) Preferred game title identifier. You can find the Title ID with the game list of yuzu (right-click on a game -> `Properties`).
YUZU_PASSWORD    |                | (Optional) Room password *(__NOT__ recommended, see the section below)*.
YUZU_ISPUBLIC    | 0              | (Optional) Make the room public. Valid User Token and Web API URL are required.
YUZU_TOKEN       |                | (Optional) The user token to use for the room. Required to make the room public.
YUZU_WEBAPIURL   |                | (Optional) URL to the custom web API. Required to make the room public.

</details>

## Password protection
The server can be protected with a (clear, unencrypted) password by:

— Bind mount a text file containing the password into the container.<br>
The mountpoint path has to be `/run/secrets/yuzuroom`.<br>
This is the __recommended__ method. See the second example in the section below.

— Using the `YUZU_PASSWORD` environment variable when creating the container.<br>
This method is __NOT__ recommended for production since all environment variables are visible via `docker inspect` to any user that can use the `docker` command. 

## Usage
__Example 1:__<br>
Run a public server for `SSB. Ultimate` on port `51267` with a maximum of `16 members`:<br>
— *You need a valid __User Token__ to make the server reachable via the public room browser.*
```bash
docker run -d \
  --name yuzu-room \
  -p 51267:51267/tcp \
  -p 51267:51267/udp \
  -e YUZU_PORT=51267 \
  -e YUZU_ROOMNAME="USA East - SSB. Ultimate" \
  -e YUZU_ROOMDESC="Fight On!" \
  -e YUZU_PREFGAME="SSB. Ultimate" \
  -e YUZU_PREFGAMEID="01006A800016E000" \
  -e YUZU_MAXMEMBERS=16 \
  -e YUZU_ISPUBLIC=1 \
  -e YUZU_TOKEN="<USER_TOKEN>" \
  -e YUZU_WEBAPIURL="<CUSTOM_API_URL>" \
  -i k4rian/yuzu-room
```

__Example 2:__<br>
Run a private password-protected server using default configuration:<br>
— *In this example, the password is stored in the `secret.txt` file located in the current working directory.* 
```bash
docker run -d \
  --name yuzu-room \
  -p 24872:24872/tcp \
  -p 24872:24872/udp \
  -v "$(pwd)"/secret.txt:/run/secrets/yuzuroom:ro \
  -i k4rian/yuzu-room
```

__Example 3:__<br />
Run a password-protected __testing__ server on port `5555`:<br>
```bash
docker run -d \
  --name yuzu-room-test \
  -p 5555:5555/tcp \
  -p 5555:5555/udp \
  -e YUZU_PORT=5555 \
  -e YUZU_PASSWORD="testing" \
  -i k4rian/yuzu-room
```

## Using Compose
See [compose/README.md][6]

## Manual build
__Requirements__:<br>
— Docker >= __18.09.0__<br>
— Git *(optional)*

Like any Docker image the building process is pretty straightforward: 

- Clone (or download) the GitHub repository to an empty folder on your local machine:
```bash
git clone https://github.com/K4rian/docker-yuzu-room.git .
```

- Then run the following command inside the newly created folder:
```bash
docker build --no-cache -t k4rian/yuzu-room .
```
> The building process can take up to 10 minutes depending on your hardware specs. <br>
> A quad-core CPU with at least 1 GB of RAM and 3 GB of disk space is recommended for the compilation.

<!---
## See also
* __[yuzu-Room Egg](https://github.com/K4rian/)__ — A custom egg of yuzu-Room for the Pterodactyl Panel.
* __[yuzu-Room Template](https://github.com/K4rian/)__ — A custom template of yuzu-Room ready to deploy from the Portainer Web UI.
--->

## License
[GPL-3.0][7]

[1]: https://web.archive.org/web/20240304211628/https://yuzu-emu.org/ "yuzu Project Website (Archive/March 4, 2024)"
[2]: https://www.alpinelinux.org/ "Alpine Linux Official Website"
[3]: https://hub.docker.com/_/alpine "Alpine Linux Docker Image"
[4]: https://switcher.co/games/tag/local-wireless/ "List of Switch Local Wireless Games"
[5]: https://github.com/K4rian/docker-yuzu-room/blob/master/Dockerfile "Latest Dockerfile"
[6]: https://github.com/K4rian/docker-yuzu-room/tree/master/compose "Compose Files"
[7]: https://github.com/K4rian/docker-yuzu-room/blob/master/LICENSE