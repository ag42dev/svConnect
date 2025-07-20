#include <amxmodx>
#include <amxmisc>

#define PLUGIN "svConnect"
#define VERSION "1.0"
#define AUTHOR "ag42.online"

#define SERVERS_PER_PAGE 7

// =============================================================================
// Server array (IP:PORT:SERVER_NAME)
// =============================================================================

new const g_szServers[][] = {
	"127.0.0.1:27015:Local Server",
	"192.168.1.101:27015:Server 2",
	"192.168.1.102:27015:Cool Name",
	"192.168.1.103:27015:Server 4",
	"192.168.1.104:27017:Test Server",
	"192.168.1.105:27015:Main Server",
	"192.168.1.106:27015:Backup Server",
	"192.168.1.107:27015:Gaming Server",
	"192.168.1.108:27015:Fun Server",
	"192.168.1.109:27015:Competitive Server"
}

// =============================================================================
//
// =============================================================================

new g_iCurrentPage[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /connect", "cmd_connect")
	register_menucmd(register_menuid("ServerConnectMenu"), 1023, "menu_handler")
}

public cmd_connect(id) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	g_iCurrentPage[id] = 0
	show_server_menu(id)
	return PLUGIN_HANDLED
}

public show_server_menu(id) {
	new szMenu[512], szTemp[128], szAddress[64], szName[64]
	new len = 0
	new iPage = g_iCurrentPage[id]
	new iStart = iPage * SERVERS_PER_PAGE
	new iEnd = min(iStart + SERVERS_PER_PAGE, sizeof(g_szServers))
	new iTotalPages = (sizeof(g_szServers) + SERVERS_PER_PAGE - 1) / SERVERS_PER_PAGE

	if(iTotalPages > 1) {
		len += formatex(szMenu[len], charsmax(szMenu) - len, "\wSelect server \y(Page %d/%d)\w:^n^n", iPage + 1, iTotalPages)
	} else {
		len += formatex(szMenu[len], charsmax(szMenu) - len, "\wSelect server:^n^n")
	}

	new iMenuPos = 1
	for(new i = iStart; i < iEnd; i++) {
		parse_server_info(g_szServers[i], szAddress, charsmax(szAddress), szName, charsmax(szName))
		formatex(szTemp, charsmax(szTemp), "\y%d. \w%s \r- \y%s^n", iMenuPos, szName, szAddress)
		len += formatex(szMenu[len], charsmax(szMenu) - len, "%s", szTemp)
		iMenuPos++
	}

	len += formatex(szMenu[len], charsmax(szMenu) - len, "^n")
	if(iTotalPages > 1) {
		len += formatex(szMenu[len], charsmax(szMenu) - len, "\r8. \w%s^n", (iPage > 0) ? "Previous Page" : "")
		len += formatex(szMenu[len], charsmax(szMenu) - len, "\r9. \w%s^n", (iPage < iTotalPages - 1) ? "Next Page" : "")
	}
	len += formatex(szMenu[len], charsmax(szMenu) - len, "\r0. \wCancel")

	new keys = (1<<9)
	for(new i = 0; i < (iEnd - iStart); i++) {
		keys |= (1<<i)
	}

	if(iPage > 0) keys |= (1<<7)
	if(iPage < iTotalPages - 1) keys |= (1<<8)

	show_menu(id, keys, szMenu, -1, "ServerConnectMenu")
}

public parse_server_info(const szServerString[], szAddress[], maxAddress, szName[], maxName) {
	new pos1 = contain(szServerString, ":")
	new pos2 = contain(szServerString[pos1 + 1], ":")
	if(pos1 != -1 && pos2 != -1) {
		pos2 += pos1 + 1
		new i = 0
		while(i < pos2 && i < maxAddress - 1) {
			szAddress[i] = szServerString[i]
			i++
		}
		szAddress[i] = 0
		copy(szName, maxName, szServerString[pos2 + 1])
	} else {
		copy(szAddress, maxAddress, szServerString)
		copy(szName, maxName, "Unknown Server")
	}
}

public menu_handler(id, key) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	new iPage = g_iCurrentPage[id]
	new iStart = iPage * SERVERS_PER_PAGE
	new iEnd = min(iStart + SERVERS_PER_PAGE, sizeof(g_szServers))
	new iTotalPages = (sizeof(g_szServers) + SERVERS_PER_PAGE - 1) / SERVERS_PER_PAGE

	switch(key) {
		case 7: {
			if(iPage > 0) {
				g_iCurrentPage[id]--
				show_server_menu(id)
			}
		}
		case 8: {
			if(iPage < iTotalPages - 1) {
				g_iCurrentPage[id]++
				show_server_menu(id)
			}
		}
		case 9: {
			client_print(id, print_chat, "[svConnect] Cancelled.")
		}
		default: {
			new iServerIndex = iStart + key
			if(iServerIndex < iEnd && iServerIndex < sizeof(g_szServers)) {
				connect_to_server(id, iServerIndex)
			}
		}
	}

	return PLUGIN_HANDLED
}

public connect_to_server(id, server_id) {
	if(!is_user_connected(id))
		return
	if(server_id < 0 || server_id >= sizeof(g_szServers))
		return

	new szAddress[64], szName[64]
	parse_server_info(g_szServers[server_id], szAddress, charsmax(szAddress), szName, charsmax(szName))
	client_print(id, print_chat, "[svConnect] Connecting to server: %s (%s)", szName, szAddress)
	send_connect_bypass(id, szAddress)
}

stock send_connect_bypass(id, const address[]) {
	new cmd_line[128]
	format(cmd_line, charsmax(cmd_line), "connect %s", address)

	message_begin(MSG_ONE, 51, _, id)
	write_byte(strlen(cmd_line) + 2)
	write_byte(10)
	write_string(cmd_line)
	message_end()
}
