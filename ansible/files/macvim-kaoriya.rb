cask :v1 => 'macvim-kaoriya' do
  if MacOS.release <= :lion
    version '20130911'
    sha256 'd9fc6e38de1852e4ef79e9ea78afa60e606bf45066cff031e349d65748cbfbce'
    url "https://macvim-kaoriya.googlecode.com/files/macvim-kaoriya-#{version}.dmg"
  else
    version '20150314'
    sha256 '267ed80d3f9b4d28a883810324bcff2ee9a4643f91a54ecc7eae5ca75984cc04'
    url "https://github.com/splhack/macvim/releases/download/#{version}/macvim-kaoriya-#{version}.dmg"
    appcast 'https://raw.githubusercontent.com/splhack/macvim-kaoriya/master/latest.xml',
            :sha256 => '52a3723c33014b4c09485a2b70c3da54aae2dd925774e5f8eb9cbd58b7b72e9d'
  end

  name 'MacVim KaoriYa'
  homepage 'https://code.google.com/p/macvim-kaoriya/'
  license :bsd

  app 'MacVim.app'
  depends_on :macos => '>= :lion'
  mvim = 'MacVim.app/Contents/MacOS/mvim'
  executables = %w[macvim-askpass mvim mvimdiff mview mvimex gvim gvimdiff gview gvimex]
  executables += %w[vi vim vimdiff view vimex] if ARGV.include? '--override-system-vim'
  executables.each { |e| binary mvim, :target => e }

  zap :delete => [
                  '~/Library/Preferences/org.vim.MacVim.LSSharedFileList.plist',
                  '~/Library/Preferences/org.vim.MacVim.plist',
                 ]

  postflight do
    system 'ruby',
           '-i.bak',
           '-pe',
           %q[sub %r[(?<=VIM_APP_DIR=)`dirname "\$0"`(?=(?:/\.\.){3})], '$(cd $(dirname $(readlink $0 || echo $0));pwd)'],
           staged_path.join(mvim)
  end

  caveats do
    files_in_usr_local
    <<-EOS.undent
      Note that homebrew also provides a compiled macvim Formula that links its
      binary to /usr/local/bin/mvim. And the Cask MacVim also does. It's not
      recommended to install both the Cask MacVim KaoriYa and the Cask MacVim
      and the Formula of MacVim.
    EOS
  end
end
