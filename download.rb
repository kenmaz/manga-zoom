(1..100).to_a.each do |i|
  name = sprintf("%03d", i)
  cmd = "curl https://image-a.mangabox.me/static/content/reader/5372/c8757e49cb67d2856d576f3d27ee9e84daf9ca56da4c42b93ef997b4e68c274d/sp/#{name}.png?t=1499408620 > #{name}.png"
  system(cmd)
end

