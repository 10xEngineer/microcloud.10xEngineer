require 'grit'
require 'uuid'
require 'yajl'
require 'hmac-md5'
require 'utils/external'
require 'securerandom'

class GitAdmService < Provider
  # FIXME currently can effectively work as singleton only

  # FIXME git config for user running git_adm service
  # FIXME resolve GIT store (part of tenant - shards / load spreading); currently hardcoded
  # FIXME proper security (currently hardcoded)

  # FIXME hardcoded hosting/gitolite repository
  GITOLITE_HOST = "ssh://tenx@bunny.laststation.net:440/"
  GITOLITE_ADMIN_REPO = GITOLITE_HOST + "gitolite-admin"
  GITOLITE_ADMIN_TMP = "/tmp/tenx-gitolite-admin"

  GITOLITE_CONFIG = "conf/gitolite.conf"
  TENX_METADATA = "10xlabs/metadata.json"

  # FIXME add user management

  before_filter :gitolite_admin

  def create_repo(request)
    lab_name = request["options"]["lab_name"]

    raise "Lab name not provided." if lab_name.nil?

    if request["options"]["token"]
      token = request["options"]["token"]
    else
      token = generate_token
    end
    
    repo = request["options"]["repo"]

    if repo
      # clone requested repository
      temp_dir = Dir.mktmpdir

      git = Grit::Git.new(GITOLITE_ADMIN_TMP)
      options = {
        :quiet => false,
        :verbose => true,
        :progress => true,
        :branch => "master"
      }

      git.clone(options, repo, temp_dir)
    end

    # create new repository
    repo_id = mkrepo(@gitolite, token, lab_name)

    # repo is created, return control to microcloud
    repo_url = GITOLITE_HOST + repo_id

    response :ok, {:repo => repo_url, :token => token }

    # push cloned repo to target repository
    if repo
      # FIXME hardcoded repository URL
      add_remote(temp_dir, "lab_repo", "ssh://tenx@bunny.laststation.net:440/#{repo_id}")
      push_to temp_dir, "lab_repo"      

      # FIXME update microcloud (data ...?)
    end
  end

private
  def generate_token(length = 32)
    SecureRandom.urlsafe_base64(length)
  end

  def mkrepo(gitolite, token, lab_name, name = repo_name)
    metadata = read_metadata

    repo = {
      # FIXME hardcoded permissions for now
      "permissions" => [{"radim" => "RW+"},{"mchammer" => "RW+"}],
      "token" => token,
      # TODO extend as part of owner/domain/user inclusion
      "lab_name" => lab_name
    }

    metadata[name] = repo

    generate_config(metadata)

    Dir.chdir(GITOLITE_ADMIN_TMP) do
      # commit changes  
      [GITOLITE_CONFIG, TENX_METADATA].each do |fname|
        file = File.join(GITOLITE_ADMIN_TMP, fname)

        gitolite.add(fname)
      end

      gitolite.commit_index("Added repository #{name}")
    end

    push_to(GITOLITE_ADMIN_TMP)  

    name  
  end

  def add_remote(repo, name, url)
    Dir.chdir(repo) do
      # FIXME configurable git location
      cmd = ["/usr/local/bin/git", "remote", "add", name, url]
      TenxLabs::External.execute(cmd.join(' ')) do 
        # what to do with output
      end
    end
  end

  def push_to(repo, target = 'origin')
    Dir.chdir(repo) do
      # FIXME configurable git location
      cmd = ["/usr/local/bin/git", "push", target, "master"]
      TenxLabs::External.execute(cmd.join(' ')) do 
        # what to do with output
      end
    end
  end

  def generate_config(metadata)
    save_metadata(metadata)

    config = gitolite_config(metadata)

    # write config
    open(File.join(GITOLITE_ADMIN_TMP, GITOLITE_CONFIG), 'w') {|f| f << config}
  end

  def gitolite_config(metadata)
    output = ""

    metadata.each do |repo_name, repo|
      interim = "repo #{repo_name}\n"

      repo["permissions"].each do |perms|

        username = perms.keys.first

        interim << "    #{perms[username]}     =   #{username}\n"
      end
      interim << "\n"

      output << interim
    end

    output
  end

  def save_metadata(metadata)
    # validate
    raise 'Invalid Gitolite metadata: missing gitolite-admin!' unless metadata.has_key? "gitolite-admin"

    # TODO add interim step to provide semi-atomicity
    open(File.join(GITOLITE_ADMIN_TMP, TENX_METADATA), 'w') {|f| f << Yajl::Encoder.encode(metadata)}
  end

  def read_metadata
    raw = File.read(File.join(GITOLITE_ADMIN_TMP, TENX_METADATA))

    data = Yajl::Parser.parse(raw)
    data
  end

  def repo_name
    UUID.new.generate
  end

  def gitolite_admin
    git = Grit::Git.new(GITOLITE_ADMIN_TMP)

    # get the gitolite admin repository
    # FIXME more than a directory exists check (inconsistent repository will stop any further
    #       operations)
    unless File.exists? GITOLITE_ADMIN_TMP
      options = {
        :quiet => false,
        :verbose => true,
        :progress => true,
        :branch => "master"
      }

      git.clone(options, GITOLITE_ADMIN_REPO, GITOLITE_ADMIN_TMP)
    end

    # FIXME automatically pull latest changes / check repository 

    @gitolite = Grit::Repo.init(GITOLITE_ADMIN_TMP)
  end

  def temp_name(repo)
    HMAC::MD5.new("#{Time.now}-#{repo}").hexdigest
  end
end