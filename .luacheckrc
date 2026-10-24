std = "lua54"
max_line_length = 100
globals = { "ya" }
read_globals = { "cx", "rt", "fs", "Url", "Command", "ps" }

files["tests/entry.lua"] = {
  globals = { "ya", "cx", "rt", "fs", "Url", "Command" },
}
