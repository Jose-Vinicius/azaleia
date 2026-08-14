#!/usr/bin/env ruby
require "date"

VERSION_FILE = "VERSION"
CHANGELOG_FILE = "CHANGELOG.md"
NOTES_FILE = "RELEASE_NOTES.md"

content = File.read(CHANGELOG_FILE)
match = content.match(/## \[Unreleased\]\n(.*?)(?=\n## \[|\z)/m)
abort "Nenhuma seção [Unreleased] encontrada." unless match

sections = match[1].strip.split(/(?=^### )/)
non_empty = sections.select { |s| s.lines.size > 1 } # descarta subseções vazias

if non_empty.empty?
  warn "Seção [Unreleased] está vazia. Nada pra lançar."
  exit 0
end

cleaned = non_empty.join.strip

bump = :patch
bump = :minor if cleaned =~ /^### Adicionado/m
bump = :major if cleaned =~ /^### Removido/m || cleaned =~ /BREAKING/i

current = File.exist?(VERSION_FILE) ? File.read(VERSION_FILE).strip : "0.0.0"
major, minor, patch = current.split(".").map(&:to_i)
case bump
when :major then major += 1; minor = 0; patch = 0
when :minor then minor += 1; patch = 0
else patch += 1
end
new_version = "#{major}.#{minor}.#{patch}"
date = Date.today.strftime("%Y-%m-%d")
released = "## [#{new_version}] - #{date}\n\n#{cleaned}\n"

fresh = "## [Unreleased]\n### Adicionado\n### Alterado\n### Corrigido\n### Removido\n"
File.write(CHANGELOG_FILE, content.sub(match[0]) { "#{fresh}\n#{released}" })
File.write(VERSION_FILE, new_version)
File.write(NOTES_FILE, released)

puts new_version
