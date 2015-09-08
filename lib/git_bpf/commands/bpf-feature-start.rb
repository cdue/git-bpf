require 'git_bpf/lib/gitflow'
require 'git_bpf/lib/git-helpers'

#
# bpf-feature-start: Start a new feature (creates the feature branch) from latest version of master or a given tag.
#
class BpfFeatureStart < GitFlow/'bpf-feature-start'

  include GitHelpersMixin

  @@prefix = "BRANCH-PER-FEATURE-PREFIX"

  @documentation = "Start a new feature (creates the feature branch) from latest version of master or a given tag."


  def options(opts)
    opts.base = 'master'
    opts.exclude = []

    [
      ['-a', '--base NAME',
        "A reference to the commit from which the source branch is based, defaults to #{opts.base}.",
        lambda { |n| opts.base = n }],
      ['-v', '--verbose',
        "Show more info about skipping branches etc.",
        lambda { |n| opts.verbose = true }],

    ]
  end

  def execute(opts, argv)
    if argv.length != 1
      run('bpf-feature-start', '--help')
      terminate
    end

    feature = argv.pop

    # If no new branch name provided, replace the source branch.
    opts.branch = feature if opts.branch == nil

    if not refExists? opts.base
      terminate "Cannot find reference '#{opts.base}' to use as a base for new branch: #{opts.branch}."
    end

    unless opts.remote
      repo = Repository.new(Dir.getwd)
      remote_name = repo.config(true, "--get", "gitbpf.remotename").chomp
      opts.remote = remote_name.empty? ? 'origin' : remote_name
    end

    puts 'Fetching tags...'
    git('fetch', '--all', '--tags')

    puts "creating new branch [#{opts.branch}] from [#{opts.remote}/#{opts.base}]"
    git('checkout', '-b', opts.branch, "#{opts.remote}/#{opts.base}")

    puts "Done... Branch #{opts.branch} ready for work."
    puts "Don't forget to integrate your work on integration branch (often called 'develop') from time to time (every 2-3 commits)"
  end
end
