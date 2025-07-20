# svConnect - Server Connection Plugin

A lightweight AMXX plugin that provides an in-game server browser menu for quick connections to predefined servers.

Players can type `/connect` in chat to open paginated menu with server list and connect instantly. Works even with `cl_filterstuffcmd` enabled using protection bypass.

## Installation

1. Place `svconnect.sma` in your `scripting/` folder
2. Compile to get `svconnect.amxx`
3. Place `svconnect.amxx` in `plugins/` folder  
4. Add `svconnect.amxx` to `plugins.ini`

## Configuration

Edit the server list in the plugin source code:

```cpp
new const g_szServers[][] = {
    "127.0.0.1:27015:Local Server",
    "192.168.1.101:27015:DeathMatch Server", 
    "your.domain.com:27016:Fun Server"
}
```

Format: `"IP_ADDRESS:PORT:DISPLAY_NAME"`

## Usage

Players type `/connect` in chat to open the server menu:

**Single page (≤7 servers):**
```
Select server:

1. Local Server - 127.0.0.1:27015
2. DeathMatch Server - 192.168.1.101:27015
3. Fun Server - your.domain.com:27016

0. Cancel
```

**Multiple pages (>7 servers):**
```
Select server (Page 2/3):

1. Competitive Server - 192.168.1.101:27015
2. Training Server - 192.168.1.102:27015

8. Previous Page
9. Next Page  
0. Cancel
```

## License

This project is released under the [Unlicense](LICENSE) - free for any use.
