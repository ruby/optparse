class << (helper = Bundler::GemHelper.instance)
  def mainfile
    "lib/#{File.basename(gemspec.loaded_from, ".gemspec")}.rb"
  end

  def update_version
    File.open(mainfile, "r+b") do |f|
      d = f.read
      if d.sub!(/^(\s*OptionParser::Version\s*=\s*)".*"/) {$1 + gemspec.version.to_s.dump}
        f.rewind
        f.truncate(0)
        f.print(d)
      end
    end
  end

  def commit_bump
    sh(%W[git -C #{File.dirname(gemspec.loaded_from)} commit -m bump\ up\ to\ #{gemspec.version}
          #{mainfile}])
  end

  def version=(v)
    gemspec.version = v
    update_version
    commit_bump
  end

  def bump(major, minor = 0, teeny = 0, pre: nil)
    self.version = [major, minor, teeny, pre].compact.join(".")
  end

  def next_prerelease(*prefix, num)
    if num
      [*prefix, num.succ]
    else
      "dev.1"
    end
  end
end

major, minor, teeny, *prerelease = helper.gemspec.version.segments

task "bump:dev", [:pre] do |t, pre: helper.next_prerelease(*prerelease)|
  helper.bump(major, minor, teeny, pre: pre)
end

task "bump:teeny", [:pre] do |t, pre: nil|
  helper.bump(major, minor, teeny+1, pre: pre)
end

task "bump:minor", [:pre] do |t, pre: nil|
  helper.bump(major, minor+1, pre: pre)
end

task "bump:major", [:pre] do |t, pre: nil|
  helper.bump(major+1, pre: pre)
end

task "bump" => "bump:teeny"

task "tag" do
  helper.__send__(:tag_version)
end
