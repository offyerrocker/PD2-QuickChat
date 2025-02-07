local hook_class,hook_name

local required_script = string.lower(RequiredScript)
if required_script == "lib/states/victorystate" then
	hook_class = VictoryState
	hook_name = "victorystate"
elseif required_script == "lib/states/gameoverstate" then
	hook_class = GameOverState
	hook_name = "gameoverstate"
end

Hooks:PostHook(hook_class,"at_enter","quickchat_on_enter_gamestate_" .. hook_name,function(self)
	QuickChat:DisposeAllWaypoints()
end)