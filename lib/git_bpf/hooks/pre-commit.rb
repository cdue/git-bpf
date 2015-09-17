#!/usr/bin/env ruby

branch = `git branch | grep '*' | cut -f2 -d' '`.chomp

if branch.empty?
  STDERR.puts "KO: unable to find current branch name."
  exit 1
end

if branch == "master"
	puts "You are about to commit on 'master' branch."
    puts "Are you sure you want to do it? Are you a Release Manager?"
    puts "If you really want to do this, commit again using '--no-verify' option."
    exit 1
end
