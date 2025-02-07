Hooks:PostHook(BaseNetworkSession,"on_peer_synched","QuickChat_BaseNetworkSession_onpeersynched",function(self,peer_id,...)
	if QuickChat then
		QuickChat:SendSyncPeerVersionToAll()
		QuickChat:SendAllMyWaypointsToPeer(peer_id)
	end
end)

Hooks:PostHook(BaseNetworkSession,"on_peer_synched","QuickChat_BaseNetworkSession_onpeersynccomplete",function(self,peer_id,...)
	if QuickChat then
		QuickChat:SendSyncPeerVersionToAll()
		QuickChat:SendAllMyWaypointsToPeer(peer_id)
	end
end)