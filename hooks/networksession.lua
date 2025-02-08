local function on_peer_synced(self,peer_id)
	if QuickChat then
		QuickChat:SendSyncPeerVersionToAll()
		QuickChat:SendAllMyWaypointsToPeer(peer_id)
	end
end

local required_script = string.lower(RequiredScript)
if required_script == "lib/network/base/clientnetworksession" then
	Hooks:PostHook(ClientNetworkSession,"on_peer_synched","QuickChat_ClientNetworkSession_onpeersynched",on_peer_synced)
elseif required_script == "lib/network/base/hostnetworksession" then
	Hooks:PostHook(HostNetworkSession,"on_peer_sync_complete","QuickChat_HostNetworkSession_onpeersynccomplete",on_peer_synced)
end