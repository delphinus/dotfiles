cask :v1 => 'github-issue-browser' do
  version '1.0.2'
  sha256 'a6de87a81d2300e3883d1c27282b3ab7c8e711360a4b5a560d01746e28fbf84d'
  url "https://github.com/ykhs/github-issue-browser/releases/download/#{version}/github-issue-browser-osx.zip"

  name 'github-issue-browser'
  homepage 'https://github.com/ykhs/github-issue-browser'
  license :mit
  app 'github-issue-browser/osx/github-issue-browser.app'
end
