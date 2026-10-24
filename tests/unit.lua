ya = { sync = function(fn) return fn end }
local mount = dofile(arg[1] or "main.lua")

local checks = 0
local function expect(label, actual, expected)
	checks = checks + 1
	assert(
		actual == expected,
		string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual))
	)
end

expect("process id", mount.pid "48213 (yazi) S 1 48213 48213 0\n", 48213)
expect("process name with parentheses", mount.pid "7 (a) b 9) R 1\n", 7)
expect("absent process", mount.pid "", nil)

local path = "/run/user/1000/yazi-archives/42/photos.zip"
expect("mount root", mount.inside(path, path), true)
expect("mount descendant", mount.inside(path .. "/2024/june", path), true)
expect("sibling with a common prefix", mount.inside(path .. ".bak", path), false)
expect("mount parent", mount.inside("/run/user/1000/yazi-archives/42", path), false)

local mounts = { path, "/run/user/1000/yazi-archives/42/music.tar" }
local unused = mount.unused(mounts, { path .. "/2024", "/home/me" })
expect("unused mount count", #unused, 1)
expect("unused mount", unused[1], mounts[2])
expect("all mounts in use", #mount.unused(mounts, { path, mounts[2] .. "/a" }), 0)
expect("no open tabs", #mount.unused(mounts, {}), 2)

local cmdline = "/nix/store/x-archivemount/bin/archivemount\0/home/me/a.zip\0" .. path .. "\0"
expect("archive server", mount.serves(cmdline, path), true)
expect("another mount", mount.serves(cmdline, path .. ".bak"), false)
expect(
	"another program",
	mount.serves("fuse-archive\0/home/me/a.zip\0" .. path .. "\0", path),
	false
)
expect("argument prefix", mount.serves("archivemount\0a\0" .. path .. "/sub\0", path), false)
expect("empty command line", mount.serves("", path), false)

local absent = { code = 2 }
local denied = { code = 13 }
expect("missing executable", mount.missing(absent), true)
expect("permission error", mount.missing(denied), false)
expect("no error", mount.missing(nil), false)

print(string.format("archive-mount: %d checks passed", checks))
