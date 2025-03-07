--TODO
	-- different behaviour/outcome options
		-- behaviours
			-- press
			-- hold
			-- double/triple tap (JUST KEEP TAPPING)
			-- double tap + hold second tap
		-- outcomes
			-- visualize a raycast to the hit unit
			-- clear raycasts
			-- open radial menu
			-- force timer mode
		
		
	-- long name for quickchat menu options title
		-- short name for quickchat message sender prefix
	-- slider for secondary sphere cast radius?
	
	-- don't mark security cameras that are disabled (eg if camera operator element is neutralized)
	
	-- fix autoping detecting bodybag interaction?
		-- use can_interact()? 
			-- but that would disable other pings, eg. pinging a car, then picking up a bag, would remove the car ping, since you can't enter a car while carrying a bag
			-- case-specific solution it is i guess.
	
	-- lock/lockpick icon?
	-- grenade case icon
	
	-- just hide waypoints on enter forbidden state and show them again on enter whitelisted state
		-- don't jump through so many hoops 
		-- this would fix waypoints being visible when existing waypoints are synced upon dropping-in to game in progress
	
	
	-- last selected radial item icon briefly floats from offscreen when hidden and re-shown
	
	-- toggle for allowing unit tagging
	-- allow peers to send a mute command
	-- radial deadzone/size/alpha menu option
	
	--SCHEMA
		--validate buttons on startup; no duplicate actions in binds
		
		
		--todo use _supported_controller_type_map instead of manual mapping?
			--may not be necessary if only the wrapper type is used
		--needs VR support
		--offscreen waypoint arrow needs visual adjustment
			--arrow triangle is too even
		
		--waypoint distance from player instead of camera?
		--downscale assets (48x?)
			-- i really thought 64x was the play
		
		--proximity priority for spherecast
		-- need to find a network receive solution that isn't spherecasting for the unit_id;
		-- as it stands, theoretically, a severely desynced unit might fail to be found by the receiver peer if it's outside the expected radius
			-- searching enemies list/interactions list?
				-- this might limit the possible unit options since not every unit is in a neat list;
	--FEATURES
		--linger time for timer waypoints
		
		--modifier key to force placement
		--modifier key to go through glass(thin walls)
		--modifier key for timers
		
		-- ping existing vanilla waypoints

		--button/keybind to remove all waypoints
			--remove all waypoints data AND all panel children
			
		--subtle light glow at waypoint area
		--feedback on waypoint placement fail
		
		-- adjust sound vector normalization
			-- based on distance?
			-- turning left/right makes the positional audio fading too extreme
			-- should probably be mostly centered unless it's offscreen (check dot?)
		
		-- don't actually show radial menu until mouse moves?
			-- assume neutral ping
			-- would need to rewrite radialmenu to not be a dialog
			--allow other movement actions during radial menu? (eg. steelsight)
				--tactical leaning compat
					--use head position instead of cam position?

		--allow raycasting teammates (ai)
		
		--display current gamepad mode in options menu
		--customization
			--custom radial messages (use QKI?)
			--preview radial in menu
			--button combos?
		--add localization chat shortcuts for things like skills or achievement names
		--localize menu button names for controllers, per gamepad type
		--allow selecting button by waiting at menu (for controllers) for x seconds
			--(this allows controllers to bind or reserve any options they desire, without interfering with menu operation)
		--remove waypoint on pinged unit death?
			--edge case where you want to keep the body marked after death is out of scope
				--in this case, players should simply re-mark the body after death
				--or i guess i could make a setting for that
			-- alternatively, waypoint can tell you something about the pinged unit? like whether it's alive or dead
		
		-- lower opacity if no LOS to waypoint?
			
	--ASSETS
		
		--autotranslate icon for pretranslated messages in chat
			-- something is wrong with the special character i'm using in the merged_font, i think
		--normal surface plane for area markers
		
	--BUGS
		--TimerManager:game():time() between client and host is desynced; use a different timer
		--QuickChat detects controller mode if a controller is plugged in, even if keyboard is the "main" input
		--character unit waypoints are in an unexpected place; move above head instead
			--probably involves differently sized waypoint panels
		--SWAT turrets have their target unit body detected incorrectly; waypoint is visually offset from the perceived turret core as a result
			-- not sure how to resolve this. it'd have to be case-specific unit->tweaktable:body lookups and i really don't wanna do that
		--known issue: discrepancies in max waypoint count between players may cause unexpected behavior
			--waypoint limits are only enforced locally, so a client with a higher count may see other players' waypoints linger
			--waypoint limit is now set at 1 globally, with no setting; consider this resolved
		
	--TESTS
		
QuickChat = QuickChat or {
	_radial_menu_manager = nil, --for reference
	_lip = nil 					--for reference
}
QuickChat._core = QuickChatCore
QuickChat._mod_path = (QuickChatCore and QuickChatCore.GetPath and QuickChatCore:GetPath()) or ModPath
QuickChat._save_path = SavePath .. "QuickChat/"
QuickChat._save_layouts_path = QuickChat._save_path .. "layouts/"
QuickChat._assets_path = QuickChat._mod_path .. "assets/"
QuickChat._l10n_path = QuickChat._mod_path .. "l10n/"
QuickChat._bindings_name = "bindings_$WRAPPER.json"
QuickChat._settings_name = "settings.json"
QuickChat._DEFAULT_LANGUAGE_ID = "english"
QuickChat.default_settings = {
	debug_draw = false,
	debug_logs = false,
	user_language = QuickChat._DEFAULT_LANGUAGE_ID,
	--compatibility_gcw_send_enabled = true, -- deprecated/combined into compatibility_gcw_enabled
	--compatibility_gcw_receive_enabled = true, -- deprecated/combined into compatibility_gcw_enabled
	compatibility_gcw_enabled = true,
	radial_deadzone = 72,
	radial_size = 300,
	waypoints_auto_icon = true, -- if true, neutral pings will automatically determine the icon+label
	waypoints_alert_on_registration = true,
	--waypoints_max_count = 1, --deprecated
	waypoints_acknowledge_sound_enabled = true,
	waypoints_acknowledge_sound_id = "chime_1", -- key to the list of registered quickchat sounds
	waypoints_acknowledge_sound_volume = 0.66, -- [0-1] volume of acknowledged/unacknowledged sound
	waypoints_unacknowledge_sound_enabled = true,
	waypoints_unacknowledge_sound_id = "scifi_3", -- key to the list of registered quickchat sounds
	waypoints_unacknowledge_sound_volume = 0.66,
	waypoints_ping_sound_enabled = true,
	waypoints_ping_sound_id = "bird", -- key to the list of registered quickchat sounds
	waypoints_ping_sound_volume = 0.66, -- [0-1] volume of ping sound
	waypoints_aim_dot_threshold = 0.995,
	waypoints_attenuate_alpha_mode = 1, -- 1: do not fadeout. 2: fadeout at screen center. 3: fadeout at screen edges.
	waypoints_attenuate_dot_threshold = 0.96,
	waypoints_attenuate_alpha_min = 0.5,
	
	-- hidden options below (no menu interface)
	_l10n_load_optimization = 2
		-- mode 1: reads each language file only once, and caches the whole thing in state memory.
			-- only one IO operation, so slightly faster load time, but every language file is perpetually kept in memory, so increased memory burden the more languages there are.
		-- mode 2: reads each language file multiple times- minimum 1, maximum 2 (once to get the language names for the options menu, and once more for actually selecting and loading a given language);
			-- two IO operations instead of one, so longer load times but very slightly less memory consumption (increased benefits the more languages there are)
}

QuickChat.settings = table.deep_map_copy(QuickChat.default_settings) --general user pref
QuickChat.sort_settings = {
	"debug_draw",
	"debug_logs",
	"user_language",
	"compatibility_gcw_enabled",
	"radial_deadzone",
	"radial_size",
	"waypoints_auto_icon",
	"waypoints_alert_on_registration",
	--"waypoints_max_count",
	"waypoints_acknowledge_sound_enabled",
	"waypoints_acknowledge_sound_id",
	"waypoints_acknowledge_sound_volume",
	"waypoints_unacknowledge_sound_enabled",
	"waypoints_unacknowledge_sound_id",
	"waypoints_unacknowledge_sound_volume",
	"waypoints_ping_sound_enabled",
	"waypoints_ping_sound_id",
	"waypoints_ping_sound_volume",
	"waypoints_aim_dot_threshold",
	"waypoints_attenuate_alpha_mode",
	"waypoints_attenuate_dot_threshold",
	"waypoints_attenuate_alpha_min",
	
	"_l10n_load_optimization"
}
QuickChat._bindings = {}

QuickChat.WAYPOINT_ICON_SIZE = 24
QuickChat.WAYPOINT_ARROW_ICON_SIZE = 16
QuickChat.WAYPOINT_LABEL_FONT_SIZE = 24
QuickChat.WAYPOINT_PANEL_SIZE = 100
QuickChat.WAYPOINT_ANIMATE_FADEIN_DURATION = 5 --pulse for 3 seconds total
QuickChat.WAYPOINT_ANIMATE_PULSE_INTERVAL = 1 --1 second per complete pulse anim

QuickChat._MESSAGE_PRESET_FORMAT = "%s" -- how pre-translated message "presets" appear to quickchat users (this stylization is not applied to messages sent to non-qc players)
QuickChat.SYNC_MESSAGE_PRESET = "QuickChat_message_preset"
QuickChat.SYNC_MESSAGE_QC_HANDSHAKE = "QuickChat_Register"
QuickChat.SYNC_MESSAGE_WAYPOINT_ADD = "QuickChat_SendWaypoint"
QuickChat.SYNC_MESSAGE_WAYPOINT_ACKNOWLEDGE = "QuickChat_AcknowledgeWaypoint"
QuickChat.SYNC_MESSAGE_WAYPOINT_REMOVE = "QuickChat_RemoveWaypoint"
QuickChat.SYNC_TDLQGCW_WAYPOINT_UNIT = "CustomWaypointAttach"
QuickChat.SYNC_TDLQGCW_WAYPOINT_PLACE = "CustomWaypointPlace"
QuickChat.SYNC_TDLQGCW_WAYPOINT_REMOVE = "CustomWaypointRemove"
QuickChat.API_VERSION = "3" -- string!
QuickChat.SYNC_TDLQGCW_VERSION = "tdlq_gcw_49" -- Goonmod's Custom Waypoints does not embed version data into its network string (the current version as of writing is revision 49, but the networking API has never changed since it was made in ~2015 or so, even after tdlq took it over) so we will assume all of them use this version identifier that I just made up, and if it ever changes then that will be a problem for me later
QuickChat.WAYPOINT_RAYCAST_DISTANCE = 250000 --250m
QuickChat.WAYPOINT_SECONDARY_CAST_RADIUS = 50 --50cm
QuickChat.WAYPOINT_OBJECT_PRIORITY_LIST = {
	"Head",
	"Neck"
--,	"a_body" --for turrets, eventually
}
--these are objects picked up by the raycast,
--not necessarily objects selected as a waypoint's unit target

QuickChat.WAYPOINT_TARGET_CAST_TYPES = {
	1, --all (includes equipment)
	2,4, --ai teammates (if host) (needs testing)
	3,5, --teammates
	8, --enemy shield props (when attached)
	11, --world geometry (not unit targetable)
	14, --standard deployables
	16,25, --criminals, including sentrygun
	17, --corpses
	20,23,--pickups
	21, --civilians
	22, --hostages
	26, --sentry gun (not sure what this is, it definitely isn't just enemy swat turrets)
	12,33,--enemies
	39 --vehicles
}
QuickChat._waypoint_target_slotmask = nil --generated on setup

QuickChat.WAYPOINT_TYPES = {
	POSITION = 1,
	UNIT = 2
}
QuickChat._synced_waypoints = {
	{},{},{},{}
}

QuickChat._INTERACTION_ICONS = {
	--atm_interaction,
	first_aid_kit = "equipment_first_aid_kit",
	ammo_bag = "equipment_ammo_bag",
	doctor_bag = "equipment_doctor_bag",
	bodybags_bag = "equipment_bodybags_bag",
	trip_mine = "equipment_trip_mine",
	sentry_gun = "equipment_sentry",
	sentry_gun_fire_mode = "equipment_sentry",
	grenade_briefcase = nil, -- closed grenade case
	grenade_crate = nil, -- open grenade case
	driving_drive = "pd2_car",
	drill = "pd2_drill",
	lance = "pd2_drill",
	gen_pku_crowbar = "wp_crowbar",
	press_printer_ink = "equipment_printer_ink",
	press_plates = "equipment_plates", 
	press_printer_paper = "equipment_paper_roll",
	carry_drop = "pd2_loot", -- bag loot
	hold_take_counterfeit_money = "pd2_loot",
	hold_take_painting = "pd2_loot",
	painting_carry_drop = "pd2_loot",
	gen_pku_evidence_bag = "pd2_loot",
	money_wrap = "pd2_loot",
	diamonds_pickup = "pd2_loot",
	pku_gold = "pd2_loot",
	disassemble_turret = "pd2_loot",
	bag_zipline = "pd2_lootdrop",
	gen_int_saw = "pd2_generic_saw",
	gen_int_saw_jammed = "pd2_generic_saw",
	gen_pku_saw = "pd2_generic_saw",
	corpse_dispose = "equipment_bodybags_bag",
	place_harddrive = "equipment_harddrive",
	pickup_harddrive = "equipment_harddrive",
	access_camera_x_axis = "qc_security_camera",
	access_camera_y_axis = "qc_security_camera",
	access_camera = "qc_security_camera",
	sc_tape_loop = "qc_security_camera", -- security camera tape loop (should be applicable to all cameras)
	-- push_button
	-- sewer_manhole
	-- hold_search_toilet
	c4 = "pd2_c4",
	c4_bag = "pd2_c4",
	c4_consume = "pd2_c4",
	cut_glass = "equipment_glasscutter",
	stash_planks_pickup = "equipment_planks",
	apply_thermite_paste_no_consume = "equipment_thermite",
	gen_pku_thermite = "equipment_thermite",
	requires_ecm_jammer_atm = "equipment_ecm_jammer",
	hold_take_medallion = nil,
	-- crate_loot_crowbar = 40,
	-- suburbia_iron_gate_crowbar = 40,
	-- interaction_ball -- counterfeit hose
	-- water_tap -- water hose start
	-- hold_start_printer
	cas_screw_down = nil,
	cas_take_hook = "equipment_winch_hook",
	-- cas_button_0 - cas_button_09, cas_button_enter, cas_button_clear
	brb_connect_winch_hook = "equipment_winch_hook",
	cas_start_winch = nil,
	shaped_sharge = "equipment_c4", -- no that's not a typo, it is called "shaped_sharge" 
	dah_panicroom_keycard = "equipment_bank_manager_key",
	timelock_panel = "equipment_bank_manager_key",
	pickup_keycard = "equipment_bank_manager_key",
	key = "equipment_bank_manager_key", -- keycard reader
	tag_take_stapler = "equipment_stapler",
	press_place_stapler = "equipment_stapler",
	money_wrap_single_bundle = "qc_loose_cash",
	interact_gen_pku_loot_take = "qc_loose_cash",
	diamond_pickup_pal = "qc_loose_cash",
	diamond_pickup = "qc_loose_cash",
	muriatic_acid = "equipment_muriatic_acid",
	hydrogen_chloride = "equipment_hydrogen_chloride",
	caustic_soda = "equipment_caustic_soda"
}

-- supergroup of icons from various sources
QuickChat._icon_presets_by_index = {
	{
		source = 1,
		icon_id = "pd2_lootdrop" --1
	},
	{
		source = 1,
		icon_id = "pd2_escape" --2
	},
	{
		source = 1,
		icon_id = "pd2_talk" --3
	},
	{
		source = 1,
		icon_id = "pd2_kill" --4
	},
	{
		source = 1,
		icon_id = "pd2_drill" --5
	},
	{
		source = 1,
		icon_id = "pd2_generic_look" --6
	},
	{
		source = 1,
		icon_id = "pd2_phone" --7
	},
	{
		source = 1,
		icon_id = "pd2_c4" --8 (identical to 39)
	},
	{
		source = 1,
		icon_id = "pd2_generic_saw" --9
	},
	{
		source = 1,
		icon_id = "pd2_chainsaw" --10
	},
	{
		source = 1,
		icon_id = "pd2_power" --11
	},
	{
		source = 1,
		icon_id = "pd2_door" --12
	},
	{
		source = 1,
		icon_id = "pd2_computer" --13
	},
	{
		source = 1,
		icon_id = "pd2_wirecutter" --14
	},
	{
		source = 1,
		icon_id = "pd2_fire" --15
	},
	{
		source = 1,
		icon_id = "pd2_loot" --16
	},
	{
		source = 1,
		icon_id = "pd2_methlab" --17
	},
	{
		source = 1,
		icon_id = "pd2_generic_interact" --18
	},
	{
		source = 1,
		icon_id = "pd2_goto" --19
	},
	{
		source = 1,
		icon_id = "pd2_ladder" --20
	},
	{
		source = 1,
		icon_id = "pd2_fix" --21
	},
	{
		source = 1,
		icon_id = "pd2_question" --22
	},
	{
		source = 1,
		icon_id = "pd2_defend" --23
	},
	{
		source = 1,
		icon_id = "wp_arrow" --24
	},
	{
		source = 1,
		icon_id = "pd2_car" --25
	},
	{
		source = 1,
		icon_id = "pd2_melee" --26
	},
	{
		source = 1,
		icon_id = "pd2_water_tap" --27
	},
	{
		source = 1,
		icon_id = "pd2_bodybag" --28
	},
	{
		source = 1,
		icon_id = "wp_vial" --29
	},
	{
		source = 1,
		icon_id = "wp_standard" --30
	},
	{
		source = 1,
		icon_id = "wp_revive" --31
	},
	{
		source = 1,
		icon_id = "wp_rescue" --32
	},
	{
		source = 1,
		icon_id = "wp_trade" --33
	},
	{
		source = 1,
		icon_id = "wp_powersupply" --34
	},
	{
		source = 1,
		icon_id = "wp_watersupply" --35
	},
	{
		source = 1,
		icon_id = "wp_drill" --36
	},
	{
		source = 1,
		icon_id = "wp_hack" --37
	},
	{
		source = 1,
		icon_id = "wp_talk" --38
	},
	{
		source = 1,
		icon_id = "wp_c4" --39 (identical to 8)
	},
	{
		source = 1,
		icon_id = "wp_crowbar" --40
	},
	{
		source = 1,
		icon_id = "wp_planks" --41 -- identical to 74
	},
	{
		source = 1,
		icon_id = "wp_door" --42
	},
	{
		source = 1,
		icon_id = "wp_saw" --43
	},
	{
		source = 1,
		icon_id = "wp_bag" --44
	},
	{
		source = 1,
		icon_id = "wp_exit" --45
	},
	{
		source = 1,
		icon_id = "wp_can" --46
	},
	{
		source = 1,
		icon_id = "wp_target" --47
	},
	{
		source = 1,
		icon_id = "wp_key" --48
	},
	{
		source = 1,
		icon_id = "wp_winch" --49
	},
	{
		source = 1,
		icon_id = "wp_escort" --50
	},
	{
		source = 1,
		icon_id = "wp_powerbutton" --51
	},
	{
		source = 1,
		icon_id = "wp_server" --52
	},
	{
		source = 1,
		icon_id = "wp_powercord" --53
	},
	{
		source = 1,
		icon_id = "wp_phone" --54
	},
	{
		source = 1,
		icon_id = "wp_scrubs" --55
	},
	{
		source = 1,
		icon_id = "wp_sentry" --56
	},
	{
		source = 1,
		icon_id = "equipment_trip_mine" --57
	},
	{
		source = 1,
		icon_id = "equipment_ammo_bag" --58
	},
	{
		source = 1,
		icon_id = "equipment_doctor_bag" --59
	}, -- fak is 169, bodybags is 170. they aren't here because i forgot about them whoops
	{
		source = 1,
		icon_id = "equipment_ecm_jammer" --60
	},
	{
		source = 1,
		icon_id = "equipment_money_bag" --61
	},
	{
		source = 1,
		icon_id = "equipment_bank_manager_key" --62
	},
	{
		source = 1,
		icon_id = "equipment_chavez_key" --63
	},
	{
		source = 1,
		icon_id = "equipment_drill" --64
	},
	{
		source = 1,
		icon_id = "equipment_ejection_seat" --65
	},
	{
		source = 1,
		icon_id = "equipment_saw" --66
	},
	{
		source = 1,
		icon_id = "equipment_glasscutter" --67 -- not to be confused with equipment_cutter
	},
	{
		source = 1,
		icon_id = "equipment_hack_ipad" --68
	},
	{
		source = 1,
		icon_id = "equipment_gold" --69
	},
	{
		source = 1,
		icon_id = "equipment_thermite" --70
	},
	{
		source = 1,
		icon_id = "equipment_c4" --71
	},
	{
		source = 1,
		icon_id = "equipment_cable_ties" --72
	},
	{
		source = 1,
		icon_id = "equipment_bleed_out" --73
	},
	{
		source = 1,
		icon_id = "equipment_planks" --74 -- identical to 41
	},
	{
		source = 1,
		icon_id = "equipment_sentry" --75
	},
	{
		source = 1,
		icon_id = "equipment_stash_server" --76
	},
	{
		source = 1,
		icon_id = "equipment_vialOK" --77
	},
	{
		source = 1,
		icon_id = "equipment_vial" --78
	},
	{
		source = 1,
		icon_id = "equipment_ticket" --79
	},
	{
		source = 1,
		icon_id = "equipment_files" --80
	},
	{
		source = 1,
		icon_id = "equipment_harddrive" --81
	},
	{
		source = 1,
		icon_id = "equipment_evidence" --82
	},
	{
		source = 1,
		icon_id = "equipment_chainsaw" --83
	},
	{
		source = 1,
		icon_id = "equipment_manifest" --84
	},
	{
		source = 1,
		icon_id = "equipment_fire_extinguisher" --85
	},
	{
		source = 1,
		icon_id = "equipment_winch_hook" --86
	},
	{
		source = 1,
		icon_id = "equipment_bottle" --87
	},
	{
		source = 1,
		icon_id = "equipment_sleeping_gas" --88
	},
	{
		source = 1,
		icon_id = "equipment_usb_with_data" --89
	},
	{
		source = 1,
		icon_id = "equipment_usb_no_data" --90
	},
	{
		source = 1,
		icon_id = "equipment_empty_cooling_bottle" --91
	},
	{
		source = 1,
		icon_id = "equipment_cooling_bottle" --92
	},
	{
		source = 1,
		icon_id = "equipment_bfd_tool" --93
	},
	{
		source = 1,
		icon_id = "equipment_elevator_key" --94
	},
	{
		source = 1,
		icon_id = "equipment_blow_torch" --95
	},
	{
		source = 1,
		icon_id = "equipment_printer_ink" --96
	},
	{
		source = 1,
		icon_id = "equipment_plates" --97
	},
	{
		source = 1,
		icon_id = "equipment_paper_roll" --98
	},
	{
		source = 1,
		icon_id = "equipment_key_chain" --99
	},
	{
		source = 1,
		icon_id = "equipment_hand" --100
	},
	{
		source = 1,
		icon_id = "equipment_briefcase" --101
	},
	{
		source = 1,
		icon_id = "equipment_soda" --102
	},
	{
		source = 1,
		icon_id = "equipment_chrome_mask" --103
	},
	{
		source = 1,
		icon_id = "equipment_born_tool" --104
	},
	{
		source = 1,
		icon_id = "equipment_liquid_nitrogen_canister" --105
	},
	{
		source = 1,
		icon_id = "equipment_medallion" --106
	},
	{
		source = 1,
		icon_id = "equipment_bloodvial" --107
	},
	{
		source = 1,
		icon_id = "equipment_bloodvialok" --108
	},
	{
		source = 1,
		icon_id = "equipment_chimichanga" --109
	},
	{
		source = 1,
		icon_id = "equipment_stapler" --110
	},
	{
		source = 1,
		icon_id = "equipment_compounda" --111
	},
	{
		source = 1,
		icon_id = "equipment_compoundb" --112
	},
	{
		source = 1,
		icon_id = "equipment_compoundc" --113
	},
	{
		source = 1,
		icon_id = "equipment_compoundd" --114
	},
	{
		source = 1,
		icon_id = "equipment_compoundok" --115
	},
	{
		source = 1,
		icon_id = "equipment_mayan_gold" --116
	},
	{
		source = 1,
		icon_id = "equipment_blueprint" --117
	},
	{
		source = 1,
		icon_id = "equipment_tape_fingerprint" --118
	},
	{
		source = 1,
		icon_id = "equipment_tape" --119
	},
	{
		source = 1,
		icon_id = "equipment_boltcutter" --120
	},
	{
		source = 1,
		icon_id = "equipment_policebadge" --121
	},
	{
		source = 1,
		icon_id = "equipment_flammable" --122
	},
	{
		source = 1,
		icon_id = "equipment_rfid_tag_01" --123
	},
	{
		source = 1,
		icon_id = "equipment_rfid_tag_02" --124
	},
	{
		source = 1,
		icon_id = "equipment_globe" --125
	},
	{
		source = 1,
		icon_id = "equipment_scythe" --126
	},
	{
		source = 1,
		icon_id = "equipment_electrical" --127
	},
	{
		source = 1,
		icon_id = "equipment_fertilizer" --128
	},
	{
		source = 1,
		icon_id = "equipment_timer" --129
	},
	{
		source = 1,
		icon_id = "equipment_documents" --130
	},
	{
		source = 1,
		icon_id = "equipment_syringe" --131
	},
	{
		source = 1,
		icon_id = "equipment_notepad" --132
	},
	{
		source = 1,
		icon_id = "equipment_cleaning_product" --133
	},
	{
		source = 1,
		icon_id = "equipment_defibrillator" --134
	},
	{
		source = 1,
		icon_id = "equipment_gas_canister" --135
	},
	{
		source = 1,
		icon_id = "equipment_businesscard" --136
	},
	{
		source = 1,
		icon_id = "equipment_car_jack" --137
	},
	{
		source = 1,
		icon_id = "equipment_cargo_strap" --138
	},
	{
		source = 1,
		icon_id = "equipment_audio_device" --139
	},
	{
		source = 1,
		icon_id = "equipment_laptop" --140
	},
	{
		source = 1,
		icon_id = "equipment_stock" --141
	},
	{
		source = 1,
		icon_id = "equipment_barrel" --142
	},
	{
		source = 1,
		icon_id = "equipment_receiver" --143
	},
	{
		source = 1,
		icon_id = "equipment_acid" --144
	},
	{
		source = 1,
		icon_id = "equipment_sheriff_star" --145
	},
	{
		source = 1,
		icon_id = "equipment_hammer" --146
	},
	{
		source = 1,
		icon_id = "equipment_silver_ingot" --147
	},
	{
		source = 1,
		icon_id = "equipment_mould" --148
	},
	{
		source = 1,
		icon_id = "equipment_muriatic_acid" --149
	},
	{
		source = 1,
		icon_id = "equipment_caustic_soda" --150
	},
	{
		source = 1,
		icon_id = "equipment_hydrogen_chloride" --151
	},
	{
		name = "qc_ps_circle", --152
		source = 2, --circle outline (ps button style)
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0,0,
			64,64
		}
	},
	{
		name = "qc_ps_square", --153
		source = 2, --square outline (ps button style)
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			1 * 64,0 * 64,
			64,64
		}
	},
	{
		name = "qc_ps_x", --154
		source = 2, --x (ps button style)
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			2 * 64,0 * 64,
			64,64
		}
	},
	{
		name = "qc_ps_triangle", --155
		source = 2, --triangle (ps button style)
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			3 * 64,0 * 64,
			64,64
		}
	},
	{
		name = "qc_numeral_1", --156
		source = 2, --number "1"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0 * 64,1 * 64,
			64,64
		}
	},
	{
		name = "qc_numeral_2", --157
		source = 2, --number "2"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0 * 64,1 * 64,
			64,64
		}
	},
	{
		name = "qc_numeral_3", --158
		source = 2, --number "3"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0 * 64,1 * 64,
			64,64
		}
	},
	{
		name = "qc_numeral_4", --159
		source = 2, --number "4"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0 * 64,1 * 64,
			64,64
		}
	},
	{
		name = "qc_letter_a", --160
		source = 2, --capital letter "A"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0 * 64,2 * 64,
			64,64
		}
	},
	{
		name = "qc_letter_b", --161
		source = 2, --capital letter "B"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			1 * 64,2 * 64,
			64,64
		}
	},
	{
		name = "qc_letter_c", --162
		source = 2, --capital letter "C"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			2 * 64,2 * 64,
			64,64
		}
	},
	{
		name = "qc_letter_d", --163
		source = 2, --capital letter "D"
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			3 * 64,2 * 64,
			64,64
		}
	},
	{
		name = "qc_loose_cash",  --164
		source = 2, -- single dollar bill icon
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			0 * 64,3 * 64,
			64,64
		}
	},
	{
		name = "qc_security_camera", --165
		source = 2, -- security camera icon
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			1 * 64,3 * 64,
			64,64
		}
	},
	{
		name = "qc_avoid",  --166
		source = 2, --"do not" symbol (circle bisected with diagonal line)
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			2 * 64,3 * 64,
			64,64
		}
	},
	{
		name = "qc_checkmark", --167
		source = 2, --checkmark symbol
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			3 * 64,3 * 64,
			64,64
		}
	},
	{
		source = 1, --infamy spade (the same one that gcw uses)
		icon_id = "infamy_icon_1" -- 168
	},
	{
		source = 1,
		icon_id = "equipment_first_aid_kit" --169
	},
	{
		source = 1,
		icon_id = "equipment_bodybags_bag" --170 
	},
	{
		source = 1,
		icon_id = "pd2_car" --171
	}
	--[[
	,
	{
		name = "qc_locked", --173
		source = 2, --checkmark symbol
		texture = "guis/textures/pd2/quickchatmod/waypoint_icons_atlas",
		texture_rect = {
			3 * 32,3 * 32,
			32,32
		}
	}
	--]]
}
QuickChat._icon_presets_by_name = {}
for index,data in ipairs(QuickChat._icon_presets_by_index) do
	QuickChat._icon_presets_by_name[data.name or data.icon_id] = index
end

QuickChat._label_presets_by_index = {
	"qc_wp_look",							--1
	"qc_wp_go",								--2
	"qc_wp_bag",							--3
	"qc_wp_kill",							--4
	"qc_wp_deploy",							--5
	"qc_wp_interact",						--6
	"qc_wp_defend",							--7
	"qc_wp_avoid"							--8
}
QuickChat._label_presets_by_name = {} -- reverse lookup table
for index,id in ipairs(QuickChat._label_presets_by_index) do 
	QuickChat._label_presets_by_name[id] = index
end

QuickChat._message_presets = {
	"qc_ptm_general_yes",					--1
	"qc_ptm_general_no",					--2
	"qc_ptm_general_cheer",					--3
	"qc_ptm_general_greeting",				--4
	"qc_ptm_general_thanks",				--5
	"qc_ptm_general_apology",				--6
	"qc_ptm_general_curse",					--7
	"qc_ptm_general_forgive",				--8
	"qc_ptm_general_acknowledged",			--9
	"qc_ptm_general_goodgame_normal",		--10
	"qc_ptm_general_goodgame_toxic",		--11
	"qc_ptm_general_bye",					--12
	"qc_ptm_general_brb",					--13
	"qc_ptm_general_nokeyboard",			--14
	"qc_ptm_general_leaving_soon",			--15
	"qc_ptm_general_leaving_last_game",		--16
	"qc_ptm_general_healembargo",			--17
	"qc_ptm_general_achievementhunting",	--18
	"qc_ptm_comms_claim",					--19
	"qc_ptm_comms_help",					--20
	"qc_ptm_comms_follow",					--21
	"qc_ptm_comms_attack",					--22
	"qc_ptm_comms_defend",					--23
	"qc_ptm_comms_regroup",					--24
	"qc_ptm_comms_reviving",				--25
	"qc_ptm_comms_comehere",				--26
	"qc_ptm_comms_caution",					--27
	"qc_ptm_comms_opening_door",			--28
	"qc_ptm_comms_jammed_drill",			--29
	"qc_ptm_comms_jammed_hack",				--30
	"qc_ptm_direction_left",				--31
	"qc_ptm_direction_right",				--32
	"qc_ptm_direction_up",					--33
	"qc_ptm_direction_down",				--34
	"qc_ptm_direction_forward",				--35
	"qc_ptm_direction_backward",			--36
	"qc_ptm_tactic_ask_stealth",			--37
	"qc_ptm_tactic_ask_hybrid",				--38
	"qc_ptm_tactic_ask_loud",				--39
	"qc_ptm_tactic_suggest_stealth",		--40
	"qc_ptm_tactic_suggest_hybrid",			--41
	"qc_ptm_tactic_suggest_loud",			--42
	"qc_ptm_need_docbag",					--43
	"qc_ptm_need_fak",						--44
	"qc_ptm_need_ammo",						--45
	"qc_ptm_need_ecm",						--46
	"qc_ptm_need_sentrygun",				--47
	"qc_ptm_need_sentrygun_silent",			--48
	"qc_ptm_need_tripmine",					--59
	"qc_ptm_need_shapedcharge",				--50
	"qc_ptm_need_bodybags",                 --51
	"qc_ptm_need_grenades",					--52
	"qc_ptm_need_convert",					--53
	"qc_ptm_need_ties",						--54
	"qc_ptm_enemy_sniper",					--55
	"qc_ptm_enemy_cloaker",					--56
	"qc_ptm_enemy_taser",					--57
	"qc_ptm_enemy_dozer",					--58
	"qc_ptm_enemy_medic",					--69
	"qc_ptm_enemy_shield",					--60
	"qc_ptm_enemy_msniper",					--61
	"qc_ptm_enemy_mshield",					--62
	"qc_ptm_enemy_winters",					--63
}
QuickChat._message_presets_by_name = {}
for i,name in ipairs(QuickChat._message_presets) do
	QuickChat._message_presets_by_name[name] = i
end

QuickChat._message_cooldowns = {} -- locally enforced chat rate limiter
QuickChat.TEXT_MESSAGE_COOLDOWN_COUNT = 3 -- maximum of three messages
QuickChat.TEXT_MESSAGE_COOLDOWN_INTERVAL = 2 -- each one has a cooldown of 2 seconds

QuickChat._language_data = {} -- cache for localization strings for each language;
-- note that the cache is dumped on state reload,
-- and the table is normally only populated with the selected language,
-- so this is just a buffer to prevent excessive io operations if the user is scrolling through the available languages

QuickChat._is_loc_loaded = false
QuickChat._loc_strings_load_queue = {
--[[ 
-- array containing string[]s waiting to be loaded once LocalizationManager is initialized
-- example: (note: FILO, so entries at the end are loaded first)
	{
		qc_lang_en = "English",
		qc_lang_es = "Spanish",
		qc_lang_fr = "French",
		qc_lang_cn = "Chinese (Simplified)",
		-- ... etc.
	},
	{
		qc_ptm_general_yes = "Yes",
		qc_ptm_general_no = "No",
		qc_ptm_general_greeting = "Hello!",
		qc_ptm_general_thanks = "Thanks!",
		qc_ptm_general_apology = "Sorry...",
		qc_ptm_general_curse = "$#@%!"
		-- ... etc.
	}
--]]
} -- note: table is set to nil after LocalizationManager is initialized, and is no longer used at that point

QuickChat._ping_sounds = { -- only played locally, controlled by local user settings
	bird = QuickChat._assets_path .. "sounds/bird.ogg",
	retro = QuickChat._assets_path .. "sounds/retro.ogg",
	scifi_1 = QuickChat._assets_path .. "sounds/scifi_1.ogg",
	scifi_2 = QuickChat._assets_path .. "sounds/scifi_2.ogg",
	scifi_3 = QuickChat._assets_path .. "sounds/scifi_3.ogg",
	whip = QuickChat._assets_path .. "sounds/whip.ogg",
	meme = QuickChat._assets_path .. "sounds/meme.ogg",
	chime_1 = QuickChat._assets_path .. "sounds/chime_1.ogg",
	chime_2 = QuickChat._assets_path .. "sounds/chime_2.ogg"
}

QuickChat._CUSTOM_RESOURCES = {
--[[
	["guis/textures/radial_menu/darklight"] = {
		file_ext = "png",
		resource_ext = "texture"
	},
	["guis/textures/radial_menu/highlight"] = {
		file_ext = "png",
		resource_ext = "texture"
	},
	--]]
	["guis/textures/radial_menu/foreground"] = {
		file_ext = "png",
		resource_ext = "texture"
	},
	["guis/textures/radial_menu/background"] = {
		file_ext = "png",
		resource_ext = "texture"
	},
	["guis/textures/radial_menu/cursor"] = {
		file_ext = "texture",
		resource_ext = "texture"
	},
	["guis/textures/pd2/quickchatmod/waypoint_icons_atlas"] = {
		file_ext = "texture",
		resource_ext = "texture"
	}
	--[[
,	["fonts/font_qc_glyphs"] = {
		file_ext = "texture",
		resource_ext = "texture"
	},
	["fonts/font_qc_glyphs"] = {
		file_ext = "texture",
		resource_ext = "texture"
	},
	["fonts/font_small_noshadow"] = {
		file_ext = "texture",
		resource_ext = "texture"
	}
	--]]
}

QuickChat.POSITIONAL_AUDIO_DISTANCE = 100 -- distance at which waypoint sfx will play 

QuickChat._radial_menus = {} --generated radial menus
QuickChat._radial_menu_params = {} --ungenerated radial menus; populated with user data

QuickChat._keybind_callbacks = {
	quick_ping = {
		callback_pressed = nil,
		callback_released = function(t,dt,action_data)
		--[[ -- todo give input_data to the callback func so that hold duration checking is possible
			if t - input_data.hold_start_t > 0.5 then --if held for longer than 0.5 seconds then
				-- do something?
				QuickChat:AddWaypoint({is_neutral_ping=false})
			else
				QuickChat:AddWaypoint({is_neutral_ping=true})
			end
			--]]
			QuickChat:AddWaypoint({is_neutral_ping=true})
		end,
		callback_held = nil
	},
	radial = {
		callback_pressed = function(t,dt,action_data)
			local radial_menu = QuickChat:GetRadialMenu(action_data.sub_type)
			if radial_menu then
				if not (QuickChat._last_menu and QuickChat._last_menu:IsActive()) then
		--			_G.Console:SetTracker(string.format("show %.1f",t),3)
					radial_menu:Show()
					QuickChat._last_menu = radial_menu
				end
			else
--				self:Log("No radial menu: " .. tostring(action_data.sub_type))
			end
		end,
		callback_released = function(t,dt,action_data)
			local radial_menu = QuickChat:GetRadialMenu(action_data.sub_type)
			if radial_menu then
				if QuickChat:IsGamepadModeEnabled() then 
					local player_unit = managers.player:local_player()
					if alive(player_unit) then
						local camera = player_unit:camera()
						local fpcamera_unit = camera and camera._camera_unit
						local fpcamera_base = fpcamera_unit and fpcamera_unit:base()
						if fpcamera_base then
							--fix for extrapolating camera movement from time when radial menu was open
							fpcamera_base._last_rot_t = nil
						end
					end
				end
				radial_menu:Hide(true)
			end
		end,
		callback_held = nil
	},
	waypoints_clear_own = {
		callback_pressed = function(t,dt,action_data)
			QuickChat:DisposeWaypoints(managers.network:session():local_peer():id())
		end,
		callback_released = nil,
		callback_held = nil,
	},
	waypoints_clear_all = {
		callback_pressed = function(t,dt,action_data)
			QuickChat:DisposeAllWaypoints()
		end,
		callback_released = nil,
		callback_held = nil,
	}
}

QuickChat._callback_bind_button = nil --dynamically set
QuickChat._updaters = {}
QuickChat._is_binding_listener_active = nil -- flag that blocks radial wheels from opening while binding window is active

QuickChat.MENU_IDS = {
	MENU_MAIN = "quickchat_menu_main",
	MENU_BINDS = "quickchat_menu_binds",
	MENU_SETTINGS = "quickchat_menu_settings"
}

QuickChat._populated_menus = {}
QuickChat._queued_menus = {}

QuickChat._input_cache = {}

QuickChat.allowed_binding_buttons = { --wrapper-specific bindings
	pc = {
		--potential buttons map is stored differently for keyboard, but should be unpacked into broadly the same format
		mouse_buttons = { --also stores mouse buttons since keyboard input scheme is also paired with mouse input
			"0","1","2","3","4","mouse wheel up","mouse wheel down"
		},
		buttons = { --the index of each these buttons as far as the controller is concerned is generally derived from its position on the keyboard, from left to right, then top to bottom (ie western book-reading order); eg. esc is 1, f1 is 2, f2 is 3, etc.
			--numbers
			"1","2","3","4","5","6","7","8","9","0",
			--letters
			"a","b","c","d","e","f","g","h","j","i","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
			--function key row
			"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",
			--punctuations and symbols
			"'","\\",",","=","`","[","-",".","]",";","/"," ",
			--arrow keys
			"up","down","left","right",
			--control keys
			"backspace","caps lock","delete","end","enter","esc","home","insert","left alt","left ctrl","left shift","left windows","page down","page up","right alt","right ctrl","right shift","right windows","scroll lock","sys rq","tab",
			--numpad
			"num 0","num 1","num 2","num 3","num 4","num 5","num 6","num 7","num 8","num 9","num lock","num ,","num enter","num =","num +","num .","num /","num -","num *",
			--application and media keys
			"applications","calculator","mail","media select","media stop","mute","my computer","next track","pause","play pause","power","prev track","sleep","volume up","volume down","wake","web back","web favorites","web forward","web home","web refresh","web search","web stop",
			--international keys
			"num abnt c1","num abnt c2","@","ax",":","convert","kana","kanji","no convert","oem 102","stop","_","unlabeled","yen"
		},
		axis = {} --no axes for keyboards; mouse axis input is handled separately
	},
	xbox360 = {
		buttons = {
			["d_up"] = "weapon_gadget",
			["d_down"] = "push_to_talk",
			["d_left"] = "left",
			["d_right"] = "right",
			["start"] = "start",
			["back"] = "back",
			["left_thumb"] = "run",
			["right_thumb"] = "melee",
			["left_shoulder"] = "use_item",
			["right_shoulder"] = "interact",
			["left_trigger"] = "trigger_left",
			["right_trigger"] = "trigger_right",
			["a"] = "confirm",
			["b"] = "cancel",
			["x"] = "reload",
			["y"] = "switch_weapon"
		},
		axis = {
			["left"] = "move",
			["right"] = "look",
			["dpad"] = "dpad" --no idea if this is correct!
		}
	},
	ps3 = {
		buttons = {
			["d_up"] = "weapon_gadget",
			["d_down"] = "push_to_talk",
			["d_left"] = "left",
			["d_right"] = "right",
			["start"] = "start",
			["back"] = "back",
			["left_thumb"] = "run",
			["right_thumb"] = "melee",
			["left_shoulder"] = "use_item",
			["right_shoulder"] = "interact",
			["left_trigger"] = "trigger_left",
			["right_trigger"] = "trigger_right",
			["cross"] = "confirm",
			["circle"] = "cancel",
			["square"] = "reload",
			["triangle"] = "switch_weapon"
		},
		axis = {
			["left"] = "move",
			["right"] = "look",
			["dpad"] = "dpad"
		}
	}
}
QuickChat.allowed_binding_buttons.ps4 = QuickChat.allowed_binding_buttons.ps3
QuickChat.allowed_binding_buttons.xb1 = QuickChat.allowed_binding_buttons.xbox360

QuickChat._allowed_binding_buttons = {}
QuickChat._allowed_binding_mouse_buttons = {} --just to hold mouse buttons!
--because this is the only case (that i know of) where multiple wrappers are naturally active at once

QuickChat._DEBUG_DRAW_DURATION = 5

--load dependencies/classes
do --load RadialMenu
	local f,e = blt.vm.loadfile(QuickChat._mod_path .. "req/RadialMenu.lua")
	if f then 
		QuickChat._radial_menu_manager = f()
		log("[QuickChat] RadialMenu loaded successfully.")
	else
		log("[QuickChat] Error loading RadialMenu.lua:")
		log(e)
	end
end
do --load Lua ini Parser
	local f,e = blt.vm.loadfile(QuickChat._mod_path .. "req/LIP.lua")
	if f then 
		QuickChat._lip = f()
		log("[QuickChat] LIP loaded successfully.")
	else
		log("[QuickChat] Error loading LIP.lua:")
		log(e)
	end
end

--init superblt XAudio
blt.xaudio.setup()

local mvec3_distance = mvector3.distance
local mvec3_dot = mvector3.dot
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
local mvec3_dot = mvector3.dot
local mvec3_normalize = mvector3.normalize
local mrot_y = mrotation.y

function QuickChat.to_int(n)
	local _n = n and tonumber(n)
	if _n then 
		return math.floor(_n)
	end
	return 0
end

function QuickChat.find_interactable(unit)
	if unit.interaction then 
		local interaction_ext = unit:interaction()
		if interaction_ext and not interaction_ext:disabled() and interaction_ext:active() then
			--look for any interactable object
			--not just any objects with an interaction extension- 
			--must be active and currently interactable
		
--				self:Log("active=" .. tostring(unit:interaction()._active) .. ",disabled=".. tostring(unit:interaction()._disabled))
			return unit,interaction_ext.tweak_data
		end
	end
end

function QuickChat.find_character(unit,no_recursion)
	if alive(unit) then
		if not no_recursion and unit:in_slot(8) and unit.parent and unit:parent() then 
			return QuickChat.find_character(unit:parent(),true)
		elseif unit.character_damage and unit:character_damage() then
			local unit_base = unit:base()
			local tweak_table = unit_base and unit_base._tweak_table
			return unit,tweak_table
--		elseif unit:parent() and alive(unit:parent():base()) and unit:parent():base().tweak_table then 
		end
	end
end

function QuickChat.get_unit_waypoint_position(unit,unit_object)
	local interaction_ext = unit:interaction()
	local is_interactable
	if interaction_ext then
		if interaction_ext:active() and not interaction_ext:disabled() then
			return interaction_ext:interact_position()
		end
	end
	
	local oobb
	if unit_object then
		oobb = unit_object:oobb()
	else
		oobb = unit:oobb()
	end
	if oobb then
		return oobb:center()
	end
	local movement_ext = unit:movement() 
	if movement_ext and movement_ext.m_pos then
		return movement_ext:m_pos()
	end
	return unit:position()
end

function QuickChat.mvector3_equals(a,b)
	--why yes i do hate myself why do you ask
	return tostring(a) == tostring(b)
end

-- copied from sblt
function QuickChat.serialize_vec3(vec)
	return string.format("%08f,%08f,%08f", v.x, v.y, v.z)
end

-- copied from sblt
function QuickChat.deserialize_vec3(s)
	local x, y, z = string.match(s,"([-0-9.]+),([-0-9.]+),([-0-9.]+)")
	x, y, z = tonumber(x), tonumber(y), tonumber(z)
	if x and y and z then
		return Vector3(x, y, z)
	end
end

function QuickChat.GetFiles(path,...)
	if FileIO then -- this is a beardlib util at BeardLib/Classes/Utils/FileIO
		return FileIO:GetFiles(path,...)
	end
	
	-- and this is the relevant function directly copied from there
	if SystemFS and SystemFS.list then
		return SystemFS:list(path)
	else
		return file.GetFiles(path)
	end
end

function QuickChat:AddLocStrings(tbl)
	if self._is_loc_loaded then
		managers.localization:add_localized_strings(tbl)
	else
		self._loc_strings_load_queue[#self._loc_strings_load_queue] = tbl
	end
end

function QuickChat:ChooseLanguage(lang_name)
	if lang_name then 
		self:Print("Using selected language:",lang_name)
		local lang_data = self._language_data[lang_name] 
		if lang_data then 
			if lang_data.strings then
				self:Print("Found lang data in cache.")
				self:AddLocStrings(lang_data.strings)
			elseif lang_data.path then 
				self:Print("No cached data for language.")
				self:LoadLanguageFile(lang_data.path)
			else
				-- unhandled case; should not occur
				self:Print("ChooseLanguage() Error: no strings/path in _language_data entry for lang:",lang_name)
			end
		else
			-- load language
			local path = self._l10n_path .. lang_name .. ".tsv"
			self:Print("ChooseLanguage() Language file unknown for language",lang_name,"...Guessing file path:",path)
			if not self:LoadLanguageFile(path) then
				local fallback_path = self._l10n_path .. self._DEFAULT_LANGUAGE_ID .. ".tsv"
				self:Print("ChooseLanguage() Language file guess failed. Using fallback",fallback_path)
				local success = self:LoadLanguageFile(fallback_path)
				self:Print("ChooseLanguage() Pass?",success)
			end
		end
	else
		self:Print("ChooseLanguage() invalid lang_name given:",lang_name)
	end
end

function QuickChat:LoadLanguageFile(path)
	self:Print("Loading localization file at:",path)
	if io.file_is_readable(path) then
		local lang_strings
		local success,e = blt.pcall(function()
			lang_strings = self.parse_l10n_csv(path)
		end)
		
		if success then
			self:AddLocStrings(lang_strings)
			return true
		else
			self:Print("Failed loading localization file:",path,e)
		end
	else
		self:Print("Could not read language file at:",path)
	end
	return false
end

-- browse the available language files in the l10n directory to populate the available language options
-- note: this also dumps the current language cache
function QuickChat:FindLanguageFiles()
	self:Log("Finding localization files...")
	local l10n_path = self._l10n_path
	local OPTIMIZE_MEMORY = self.settings._l10n_load_optimization ~= 2 -- technically should be == 1 but i want the default/fallback to be optimizing memory over load times if the setting does not exist
	
	local lang_names
	for _,filename in pairs(self.GetFiles(l10n_path)) do 
		--self:Print("loc file:",l10n_path,filename)
		local lang_rev = string.reverse(filename)
		local a,b = string.find(lang_rev,"%.")
		local ext = string.reverse(string.sub(lang_rev,1,a-1))
		local lang_name = string.reverse(string.sub(lang_rev,b+1))
		if ext == "tsv" and lang_name and lang_name ~= "" then
			self:Print("Found localization file:",lang_name,ext)
			
			local path = l10n_path .. filename
			local lang_strings
			
			local success,e = blt.pcall(function()
				lang_strings = self.parse_l10n_csv(path)
			end)
			if success then
				local lang_loc_id = "qc_lang_" .. lang_name
				local lang_name_localized = lang_strings.qc_this_language
				local lang_data = {
					path = path,
					lang_loc_id = lang_loc_id,
					lang_loc_name = lang_name_localized,
					strings = nil
				}
				if not OPTIMIZE_MEMORY then 
					lang_data.strings = lang_strings
				end
				lang_names = lang_names or {}
				lang_names[lang_loc_id] = lang_name_localized
				self._language_data[lang_name] = lang_data
			else
				self:Print("Failed loading loc file:",filename,e)
			end
		else
			self:Print("Invalid ext for localization file:",lang_name,ext)
		end
	end
	
	if lang_names then
		self:AddLocStrings(lang_names)
	end
end

-- deprecated; do not use
function QuickChat:LoadLanguageFiles()
	self:Log("Loading localization files...")
	local l10n_path = self._l10n_path
	for _,filename in pairs(self.GetFiles(l10n_path)) do 
		self:Print("loc file:",l10n_path,filename)
		local lang_rev = string.reverse(filename)
		local a,b = string.find(lang_rev,"%.")
		local ext = string.reverse(string.sub(lang_rev,1,a-1))
		if ext == "tsv" then
			local data
			local success,e = blt.pcall(function()
				data = self.parse_l10n_csv(l10n_path .. filename)
			end)
			if not success then
				self:Print("Could not load localization file:",filename,e)
			else
				local lang_name = string.reverse(string.sub(lang_rev,b+1))
				
				self._language_data[lang_name] = data
				self:AddLocStrings({
					["qc_lang_" .. lang_name] = data.qc_this_language
				})
			end
		else
			self:Print("Invalid localization format:",ext)
		end
	end
	self:Log("Done loading localization files.")
end

function QuickChat.parse_l10n_csv(path)
	local line_num = 0
	local lang_code
	local all_data = {}
	local file = io.open(path,"r+")

	for line in file:lines() do 
		line_num = line_num + 1
		local this_row = string.split(line,"\t")
		if line_num ~= 1 then
			for column=1,#this_row,1 do 
				local c_data = all_data[column]
				if c_data then
					table.insert(c_data,#c_data+1,this_row[column] or "")
				end
			end
		else
			for column=1,#this_row,1 do 
				all_data[column] = {}
			end
			lang_code = this_row[2]
		end
	end
	file:close()
	
	local num_lines = #all_data[1]
	
	local lang_data = {}
	for i=1,num_lines,1 do
		local loc_id = all_data[1][i]
		local loc_str = all_data[2][i]
		if loc_id and string.gsub(loc_id,"%s","") ~= "" then
			-- un-escape quotes and newlines
			lang_data[loc_id] = string.gsub(string.gsub(loc_str,"\\n","\n"),'\\"','"')
		end
	end
	return lang_data
end

function QuickChat._animate_grow(o,duration,speed,w,h,c_x,c_y)
	over(duration,function(p)
		local mul = 1.5-math.cos(p * 360 * speed) / 2
		o:set_size(w*mul,h*mul)
		o:set_center(c_x,c_y)
	end)
	o:set_size(w,h)
	o:set_center(c_x,c_y)
end

function QuickChat:GetIgnoreUnits(ignore_units)
	ignore_units = ignore_units or {}
	local session = managers.network:session()
	-- don't allow pinging teammates
	if session then
		for _,peer in pairs(session:peers()) do 
			local peer_unit = peer:unit()
			if alive(peer_unit) then
				table.insert(ignore_units,#ignore_units+1,peer_unit)
			end
		end
	end
	
	return ignore_units
end

function QuickChat:stylize_translated_message(s)
	return string.format(self._MESSAGE_PRESET_FORMAT,s)
end

function QuickChat:Log(msg)
	if self:IsDebugLoggingEnabled() then
		if Console then
			Console:Log(msg)
		else
			log(tostring(msg))
		end
	end
end

function QuickChat:Print(...)
	if self:IsDebugLoggingEnabled() then
		if Console then
			Console:Print(...)
		else
			log(...)
		end
	end
end

function QuickChat:GetMaxNumWaypoints()
	return 1 --self.settings.waypoints_max_count
end

function QuickChat:GetIconDataByIndex(icon_index)
	if icon_index then
		local icon_data = self._icon_presets_by_index[icon_index]
		if icon_data then
			if icon_data.source == 1 then
				return tweak_data.hud_icons:get_icon_data(icon_data.icon_id)
			elseif icon_data.source == 2 then
				return icon_data.texture,icon_data.texture_rect
			end
		end
	end
end

function QuickChat:GetIconIndexFromInteractionId(interaction_id)
	--[[
	local interaction_ext = alive(unit) and unit:interaction()
	if interaction_ext and interaction_ext._special_equipment then
		local equipment_td = tweak_data.equipment.specials[interaction_ext._special_equipment]
		local icon = equipment_td and equipment_td.icon
		icon_index = icon and self._icon_presets_by_name[icon]
		if icon_index then
			return icon_index
		end
	end
	--]]
	
	local icon_index = self:GetIconIndexFromId(self._INTERACTION_ICONS[interaction_id])
	if icon_index then
		return icon_index
	end
	local interaction_td = interaction_id and tweak_data.interaction[interaction_id]
	if interaction_td and interaction_td.is_lockpicking then
		return self:GetIconIndexFromId("equipment_key_chain" or "qc_wp_locked")
	end
	
	return self:GetIconIndexFromId("pd2_generic_interact")
end

function QuickChat:GetIconIndexFromId(icon_id)
	return icon_id and self._icon_presets_by_name[icon_id]
end

function QuickChat:GetIconDataByName(name)
	local icon_index = name and self._icon_presets_by_name[name]
	return self:GetIconDataByIndex(icon_index)
end

-- near aim threshold for detecting pinging an existing waypoint
function QuickChat:GetWaypointAimDotThreshold()
	return self.settings.waypoints_aim_dot_threshold
end	

function QuickChat:GetWaypointAttenuateDotThreshold()
	return self.settings.waypoints_attenuate_dot_threshold
end

function QuickChat:GetWaypointAttenuateAlphaMin()
	return self.settings.waypoints_attenuate_alpha_min
end

function QuickChat:GetWaypointAttenuateAlphaMode()
	return self.settings.waypoints_attenuate_alpha_mode
end

function QuickChat:IsWaypointSfxEnabled()
	return self.settings.waypoints_ping_sound_enabled
end
function QuickChat:GetWaypointSfxId()
	return self.settings.waypoints_ping_sound_id
end
function QuickChat:GetWaypointSfxVolume()
	return self.settings.waypoints_ping_sound_volume
end

function QuickChat:IsAcknowledgedSfxEnabled()
	return self.settings.waypoints_acknowledge_sound_enabled
end
function QuickChat:GetAcknowledgedSfxId()
	return self.settings.waypoints_acknowledge_sound_id
end
function QuickChat:GetAcknowledgedSfxVolume()
	return self.settings.waypoints_acknowledge_sound_volume
end

function QuickChat:IsUnacknowledgedSfxEnabled()
	return self.settings.waypoints_unacknowledge_sound_enabled
end
function QuickChat:GetUnacknowledgedSfxId()
	return self.settings.waypoints_unacknowledge_sound_id
end
function QuickChat:GetUnacknowledgedSfxVolume()
	return self.settings.waypoints_unacknowledge_sound_volume
end

function QuickChat:IsWaypointRegistrationAlertEnabled()
	return self.settings.waypoints_alert_on_registration
end

function QuickChat:GetRadialDeadzone()
	return self.settings.radial_deadzone
end

function QuickChat:GetRadialSize()
	return self.settings.radial_size
end

function QuickChat:IsGCWCompatibilityReceiveEnabled()
	return self.settings.compatibility_gcw_enabled
end

function QuickChat:IsGCWCompatibilitySendEnabled()
	return self.settings.compatibility_gcw_enabled
end

function QuickChat:IsWaypointAutoIconEnabled()
	return self.settings.waypoints_auto_icon
end

-- if true, converts pings on non-interactable units (which would not be applicable for GCW "Attach" type waypoints) into static gcw position waypoints; this only applies to what is sent to the gcw user, not to the local user
function QuickChat:UseGCWUnitPingResolution()
	return true
end

function QuickChat:IsDebugLoggingEnabled()
	return self.settings.debug_logs
end

function QuickChat:IsDebugDrawEnabled()
	return self.settings.debug_draw
end

-- Asset loading
function QuickChat:CheckResourcesAdded(skip_load)
	local assets_path = self._assets_path
	
	-- cache idstrings of extensions for perf; 
	-- won't make a huge difference, but it's good to do in case this mod ends up using a lot of custom assets
	local type_ids = {
		--[[
		texture = Idstring("texture")
		--]]
	}
	for path,data in pairs(self._CUSTOM_RESOURCES) do 
		local ids_resource_ext = type_ids[data.resource_ext]
		if not ids_resource_ext then
			ids_resource_ext = Idstring(data.resource_ext)
			type_ids[data.resource_ext] = ids_resource_ext
		end
		if DB and DB:has(ids_resource_ext, path) then 
			-- resource is already in the asset db
		else
			if not skip_load then 
				local full_asset_path = assets_path .. path
				self:Print("Adding asset...",full_asset_path,"as",path)
				BLT.AssetManager:CreateEntry(Idstring(path),ids_resource_ext,full_asset_path .. "." .. data.file_ext)
			end
		end
	end
end

function QuickChat:CheckResourcesReady(skip_load,done_loading_cb)
	self:Log("[QuickChat] Checking assets...")
	local assets_path = self._assets_path
	local dyn_pkg = DynamicResourceManager.DYN_RESOURCES_PACKAGE

	if done_loading_cb and done_loading_cb ~= false then 
		done_loading_cb = function(done,resource_type_ids,resource_ids)
			if done then 
				self:Print("Completed manual asset loading for",resource_ids)
			end
		end
		
	end
	
	local type_ids = {
		--[[
		texture = Idstring("texture")
		--]]
	}
	
	local resources_ready = true
	for path,data in pairs(self._CUSTOM_RESOURCES) do 
		local ids_path = Idstring(path)
		local ids_resource_ext = type_ids[data.resource_ext]
		if not ids_resource_ext then
			ids_resource_ext = Idstring(data.resource_ext)
			type_ids[data.resource_ext] = ids_resource_ext
		end
		
		if not managers.dyn_resource:is_resource_ready(ids_resource_ext,ids_path,dyn_pkg) then 
			if not skip_load then 
				self:Print("Creating DB entry for",data.resource_ext,path,data.file_ext)
				managers.dyn_resource:load(ids_resource_ext,ids_path,dyn_pkg,done_loading_cb)
			end
			self:Print("Resource is not ready:",path,data.file_ext,(skip_load and "...Skipped loading." or "...Started manual load."))
			resources_ready = false
		else
			self:Print("Resource is ready:",data.resource_ext,path,data.file_ext)
		end
	end
	return resources_ready
end

function QuickChat:GetUserLanguage()
	return self.settings.user_language
end

--Setup

function QuickChat:Setup() --on game setup complete
	
	self._waypoint_target_slotmask = World:make_slot_mask(unpack(self.WAYPOINT_TARGET_CAST_TYPES))
	
	self:PopulateInputCache()
	self:PopulateActions()
	if managers.hud then
		local ws = managers.hud._saferect
		self._ws = ws
		local ws_panel = ws:panel()
		self._parent_panel = ws_panel:panel({
			name = "quickchat_parent_panel",
			valign = "grow",
			halign = "grow",
			layer = 4
		})
	end
	self:AddUpdater("QuickChat_UpdateInGame",callback(self,self,"UpdateGame"),false)
end

function QuickChat:LoadCustomRadials() --read radial files from qc and user saves, load them as possibly bindable radials
	local file_util = _G.file
	if self._lip then
		local directory_exists = file_util.DirectoryExists
		local file_exists = file_util.FileExists
		local get_files = self.GetFiles 
		
		local function make_dir(path)
			if SystemFS and SystemFS.make_dir then
				local p
				for _, s in pairs(string.split(path, "/")) do
					p = p and p .. "/" .. s  or s
					if not directory_exists(p) then
						SystemFS:make_dir(p)
					end
				end
			else
				os.execute(string.format("mkdir \"%s\"", path))
			end
		end
		
		--load default layouts (built-in) first
		local default_layouts_path = self._mod_path .. "layouts/"
		local files = get_files(default_layouts_path)
		for _,filename in pairs(files) do 
			local ext = string.sub(filename,-4)
			if ext == ".ini" then
				--check if get_files is alphabetized
				local ini_data = self._lip.load(default_layouts_path .. filename)
				local radial_id,new_radial_data = self:LoadMenuFromIni(ini_data)
				if new_radial_data then
					radial_id = radial_id or string.sub(filename,1,-5)
					self._radial_menu_params[radial_id] = new_radial_data
				end
			end
		end
		
		--load custom layouts last so that they can overwrite existing defaults
		local custom_layouts_path = self._save_layouts_path
		if not directory_exists(custom_layouts_path) then 
			make_dir(custom_layouts_path)
		end
		
		local files = get_files(custom_layouts_path)
		for _,filename in pairs(files) do 
			local ext = string.sub(filename,-4)
			if ext == ".ini" then
				local ini_data = self._lip.load(custom_layouts_path .. filename)
				local radial_id,new_radial_data = self:LoadMenuFromIni(ini_data)
				if new_radial_data then
					radial_id = radial_id or string.sub(filename,1,-5)
					self._radial_menu_params[radial_id] = new_radial_data
				end
			end
		end
	end
end

function QuickChat:ClearInputCache()
	for button_name_ids,input_data in pairs(self._input_cache) do
		self._input_cache[button_name_ids] = nil
	end
end

function QuickChat:CloseAllRadialMenus()
	for radial_id,radial_menu in pairs(self._radial_menus) do 
		if radial_menu:IsActive() then
			radial_menu:Hide(false) --do not activate "confirm" callback
		end
	end
end

function QuickChat:PopulateInputCache() -- register active keybinds for the updater to detect and check the input state for
	--for each button,
		--register button data to the button in the input cache
	
	for _,bind_data in pairs(self._bindings) do 
		local button_name = bind_data.button_name
		local button_name_ids = Idstring(button_name)
		local is_mouse_button = bind_data.is_mouse_button
		local action_data = bind_data.action_data
		if action_data then
			local action_type = action_data.action_type
			local sub_type = action_data.sub_type
			
			local callback_pressed,callback_released,callback_held = self:GetBindingCallbacks(action_data)

			local new_input_data = {
				state = false, --start un-pressed
				button_name = button_name,
				is_mouse_button = is_mouse_button,
				action_data = {
					action_type = action_type,
					sub_type = sub_type
				},
				callback_pressed = callback_pressed,
				callback_released = callback_released,
				callback_held = callback_held
			}
			self._input_cache[button_name_ids] = self._input_cache[button_name_ids] or {}
			if is_mouse_button then
				self._input_cache[button_name_ids].mouse = new_input_data
			else
				self._input_cache[button_name_ids].default = new_input_data
			end
		else
			--self:Log("No action data defined for this bind! " .. tostring(button_name))
		end
	end
end

function QuickChat:PopulateActions() -- generate radials and other actions for their keybinds
	--for each button,
		--if the button is bound to a radial menu,
			--if the radial menu does not exist, create it
		--else, if the button has a different callback type,
			--then assign the callback(s) to that button data
			
	for _,bind_data in pairs(self._bindings) do 
		local button_name = bind_data.button_name
		local button_name_ids = Idstring(button_name)
		local is_mouse_button = bind_data.is_mouse_button
		local action_data = bind_data.action_data
		if action_data then
			local action_type = action_data.action_type
			local sub_type = action_data.sub_type
			if action_type == "radial" then
				local radial_id = sub_type
				if radial_id then
					local radial_menu = self._radial_menus[radial_id]
					if radial_menu then
						radial_menu:Remove()
						radial_menu = nil
					end
					
					local radial_menu_params = self._radial_menu_params[radial_id]
					if radial_menu_params then
						radial_menu = self._radial_menu_manager:NewMenu(radial_menu_params)
					end
					if radial_menu then
						self._radial_menus[radial_id] = radial_menu
					else
						self:Log("PopulateInputCache(): Error creating menu: " .. tostring(radial_id))
					end
				end
			else
				--other action type
			end
		else
			self:Log("No action data defined for this bind! " .. tostring(button_name))
		end
	end
end

function QuickChat:GetBindingCallbacks(action_data)
	local callback_pressed = false
	local callback_released = false
	local callback_held = false
	
	local action_type = action_data.action_type
	local callbacks = action_type and self._keybind_callbacks[action_type]
	if callbacks then
		if callbacks.callback_pressed then
			callback_pressed = callbacks.callback_pressed
		end
		if callbacks.callback_released then
			callback_released = callbacks.callback_released
		end
		if callbacks.callback_held then
			callback_held = callbacks.callback_held
		end
	end
	return callback_pressed,callback_released,callback_held
end

-- called when localization has changed and text needs to be refreshed
function QuickChat:OnLocalizationChanged()
	if not managers.localization then
		return
	end
	
	-- update radials with new localization
	QuickChat:LoadCustomRadials()
	QuickChat:PopulateInputCache()
	QuickChat:PopulateActions()
	
	for peer_id,waypoint_data in pairs(self._synced_waypoints) do 
		for waypoint_index,waypoint in pairs(waypoint_data) do 
			local panel = waypoint.panel
			if alive(panel) then
				if waypoint.creation_data and waypoint.creation_data.label_index then 
					local label_id = self._label_presets_by_index[waypoint.creation_data.label_index]
					local label_text = label_id and managers.localization:text(label_id)
					if label_text then
						panel:child("label"):set_text(label_text)
					end
				end
			end
			-- panel:child("desc"):set_text("here's where i'd put a desc... IF I HAD ONE")
			--this is not necessary since the desc only holds timer or distance, which are numbers that don't need localization (afaik)
		end
	end
	
	-- todo change chat messages? probably not feasible
	-- todo change menu buttons? those don't seem to refresh when the rest of the menu items do
end

--Keybind and Input Management

function QuickChat:BindButtonToRadial(button_name,is_mouse_button,radial_id)
	local action_data = {
		action_type = "radial",
		sub_type = radial_id
	}
	
	return self:BindButtonData(button_name,is_mouse_button,action_data)
end

function QuickChat:BindButtonData(button_name,is_mouse_button,action_data)
	--unbind the button if it is already bound
	self:UnbindButton(button_name,is_mouse_button,true)
	--skip clear cache
	--since we need to repopulate input cache after adding new bind anyway
	
	local new_bind_data = {
		button_name = button_name,
		is_mouse_button = is_mouse_button,
		action_data = action_data
	}
	
	table.insert(self._bindings,new_bind_data)
	
	self:PopulateInputCache()
	self:PopulateActions()
end

function QuickChat:UnbindButton(button_name,is_mouse_button,skip_clear_cache)
	local done_any = false
	if button_name then
		for i=#self._bindings,1,-1 do 
			local bind_data = self._bindings[i]
			if button_name == bind_data.button_name then
				if (not not is_mouse_button) == (not not bind_data.is_mouse_button) then
					done_any = true
					table.remove(self._bindings,i)
				end
			end
		end
	end
	if done_any and not skip_clear_cache then
		self:ClearInputCache()
	end
	return done_any
end

function QuickChat:GetBindDataByButton(button_name,is_mouse_button)
	if button_name then
		for i,bind_data in pairs(self._bindings) do 
			if bind_data.button_name == button_name then
				if (not not is_mouse_button) == (not not bind_data.is_mouse_button) then
					return bind_data,i
				end
			end
		end
	end
end

function QuickChat:GetBindDataByAction(action_type,sub_type)
	for i,bind_data in pairs(self._bindings) do 
		local action_data = bind_data.action_data
		if action_data.action_type == action_type and action_data.sub_type == sub_type then
			return bind_data,i
		end
	end
end

function QuickChat:GetButtonByAction(action_type,sub_type)
	for i,bind_data in pairs(self._bindings) do 
		local action_data = bind_data.action_data
		if action_data.action_type == action_type and action_data.sub_type == sub_type then
			return bind_data.button_name,bind_data.is_mouse_button and true or false
		end
	end
end

function QuickChat:GetButtonDisplayName(button_name,is_mouse_button) --only used for distinguishing mouse buttons in the menu atm
	if is_mouse_button then
		if string.find(button_name,"mouse") then
			return button_name
		else
			return string.format("mouse %s",button_name)
		end
	else
		return button_name
	end
end

function QuickChat:GetActionDisplayName(action_type,sub_type)
	if action_type == "radial" then
		return sub_type
	else
		return action_type
	end
end

function QuickChat:IsGamepadModeEnabled()
	return managers.controller and managers.controller:get_default_wrapper_type() ~= "pc"
end

function QuickChat:UnpackGamepadBindings()
	local wrapper_type = managers.controller:get_default_wrapper_type()
	local allowed_wrapper_bindings = self.allowed_binding_buttons[wrapper_type]
	if allowed_wrapper_bindings then 
		local allowed_wrapper_buttons = allowed_wrapper_bindings.buttons
		
		if wrapper_type == "pc" then 
			for button_index,controllerbutton in ipairs(allowed_wrapper_buttons) do
				QuickChat._allowed_binding_buttons[Idstring(controllerbutton):key()] = controllerbutton
			end
			if allowed_wrapper_bindings.mouse_buttons then
				for button_index,controllerbutton in ipairs(allowed_wrapper_bindings.mouse_buttons) do 
					QuickChat._allowed_binding_mouse_buttons[Idstring(controllerbutton):key()] = controllerbutton
				end
			end
		else
			for controllerbutton,wrapperbutton in pairs(allowed_wrapper_buttons) do
				QuickChat._allowed_binding_buttons[Idstring(controllerbutton):key()] = controllerbutton
			end
		end
	end
end

function QuickChat:GetController()
	local controller
	if self:IsGamepadModeEnabled() then 
		local cm = managers.controller
		--get_start_pressed_controller_index
		local index = Global.controller_manager.default_wrapper_index or cm:get_preferred_default_wrapper_index()
		
		local controller_index = cm._wrapper_to_controller_list[index][1]
		controller = Input:controller(controller_index)
		--[[
		local player_unit = managers.player and managers.player:local_player()
		local wrapper = managers.system_menu:_get_controller()
		if alive(player_unit) then 
			local state = player_unit:movement():current_state()
			wrapper = state._controller or wrapper
		end
		local wrapper_index = wrapper and wrapper._id
--		local controller_index = wrapper_index and managers.controller._wrapper_to_controller_list[wrapper_index]
		controller = wrapper_index and Input:controller(wrapper_index)
		--]]
	else
		controller = Input:keyboard()
	end
	return controller
end

--Radial Menu Management

function QuickChat:LoadMenuFromIni(ini_data) --converts and validates saved data from ini format into a table ready to be passed to the radial menu constructor
	if ini_data then
		local new_menu_params = {
			items = {}
		}
		
		local basic_body_values = {
			"id",
			"size",
			"deadzone",
			"focus_alpha",
			"unfocus_alpha",
			"item_margin",
			"item_text_visible",
			"animate_open_duration",
			"animate_open_size_mul",
			"animate_focus_grow_size",
			"animate_focus_duration",
			"mouseover_text_visible",
			"reset_mouse_position_on_show"
			--"default_mouseover_text"
		}
		local basic_item_values = {
			"mouseover_text",
			"keep_open",
			"font",
			"font_size"
		}
		
		local body = ini_data.RadialMenu
		local id = body.id
		local default_menu_data = {
			size = self:GetRadialSize(),
			deadzone = self:GetRadialDeadzone(),
			focus_alpha = 1,
			unfocus_alpha = 0.5,
			item_margin = 0.2,
			item_text_visible=true,
			animate_open_duration = 0.25,
			animate_open_size_mul = 0.1,
			animate_focus_grow_size = 1.66,
			animate_focus_duration = 0.33,
			mouseover_text_visible=true,
			reset_mouse_position_on_show=true,
			--default_mouseover_text = nil
			texture_highlight="guis/textures/radial_menu/foreground",
			texture_darklight="guis/textures/radial_menu/background",
			texture_cursor="guis/textures/radial_menu/cursor"
			
		} --self._radial_menu_params.default
		
		if body then
			
			for _,key in pairs(basic_body_values) do 
				if body[key] ~= nil then 
					new_menu_params[key] = body[key]
				else
					new_menu_params[key] = default_menu_data[key]
				end
			end
			
			if body.ping_as_default then 
--				new_menu_params.callback_on_cancelled = callback(self,self,"AddWaypoint")
				new_menu_params.callback_on_cancelled = function()
					local success,err = blt.pcall(
						function()
							self:AddWaypoint({
								is_neutral_ping = true
							})
						end
					)
					if not success then
						self:Log(err)
					end
				end
				
			end
			
			if body.default_mouseover_text then
				new_menu_params.default_mouseover_text = managers.localization:text(body.default_mouseover_text)
			end
			
			new_menu_params.texture_highlight = body.texture_highlight or default_menu_data.texture_highlight
			new_menu_params.texture_darklight = body.texture_darklight or default_menu_data.texture_darklight
			new_menu_params.texture_cursor = body.texture_cursor or default_menu_data.texture_cursor
			
			for i,item_data in ipairs(ini_data) do 
				
				local preset_text_index -- send pretranslated chat message
				local text_message -- send custom chat message
				local voice = item_data.voice -- player voiceline
				local gesture = item_data.gesture -- player fp animation
				local waypoint = item_data.waypoint -- if true, place waypoint
				local timer = item_data.timer and tonumber(item_data.timer) -- countdown timer for waypoint
				local icon_index -- used for waypoints
				local label_index -- used for waypoints
				
				local new_item = {
					userdata = nil, -- gets set later
					mouseover_text = nil -- gets set later
				}
				
				if item_data.icon and self._icon_presets_by_name[item_data.icon] then
					local texture,texture_rect = self:GetIconDataByName(item_data.icon)
					new_item.texture = texture
					new_item.texture_rect = texture_rect
					
					icon_index = self._icon_presets_by_name[item_data.icon]
				elseif item_data.icon_index and self._icon_presets_by_index[item_data.icon_index] then
					local texture,texture_rect = self:GetIconDataByIndex(item_data.icon_index)
					new_item.texture = texture
					new_item.texture_rect = texture_rect
					
					icon_index = item_data.icon_index
				elseif item_data.texture then
					new_item.texture = item_data.texture
					if item_data.texture_rect then 
						new_item.texture_rect = string.split(item_data.texture_rect,",")
					end
				end
				
				if item_data.preset_text_index and self._message_presets[item_data.preset_text_index] then
					preset_text_index = item_data.preset_text_index
				elseif item_data.preset_text then
					local message_preset_index = item_data.preset_text and self._message_presets_by_name[item_data.preset_text]
					if message_preset_index and self._message_presets[message_preset_index] then
						preset_text_index = message_preset_index
					end
				end
				
				if item_data.preview_text then --not localized
					new_item.text = item_data.preview_text
				elseif item_data.text then 
					new_item.text = item_data.text
					text_message = item_data.text
				elseif item_data.text_id then
					-- localized but not used for waypoint
					new_item.text = managers.localization:text(item_data.text_id)
				elseif body.use_preset_as_radial_label and item_data.preset_text then
					new_item.text = managers.localization:text(item_data.preset_text)
				end
				
				if item_data.label_id then
					new_item.text = new_item.text or managers.localization:text(item_data.label_id)
					label_index = self._label_presets_by_name[item_data.label_id]
				elseif item_data.label_index then
					local label = self._label_presets_by_index[item_data.label_index]
					new_item.text = new_item.text or (label and managers.localization:text(label))
					label_index = item_data.label_index
				end
				
				if item_data.color then 
					local color
					if string.find(item_data.color,",") then
						local col_tbl = string.split(item_data.color,",")
						color = Color(unpack(col_tbl))
					else
						color = Color(item_data.color)
					end
					if color then 
						new_item.color = color
					end
				end
				
				local userdata = {
					-- expected fields (all optional):
					preset_text_index = preset_text_index, -- int; checked before text
					text_message = text_message, -- string; used if preset_text_index is not valid
					
					voice = voice, -- string
					gesture = gesture, -- string
					
					waypoint = waypoint, -- bool
					timer = timer, -- float; only used if waypoint is true
					label_index = label_index, -- int
					icon_index = icon_index -- int
				}
				new_item.user_data = userdata
				new_item.mouseover_text = preset_text_index and managers.localization:text(self._message_presets[preset_text_index]) or nil
				
				
				if false and item_data.custom_callback then -- i don't like executing random code from shared radial files actually
					local f,e = loadstring(custom_callback)
					if f then 
						new_item.callback = f
					else
						--error
	--					log(e)
					end
				else
					new_item.callback = callback(self,self,"CallbackRadialSelection",userdata)
				end
				
				for _,key in pairs(basic_item_values) do 
					if item_data[key] ~= nil then 
						new_item[key] = item_data[key]
					end
				end
				new_menu_params.items[i] = new_item
			end
			
		end
		return id,new_menu_params
	end
end

function QuickChat:GetRadialMenu(id)
	return id and self._radial_menus[id]
end

function QuickChat:ToggleMenu(id)
	local menu = id and self._radial_menus[id]
	if menu then 
		menu:Toggle()
	end
end

function QuickChat:CallbackRadialSelection(userdata) --callback for selecting a radial option

	if userdata.waypoint then
		--do not perform other callback actions if waypoint placement fails
		local success = self:AddWaypoint({
			icon_index = userdata.icon_index,
			label_index = userdata.label_index,
			timer = userdata.timer
		}) 
		if not success then
			--todo feedback here
			return
		end
	end
	
	if userdata.voice then
		self:PlayCriminalSound(userdata.voice)
	end
	
	if userdata.gesture then
		self:PlayGesture(userdata.gesture)
	end
	
	if userdata.preset_text_index then 
		self:SendPresetMessage(userdata.preset_text_index)
	elseif userdata.text_message then
		self:SendChatToAll(userdata.text_message)
	end
end

--Waypoints

local tmp_camfrom_vec3 = Vector3()
local tmp_camto_vec3 = Vector3()
function QuickChat:AddWaypoint(params) --called whenever local player attempts to create a new waypoint
	if GameStateFilters.any_end_game[game_state_machine:current_state_name()] then
		return
	end
	local viewport_cam = managers.viewport:get_current_camera()
	if not viewport_cam then 
		--doesn't typically happen, usually for only a brief moment when all four players go into custody
		return
	end
	local debug_draw_enabled = self:IsDebugDrawEnabled()
	local debug_draw_duration = self._DEBUG_DRAW_DURATION
	local session = managers.network:session()
	if not session then return end
	local peer_id = session:local_peer():id()
	params = params or {}
	local is_neutral_ping = params.is_neutral_ping
	local is_auto_icon = is_neutral_ping and self:IsWaypointAutoIconEnabled()
	
	local dot_aim_threshold = self:GetWaypointAimDotThreshold()
	local aimed_index,aimed_peerid,aimed_wp_data = self:GetAimedWaypoint(true,dot_aim_threshold,"all",nil)
	if aimed_index then
		if aimed_peerid == peer_id then
			self:RemoveWaypoint(aimed_index)
			if is_neutral_ping then
				-- if quick press,
				-- then "dismiss" the waypoint, 
				-- stop here and don't replace it with a new one
				return
			end
		else
			if is_neutral_ping then
				-- if quick press,
				-- then acknowledge the waypoint,
				-- stop here and don't replace it with a new one
				self:AcknowledgeWaypoint(aimed_peerid,aimed_index)
				return
			end
		end
	end
	
	mvec3_set(tmp_camfrom_vec3,viewport_cam:position())
	mvec3_set(tmp_camto_vec3,viewport_cam:rotation():y())
	
	local ignore_units = self:GetIgnoreUnits()
	if game_state_machine and game_state_machine:current_state_name() == "ingame_access_camera" then
		-- allow pinging through cameras
		local state = game_state_machine:current_state()
		if state._last_access_camera and state._last_access_camera:has_camera_unit() then
			table.insert(ignore_units,1,state._last_access_camera:camera_unit())
		end
	end
	
	mvec3_mul(tmp_camto_vec3,self.WAYPOINT_RAYCAST_DISTANCE)
	mvec3_add(tmp_camto_vec3,tmp_camfrom_vec3)
	
	local raycast = World:raycast("ray",tmp_camfrom_vec3,tmp_camto_vec3,"slot_mask",self._waypoint_target_slotmask,"ignore_unit",ignore_units) or {}
	if raycast and raycast.position then
		if debug_draw_enabled then
			local brush = Draw:brush(Color.red:with_alpha(0.66),debug_draw_duration)
			brush:line(tmp_camfrom_vec3,raycast.position,10)
		end
		local position = raycast.position
		local unit_result,interaction_tweak_id,unit_tweak_id
		local unit = raycast.unit
		local end_t
		if params.timer and params.timer > 0 then
			end_t = TimerManager:game():time() + params.timer
		end
		local label_index = 0
		if params.label_index then
			label_index = params.label_index or label_index
		elseif params.label_id then
			label_index = self._label_presets_by_name[params.label_id] or label_index
		end
		local label_text -- non-localized, non-synced direct label text, for edge cases and enemy unit names
		local icon_index = 0
		local is_interaction
		
		local find_interactable = self.find_interactable
		local find_character = self.find_character
		
		if unit then
			if unit and alive(unit) then 
				unit_result,unit_tweak_id = find_character(unit,false) 
				if not unit_result then
					unit_tweak_id = nil
					unit_result,interaction_tweak_id = find_interactable(unit)
					is_interaction = unit_result and true or false
				end
				
				if debug_draw_enabled then
					local oobb = unit:oobb()
					if oobb and BeardLib then
						BeardLib:AddUpdater("qc_debug_draw",function(t,dt)
							Draw:brush(Color.red:with_alpha(0.66)):sphere(raycast.position,self.WAYPOINT_SECONDARY_CAST_RADIUS)
							debug_draw_duration = debug_draw_duration - dt
							if alive(unit) then
								--todo draw head or other object here
								if debug_draw_duration <= 0 then
									BeardLib:RemoveUpdater("qc_debug_draw")
								else
									local _oobb = unit:oobb()
									if _oobb then
										_oobb:debug_draw(0,0,1)
										Draw:brush(Color.blue:with_alpha(0.66)):sphere(_oobb:center(),10)
									end
									
									local interaction_ext = unit:interaction()
									if interaction_ext then
										Draw:brush(Color.green:with_alpha(0.66)):sphere(interaction_ext:interact_position(),10)
									end
								end
							else
								BeardLib:RemoveUpdater("qc_debug_draw")
							end
						end)
					end
				end
				
			end
		end
		
		if not unit_result then
			--do secondary sphere cast to catch interactables specifically
			local spherecast = World:find_units_quick("sphere",position,self.WAYPOINT_SECONDARY_CAST_RADIUS,self._waypoint_target_slotmask,"ignore_unit",self:GetIgnoreUnits())
			local tmp_unit_result
			for _,_unit in ipairs(spherecast) do 
				--secondary (spherecast) targets should prioritize objects instead of people
				interaction_tweak_id = nil
				unit_tweak_id = nil
				-- if unit_result:base().security_camera == true then
					-- icon_index = self:GetIconIndexFromId("qc_security_camera")
				-- end
				tmp_unit_result,interaction_tweak_id = find_interactable(_unit)
				if tmp_unit_result then
					is_interaction = true
					unit_result = tmp_unit_result
					break
				end
				
				tmp_unit_result,unit_tweak_id = find_character(unit,false)
				if tmp_unit_result then
					unit_result = tmp_unit_result
					break
				end
			end
		end
		
		local is_gcw_interactable_unit = nil
		
		local waypoint_type
		local _unit_id,unit_id
		local alive_unit_result = alive(unit_result)
		if alive_unit_result then
			--check if valid unit
			_unit_id = unit_result:id()
			if _unit_id and _unit_id > 0 then	
				--attach waypoint to unit
				waypoint_type = self.WAYPOINT_TYPES.UNIT
				unit_id = _unit_id
				
				-- if gcw compat is enabled,
				-- only send a unit ("Attach") type waypoint if the unit is "interactable"
				-- since gcw only supports unit waypoints on interactable units
				if self:IsGCWCompatibilitySendEnabled() and self:UseGCWUnitPingResolution() then
					for _,unit in ipairs(managers.interaction._interactive_units) do 
						if alive(unit) then
							if unit:id() == _unit_id then
								is_gcw_interactable_unit = true
								break
							end
						end
					end
				end
			else
				-- unit has no network component; create waypoint at position instead
				waypoint_type = self.WAYPOINT_TYPES.POSITION
			end
		else
			-- no unit found
			waypoint_type = self.WAYPOINT_TYPES.POSITION
		end
		
		if is_auto_icon and (interaction_tweak_id or unit_tweak_id) then
			if interaction_tweak_id then
				icon_index = self:GetIconIndexFromInteractionId(interaction_tweak_id)
				is_interaction = icon_index and true or false
			else
				if unit_tweak_id then
					local e_m = managers.enemy
					if e_m:is_civilian(unit_result) then
						icon_index = self:GetIconIndexFromId("equipment_cable_ties")
					elseif e_m:is_enemy(unit_result) then
						local group_ai_state = managers.groupai:state()
						if group_ai_state then 
							local dmg_ext = unit_result:character_damage()
							if dmg_ext:dead() and group_ai_state:whisper_mode() then
								icon_index = self:GetIconIndexFromId("pd2_bodybag")
							elseif group_ai_state:is_enemy_converted_to_criminal(unit_result) then
								icon_index = self:GetIconIndexFromId("qc_avoid")
							else
								-- check to see if team is friendly
								if dmg_ext:is_friendly_fire(managers.player:local_player()) then
									icon_index = self:GetIconIndexFromId("qc_avoid")
								else
									icon_index = self:GetIconIndexFromId("pd2_kill")
								end
							end
						end
					end
					
					-- set manual label text here
					label_text = self:GetCharacterName(unit_tweak_id)
				end
			end
		else
			if params.icon then
				icon_index = self._icon_presets_by_name[params.icon] or icon_index
			elseif params.icon_index then
				icon_index = params.icon_index or icon_index
			elseif is_auto_icon and alive_unit_result then
				if unit_result:in_slot(managers.slot:get_mask("sentry_gun")) then
					local dmg_ext = unit_result and unit_result:character_damage()
					if dmg_ext then
						local player = managers.player:local_player()
						if (dmg_ext.is_friendly_fire and dmg_ext:is_friendly_fire(player)) or PlayerDamage.is_friendly_fire(dmg_ext,player) then
							icon_index = self:GetIconIndexFromId("equipment_sentry")
						else
							icon_index = self:GetIconIndexFromId("wp_sentry")
						end
					end
				end
			end
		end
		
		
		local waypoint_data = {
			waypoint_type = waypoint_type,
			icon_index = icon_index,
			label_text = label_text,
			label_index = label_index,
			start_t = TimerManager:game():time(),
			end_t = end_t,
			position = position,
			unit_id = unit_id,
			unit = unit_result,
			is_neutral_ping = is_neutral_ping,
			is_interaction = is_interaction, -- allows checking it during update loop to see if interaction is now inactive
			is_gcw_interactable_unit = is_gcw_interactable_unit
		}
		
		self:_SendWaypoint(waypoint_data)
		self:_AddWaypoint(peer_id,waypoint_data)
		return true
	end
	
	return false
end

function QuickChat:_SendWaypoint(waypoint_data) --format data and send to peers
	local session = managers.network:session()
	if session then
		local gcw_compat = self:IsGCWCompatibilitySendEnabled()
		local sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body = self:SerializeWaypoint(waypoint_data,gcw_compat)
		if sync_string then
	--		self:Log(sync_string)
			for _,peer in pairs(session:peers()) do 
				if peer._quickchat_version then
					if peer._quickchat_version == self.API_VERSION then
						LuaNetworking:SendToPeer(peer:id(),sync_id,sync_string)
					end
				elseif gcw_compat then -- and peer._gcw_version == self.SYNC_TDLQGCW_VERSION then
					-- just send gcw waypoint to all peers just in case they have the mod but haven't sent a waypoint yet
					if tdlq_gcw_msg_id and tdlq_gcw_msg_body then
						LuaNetworking:SendToPeer(peer:id(),tdlq_gcw_msg_id,tdlq_gcw_msg_body)
					end
					--Print("Sending waypoint. type", waypoint_type, "interactable",is_gcw_interactable_unit,"message",tdlq_gcw_msg_id,tdlq_gcw_msg_body)
				end
			end
		end
	end
end

function QuickChat:SerializeWaypoint(waypoint_data,use_gcw)
	local sync_string
	local sync_id = self.SYNC_MESSAGE_WAYPOINT_ADD
	local to_int = self.to_int
	local end_t = waypoint_data.end_t
	local timer_string = waypoint_data.timer_string
	if end_t and end_t ~= 0 then
		if end_t < TimerManager:game():time() then
			-- likely caught the one frame where the timer had already expired but the waypoint hadn't been deleted;
			-- don't bother sending
			return
		end
		local int = math.floor(end_t)
		local dec = end_t - int
		timer_string = string.format("%i:%i",int,dec * 100)
	else
		timer_string = "0"
	end
	local is_gcw_interactable_unit = waypoint_data.is_gcw_interactable_unit
	local waypoint_type = to_int(waypoint_data.waypoint_type)
	local label_index = to_int(waypoint_data.label_index)
	local icon_index = to_int(waypoint_data.icon_index)
	
	local pos = waypoint_data.position or {}
	local x = to_int(pos.x)
	local y = to_int(pos.y)
	local z = to_int(pos.z)
	local unit_id = to_int(waypoint_data.unit_id)
	if waypoint_type == self.WAYPOINT_TYPES.POSITION then
		sync_string = string.format("%i;%i;%i;%s;%i;%i;%i",
			waypoint_type,
			label_index,
			icon_index,
			timer_string,
			x,
			y,
			z
		)
	elseif waypoint_type == self.WAYPOINT_TYPES.UNIT then
		sync_string = string.format("%i;%i;%i;%s;%i;%i;%i;%i",
			waypoint_type,
			label_index,
			icon_index,
			timer_string,
			x,
			y,
			z,
			unit_id
		)
	end
	if use_gcw then
		if waypoint_type == self.WAYPOINT_TYPES.UNIT and is_gcw_interactable_unit then
			tdlq_gcw_msg_id = self.SYNC_TDLQGCW_WAYPOINT_UNIT
			tdlq_gcw_msg_body = unit_id
		elseif waypoint_type == self.WAYPOINT_TYPES.POSITION or self:UseGCWUnitPingResolution() then
			-- if unit is not applicable to be a gcw unit ("Attach") waypoint, 
			-- convert it to a static position waypoint instead
			tdlq_gcw_msg_id = self.SYNC_TDLQGCW_WAYPOINT_PLACE
			tdlq_gcw_msg_body = string.format("%.1f,%.1f,%.1f",x,y,z)
		end
	end
	
	return sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body
end

function QuickChat:SerializeRemoveWaypoint(waypoint_data,use_gcw)
	if not waypoint_data then
		return
	end
	local sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body
	local to_int = self.to_int
	local waypoint_type = to_int(waypoint_data.waypoint_type)
	local pos = waypoint_data.position or {}
	local x = to_int(pos.x)
	local y = to_int(pos.y)
	local z = to_int(pos.z)
	local unit_id = to_int(waypoint_data.unit_id)

	sync_id = self.SYNC_MESSAGE_WAYPOINT_REMOVE
	sync_string = string.format("%i;%i;%i;%i;%i",waypoint_type,x,y,z,unit_id)
	
	if use_gcw then
		tdlq_gcw_msg_id = self.SYNC_TDLQGCW_WAYPOINT_REMOVE
		tdlq_gcw_msg_body = string.format("%.1f,%.1f,%.1f",x,y,z)
	end
	
	return sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body
end

function QuickChat:SendAllMyWaypointsToPeer(peer_id)
	
	local gcw_compat = self:IsGCWCompatibilitySendEnabled()
	local session = managers.network:session()
	
	local peer = session:peer(peer_id)
	local my_peer_id = session:local_peer():id()
	for _,waypoint_data in pairs(self._synced_waypoints[my_peer_id]) do
		if waypoint_data.creation_data then
			local sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body = self:SerializeWaypoint(waypoint_data.creation_data,gcw_compat)
			if peer._quickchat_version and sync_string then
				if peer._quickchat_version == self.API_VERSION then
					LuaNetworking:SendToPeer(peer_id,sync_id,sync_string)
				else
					-- version mismatch
				end
			elseif gcw_compat then
				if tdlq_gcw_msg_id and tdlq_gcw_msg_body then
					LuaNetworking:SendToPeer(peer_id,tdlq_gcw_msg_id,tdlq_gcw_msg_body)
				end
			end
		end
		--LuaNetworking:SendToPeer(peer_id,msg_id,msg_body)
		
		--todo maybe don't recopy waypoint data? would be easier to just send the original,
		-- if making the waypoint didn't mutate that data 
	end
	
end

function QuickChat:ReceiveAddWaypoint(peer_id,message_string) --sync create waypoint request from peers
	local data = string.split(message_string,";")
	if data then
		local to_int = self.to_int
		
		local waypoint_type = to_int(data[1])
		local waypoint_label = to_int(data[2])
		local waypoint_icon = to_int(data[3])
		local _timer_data = data[4]
		local start_t = TimerManager:game():time() --not exactly the same as original send time due to latency, but close enough; 
		local end_t = nil --end_t should be properly synced, on the other hand
		if _timer_data and _timer_data ~= "0" and string.find(_timer_data,":") then
			local timer_data = string.split(_timer_data,":")
			--circumvent issue with regional "." vs "," difference for post-decimal values
			end_t = to_int(timer_data[1]) + to_int(timer_data[2]) / 100
		end
		local position = Vector3(to_int(data[5]),to_int(data[6]),to_int(data[7]))
		
		if waypoint_type == self.WAYPOINT_TYPES.POSITION then
			self:_AddWaypoint(peer_id,{
				waypoint_type = waypoint_type,
				label_index = waypoint_label,
				icon_index = waypoint_icon,
				start_t = start_t,
				end_t = end_t,
				position = position,
				unit = nil
			})
		elseif waypoint_type == self.WAYPOINT_TYPES.UNIT then
			local unit_id = to_int(data[8])
			local unit_result
			if unit_id > 0 then
				--cheat the networking a little bit; 
				--syncing units directly without using the built-in network extensions is a challenge
				--but hypothetically, most units should probably be well within this distance at the time of receiving the waypoint message
				local slot_mask = self._waypoint_target_slotmask
				local near_units = World:find_units_quick("sphere",position,self.WAYPOINT_RAYCAST_DISTANCE / 2,slot_mask,"ignore_unit",self:GetIgnoreUnits())
				for _,unit in pairs(near_units) do 
					if unit:id() == unit_id then
						unit_result = unit
						break
					end
				end
			else
				--bad data
				return
			end
			self:_AddWaypoint(peer_id,{
				waypoint_type = waypoint_type,
				label_index = waypoint_label,
				icon_index = waypoint_icon,
				start_t = start_t,
				end_t = end_t,
				position = position,
				unit_id = unit_id,
				unit = unit_result
			})
		end
	end
end

function QuickChat:ReceiveRemoveWaypoint(peer_id,message_string) --synced removal request from other players in the lobby
	local message_data = string.split(message_string,";")
	if message_data then
		local to_int = self.to_int
		
		local waypoint_type = to_int(message_data[1])
		local x = to_int(message_data[2])
		local y = to_int(message_data[3])
		local z = to_int(message_data[4])
		local unit_id = to_int(message_data[5])
		local data = {
			waypoint_type = waypoint_type,
			unit_id = unit_id,
			position = Vector3(x,y,z)
		}
		
		local waypoint_index,_,_ = self:FindWaypoint(data,peer_id,nil)
		if waypoint_index then
			self:_RemoveWaypoint(peer_id,waypoint_index)
		else
			self:Log("Error: Failed to find and remove waypoint: " .. tostring(message_string))
		end
	end
end

function QuickChat:_AddWaypoint(peer_id,waypoint_data) --called for both local player and for peers
	local sound_source
	if self:IsWaypointSfxEnabled() then
		local snd_id = self:GetWaypointSfxId()
		local snd_path = snd_id and self._ping_sounds[snd_id]
		if snd_path then
			sound_source = XAudio.UnitSource:new(XAudio.PLAYER,XAudio.Buffer:new(snd_path))
			sound_source:set_volume(self:GetWaypointSfxVolume())
		end
	end
	
	local label_index = waypoint_data.label_index
	local icon_index = waypoint_data.icon_index
	local end_t = waypoint_data.end_t
	local peer_color = tweak_data.chat_colors[peer_id]
	local parent_panel = self._parent_panel
	if alive(parent_panel) then 
		local waypoint_panel_size = self.WAYPOINT_PANEL_SIZE
		local waypoint_panel = parent_panel:panel({
			name = "panel",
			w = waypoint_panel_size,
			h = waypoint_panel_size,
			valign = "grow",
			halign = "grow",
			visible = true,
			alpha = 1,
			layer = 1
		})
		local c_x,c_y = waypoint_panel:center()
		
		local debug_rect = waypoint_panel:rect({
			name="debug_rect",
			color=Color.red,
			valign="grow",
			halign="grow",
			alpha=0.2,
			visible = false
		})
		
		local acknowledgement_wheel_panel = waypoint_panel:panel({
			name = "acknowledgement_wheel_panel",
				valign = "grow",
				halign = "grow"
		})
		acknowledgement_wheel_panel:set_center(waypoint_panel:center())
		
		local num_players_max = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
		for i=1,num_players_max,1 do
			local distance = 16
			local angle = 45 + 180 + (360 * i / num_players_max)
			local dot_x = math.cos(angle) * distance
			local dot_y = math.sin(angle) * distance
			local c_x,c_y = acknowledgement_wheel_panel:center()
			local texture,texture_rect = self:GetIconDataByIndex(167) --dot
			local dot = acknowledgement_wheel_panel:bitmap({
				name = tostring(i),
				texture = texture,
				texture_rect = texture_rect,
				w = 12,
				h = 12,
				valign = "grow",
				halign = "grow",
				color = tweak_data.chat_colors[i],
				visible = false
			})
			dot:set_center(c_x + dot_x,c_y + dot_y)
		end
		
		local texture,texture_rect = self:GetIconDataByIndex(icon_index)
		local icon_visible = texture and true or false
		local label_id = label_index and self._label_presets_by_index[label_index]
		local label_text = waypoint_data.label_text or label_id and managers.localization:text(label_id)
		
		local icon_size = self.WAYPOINT_ICON_SIZE
		local arrow_size = self.WAYPOINT_ARROW_ICON_SIZE
		local label_font_size = self.WAYPOINT_LABEL_FONT_SIZE
		local arrow_texture,arrow_texture_rect = self:GetIconDataByIndex(152) --circle
		local arrow = waypoint_panel:bitmap({
			name = "arrow",
			texture = arrow_texture,--"guis/textures/pd2/progress_reload",
			texture_rect = arrow_texture_rect,
			w = arrow_size,
			h = arrow_size,
			valign = "grow",
			halign = "grow",
			color = peer_color,
			visible = true,
			layer = 4
		})
		arrow:set_center(c_x,c_y)
		local arrow_ghost = waypoint_panel:bitmap({
			name = "arrow_ghost",
			texture = arrow_texture,
			texture_rect = arrow_texture_rect,
			w = arrow_size,
			h = arrow_size,
			x = arrow:x(),
			y = arrow:y(),
			valign = "grow",
			halign = "grow",
			color = peer_color,
			alpha = 0,
			visible = true,
			layer = 5
		})
		
		local icon = waypoint_panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			w = icon_size,
			h = icon_size,
			color = peer_color,
			visible = icon_visible,
			layer = 1
		})
		icon:set_bottom(arrow:y())
		icon:set_center_x(c_x)
		
		local label = waypoint_panel:text({
			name = "label",
			text = label_text or "",
			font = tweak_data.menu.pd2_medium_font,
			font_size = label_font_size,
			align = "center",
			vertical = "top",
			color = peer_color,
			layer = 3
		})
		if not icon_visible then
			label:set_y(arrow:y() - label_font_size)
		end
		
		--timer or distance
		local desc = waypoint_panel:text({ 
			name = "desc",
			text = "",
			font = tweak_data.menu.pd2_medium_font, --timer icon character is not present in font_medium_shadow_mf
			font_size = 16,
			y = arrow:bottom() + 4,
			align = "center",
			vertical = "top",
			color = peer_color,
			layer = 3
		})
		local peer_waypoints = QuickChat._synced_waypoints[peer_id]
		local current_num_waypoints = #peer_waypoints
		local max_num_waypoints = self:GetMaxNumWaypoints()
		if current_num_waypoints >= max_num_waypoints then
			--locally enforce waypoint count limit;
			--remove oldest waypoint if over the limit
			self:_RemoveWaypoint(peer_id,1)
		end
		local unit = waypoint_data.unit
		local object
		if alive(unit) then
			local _object
			for _,object_name in ipairs(self.WAYPOINT_OBJECT_PRIORITY_LIST) do 
				_object = unit:get_object(Idstring(object_name))
				--if necessary, can get the orientation object with Unit:orientation_object(), or the body for an object with Unit:body(Object3D)
				if _object then
					object = _object
					break
				end
			end
		end
		
		local new_waypoint = {
			creation_data = waypoint_data,
			panel = waypoint_panel,
			is_gcw = waypoint_data.is_gcw,
			icon = icon,
			label = label,
			desc = desc,
			arrow = arrow,
			arrow_ghost = arrow_ghost,
			is_interaction = waypoint_data.is_interaction,
			start_t = waypoint_data.start_t or TimerManager:game():time(),
			end_t = end_t,
			state = "onscreen",
			animate_in_duration = self.WAYPOINT_ANIMATE_FADEIN_DURATION,
			waypoint_type = waypoint_data.waypoint_type,
			unit = unit,
			unit_object = object,
			unit_id = waypoint_data.unit_id,
			sound_source = sound_source,
			position = waypoint_data.position
		}
		table.insert(peer_waypoints,#peer_waypoints + 1,new_waypoint)
	end
end

function QuickChat:RemoveWaypoint(waypoint_index) --from local player
	local session = managers.network:session()
	local peer_id = session:local_peer():id()
	local use_gcw = self:IsGCWCompatibilitySendEnabled()
	local waypoint_data = self._synced_waypoints[peer_id][waypoint_index]
	local sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body = self:SerializeRemoveWaypoint(waypoint_data,use_gcw)
	for _,peer in pairs(session:peers()) do 
		local peer_version = peer._quickchat_version
		if peer_version == self.API_VERSION then
			if sync_string then
				LuaNetworking:SendToPeer(peer:id(),sync_id,sync_string)
			end
		elseif use_gcw and tdlq_gcw_msg_id and tdlq_gcw_msg_body then
			LuaNetworking:SendToPeer(peer:id(),tdlq_gcw_msg_id,tdlq_gcw_msg_body)
		end
	end
	self:_RemoveWaypoint(peer_id,waypoint_index)
end

function QuickChat:_RemoveWaypoint(peer_id,waypoint_index)
	local peer_waypoints = peer_id and self._synced_waypoints[peer_id]
	if peer_waypoints and waypoint_index then
		local waypoint_data = table.remove(peer_waypoints,waypoint_index)
		if waypoint_data and alive(waypoint_data.panel) then
			waypoint_data.panel:parent():remove(waypoint_data.panel)
		end
	end
end

function QuickChat:OnPeerDisconnected(peer_id)
	if peer_id then
		self:DisposeWaypoints(peer_id)
	end
end

function QuickChat:DisposeWaypoints(peer_id)
	local session = managers.network:session()
	if session then
		local is_local_player = peer_id == session:local_peer():id()
		local peer_waypoints = peer_id and self._synced_waypoints[peer_id]
		if peer_waypoints then
			for waypoint_index=#peer_waypoints,1,-1 do
				if is_local_player then
					self:RemoveWaypoint(waypoint_index)
				else
					local waypoint_data = table.remove(peer_waypoints,waypoint_index)
					if alive(waypoint_data.panel) then
						waypoint_data.panel:parent():remove(waypoint_data.panel)
					end
				end
			end
		end
	end
end

function QuickChat:DisposeAllWaypoints()
	for peer_id,waypoints in pairs(self._synced_waypoints) do 
		self:DisposeWaypoints(peer_id)
	end
end
			
function QuickChat:AcknowledgeWaypoint(waypoint_owner,waypoint_id)
	self:_AcknowledgeWaypoint(managers.network:session():local_peer():id(),waypoint_owner,waypoint_id)
	self:SendAcknowledgeWaypoint(waypoint_owner,waypoint_id)
end

function QuickChat:_AcknowledgeWaypoint(peer_id,waypoint_owner,waypoint_id)
	local peer_waypoints = waypoint_owner and self._synced_waypoints[waypoint_owner]
	local waypoint_data = waypoint_id and peer_waypoints[waypoint_id]
	if waypoint_data then
		local panel = waypoint_data.panel
		local checkmark_visible
		if alive(panel) then
			local acknowledgement_wheel_panel = panel:child("acknowledgement_wheel_panel")
			local checkmark = acknowledgement_wheel_panel:child(tostring(peer_id))
			if alive(checkmark) then
				checkmark_visible = not checkmark:visible()
				checkmark:set_visible(checkmark_visible)
				local c_x,c_y = checkmark:center()
				local w,h = 12,12
				checkmark:stop()
				checkmark:animate(self._animate_grow,0.75,2,w,h,c_x,c_y)
			else
				--self:Log("No checkmark alive " .. tostring(peer_id))
			end
			
		else
			--self:Log("Waypoint panel not alive")
		end
		
		local snd_id,snd_vol
		if checkmark_visible then
			if self:IsAcknowledgedSfxEnabled() then
				snd_id = self:GetAcknowledgedSfxId()
				snd_vol = self:GetAcknowledgedSfxVolume()
			end
		else
			-- play unacknowledge sound
			if self:IsUnacknowledgedSfxEnabled() then
				snd_id = self:GetUnacknowledgedSfxId()
				snd_vol = self:GetUnacknowledgedSfxVolume()
			end
		end
		if snd_id then
			local snd_path = self._ping_sounds[snd_id]
			if snd_path then
				local src
				if managers.player:local_player() then
					src = XAudio.UnitSource:new(XAudio.PLAYER,XAudio.Buffer:new(snd_path))
				else
					-- play sound even if user is dead
					src = XAudio.Source:new(XAudio.Buffer:new(snd_path))
				end
				src:set_volume(snd_vol)
			end
		end
	else
		self:Log(string.format("Attempted to acknowledge an invalid waypoint: sender %i | owner %i | waypoint %i",peer_id,waypoint_owner,waypoint_id))
	end
end

function QuickChat:SendAcknowledgeWaypoint(waypoint_owner,waypoint_id)
	local sync_string = string.format("%i;%i",waypoint_owner,waypoint_id)
	for _,peer in pairs(managers.network:session():peers()) do 
		if peer._quickchat_version == self.API_VERSION then
			-- only send to qc peers
			LuaNetworking:SendToPeer(peer:id(),self.SYNC_MESSAGE_WAYPOINT_ACKNOWLEDGE,sync_string)
		end
	end
end

function QuickChat:ReceiveAcknowledgeWaypoint(peer_id,message_string)
	local data = string.split(message_string,";")
	if data then
		local to_int = self.to_int
		local waypoint_owner = to_int(data[1])
		local waypoint_id = to_int(data[2])
		if waypoint_owner and waypoint_id then
			self:_AcknowledgeWaypoint(peer_id,waypoint_owner,waypoint_id)
		else
			self:Log("Invalid data from",peer_id,":",message_string)
		end
	end
end

function QuickChat:ReceiveGCWAttach(peer_id,message_string)
	local qc_version,gcw_version = self:GetPeerVersion(peer_id)
	if not qc_version then
		self:RegisterGCWPeerById(peer_id,self.SYNC_TDLQGCW_VERSION)
	end
	
	local unit_id = self.to_int(message_body)
	local unit
	for _, _unit in ipairs(managers.interaction._interactive_units) do
		if alive(_unit) and _unit:id() == unit_id then
			unit = _unit
			break
		end
	end
	
	if unit then
		local position = Vector3() --shouldn't matter much for a unit waypoint
		self:_AddWaypoint(peer_id,{
			waypoint_type = self.WAYPOINT_TYPES.UNIT,
			is_gcw = true,
			label_index = nil,
			icon_index = self:GetIconIndexFromId("infamy_icon_1"),
			end_t = nil,
			position = position,
			unit_id = unit_id,
			unit = unit
		})
	end
end

function QuickChat:ReceiveGCWPlace(peer_id,message_string)
	local position = self.deserialize_vec3(message_string)
	local qc_version,gcw_version = self:GetPeerVersion(peer_id)
	if not qc_version then
		self:RegisterGCWPeerById(peer_id,self.SYNC_TDLQGCW_VERSION)
	end
	if position then
		self:_AddWaypoint(peer_id,{
			waypoint_type = self.WAYPOINT_TYPES.POSITION,
			is_gcw = true,
			label_index = nil,
			icon_index = self:GetIconIndexFromId("infamy_icon_1"),
			end_t = nil,
			position = position,
			unit_id = unit_id,
			unit = unit
		})
	end
end

function QuickChat:ReceiveGCWRemove(peer_id,message_string)
	local qc_version,gcw_version = self:GetPeerVersion(peer_id)
	if not qc_version then
		self:RegisterGCWPeerById(peer_id,self.SYNC_TDLQGCW_VERSION)
	end
	self:DisposeWaypoints(peer_id)
end

--gets the waypoint that the player is looking at, if any
--can only select waypoints placed by self
local tmp_wp_dir = Vector3()
function QuickChat:GetAimedWaypoint(force_recalculate,dot_threshold,filter_peerids,filter_wp_func)
	local camera_position = managers.viewport:get_current_camera_position()
	local camera_rotation = managers.viewport:get_current_camera_rotation()
	local get_unit_waypoint_position = self.get_unit_waypoint_position
	local cam_dir = camera_rotation:y()
	
	local best_wp_index = false
	local best_wp_peerid,best_wp_data
	
	local function find_waypoint(data)
		local best_dot = dot_threshold or -1
		local best_index
		for i,waypoint_data in ipairs(data) do 
			local dot = waypoint_data.last_dot
			local allowed = true
			if type(filter_wp_func) == "function" then
				allowed = filter_wp_func(waypoint_data)
			end
			if allowed then
				if force_recalculate or not dot then
					if waypoint_data.waypoint_type == self.WAYPOINT_TYPES.UNIT then
						local unit = waypoint_data.unit
						if alive(unit) then
							local unit_pos = get_unit_waypoint_position(unit,waypoint_data.unit_object)
							mvec3_set(tmp_wp_dir,unit_pos)
							mvec3_sub(tmp_wp_dir,camera_position)
							mvec3_normalize(tmp_wp_dir)
							dot = mvec3_dot(cam_dir,tmp_wp_dir)
						end
					elseif waypoint_data.waypoint_type == self.WAYPOINT_TYPES.POSITION then
						local position = waypoint_data.position
						mvec3_set(tmp_wp_dir,position)
						mvec3_sub(tmp_wp_dir,camera_position)
						mvec3_normalize(tmp_wp_dir)
						dot = mvec3_dot(cam_dir,tmp_wp_dir)
					else
						--invalid data/unknown waypoint type
					end
				end
				if dot and dot > best_dot then
					best_dot = dot
					best_index = i
				end
			end
		end
		if best_index then
			return best_dot,best_index
		end
	end
	if filter_peerids == "all" then
		local best_dot = dot_threshold or -1
		for peer_id,waypoints in pairs(self._synced_waypoints) do 
			--best dot of this peer's waypoints
			local tmp_best_dot,tmp_best_index = find_waypoint(waypoints)
			
			--compare against all best
			if tmp_best_dot and tmp_best_dot > best_dot then
				best_dot = tmp_best_dot
				best_wp_index = tmp_best_index
				best_wp_peerid = peer_id
			end
		end
		
		best_wp_data = best_wp_index and self._synced_waypoints[best_wp_peerid][best_wp_index]
	elseif type(filter_peerids) == "table" then

		--best dot of all peer waypoints
		local best_dot = dot_threshold or -1

		for _,peer_id in pairs(filter_peerids) do
			local waypoints = self._synced_waypoints[peer_id]
			--best dot of this peer's waypoints
			local tmp_best_dot,tmp_best_index = find_waypoint(waypoints)
			
			--compare against all best
			if tmp_best_dot and tmp_best_dot > best_dot then
				best_dot = tmp_best_dot
				best_wp_index = tmp_best_index
				best_wp_peerid = peer_id
			end
		end
		best_wp_data = best_wp_index and self._synced_waypoints[best_wp_peerid][best_wp_index]
	else
		local peer_id
		if type(filter_peerids) == "number" then
			peer_id = filter_peerids
		else
			peer_id = managers.network:session():local_peer():id()
		end
		
		local waypoints = self._synced_waypoints[peer_id]
		local _,tmp_best_index = find_waypoint(waypoints)
		
		best_wp_index = tmp_best_index
		best_wp_peerid = peer_id
		best_wp_data = tmp_best_index and waypoints[tmp_best_index]
	end
	
	return best_wp_index,best_wp_peerid,best_wp_data
end

function QuickChat:FindWaypoint(data,filter_peerids,filter_wp_func)
	local wp_index,wp_peer_id,wp_data
	
	local desired_type = data.waypoint_type
	local desired_pos = data.position
	local desired_unit_id = data.unit_id or alive(data.unit) and data.unit:id()
	
	local find_waypoints = function(waypoints)
		for waypoint_index,waypoint_data in pairs(waypoints) do 
			local allowed = true
			if type(filter_wp_func) == "function" then
				allowed = filter_wp_func(waypoint_data)
			end
			if allowed then
				if desired_type == waypoint_data.waypoint_type then
					if desired_type == self.WAYPOINT_TYPES.UNIT then
						if waypoint_data.unit_id == desired_unit_id then
							return waypoint_index,waypoint_data
						end
					elseif desired_type == self.WAYPOINT_TYPES.POSITION then
						if self.mvector3_equals(desired_pos,waypoint_data.position) then
							return waypoint_index,waypoint_data
						end
					end
				end
			end
		end
	end
	
	if type(filter_peerids) == "table" then
		for _,peer_id in pairs(filter_peerids) do 
			local waypoints = self._synced_waypoints[peer_id]
			wp_index,wp_data = find_waypoints(waypoints)
			if wp_index then
				wp_peer_id = peer_id
				break
			end
		 end
	else
		if type(filter_peerids) == "number" then
			wp_peer_id = filter_peerids
		else
			wp_peer_id = managers.network:session():local_peer():id()
		end
		local waypoints = self._synced_waypoints[wp_peer_id]
		
		wp_index,wp_data = find_waypoints(waypoints)
	end
	return wp_index,wp_peer_id,wp_data
end

function QuickChat:GetCharacterName(unit_name_id)
	if HopLib then
		local name_provider = HopLib:name_provider()
		if name_provider then
			return name_provider:name_by_id(unit_name_id)
		end
	end
end

--Voicelines/Gestures
function QuickChat:PlayCriminalSound(id)		
	if not id then return end
	
	local player = managers.player:local_player()
	if alive(player) then
		player:sound():say(id,true,true)
	end
end

function QuickChat:PlayGesture(id)
	if not id then return end
	
	local player = managers.player:local_player()
	if alive(player) then
		local mov_ext = player:movement()
		if mov_ext and not mov_ext:in_clean_state() then 
			mov_ext:current_state():_play_distance_interact_redirect(0, id)
		end
	end
end


--Networking

function QuickChat:RegisterGCWPeerById(peer_id,version)
	if peer_id then 
		local session = managers.network:session()
		local peer = session and session:peer(peer_id)
		if peer then 
			if version then
				if not (peer._quickchat_version or peer._gcw_version) then
					self:Log("Registering peer " .. tostring(peer_id) .. " as GCW version " .. tostring(version))
					peer._gcw_version = version
					if self:IsWaypointRegistrationAlertEnabled() then
						local peer_name = peer:name()
						local sender_name = managers.localization:text("qc_menu_main_title")
						local peer_color = tweak_data.chat_colors[peer_id]
						local alert_string_id = "qc_alert_player_gcw"
						managers.chat:_receive_message(ChatManager.GAME,sender_name,managers.localization:text(alert_string_id,{USERNAME=peer_name,YOUR_VERSION=self.API_VERSION,PEER_VERSION=version}),peer_color)
					end
				end
			end
			self._synced_waypoints[peer_id] = self._synced_waypoints[peer_id] or {}
		end
	end
end

function QuickChat:RegisterPeerById(peer_id,version)
	self:Log("Registering peer " .. tostring(peer_id) .. " as QC version " .. tostring(version))
	if peer_id then 
		local session = managers.network:session()
		local peer = session and session:peer(peer_id)
		if peer then 
			if version then
				if peer._gcw_version then
					if _G.CustomWaypoints then
						--QuickChat:DisposeWaypoints(peer_id)				
					end
				end
				if not peer._quickchat_version then
					peer._quickchat_version = version
					
					-- if any waypoints were already sent as gcw waypoints,
					-- (eg. if waypoint already existed and was auto-synced on peer join as gcw waypoint)
					-- then send the gcw remove message, and send them as qc waypoints instead
					
					-- dispose all gcw waypoints
					local local_peer_id = session:local_peer():id()
					local my_waypoints = local_peer_id and self._synced_waypoints[local_peer_id]
					if my_waypoints then
						for i,waypoint_data in pairs(my_waypoints) do
							local sync_id,sync_string,tdlq_gcw_msg_id,tdlq_gcw_msg_body = self:SerializeRemoveWaypoint(waypoint_data,true)
							LuaNetworking:SendToPeer(peer_id,tdlq_gcw_msg_id,tdlq_gcw_msg_body)
						end
					end
					
					self:SendAllMyWaypointsToPeer(peer_id)
					
					if self:IsWaypointRegistrationAlertEnabled() then
						local peer_name = peer:name()
						local sender_name = managers.localization:text("qc_menu_main_title")
						local peer_color = tweak_data.chat_colors[peer_id]
						local alert_string_id
						if version == self.API_VERSION then
							alert_string_id = "qc_alert_player_registered_version_match"
						else
							alert_string_id = "qc_alert_player_registered_version_mismatch"
						end
						managers.chat:_receive_message(ChatManager.GAME,sender_name,managers.localization:text(alert_string_id,{USERNAME=peer_name,YOUR_VERSION=self.API_VERSION,PEER_VERSION=version}),peer_color)
					end
				end
			end
			self._synced_waypoints[peer_id] = self._synced_waypoints[peer_id] or {}
		end
	end
end

function QuickChat:GetPeerVersion(peer_id)
	if peer_id then 
		local session = managers.network:session()
		local peer = session and session:peer(peer_id)
		if peer then 
			return peer._quickchat_version,peer._gcw_version
		end
	end
end

function QuickChat:SendPresetMessage(preset_text_index)
	if self:CheckChatCooldown(true) then
		local preset_text = preset_text_index and self._message_presets[preset_text_index]
		if preset_text then
			if managers.chat then
				local network_mgr = managers.network
				if network_mgr then
					local session = network_mgr:session()
					if session then 
						local local_peer = session:local_peer()
						local username = network_mgr.account:username()
						local text_localized = managers.localization:text(preset_text)
						for _,peer in pairs(session:peers()) do 
							local peer_version = peer._quickchat_version 
							
							--if the QC API changes in the future, outbound messages will be reformatted here
							if peer_version == "1" or peer_version == self.API_VERSION then
								--v1-v2
								LuaNetworking:SendToPeer(peer:id(),self.SYNC_MESSAGE_PRESET,preset_text_index)
							else
								if peer:ip_verified() then
									peer:send("send_chat_message", ChatManager.GAME, text_localized) --LuaNetworking.HiddenChannel
								end
							end
						end
						
						managers.chat:receive_message_by_peer(ChatManager.GAME,local_peer,self:stylize_translated_message(text_localized))
					end
				end
			end
		else
			self:Log("Error: SendPresetMessage(" .. tostring(preset_text_index) .. ") bad preset index!")
			return
		end
	end
end

function QuickChat:ReceivePresetMessage(peer_id,preset_text_index)
	local preset_text = preset_text_index and self._message_presets[preset_text_index]
	if preset_text then
		if managers.chat then
			local network_mgr = managers.network
			if network_mgr then
				local session = network_mgr:session()
				if session then
					local peer = session:peer()
					if peer then
						local peer_color = tweak_data.chat_colors[peer_id]
						local username = peer:name()
						local text_localized = managers.localization:text(preset_text)
						--local quickchat_version = peer._quickchat_version
						--if the QC API changes in the future, inbound messages will be reformatted here
						managers.chat:_receive_message(ChatManager.GAME,username,self:stylize_translated_message(text_localized),peer_color)
					end
				end
			end
		end
	end
end

-- checks whether sending a chat message is blocked by cooldown
-- returns true if message can be sent; else, returns false
function QuickChat:CheckChatCooldown(is_sending)
	local session = managers.network and managers.network:session()
	if session then
		if session:amount_of_players() == 1 then 
			-- don't limit chat messages (or count against cooldown) if singleplayer or is the only person in the lobby
			return true
		end
	end
	
	local cooldowns = self._message_cooldowns
	
	local t = Application:time()
	if #cooldowns >= self.TEXT_MESSAGE_COOLDOWN_COUNT then
		-- check cooldown timer (only need to check topmost entry since only one message is sent at a time)
		if cooldowns[1] + self.TEXT_MESSAGE_COOLDOWN_INTERVAL > t then
			-- rate limited
			if managers.chat and is_sending then
				managers.chat:_receive_message(ChatManager.GAME,managers.localization:text("qc_menu_main_title"),managers.localization:text("qc_error_chat_rate_limited",{COOLDOWN=math.ceil(self.TEXT_MESSAGE_COOLDOWN_INTERVAL+cooldowns[1] - t)}),Color(249/255,110/255,35))
			end
			return false
		else
			-- sufficient time has passed since last message; allow sending
			if is_sending then
				table.remove(cooldowns,1)
			end
		end
	else
		-- allow sending
	end
	
	if is_sending then
		table.insert(cooldowns,#cooldowns+1,t)
	end
	return true
end

function QuickChat:SendChatToAll(msg)
	if self:CheckChatCooldown(true) then
		return self:_SendChatToAll(msg)
	end
end

function QuickChat:_SendChatToAll(msg)
	if managers.chat then
		local session = managers.network:session()
		local peer_id = session:local_peer():id()
		local col = tweak_data.chat_colors[peer_id]
		local username = managers.network.account:username()
		managers.chat:send_message(ChatManager.GAME,username,msg)
	end
end

function QuickChat:SendSyncPeerVersionToAll()
	LuaNetworking:SendToPeers(self.SYNC_MESSAGE_QC_HANDSHAKE,self.API_VERSION)
end

--Updaters

function QuickChat:AddControllerInputListener() --only for rebinding
	self._is_binding_listener_active = true
	self:AddUpdater("quickchat_update_rebinding",callback(self,self,"UpdateRebindingListener"),true)
--	self:Log("QuickChat: Adding listener for " .. tostring(self:GetController()) .. ", gamepad mode " .. tostring(self:IsGamepadModeEnabled()))
end

function QuickChat:RemoveControllerInputListener() --only for rebinding
	self:AddDelayedCallback("quickchat_rebinding_delayed_unblock_input",function()
		self._is_binding_listener_active = false
	end,
	0.5,true)
	self:RemoveUpdater("quickchat_update_rebinding")
--	self:Log("QuickChat: Rebinding listener removed.")
end

function QuickChat:UpdateRebindingListener(t,dt)
	--options: --pressed_list --released_list --down_list 
	local controller = self:GetController()
	if controller then
		local pressed_list = controller:pressed_list()
		local gamepad_mode_enabled = self:IsGamepadModeEnabled()
		if #pressed_list > 0 then
			for _,button_index in ipairs(pressed_list) do 
				local button_ids = controller:button_name(button_index)
				local button_ids_key = button_ids:key()
				
				local button_name = self._allowed_binding_buttons[button_ids_key]
				if button_name then
--						self:Log("detected controller " .. button_name)
--						if gamepad_mode_enabled then 
--						end
					--associate that menu with this button
					if self._callback_bind_button then
						self:_callback_bind_button(button_name,false)
					end
					self:RemoveControllerInputListener()
					break
				end
			end
		end
	end
	
	--check mouse input (different device)
	if not gamepad_mode_enabled then
		local mouse = Input:mouse() --just directly get the mouse device
		local pressed_list = mouse:pressed_list()
		if #pressed_list > 0 then
			for _,button_index in ipairs(pressed_list) do 
				local button_ids = mouse:button_name(button_index)
				local button_ids_key = button_ids:key()
				
				local button_name = self._allowed_binding_mouse_buttons[button_ids_key]
				if button_name then
					--associate that menu with this button
					if self._callback_bind_button then
						self:_callback_bind_button(button_name,true)
					end
					self:RemoveControllerInputListener()
					break
				end
			end
		end
	end
end

function QuickChat:AddUpdater(id,func,run_while_paused)
	local f_type = type(func)
	if f_type == "function" then
		self._updaters[id] = {
			id = id,
			func = func,
			pause_enabled = run_while_paused
		}
	else
		self:Log("ERROR: Bad updater type for " .. tostring(id) .. ": " .. f_type .. " (expected function)")
	end
end

function QuickChat:RemoveUpdater(id)
	self._updaters[id] = nil
end

function QuickChat:Update(source,t,dt)
--	if source == "GameSetupUpdate" then
--		Console:SetTracker(string.format("%s %0.2f %0.2f",source,Application:time(),t),1)
--	elseif source == "GameSetupPausedUpdate" then
--		Console:SetTracker(string.format("%s %0.2f %0.2f",source,Application:time(),t),2)
--	elseif source == "MenuUpdate" then
--		Console:SetTracker(string.format("%s %0.2f %0.2f",source,Application:time(),t),3)
--	end
	
	local game_is_paused = source == "GameSetupPausedUpdate"
	for id,data in pairs(self._updaters) do 
		if not game_is_paused or data.pause_enabled then
			data.func(t,dt,game_is_paused)
		end
	end
end

function QuickChat:UpdateGame(t,dt)
	self:UpdateInput(t,dt)
	self:UpdateWaypoints(t,dt)
end

function QuickChat:UpdateInput(t,dt)
	if self._is_binding_listener_active then
		-- block keybind execution if currently listening for rebind key input
		return
	end
	local dialog = managers.system_menu._active_dialog 
	if dialog and dialog.NAME ~= "RadialMenuDialog" then -- or managers.system_menu:is_active()
		-- block keybind execution if a dialog (besides a radial menu) is open
		return
	end
	
--	if #managers.menu._open_menus > 0 then
--		-- block keybind execution if a menu is open
--	--and not (game_state_machine or GameStateFilters.player_slot[game_state_machine:current_state_name()]) then
--		return
--	end

	if managers.hud and managers.hud:chat_focus() then
		return
	elseif managers.menu_component and managers.menu_component:input_focut_game_chat_gui() then
		return
	end
	
	local controller = self:GetController()
	if not controller then
		return
	end
	local player_unit = managers.player:local_player()
	local gamepad_mode_enabled = self:IsGamepadModeEnabled()
	local mouse
	if not gamepad_mode_enabled then
		mouse = Input:mouse()
	end
	for button_name_ids,v in pairs(self._input_cache) do 
		for _,input_data in pairs(v) do 
			local state
			if input_data.is_mouse_button then
				state = mouse:down(button_name_ids)
			else
				--do controller source checking here
				state = controller:down(button_name_ids)
			end
			if state then
				if not input_data.state then
					if input_data.callback_pressed then
						input_data.callback_pressed(t,dt,input_data.action_data)
					end
					input_data.hold_start_t = t
					--on pressed
				else
					if input_data.callback_held then
						input_data.callback_held(t,dt,input_data.action_data)
					end
					--on held
				end
			else
				if input_data.state then
					--on released
					if input_data.callback_released then
						input_data.callback_released(t,dt,input_data.action_data)
					end
					input_data.hold_start_t = nil
				end
			end
			input_data.state = state
		end
	end
end

-- update positional audio;
-- audio can't be at the actual waymark/unit position because if it's too far it won't be audible
-- so the position needs to be updated along a normalized vector, at a fixed distance from the listener (camera)

local tmp_cam_fwd = Vector3() -- used for UpdateWaypoints()
local tmp_snd_pos = Vector3() -- used for UpdateWaypoints() ( for positional audio )
-- includes setting sound positions
function QuickChat:UpdateWaypoints(t,dt)	
	local game_t = TimerManager:game():time()
	local viewport_cam = managers.viewport:get_current_camera()
	local ws = self._ws
	if not viewport_cam then 
		return
	end
	local parent_panel = self._parent_panel
	if not alive(parent_panel) then
		return
	end
	local timer_char = managers.localization:get_default_macro("BTN_SPREE_SHORT")
	local pc_x,pc_y = parent_panel:center()
	local pw,ph = parent_panel:size()
	
	local arrow_ghost_size = self.WAYPOINT_ARROW_ICON_SIZE
	local waypoint_panel_size = self.WAYPOINT_PANEL_SIZE
	local waypoint_animate_pulse_interval = self.WAYPOINT_ANIMATE_PULSE_INTERVAL
	local outer_clamp_x_min = 0 + waypoint_panel_size/2
	local outer_clamp_x_max = pw - (waypoint_panel_size/2)
	local outer_clamp_y_min = 0 + waypoint_panel_size/2
	local outer_clamp_y_max = ph - (waypoint_panel_size/2)
	local camera_position = managers.viewport:get_current_camera_position()
	local camera_rotation = managers.viewport:get_current_camera_rotation()
	
	mrot_y(camera_rotation,tmp_cam_fwd)
	
	local get_unit_waypoint_position = self.get_unit_waypoint_position
	local waypoint_attenuate_alpha_mode = self:GetWaypointAttenuateAlphaMode()
	local waypoint_attenuate_alpha_min = self:GetWaypointAttenuateAlphaMin()
	local waypoint_attenuate_dot_threshold = self:GetWaypointAttenuateDotThreshold()
	
	local waypoint_reverse_dot = waypoint_attenuate_alpha_mode == 3
	
--	local player = managers.player:local_player()
	local session = managers.network:session()
	if not session then 
		return
	end
	local local_peer_id = session:local_peer():id() --todo cache this?
	for peer_id,peer_data in pairs(self._synced_waypoints) do 
		for waypoint_id=#peer_data,1,-1 do 
			
			local waypoint_data = peer_data[waypoint_id]
			local is_valid = true
			local end_t = waypoint_data.end_t
			local wp_position = waypoint_data.position
			if end_t then
				local remaining_t = end_t - game_t
				if remaining_t <= 0 then
					--timer expired
					is_valid = false
				else
					waypoint_data.desc:set_text(string.format("%s%0.1fs",timer_char,remaining_t))
				end
			else
				local waypoint_type = waypoint_data.waypoint_type
				if waypoint_type == self.WAYPOINT_TYPES.UNIT then
					local unit = waypoint_data.unit
					if alive(unit) then
						if waypoint_data.is_interaction then
							local interaction_ext = unit:interaction()
							if interaction_ext then
								if interaction_ext:disabled() or not interaction_ext:active() then -- or not interaction_ext:can_interact() 
									is_valid = false
								else
									-- is_valid = true -- yay
								end
							else
								is_valid = false
							end
						end
						
						if is_valid then
							wp_position = get_unit_waypoint_position(unit,waypoint_data.unit_object) or wp_position
						end
					else
						--unit despawned or otherwise invalid
						is_valid = false
					end
				else
					--is position based (wp_position is already set by default)
				end
				
				if is_valid then
					local distance = mvec3_distance(camera_position,wp_position)
					if distance >= 100000 then -- if 1 km or further away, show distance in km
						local km = math.floor(distance / 100000)
						local m = (distance % 100000) / 1000
						waypoint_data.desc:set_text(string.format("%i.%ikm",km,m))
					else
						waypoint_data.desc:set_text(string.format("%0.1fm",distance / 100))
					end
				end
			end
			
			if is_valid then
				local panel_pos = ws:world_to_screen(viewport_cam,wp_position)
				local panel_x,panel_y = panel_pos.x,panel_pos.y
				
				
				local direction = wp_position - camera_position
				mvec3_normalize(direction)
				
				if waypoint_data.sound_source then
					if not waypoint_data.sound_source:is_closed() then
						if waypoint_data.sound_source:is_active() then
							mvec3_set(tmp_snd_pos,direction)
							mvec3_mul(tmp_snd_pos,self.POSITIONAL_AUDIO_DISTANCE)
							mvec3_add(tmp_snd_pos,camera_position)
							waypoint_data.sound_source:set_position(tmp_snd_pos)
							--Draw:brush(Color.red:with_alpha(0.25)):sphere(tmp_snd_pos,25) -- visualize sound position
						else
							-- don't do this; the sound source is not technically considered "active" in the first frame before it updates
							-- waypoint_data.sound_source = nil
						end
					else
						waypoint_data.sound_source = nil
					end
				end
				
				
				local dot = mvec3_dot(tmp_cam_fwd,direction)
				
				--[[
				Console:SetTracker(dot,1)
				Console:SetTracker(math.X:angle(tmp_cam_fwd,2))
				Console:SetTracker(math.sign(tmp_cam_fwd.y),3)
				Console:SetTracker(math.X:angle(tmp_cam_fwd) * math.sign(tmp_cam_fwd.y),4)
				--]]
				
				local hud_direction
				--angle from screen center to the waypoint
				
				local c_x = panel_x - pc_x
				local c_y = panel_y - pc_y
				local new_waypoint_state
				local arrow = waypoint_data.arrow
				
				if dot < 0 or parent_panel:outside(panel_x - outer_clamp_x_min,panel_y - outer_clamp_y_min) or parent_panel:outside(panel_x + outer_clamp_x_min,panel_y + outer_clamp_y_min) then
					new_waypoint_state = "offscreen"
					
					local x_r = math.clamp(panel_x,0,pw) / pw
					local y_r = math.clamp(panel_y,0,ph) / ph
					
					if c_x ~= 0 or c_y ~= 0 then
						hud_direction = math.atan(c_y/c_x)
						if c_x < 0 then
							hud_direction = hud_direction + 180
						end
					else
						hud_direction = 0
					end
					
					panel_x = pc_x + (outer_clamp_x_max * math.cos(hud_direction) / 2)
					panel_y = pc_y + (outer_clamp_y_max * math.sin(hud_direction) / 2)
				else
					new_waypoint_state = "onscreen"
					if c_x ~= 0 or c_y ~= 0 then
						hud_direction = math.atan(c_y/c_x)
						if c_x > 0 then
							hud_direction = hud_direction + 180
						end
					end
				end
--				Console:SetTracker(hud_direction,2)

				if waypoint_data.animate_in_duration then
					--do pulse for new waypoints
					local arrow_ghost = waypoint_data.arrow_ghost
					if waypoint_data.animate_in_duration > 0 then
						local start_t = waypoint_data.start_t
						local pulse_t = 1 - (math.cos(((game_t - start_t) * 180/waypoint_animate_pulse_interval) % 180)+1) / 2
						local size_scaled = arrow_ghost_size * (1 + pulse_t)
						arrow_ghost:set_size(size_scaled,size_scaled)
						arrow_ghost:set_alpha(1 - pulse_t)
						arrow_ghost:set_center(waypoint_data.panel:w()/2,waypoint_data.panel:h()/2)
						
						waypoint_data.animate_in_duration = waypoint_data.animate_in_duration - dt
					else
						arrow_ghost:hide()
						waypoint_data.animate_in_duration = nil
					end
				end
				
				if new_waypoint_state == "offscreen" then
					arrow:set_rotation(hud_direction)
				elseif new_waypoint_state == "onscreen" then
					if waypoint_data.animate_in_duration or waypoint_attenuate_alpha_mode == 1 then
						waypoint_data.panel:set_alpha(1)
					else
						local dot_alpha
						if dot > waypoint_attenuate_dot_threshold then
							if waypoint_reverse_dot then 
								dot_alpha = waypoint_attenuate_alpha_min + (1-waypoint_attenuate_alpha_min) * (dot - waypoint_attenuate_dot_threshold) / (1 - waypoint_attenuate_dot_threshold)
							else
								dot_alpha = waypoint_attenuate_alpha_min + (1-waypoint_attenuate_alpha_min) * (1-(dot - waypoint_attenuate_dot_threshold) / (1 - waypoint_attenuate_dot_threshold))
							end
							--dot_alpha = math.max(1-(d_dot/(1-waypoint_attenuate_dot_threshold)),waypoint_attenuate_alpha_min)
						else
							if waypoint_reverse_dot then
								dot_alpha = waypoint_attenuate_alpha_min
							else
								dot_alpha = 1
							end
						end
						--Console:SetTracker(string.format("%0.5f / %0.2f / a= %0.2f",dot,(dot - waypoint_attenuate_dot_threshold) or -1,dot_alpha),1)
						waypoint_data.panel:set_alpha(dot_alpha)
					end
				end
				
				--update icon angle/alpha for offscreen waypoints
				if new_waypoint_state ~= waypoint_data.state then
					local arrow_texture,arrow_texture_rect
					if new_waypoint_state == "offscreen" then
						arrow_texture,arrow_texture_rect = self:GetIconDataByIndex(24) --arrow
					elseif new_waypoint_state == "onscreen" then
						--waypoint_data.panel:set_alpha(1)
						arrow:set_rotation(0)
						arrow_texture,arrow_texture_rect = self:GetIconDataByIndex(152) --dot
					end
					arrow:set_image(arrow_texture,unpack(arrow_texture_rect or {}))
					waypoint_data.state = new_waypoint_state
				end
				waypoint_data.panel:set_center(panel_x,panel_y)
			else -- not is_valid
				
				if peer_id == local_peer_id then
					-- send sync remove this waypoint;
					-- other qc users should have removed it anyway since the unit no longer exists,
					-- but if it's synced to gcw users as a position waypoint (for non-interactable units)
					-- then it won't ever be removed on their end
					self:RemoveWaypoint(waypoint_id)
				else
					self:_RemoveWaypoint(peer_id,waypoint_id)
				end
			end
		end
	end
end

function QuickChat:AddDelayedCallback(id,cb,duration,run_while_paused)
	local timer = duration
	if id and type(cb) == "function" then
		local updater_id = "delayedcallback_" .. tostring(id)
		self:AddUpdater(updater_id,function(t,dt)
			timer = timer - dt
			if timer <= 0 then
				cb()
				self:RemoveUpdater(updater_id)
			end
		end,run_while_paused)
	else
		self:Log("Error: AddDelayedCallback(): You must supply an id!")
	end
end

function QuickChat:RemoveDelayedCallback(id,exec)
	local updater_id = "delayedcallback_" .. tostring(id)
	self._updaters[updater_id] = nil
end

--I/O

function QuickChat:GetBindingsFileName()
	return string.gsub(self._bindings_name,"$WRAPPER",managers.controller:get_default_wrapper_type())
end

function QuickChat:LoadSettings()
	local save_path = self._save_path .. self._settings_name
	local file = io.open(save_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
		file:close()
	end
end

function QuickChat:SaveSettings()
	local save_path = self._save_path .. self._settings_name
	local file = io.open(save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function QuickChat:SaveBindings(filename)
	local save_path = self._save_path .. tostring(filename)
	local file = io.open(save_path,"w+")
	if file then
		file:write(json.encode(self._bindings))
		file:close()
	end
end

function QuickChat:LoadBindings(filename)
	local save_path = self._save_path .. tostring(filename)
	local file = io.open(save_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			local action_data = v.action_data
			if action_data and action_data.action_type == "radial" and action_data.sub_type then
				if self._radial_menu_params[action_data.sub_type] then
					-- valid binding with (probably) valid radial id
					self._bindings[k] = v
				else
					self:Print("Invalid binding",k,"action_data",action_data,"sub_type",action_data.sub_type)
				-- invalid binding; discard
				end
			else
				self._bindings[k] = v
			end
		end
		file:close()
	end
end

function QuickChat:Load() -- deprecated
	self:LoadSettings()
	self:LoadBindings(self:GetBindingsFileName())
end

function QuickChat:Save()
	self:SaveSettings()
	self:SaveBindings(self:GetBindingsFileName())
end

--Menu Creation and other hooks

function QuickChat.add_menu_option_from_data(priority,menu_data,parent_menu_id,settings,default_settings)
	-- priority can be nil
	if not parent_menu_id then 
		QuickChat:Log("add_menu_option_from_data(): bad parent menu id!")
		return
	end
	
	local menu_type = menu_data.type
	local item_id = menu_data.id
	local title_id = menu_data.title
	local desc_id = menu_data.description or menu_data.desc
	local value_id = menu_data.value or ""
	local value = menu_data.value_raw or value_id and settings[value_id]
	local default_value = menu_data.default_value
	local callback_id = menu_data.callback
	local localized = menu_data.localized
	local disabled = menu_data.disabled
	
	if menu_type == "menu" then 
		QuickChat._populated_menus[item_id] = {
			menu = MenuHelper:GetMenu(item_id) or MenuHelper:NewMenu(item_id),
			
			area_bg = menu_data.area_bg,
			back_callback = menu_data.back_callback,
			focus_changed_callback = menu_data.focus_changed_callback
		}
		table.insert(QuickChat._queued_menus,{
			parent_menu_id = parent_menu_id,
			submenu_id = item_id,
			title = title_id,
			desc = desc_id,
			priority = priority
		})
		
		if type(menu_data.children) == "table" then
			return menu_data.children,{item_id}
		end
	else
		if menu_type == "toggle" then 
			MenuHelper:AddToggle({
				id = item_id,
				title = title_id,
				desc = desc_id,
				callback = callback_id,
				value = value,
				default_value = menu_data.default_value or default_settings[value_id],
				disabled = disabled,
				localized = localized,
				menu_id = parent_menu_id,
				priority = priority
			})
		elseif menu_type == "slider" then 
			MenuHelper:AddSlider({
				id = item_id,
				title = title_id,
				desc = desc_id,
				value = value,
				default_value = menu_data.default_value or default_settings[value_id],
				min = menu_data.min,
				max = menu_data.max,
				step = menu_data.step,
				show_value = menu_data.show_value,
				disabled = disabled,
				localized = localized,
				callback = callback_id,
				menu_id = parent_menu_id,
				priority = priority
			})
		elseif menu_type == "button" then 
			MenuHelper:AddButton({
				id = item_id,
				title = title_id,
				desc = desc_id,
				callback = callback_id,
				disabled = disabled,
				localized = localized,
				menu_id = parent_menu_id,
				priority = priority
			})
		elseif menu_type == "divider" then 
			return MenuHelper:AddDivider({
				id = item_id,
				size = menu_data.size,
				disabled = disabled,
				localized = localized,
				menu_id = parent_menu_id,
				priority = priority
			})
		elseif menu_type == "multiple_choice" then 
			MenuHelper:AddMultipleChoice({
				id = item_id,
				title = title_id,
				desc = desc_id,
				callback = callback_id,
				items = menu_data.items,
				value = value,
				default_value = menu_data.default_value or default_settings[value_id],
				disabled = disabled,
				localized = localized,
				menu_id = parent_menu_id,
				priority = priority
			})
		elseif menu_type == "keybind" then 
			MenuHelper:AddKeybinding({
				id = item_id,
				title = title_id,
				--desc doesn't seem to be used here?
				callback = callback_id,
				connection_name = menu_data.connection_name,
				binding = menu_data.binding,
				button = menu_data.button,
				disabled = disabled,
				localized = localized,
				menu_id = parent_menu_id,
				priority = priority
			})
		end
	end
end


Hooks:Add("MenuManagerSetupCustomMenus","QuickChat_MenuManagerSetupCustomMenus",function(menu_manager, nodes)
	QuickChat:FindLanguageFiles()
	--QuickChat:ChooseLanguage(QuickChat._DEFAULT_LANGUAGE_ID) -- default
	
	QuickChat:CheckResourcesReady()
	
	QuickChat:UnpackGamepadBindings()
	QuickChat:LoadSettings()
	QuickChat:ChooseLanguage(QuickChat:GetUserLanguage())
	QuickChat:LoadCustomRadials()
	QuickChat:LoadBindings(QuickChat:GetBindingsFileName())
	
	
	MenuHelper:NewMenu(QuickChat.MENU_IDS.MENU_MAIN)
	
	-- todo integrate this into the menu building helper func
	MenuHelper:NewMenu(QuickChat.MENU_IDS.MENU_BINDS)
	MenuHelper:NewMenu(QuickChat.MENU_IDS.MENU_SETTINGS)
	--[[
	-- add binds submenu to main menu
	QuickChat.add_menu_option_from_data(nil,{
		id = parent_menu_id,
		title = "qc_menu_binds_title",
		desc = "qc_menu_binds_desc",
		
		area_bg = "none",
		back_callback = "callback_menu_quickchat_back",
		focus_changed_callback = nil
	},QuickChat.MENU_IDS.MENU_MAIN,QuickChat.settings,QuickChat.default_settings)
	--]]
end)

Hooks:Add("MenuManagerPopulateCustomMenus","QuickChat_MenuManagerPopulateCustomMenus",function(menu_manager, nodes)
	
	local parent_menu_id = QuickChat.MENU_IDS.MENU_BINDS
	
	local binding_items = {}
	
	local function add_binding_button(data)
		local id = tostring(data.id)
		local header_id = "qc_menu_bind_header_" .. id
		local header_title = data.header_title
		local header_desc = data.header_desc
		local button_id = "qc_menu_bind_button_" .. id
		local button_title = data.button_title
		local button_desc = data.button_desc
		local callback_id = "callback_qc_menu_bind_button_" .. id
		local divider_id = "qc_menu_divider_" .. id
		table.insert(binding_items,#binding_items+1,{ --header button
			type = "button",
			id = header_id,
			title = header_title,
			desc = header_desc,
			localized = false,
			callback = nil, --look, don't touch
			menu_id = data.parent_menu_id,
			disabled = true
		})
		table.insert(binding_items,#binding_items+1,{ --bind button
			type = "button",
			id = button_id,
			title = button_title,
			desc = button_desc,
			localized = false,
			callback = callback_id,
			menu_id = data.parent_menu_id,
			disabled = false
		})
		table.insert(binding_items,#binding_items+1,{ --divider
			type = "divider",
			id = divider_id,
			size = 16,
			menu_id = data.parent_menu_id
		})
		MenuCallbackHandler[callback_id] = data.callback
	end
	
	--create menus for each user radial, in alphabetical order
	local radial_keys = {}
	for radial_id,radial_data in pairs(QuickChat._radial_menu_params) do 
		table.insert(radial_keys,radial_id)
	end
	table.sort(radial_keys)
	
	local function refresh_menu_item(menu_id,item_id,new_text)
		local parent_menu = MenuHelper:GetMenu(menu_id)
		for _,item in pairs(parent_menu._items) do 
			local item_parameters = item and item._parameters 
			if item_parameters and item_parameters.name == item_id then
				item_parameters.text_id = new_text
				item_parameters.gui_node:reload_item(item)
				break
			end
		end
	end
	
	local function get_button_display_name(...)
		return utf8.to_upper(QuickChat:GetButtonDisplayName(...))
	end
	
	--returns the callback that is called when the button is pressed
	local function generate_menu_callback(action_type,action_subtype)
		local current_binding_text = managers.localization:text("qc_bind_status_unbound")
		
		--called when button is pressed
		local menu_callback = function(self)
			
			--get the current bind for this action
			local current_button_name,current_is_mouse_button = QuickChat:GetButtonByAction(action_type,action_subtype)
			local action_id = QuickChat:GetActionDisplayName(action_type,action_subtype)
			
			local current_key_display_name = get_button_display_name(current_button_name,current_is_mouse_button)
			if current_button_name then
				current_binding_text = managers.localization:text("qc_bind_status_title",{KEYNAME=current_key_display_name})
			end
			
			local title,desc
			local button_unbind_name,button_cancel_name
			if QuickChat:IsGamepadModeEnabled() then
				title = "qc_menu_bind_prompt_controller_title"
				desc = "qc_menu_bind_prompt_controller_desc"
				button_unbind_name = "start"
				button_cancel_name = "back"
			else
				title = "qc_menu_bind_prompt_keyboard_title"
				desc = "qc_menu_bind_prompt_keyboard_desc"
				button_unbind_name = "backspace"
				button_cancel_name = "esc"
			end
			QuickChat._quickmenu_item = QuickMenu:new(
				managers.localization:text(title),
				managers.localization:text(desc,{BTN_UNBIND=get_button_display_name(button_unbind_name),BTN_CANCEL=get_button_display_name(button_cancel_name)}),
				{
					{
						text = managers.localization:text("qc_menu_bind_prompt_unbind"),
						callback = function()
							if QuickChat._callback_bind_button then
								QuickChat:_callback_bind_button(button_unbind_name)
							end
							QuickChat:RemoveControllerInputListener()
						end
					},
					{
						text = managers.localization:text("qc_menu_dialog_cancel"),
						is_cancel_button = true,
						is_default_button = true,
						callback = function()
							QuickChat:RemoveControllerInputListener()
						end
					}
				},
				true
			)
			
			--called on pressing a button in the bind dialog
			QuickChat._callback_bind_button = function(self,button_name,is_mouse_button)
				local button_display_name = get_button_display_name(button_name,is_mouse_button)
--				self:Log("QuickChat: Found button " .. tostring(button_name))
				
				--hide current dialog boxes (waiting for bind input, etc)
				if self._quickmenu_item then 
					self._quickmenu_item:Hide()
					self._quickmenu_item = nil
				end
				
				if button_name == button_unbind_name then 
					
					--unbind the button currently bound to this action
					local bind_data,_ = self:GetBindDataByAction(action_type,action_subtype)
					if bind_data then
						local action_name = self:GetActionDisplayName(bind_data.action_data.action_type,bind_data.action_data.sub_type)
						self:UnbindButton(bind_data.button_name,bind_data.is_mouse_button,false)
						refresh_menu_item(parent_menu_id,"qc_menu_bind_button_" .. action_name,managers.localization:text("qc_bind_status_unbound"))
						QuickMenu:new(
							managers.localization:text("qc_menu_bind_prompt_unbound_title"),
							managers.localization:text("qc_menu_bind_prompt_unbound_desc",{KEYNAME=get_button_display_name(bind_data.button_name,bind_data.is_mouse_button),ACTION=action_name}),
							{
								{
									text = managers.localization:text("qc_menu_dialog_accept"),
									is_cancel_button = true
								}
							},
							true
						)
					end
				elseif button_name == button_cancel_name then
					--cancel, do nothing
					return
				else
					local conflict_action_name
					local bind_data,_ = self:GetBindDataByButton(button_name,is_mouse_button)
					if bind_data then
						conflict_action_name = self:GetActionDisplayName(bind_data.action_data.action_type,bind_data.action_data.sub_type)
					end
					
					if conflict_action_name then
						--internal keybind conflict detection
						--check if the new button is already bound to something else
						QuickMenu:new(
							managers.localization:text("qc_menu_bind_prompt_conflict_title"),
							managers.localization:text("qc_menu_bind_prompt_conflict_desc",{KEYNAME=button_display_name,ACTION=conflict_action_name}),
							{
								{
									text = managers.localization:text("qc_menu_dialog_accept"),
									is_cancel_button = true
								}
							},
							true
						)
						return
					end
					
					--unbind previous button bound to this action
					self:UnbindButton(current_button_name,current_is_mouse_button,true)
					
					if action_type then
						self:BindButtonData(button_name,is_mouse_button,{
							action_type = action_type,
							sub_type = action_subtype
						})
					else
						self:Log("Error: Attempted to bind button " .. tostring(button_display_name) .. " to invalid action " .. tostring(action_id))
					end
					QuickMenu:new(
						managers.localization:text("qc_bind_status_success_title"),
						managers.localization:text("qc_bind_status_success_desc",{KEYNAME=button_display_name,ACTION=action_id}),
						{
							{
								text = managers.localization:text("qc_menu_dialog_accept"),
								is_cancel_button = true
							},
						},
						true
					)
					self:CloseAllRadialMenus()
					self:ClearInputCache()
					self:PopulateInputCache()
					self:PopulateActions()
					refresh_menu_item(parent_menu_id,"qc_menu_bind_button_" .. tostring(action_id),managers.localization:text("qc_bind_status_title",{KEYNAME=button_display_name}))
				end
				
				self:Save()
				self._callback_bind_button = nil
			end
			QuickChat:AddDelayedCallback("quickchat_inputlistener",callback(QuickChat,QuickChat,"AddControllerInputListener"),0.1,true)
		end
		
		return menu_callback
	end
	--end of callback generator
	
	for i,radial_id in ipairs(radial_keys) do 
		local radial_data = QuickChat._radial_menu_params[radial_id]
		
		local current_button,current_is_mouse_button = QuickChat:GetButtonByAction("radial",radial_id)
		
		--unique name used to prevent collision between ids of radial actions and normal actions
		local action_id = QuickChat:GetActionDisplayName("radial",radial_id)
		
		local radial_menu_name
		if radial_data.name_id then
			radial_menu_name = managers.localization:text(radial_data.name_id)
		else
			radial_menu_name = radial_id
		end
		
		local menu_callback = generate_menu_callback("radial",radial_id)
		
		local current_binding_text
		if current_button then
			current_binding_text = managers.localization:text("qc_bind_status_title",{KEYNAME=get_button_display_name(current_button,current_is_mouse_button)})
		else
			current_binding_text = managers.localization:text("qc_bind_status_unbound")
		end
		add_binding_button({
			id = action_id,
			header_title = managers.localization:text("qc_menu_keybind_radial_title",{NAME=action_id}),
			header_desc = managers.localization:text("qc_menu_keybind_radial_desc"),
			button_title = current_binding_text,
			button_desc = managers.localization:text("qc_bind_status_desc"),
			callback = menu_callback,
			parent_menu_id = parent_menu_id
		})
	end
	
	
	do -- quick ping bind
		local current_binding_text
		local current_button,current_is_mouse_button = QuickChat:GetButtonByAction("quick_ping","")
		if current_button then
			current_binding_text = managers.localization:text("qc_bind_status_title",{KEYNAME=get_button_display_name(current_button,current_is_mouse_button)})
		else
			current_binding_text = managers.localization:text("qc_bind_status_unbound")
		end
		
		add_binding_button({
			id = "quick_ping",
			header_title = managers.localization:text("qc_menu_keybind_quick_ping_title"),
			header_desc = managers.localization:text("qc_menu_keybind_quick_ping_desc"),
			button_title = current_binding_text,
			button_desc = managers.localization:text("qc_bind_status_desc"),
			callback = generate_menu_callback("quick_ping",""),
			parent_menu_id = parent_menu_id
		})
	end
	
	do -- clear own waypoints bind
		local current_binding_text
		local current_button,current_is_mouse_button = QuickChat:GetButtonByAction("waypoints_clear_own","")
		if current_button then
			current_binding_text = managers.localization:text("qc_bind_status_title",{KEYNAME=get_button_display_name(current_button,current_is_mouse_button)})
		else
			current_binding_text = managers.localization:text("qc_bind_status_unbound")
		end
		
		add_binding_button({
			id = "waypoints_clear_own",
			header_title = managers.localization:text("qc_menu_keybind_clear_my_waypoints_title"),
			header_desc = managers.localization:text("qc_menu_keybind_clear_my_waypoints_desc"),
			button_title = current_binding_text,
			button_desc = managers.localization:text("qc_bind_status_desc"),
			callback = generate_menu_callback("waypoints_clear_own",""),
			parent_menu_id = parent_menu_id
		})
	end
		
	do -- clear all waypoints bind
		local current_binding_text
		local current_button,current_is_mouse_button = QuickChat:GetButtonByAction("waypoints_clear_all","")
		if current_button then
			current_binding_text = managers.localization:text("qc_bind_status_title",{KEYNAME=get_button_display_name(current_button,current_is_mouse_button)})
		else
			current_binding_text = managers.localization:text("qc_bind_status_unbound")
		end
		add_binding_button({
			id = "waypoints_clear_all",
			header_title = managers.localization:text("qc_menu_keybind_clear_all_waypoints_title"),
			header_desc = managers.localization:text("qc_menu_keybind_clear_all_waypoints_desc"),
			button_title = current_binding_text,
			button_desc = managers.localization:text("qc_bind_status_desc"),
			callback = generate_menu_callback("waypoints_clear_all",""),
			parent_menu_id = parent_menu_id
		})
	end
	
	
	-- populate settings
	
	local function validate(value,value_type)
		if value_type == "boolean" then
			return value == "on"
		elseif value_type == "number" then
			return tonumber(value)
		end
		return value
	end
	
	
	
	local selected_lang_index = 1
	local selected_lang_id = QuickChat:GetUserLanguage()
	local user_lang_callback_id = "callback_qc_set_user_language"
	
	
	-- populate language items
	
	local lang_items = {} -- index : loc(qc_this_language)
	local lang_ids = {} -- index : code2
	
	
	for lang_id,lang_data in pairs(QuickChat._language_data) do
		table.insert(lang_ids,1,lang_id)
	end
	table.sort(lang_ids,function(a,b) -- sort by localized name
		local data_a = QuickChat._language_data[a]
		local data_b = QuickChat._language_data[b]
		return data_a.lang_loc_name < data_b.lang_loc_name
	end)
	for i,lang_id in ipairs(lang_ids) do
		lang_items[i] = QuickChat._language_data[lang_id].lang_loc_id
		if lang_id == selected_lang_id then
			selected_lang_index = i
		end
	end
	
	MenuCallbackHandler[user_lang_callback_id] = function(this,item)
		local selected_index = validate(item:value(),"number")
		local lang_id = lang_ids[selected_index]
		QuickChat:ChooseLanguage(lang_id)
		QuickChat.settings.user_language = lang_id
		QuickChat:SaveSettings()
		
		QuickChat:OnLocalizationChanged()
	end
	
	local ping_sound_index = 1
	local acknowledge_sound_index = 1
	local unacknowledge_sound_index = 1
	local sound_id_ping = QuickChat:GetWaypointSfxId()
	local sound_id_acknowledge = QuickChat:GetAcknowledgedSfxId()
	local sound_id_unacknowledge = QuickChat:GetUnacknowledgedSfxId()
	
	local sound_ids = {} -- index:id 
	local sound_items = {} -- index:loc_id
	local sound_locs = {} -- loc_id:str
	
	for id,path in pairs(QuickChat._ping_sounds) do 
		sound_ids[#sound_ids+1] = id -- create an array in which to sort the sound selections
	end
	table.sort(sound_ids,function(a,b)
		-- sort selections alphabetically
		return managers.localization:text(a) < managers.localization:text(b)
	end)
	for i,id in ipairs(sound_ids) do
		local loc_str = "qc_menu_snd_" .. id
		sound_items[i] = loc_str
		sound_locs[loc_str] = id
		-- multiplechoice options must be localized (afaik) even if you have the "localized" flag set to false
		-- so "localize" the sound by generating a unique loc id for it, and setting the sound id to the "localized" string
		
		-- assign the proper selection index for each option,
		-- so that the multiplechoice has your current sound already visually selected when you enter the menu
		if id == sound_id_ping then
			ping_sound_index = i
		end
		if id == sound_id_acknowledge then
			acknowledge_sound_index = i
		end
		if id == sound_id_unacknowledge then
			unacknowledge_sound_index = i
		end
	end
	QuickChat:AddLocStrings(sound_locs)
	
	local ping_sound_callback_id = "callback_menu_waypoints_ping_sound_id"
	MenuCallbackHandler[ping_sound_callback_id] = function(this,item)
		local selected_index = validate(item:value(),"number")
		local id = sound_ids[selected_index]
		if id then
			QuickChat.settings.waypoints_ping_sound_id = id
			-- preview sound
			local path = QuickChat._ping_sounds[id]
			if path then
				local src
				if managers.player:local_player() then
					src = XAudio.UnitSource:new(XAudio.PLAYER,XAudio.Buffer:new(path))
				else
					src = XAudio.Source:new(XAudio.Buffer:new(path))
				end
				src._auto_pause = false
				src:set_volume(QuickChat:GetWaypointSfxVolume())
			end
		end
		QuickChat:SaveSettings()
	end
	
	local acknowledge_sound_callback_id = "callback_menu_waypoints_acknowledge_sound_id"
	MenuCallbackHandler[acknowledge_sound_callback_id] = function(this,item)
		local selected_index = validate(item:value(),"number")
		local id = sound_ids[selected_index]
		if id then
			QuickChat.settings.waypoints_acknowledge_sound_id = id
			-- preview sound
			local path = QuickChat._ping_sounds[id]
			if path then
				local src
				if managers.player:local_player() then
					src = XAudio.UnitSource:new(XAudio.PLAYER,XAudio.Buffer:new(path))
				else
					src = XAudio.Source:new(XAudio.Buffer:new(path))
				end
				src._auto_pause = false
				src:set_volume(QuickChat:GetAcknowledgedSfxVolume())
			end
		end
		QuickChat:SaveSettings()
	end
	
	local unacknowledge_sound_callback_id = "callback_menu_waypoints_unacknowledge_sound_id"
	MenuCallbackHandler[unacknowledge_sound_callback_id] = function(this,item)
		local selected_index = validate(item:value(),"number")
		local id = sound_ids[selected_index]
		if id then
			QuickChat.settings.waypoints_unacknowledge_sound_id = id
			-- preview sound
			local path = QuickChat._ping_sounds[id]
			if path then
				local src
				if managers.player:local_player() then
					src = XAudio.UnitSource:new(XAudio.PLAYER,XAudio.Buffer:new(path))
				else
					src = XAudio.Source:new(XAudio.Buffer:new(path))
				end
				src._auto_pause = false
				src:set_volume(QuickChat:GetUnacknowledgedSfxVolume())
			end
		end
		QuickChat:SaveSettings()
	end
	
	
	local settings_items = { -- block of items that (mostly) need callbacks generated
		{
			type = "toggle",
			id = "menu_waypoints_alert_on_registration",
			title = "qc_menu_waypoints_alert_on_registration_title",
			desc = "qc_menu_waypoints_alert_on_registration_desc",
			value = "waypoints_alert_on_registration",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "divider",
			id = "menu_waypoints_handshake_divider",
			size = 8,
			skip_callback = true
		},
		{
			type = "toggle",
			id = "menu_compatibility_gcw_enabled",
			title = "qc_menu_compatibility_gcw_enabled_title",
			desc = "qc_menu_compatibility_gcw_enabled_desc",
			value = "compatibility_gcw_enabled",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "divider",
			id = "menu_waypoints_handshake_divider",
			size = 8,
			skip_callback = true
		},
		--[[
		{
			type = "toggle",
			id = "menu_waypoints_max_count",
			title = "waypoints_max_count_title",
			desc = "waypoints_max_count_desc",
			value = "waypoints_max_count",
			value_type = "number"
		},
		--]]
		{
			type = "toggle",
			id = "menu_waypoints_auto_icon",
			title = "qc_menu_waypoints_auto_icon_title",
			desc = "qc_menu_waypoints_auto_icon_desc",
			value = "waypoints_auto_icon",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "divider",
			id = "menu_waypoints_autoicon_divider",
			size = 8,
			skip_callback = true
		},
		{
			type = "slider",
			id = "menu_waypoints_aim_dot_threshold",
			title = "qc_menu_waypoints_aim_dot_threshold_title",
			desc = "qc_menu_waypoints_aim_dot_threshold_desc",
			value = "waypoints_aim_dot_threshold",
			min = 0.9,
			max = 1,
			step = 0.001,
			show_value = true,
			skip_callback = false,
			value_type = "number"
		},
		{
			type = "multiple_choice",
			id = "menu_waypoints_attenuate_alpha_mode",
			title = "qc_menu_waypoints_attenuate_alpha_mode_title",
			desc = "qc_menu_waypoints_attenuate_alpha_mode_desc",
			items = {
				"qc_menu_waypoints_attenuate_alpha_mode_option_hide_disabled",
				"qc_menu_waypoints_attenuate_alpha_mode_option_hide_center",
				"qc_menu_waypoints_attenuate_alpha_mode_option_hide_edges"
			},
			skip_callback = false,
			value = "waypoints_attenuate_alpha_mode",
			value_type = "number"
		},
		{
			type = "slider",
			id = "menu_waypoints_attentuate_dot_threshold",
			title = "qc_menu_waypoints_attentuate_dot_threshold_title",
			desc = "qc_menu_waypoints_attentuate_dot_threshold_desc",
			value = "waypoints_attenuate_dot_threshold",
			min = 0.9,
			max = 1,
			step = 0.001,
			show_value = true,
			skip_callback = false,
			value_type = "number"
		},
		{
			type = "slider",
			id = "menu_waypoints_attenuate_alpha_min",
			title = "qc_menu_waypoints_attenuate_alpha_min_title",
			desc = "qc_menu_waypoints_attenuate_alpha_min_desc",
			value = "waypoints_attenuate_alpha_min",
			min = 0,
			max = 1,
			step = 0.1,
			show_value = true,
			skip_callback = false,
			value_type = "number"
		},
		{
			type = "divider",
			id = "menu_waypoints_attenuate_divider",
			size = 16,
			skip_callback = true
		},
		{
			type = "toggle",
			id = "menu_waypoints_ping_sound_enabled",
			title = "qc_menu_waypoints_ping_sound_enabled_title",
			desc = "qc_menu_waypoints_ping_sound_enabled_desc",
			value = "waypoints_ping_sound_enabled",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "slider",
			id = "menu_waypoints_ping_sound_volume",
			title = "qc_menu_waypoints_generic_sound_volume_title",
			desc = "qc_menu_waypoints_generic_sound_volume_desc",
			value = "waypoints_ping_sound_volume",
			min = 0,
			max = 1,
			step = 0.1,
			show_value = true,
			skip_callback = false,
			value_type = "number"
		},
		{
			type = "multiple_choice",
			id = "menu_waypoints_ping_sound_id",
			title = "qc_menu_waypoints_generic_sound_id_title",
			desc = "qc_menu_waypoints_generic_sound_id_desc",
			items = table.deep_map_copy(sound_items),
			callback = ping_sound_callback_id,
			skip_callback = true,
			value_raw = ping_sound_index,
			value_type = "number"
		},
		{
			type = "divider",
			id = "menu_waypoints_pingsnd_divider",
			size = 8,
			skip_callback = true
		},
		{
			type = "toggle",
			id = "menu_waypoints_acknowledged_sound_enabled",
			title = "qc_menu_waypoints_acknowledged_sound_enabled_title",
			desc = "qc_menu_waypoints_acknowledged_sound_enabled_desc",
			value = "waypoints_acknowledge_sound_enabled",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "slider",
			id = "menu_waypoints_acknowledge_sound_volume",
			title = "qc_menu_waypoints_generic_sound_volume_title",
			desc = "qc_menu_waypoints_generic_sound_volume_desc",
			value = "waypoints_acknowledge_sound_volume",
			min = 0,
			max = 1,
			step = 0.1,
			show_value = true,
			skip_callback = false,
			value_type = "number"
		},
		{
			type = "multiple_choice",
			id = "menu_waypoints_acknowledge_sound_id",
			title = "qc_menu_waypoints_generic_sound_id_title",
			desc = "qc_menu_waypoints_generic_sound_id_desc",
			items = table.deep_map_copy(sound_items),
			callback = acknowledge_sound_callback_id,
			skip_callback = true,
			value_raw = acknowledge_sound_index,
			value_type = "number"
		},
		{
			type = "divider",
			id = "menu_waypoints_acksnd_divider",
			size = 8,
			skip_callback = true
		},
		{
			type = "toggle",
			id = "menu_waypoints_unacknowledge_sound_enabled",
			title = "qc_menu_waypoints_unacknowledge_sound_enabled_title",
			desc = "qc_menu_waypoints_unacknowledge_sound_enabled_desc",
			value = "waypoints_unacknowledge_sound_enabled",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "slider",
			id = "menu_waypoints_unacknowledge_sound_volume",
			title = "qc_menu_waypoints_generic_sound_volume_title",
			desc = "qc_menu_waypoints_generic_sound_volume_desc",
			value = "waypoints_unacknowledge_sound_volume",
			min = 0,
			max = 1,
			step = 0.1,
			show_value = true,
			skip_callback = false,
			value_type = "number"
		},
		{
			type = "multiple_choice",
			id = "menu_waypoints_unacknowledge_sound_id",
			title = "qc_menu_waypoints_generic_sound_id_title",
			desc = "qc_menu_waypoints_generic_sound_id_desc",
			items = table.deep_map_copy(sound_items),
			callback = unacknowledge_sound_callback_id,
			skip_callback = true,
			value_raw = unacknowledge_sound_index,
			value_type = "number"
		},
		{
			type = "divider",
			id = "menu_waypoints_unacksnd_divider",
			size = 16,
			skip_callback = true
		},
		{
			type = "multiple_choice",
			id = "qc_menu_user_language",
			title = "qc_menu_user_language_title",
			desc = "qc_menu_user_language_title_desc",
			items = table.deep_map_copy(lang_items),
			callback = user_lang_callback_id,
			skip_callback = true,
			value_raw = selected_lang_index,
			value_type = "number"
		},
		{
			type = "divider",
			id = "menu_waypoints_lang_divider",
			size = 8,
			skip_callback = true
		},
		{
			type = "toggle",
			id = "menu_debug_logs_enabled",
			title = "qc_menu_debug_logs_enabled_title",
			desc = "qc_menu_debug_logs_enabled_desc",
			value = "debug_logs",
			skip_callback = false,
			value_type = "boolean"
		},
		{
			type = "toggle",
			id = "menu_debug_draw_enabled",
			title = "qc_menu_debug_draw_enabled_title",
			desc = "qc_menu_debug_draw_enabled_desc",
			value = "debug_draw",
			skip_callback = false,
			value_type = "boolean"
		}
	}
	for i,menu_data in ipairs(settings_items) do
--	for i=#settings_items,1,-1 do
--		local menu_data = settings_items[i]
		local value_id = menu_data.value
		if value_id and not menu_data.skip_callback then
			local callback_id = "callback_" .. menu_data.id
			local value_type = menu_data.value_type
			MenuCallbackHandler[callback_id] = function(this, item)
				local value = item:value()
				QuickChat.settings[value_id] = validate(value,value_type)
				QuickChat:SaveSettings()
			end
			--menu_data.value = QuickChat.settings[value_id]
			menu_data.default_value = QuickChat.default_settings[value_id]
			menu_data.callback = callback_id
			-- menu_data.items = {}
			-- menu_data.binding = ""
			-- menu_data.button = ""
			-- menu_data.connection_name = "" 
		end
		QuickChat.add_menu_option_from_data(1+#settings_items-i,menu_data,QuickChat.MENU_IDS.MENU_SETTINGS,QuickChat.settings,QuickChat.default_settings)
--		menu_data.menu_id = QuickChat.MENU_IDS.MENU_SETTINGS
--		table.insert(binding_items,#binding_items+1,menu_data)
	end
	
	for i,menu_data in ipairs(binding_items) do
		QuickChat.add_menu_option_from_data(1+#binding_items-i,menu_data,menu_data.menu_id,QuickChat.settings,QuickChat.default_settings)
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus","QuickChat_MenuManagerBuildCustomMenus",function(menu_manager, nodes)
	
	local qc_main_menu = MenuHelper:BuildMenu(
		QuickChat.MENU_IDS.MENU_MAIN,{
			area_bg = "none",
			back_callback = "callback_menu_quickchat_back",
			focus_changed_callback = nil
		}
	)
	nodes[QuickChat.MENU_IDS.MENU_MAIN] = qc_main_menu
	MenuHelper:AddMenuItem(nodes.blt_options,QuickChat.MENU_IDS.MENU_MAIN,"qc_menu_main_title","qc_menu_main_desc")
	
	-- todo integrate this into the menu building helper func
	nodes[QuickChat.MENU_IDS.MENU_BINDS] = MenuHelper:BuildMenu(
		QuickChat.MENU_IDS.MENU_BINDS,{
			area_bg = "none",
			back_callback = nil,
			focus_changed_callback = nil
		}
	)
	MenuHelper:AddMenuItem(qc_main_menu,QuickChat.MENU_IDS.MENU_BINDS,"qc_menu_binds_title","qc_menu_binds_desc")
	
	
	nodes[QuickChat.MENU_IDS.MENU_SETTINGS] = MenuHelper:BuildMenu(
		QuickChat.MENU_IDS.MENU_SETTINGS,{
			area_bg = "none",
			back_callback = nil,
			focus_changed_callback = nil
		}
	)
	MenuHelper:AddMenuItem(qc_main_menu,QuickChat.MENU_IDS.MENU_SETTINGS,"qc_menu_settings_title","qc_menu_settings_desc")

	
	for menu_id,menu_data in pairs(QuickChat._populated_menus) do 
		nodes[menu_id] = MenuHelper:BuildMenu(
			menu_id,
			{
				area_bg = menu_data.area_bg,
				back_callback = menu_data.back_callback,
				focus_changed_callback = menu_data.focus_changed_callback
			}
		)
	end
	
	for _,menu_data in ipairs(QuickChat._queued_menus) do 
		local parent_menu_id = menu_data.parent_menu_id
		local menu = MenuHelper:GetMenu(parent_menu_id)
		local submenu_id = menu_data.submenu_id
		local title = menu_data.title
		local desc = menu_data.desc
		local priority = menu_data.priority
		if menu then 
			MenuHelper:AddMenuItem(menu,submenu_id,title,desc,priority)
		end
	end
	
end)

Hooks:Add("MenuManagerInitialize","QuickChat_MenuManagerInitialize",function(menu_manager)
	MenuCallbackHandler.callback_menu_quickchat_back = function()
		QuickChat:RemoveControllerInputListener()
		QuickChat:CloseAllRadialMenus()
		QuickChat:ClearInputCache()
		QuickChat:PopulateInputCache()
		QuickChat:PopulateActions()
	end
end)

Hooks:Add("LocalizationManagerPostInit","QuickChat_LocalizationManagerPostInit",function(loc)
	QuickChat._is_loc_loaded = true
	if QuickChat._loc_strings_load_queue then
		for i=#QuickChat._loc_strings_load_queue,1,-1 do 
			local strings = table.remove(QuickChat._loc_strings_load_queue,i)
			loc:add_localized_strings(strings)
		end
		QuickChat._loc_strings_load_queue = nil
	end
end)

Hooks:Add("NetworkReceivedData","QuickChat_NetworkReceivedData",function(sender, message_id, message_body)
	local peer = managers.network:session():peer(sender)
	if managers.chat and managers.chat:is_peer_muted(peer) then
		return
	end
	if message_id == QuickChat.SYNC_MESSAGE_QC_HANDSHAKE then
		QuickChat:RegisterPeerById(sender,message_body)
	elseif peer._quickchat_version == QuickChat.API_VERSION then
		if message_id == QuickChat.SYNC_MESSAGE_PRESET then
			QuickChat:ReceivePresetMessage(sender,message_body)
		elseif message_id == QuickChat.SYNC_MESSAGE_WAYPOINT_ADD then
			QuickChat:ReceiveAddWaypoint(sender,message_body)
		elseif message_id == QuickChat.SYNC_MESSAGE_WAYPOINT_REMOVE then
			QuickChat:ReceiveRemoveWaypoint(sender,message_body)
		elseif message_id == QuickChat.SYNC_MESSAGE_WAYPOINT_ACKNOWLEDGE then
			QuickChat:ReceiveAcknowledgeWaypoint(sender,message_body)
		end
	elseif QuickChat:IsGCWCompatibilityReceiveEnabled() then
		if not _G.CustomWaypoints then -- if local player has gcw installed, let gcw handle it
			if message_id == QuickChat.SYNC_TDLQGCW_WAYPOINT_PLACE then
				QuickChat:ReceiveGCWPlace(sender,message_body)
			elseif message_id == QuickChat.SYNC_TDLQGCW_WAYPOINT_UNIT then
				QuickChat:ReceiveGCWPlace(sender,message_body)
			elseif message_id == QuickChat.SYNC_TDLQGCW_WAYPOINT_REMOVE then
				QuickChat:ReceiveGCWRemove(sender,message_body)
			end
		end
	end
end)

Hooks:Add("BaseNetworkSessionOnLoadComplete","QuickChat_OnLoaded",callback(QuickChat,QuickChat,"Setup"))

Hooks:Add("GameSetupUpdate","QuickChat_GameUpdate",callback(QuickChat,QuickChat,"Update","GameSetupUpdate"))
Hooks:Add("GameSetupPausedUpdate","QuickChat_GamePausedUpdate",callback(QuickChat,QuickChat,"Update","GameSetupPausedUpdate"))
Hooks:Add("MenuUpdate","QuickChat_MenuUpdate",callback(QuickChat,QuickChat,"Update","MenuUpdate"))

QuickChat:CheckResourcesAdded()

