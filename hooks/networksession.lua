local required_script = string.lower(RequiredScript)
if required_script == "lib/network/base/clientnetworksession" then
	Hooks:PostHook(ClientNetworkSession,"on_peer_synched","QuickChat_ClientNetworkSession_onpeersynched",function(self,peer_id)
		if QuickChat then
			QuickChat:SendSyncPeerVersionToAll()
			QuickChat:SendAllMyWaypointsToPeer(peer_id)
		end
	end)
elseif required_script == "lib/network/base/hostnetworksession" then
	Hooks:PostHook(HostNetworkSession,"on_peer_sync_complete","QuickChat_HostNetworkSession_onpeersynccomplete",function(self,peer,peer_id)
		if QuickChat then
			QuickChat:SendSyncPeerVersionToAll()
			QuickChat:SendAllMyWaypointsToPeer(peer_id)
		end
	end)
end