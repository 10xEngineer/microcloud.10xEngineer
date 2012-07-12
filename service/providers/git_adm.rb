require 'grit'

class GitAdmService < Provider
  # FIXME hardcoded gitolite repository
  GITOLITE_ADMIN_REPO = "ssh://tenx@bunny.laststation.net:440/gitolite-admin"
  GITOLITE_ADMIN_TMP = "/tmp/tenx-gitolite-admin"

  before_filter :gitolite_admin

  # use case 1. create repository
  # - get admin repository
  # - 
  # use case 2. clone repository

  def ping(request)
    puts "--- got gitolite" if @gitolite
  end

private

  def gitolite_admin
    @gitolite = nil
    @gitolite = Grit::Git.new(GITOLITE_ADMIN_TMP)

    # get the gitolite admin repository
    unless File.exists? GITOLITE_ADMIN_TMP
      options = {
        :quiet => false,
        :verbose => true,
        :progress => true,
        :branch => "master"
      }

      @gitolite.clone(options, GITOLITE_ADMIN_REPO, GITOLITE_ADMIN_TMP)
    end

    puts '---'

    puts @gitolite.commits
  end
end