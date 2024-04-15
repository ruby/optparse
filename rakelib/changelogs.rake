task "build" => "changelogs"

changelog = proc do |output, ver = nil, prev = nil|
  ver &&= Gem::Version.new(ver)
  range = [[prev], [ver, "HEAD"]].map {|ver, branch| ver ? "v#{ver.to_s}" : branch}.compact.join("..")
  cmd = %W[git log --date=iso --format=fuller --topo-order --no-merges
               --invert-grep --fixed-strings --grep=#{'[ci skip]'}
               #{range} --]
  IO.popen(cmd) do |log|
    line = log.gets
    FileUtils.mkpath(File.dirname(output))
    File.open(output, "wb") do |f|
      f.print "-*- coding: utf-8 -*-\n\n", line
      log.each_line do |line|
        line.sub!(/^(?!:)(?:Author|Commit)?(?:Date)?: /, '  \&')
        line.sub!(/ +$/, '')
        f.print(line)
      end
    end
  end
end

tags = IO.popen(%w[git tag -l v[0-9]*]).grep(/v(.*)/) {$1}
unless tags.empty?
  tags.sort_by! {|tag| tag.scan(/\d+/).map(&:to_i)}
  tags.pop if IO.popen(%W[git log --format=%H v#{tags.last}..HEAD --], &:read).empty?
  tags.inject(nil) do |prev, tag|
    task("logs/ChangeLog-#{tag}") {|t| changelog[t.name, tag, prev]}
    tag
  end
end

desc "Make ChangeLog"
task "ChangeLog", [:ver, :prev] do |t, ver: nil, prev: tags.last|
  changelog[t.name, ver, prev]
end

changelogs = ["ChangeLog", *tags.map {|tag| "logs/ChangeLog-#{tag}"}]
task "changelogs" => changelogs
CLOBBER.concat(changelogs) << "logs"
