-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local tyrannical = require("tyrannical")

local xrandr = require("xrandr")

local lain = require("lain")
local helpers = require("lain.helpers")
local markup = lain.util.markup

-- Battery
local battery_trayicon = wibox.widget.imagebox(beautiful.widget_battery)
local battery_traywidget = lain.widget.bat({
	ac = "AC",
    settings = function()
        if bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                --widget:set_markup(markup.font(beautiful.font, " AC "))
                widget:set_markup(" AC ")
                battery_trayicon:set_image(beautiful.widget_ac)
                return
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                battery_trayicon:set_image(beautiful.widget_battery_empty)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                battery_trayicon:set_image(beautiful.widget_battery_low)
            else
                battery_trayicon:set_image(beautiful.widget_battery)
            end
            widget:set_markup(" " .. bat_now.perc .. "% ")
            --widget:set_markup(markup.font(beautiful.font, " " .. bat_now.perc .. "% "))
        else
            widget:set_markup(markup.font(beautiful.font, " AC "))
            battery_trayicon:set_image(beautiful.widget_ac)
        end
    end
})

-- Pulse volume
local volume_trayicon = wibox.widget.imagebox(beautiful.widget_vol)
local volume_traywidget = lain.widget.pulse({
    settings = function()
    	if tonumber(volume_now.left) == nil then
    		volume_trayicon:set_image(beautiful.widget_vol_mute)
        else
        	if volume_now.muted == "yes" then
            	volume_trayicon:set_image(beautiful.widget_vol_mute)
        	elseif tonumber(volume_now.left) == 0 then
            	volume_trayicon:set_image(beautiful.widget_vol_no)
        	elseif tonumber(volume_now.left) <= 50 then
            	volume_trayicon:set_image(beautiful.widget_vol_low)
        	else
            	volume_trayicon:set_image(beautiful.widget_vol)
        	end

        widget:set_markup(markup.font(beautiful.font, " " .. volume_now.left .. "% "))
    	end
    end
})

-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

local calendar = lain.widget.calendar({
	attach_to = {mytextclock},
	notification_preset	= {
	    font = "Monospace 10",
    	fg   = "#FFFFFF",
    	bg   = "#000000",
		position = "bottom_right"
	}
})

local taskwarrior_widget = lain.widget.contrib.task.attach(nil, {
    notification_preset = {
        font = "Monospace 10",
        icon = helpers.icons_dir .. "/taskwarrior.png",
        position = "bottom_middle"
    }
})

local weather_widget = lain.widget.weather({
	city_id = "703448",
    notification_preset = {
        font = "Monospace 10",
        fg   = "#FFFFFF",
        bg   = "#000000",
        position = "bottom_right"
    },
	settings = function()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(" " .. units .. " °C")
    end
})

local separators = lain.util.separators
local arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")

-- Load Debian menu entries
-- require("debian.menu")

awful.spawn.with_shell("~/.config/awesome/autorun.sh")
-- awful.util.spawn_with_shell("/usr/bin/run_once /usr/bin/blueman-applet")
-- awful.util.spawn_with_shell("xautolock -time 10 -locker 'i3lock -u -e -t -i ~/.config/awesome/mytheme/the_witcher1.png' & ")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.get_configuration_dir() .. "themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal --hide-menubar --hide-scrollbar"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
modkey_alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
	awful.button({ }, 1,
		function (c)
			client.focus = c
			c:raise()
		end
	)
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    -- awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    --tyrannical.settings.default_layout = awful.layout.suit.floating

    tyrannical.tags = {
        {
            name        = "1",                 -- Call the tag "Term"
            init        = true,                   -- Load the tag on startup
            exclusive   = true,                   -- Refuse any other type of clients (by classes)
            screen      = {1},                  -- Create this tag on screen 1 and screen 2
            layout      = awful.layout.suit.max, -- Use the tile layout
            -- instance    = {"dev", "ops"},         -- Accept the following instances. This takes precedence over 'class'
            class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
                "xterm" , "urxvt" , "aterm","URxvt","XTerm","konsole","terminator","gnome-terminal", "xfce4-terminal" }
        },
        {
            name        = "2:web",
            init        = true,
            exclusive   = true,
          --icon        = "~net.png",                 -- Use this icon for the tag (uncomment with a real path)
            screen      = {1},
            layout      = awful.layout.suit.max,      -- Use the max layout
            class = {
                "Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
                "Chromium"      , "nightly"        , "minefield", "Google-chrome"     }
        },
        {
            name       = "3:web2",
            init       = true,
            exclusive  = true,
            screen     = {1},
            layout     = awful.layout.suit.max,
            no_focus_stealing_in = true,
            no_focus_stealing_out = true,
            class      = {
                "Skypeforlinux", "Slack"
            }
        },
        {
            name       = "4:dev",
            init       = true,
            exclusive  = false,
            screen     = {1},
            layout     = awful.layout.suit.tile
        },
        {
            name       = "5",
            init       = true,
            exclusive  = true,
            screen     = {1},
            layout     = awful.layout.suit.max,
            class      = {
                "TelegramDesktop"
            }
        },
        {
            name      = "9:vpn",
            init      = false,
            exclusive = true,
            screen    = {1},
            layout    = awful.layout.suit.max,
            class     = {
                "Vpnui"
            }
        }
    }

    -- Ignore the tag "exclusive" property for the following clients (matched by classes)
    tyrannical.properties.intrusive = {
        "gitk", "Emacs24", "Gnome-calculator", "Meld", "Sublime_text"
    }

    tyrannical.properties.placement = {
       calculator = awful.placement.centered
    }

    tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client
    tyrannical.settings.no_focus_stealing_out = true


    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            arrl_dl,
            weather_widget.icon,
            weather_widget.widget,
            arrl_dl,
            volume_trayicon,
            volume_traywidget.widget,
        	arrl_dl,
        	battery_trayicon,
        	battery_traywidget.widget,
            arrl_dl,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "Right",
        function ()
            awful.client.focus.byidx(1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Left",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),


    -- Standard program
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "x", function()
            xrandr.xrandr()
            end,
           {description = "Xrandr" , group = "awesome"}),

    awful.key({ modkey, }, "t", function () lain.widget.contrib.task.show(scr) end),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Menubar
    --awful.key({ modkey }, "p", function() menubar.show() end,
    --          {description = "show the menubar", group = "launcher"})
    awful.key({ modkey }, "p",
        function ()
--            awful.util.spawn("dmenu_run -i -p 'Run command:' -nb ''" ..
--                                 beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal ..
--                                 "' -sb '" .. beautiful.bg_focus ..
            --                                 "' -sf '" .. beautiful.fg_focus .. "''")
            awful.spawn.with_shell("dmenu_path | dmenu_run -i -p 'Run command:' ")
        end,
        {description = "show the menubar", group = "launcher"}),

    awful.key({ modkey }, "l",
        function()
            awful.spawn.with_shell("xautolock -locknow")
        end,
        {description = "Lock desktop", group = "awesome"}),

    awful.key({ Any }, "XF86AudioRaiseVolume",
        function()
            awful.spawn(string.format("pactl set-sink-volume %d +5%%", volume_traywidget.device))
            volume_traywidget.update()
        end,
        {description = "Raise volume", group = "Volume"}),

    awful.key({ Any }, "XF86AudioLowerVolume",
        function()
            awful.spawn(string.format("pactl set-sink-volume %d -5%%", volume_traywidget.device))
            volume_traywidget.update()
        end,
        {description = "Lower volume", group = "Volume"}),

    awful.key({ Any }, "XF86AudioMute",
        function()
            awful.spawn(string.format("pactl set-sink-mute %d toggle", volume_traywidget.device))
            volume_traywidget.update()
        end,
        {description = "Mute volume", group = "Volume"})


--    awful.key({ Any }, "XF86MonBrightnessUp",
--        function ()
--            awful.spawn.with_shell("xbacklight -inc 5")
--        end,
--        {description = "increase brightness", group = "Brightness"}),

--    awful.key({ Any }, "XF86MonBrightnessDown",
--        function ()
--            awful.spawn.with_shell("xbacklight -dec 5")
--        end,
--        {description = "decrease brightness", group = "Brightness"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag view"}),
        -- Toggle tag display.
        --awful.key({ modkey, "Control" }, "#" .. i + 9,
        --          function ()
        --              local screen = awful.screen.focused()
        --              local tag = screen.tags[i]
        --              if tag then
        --                 awful.tag.viewtoggle(tag)
        --              end
        --          end,
        --          {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag shift"})
        -- Toggle tag on focused client.
        --awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        --          function ()
        --              if client.focus then
        --                  local tag = client.focus.screen.tags[i]
        --                  if tag then
        --                      client.focus:toggle_tag(tag)
        --                  end
        --              end
        --          end,
        --          {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

--    awful.titlebar(c) : setup {
--        { -- Left
--            awful.titlebar.widget.iconwidget(c),
--            buttons = buttons,
--            layout  = wibox.layout.fixed.horizontal
--        },
--        { -- Middle
--            { -- Title
--                align  = "center",
--                widget = awful.titlebar.widget.titlewidget(c)
--            },
--            buttons = buttons,
--            layout  = wibox.layout.flex.horizontal
--        },
--        { -- Right
--            awful.titlebar.widget.floatingbutton (c),
--            awful.titlebar.widget.maximizedbutton(c),
--            awful.titlebar.widget.stickybutton   (c),
--            awful.titlebar.widget.ontopbutton    (c),
--            awful.titlebar.widget.closebutton    (c),
--            layout = wibox.layout.fixed.horizontal()
--        },
--        layout = wibox.layout.align.horizontal
--    }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
