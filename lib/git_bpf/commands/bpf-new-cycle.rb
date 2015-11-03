require 'git_bpf/lib/gitflow'
require 'git_bpf/lib/git-helpers'

#
# bpf-new-cycle: Used by a release manager to start a new cycle. It recreates 'develop' and 'QA' branches from the latest version of 'master' or a given Tag.
#
class BpfNewCycle < GitFlow/'bpf-new-cycle'

  include GitHelpersMixin

  @@prefix = "BRANCH-PER-FEATURE-PREFIX"

  @documentation = "Recreates 'develop', 'QA', 'release' and 'pfr-p2000' branches from the latest version of 'master' or a given Tag."


  def options(opts)
    opts.base = 'master'
    opts.exclude = []

    [
      ['-a', '--base NAME',
        "A reference to the commit from which 'develop', 'QA' and 'release' branches are based, defaults to #{opts.base}.",
        lambda { |n| opts.base = n }],
      ['-v', '--verbose',
        "Show more info...",
        lambda { |n| opts.verbose = true }],

    ]
  end

  def execute(opts, argv)
    #if argv.length != 1
    #  run('bpf-cycle-new', '--help')
    #  terminate
    #end

    #source = argv.pop

    # If no new branch name provided, replace the source branch.
    #opts.branch = source if opts.branch == nil
    puts 'Init new BPF cycle...'

    if not refExists? opts.base
      terminate "Cannot find reference '#{opts.base}' to use as a base for new develop and QA branches."
    end

    unless opts.remote
      repo = Repository.new(Dir.getwd)
      remote_name = repo.config(true, "--get", "gitbpf.remotename").chomp
      opts.remote = remote_name.empty? ? 'origin' : remote_name
    end
    #git('fetch', opts.remote, '--all', '--tags')
    puts 'Fetching tags...'
    git('fetch', '--all', '--tags')

    opoo "Are you sure you want to overwrite 'develop', 'QA' and 'release' branches (local and remote) with #{opts.base}?"
    if not promptYN "Continue?"
      terminate "Aborting."
    end
    git('checkout', opts.base)
    git('pull', opts.remote, opts.base)

    puts 'Deleting local develop branch (if it exists)'
    git('branch', '-d', 'develop') if branchExists? 'develop'

    puts 'Deleting local QA branch (if it exists)'
    git('branch', '-d', 'QA') if branchExists? 'QA'

    puts 'Deleting local release branch (if it exists)'
    git('branch', '-d', 'release') if branchExists? 'release'

    puts 'Deleting local pfr-p2000 branch (if it exists)'
    git('branch', '-d', 'pfr-p2000') if branchExists? 'pfr-p2000'

    git('checkout', '-b', 'develop', opts.base)
    puts "Replacing remote develop branch with #{opts.base}"
    git('push', '-u', opts.remote, 'develop', '--force')

    git('checkout', '-b', 'QA', opts.base)
    puts "Replacing remote QA branch with #{opts.base}"
    git('push', '-u', opts.remote, 'QA', '--force')

    git('checkout', '-b', 'release', opts.base)
    puts "Replacing remote release branch with #{opts.base}"
    git('push', '-u', opts.remote, 'release', '--force')

    git('checkout', '-b', 'pfr-p2000', opts.base)
    puts "Replacing remote pfr-p2000 branch with #{opts.base}"
    git('push', '-u', opts.remote, 'pfr-p2000', '--force')

    git('checkout', opts.base)

    puts "Done... New cycle iniated from #{opts.base}"
  end

end
