local notification, removed, opened
local state = {}
local failure = { code = 2 }
ya = {
	sync = function(fn)
		return function(...) return fn(state, ...) end
	end,
	notify = function(value) notification = value end,
	emit = function() opened = true end,
}
cx = {
	active = {
		current = {
			hovered = {
				url = "/tmp/example.tar",
				name = "example.tar",
				mime = function() return "application/x-tar" end,
			},
		},
	},
}
rt = {
	plugin = {
		previewers = {
			match = function()
				return setmetatable({}, {
					__pairs = function() return next, { { name = "archive" } }, nil end,
				})
			end,
		},
	},
}
Url = function(path) return path end
fs = {
	create = function() return true end,
	unique = function(_, path) return path end,
	remove = function(_, path) removed = path end,
}
Command = setmetatable({ PIPED = 1 }, {
	__call = function()
		local command = {}
		function command:arg() return self end
		function command:stdout() return self end
		function command:stderr() return self end
		function command.output() return nil, failure end
		return command
	end,
})

local plugin = dofile(arg[1] or "main.lua")
plugin:entry { args = { "open" } }
assert(notification and notification.level == "error", "a failed command must show an error")
assert(
	notification.content:find("fuse-archive", 1, true),
	"the error must identify the absent executable"
)
assert(
	notification.content:find("Install", 1, true),
	"the error must explain how to resolve a missing executable"
)
assert(
	removed and removed:find("example.tar", 1, true),
	"a failed mount must remove its empty directory"
)
assert(not opened, "a failed mount must not change directory")

failure = setmetatable({ code = 13 }, { __tostring = function() return "permission denied" end })
plugin:entry { args = { "open" } }
assert(notification.content == "permission denied", "other command errors must retain their cause")
print "archive-mount: entry errors and previewer iterator passed"
