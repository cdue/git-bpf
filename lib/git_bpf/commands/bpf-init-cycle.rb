require 'git_bpf/lib/gitflow'
require 'git_bpf/lib/git-helpers'

#
# bpf-init-cycle: Used by developers to initialise a new cycle. It resets 'develop' and 'QA' local branches to their remote state.
#
class BpfInitCycle < GitFlow/'bpf-init-cycle'

  include GitHelpersMixin

  @@prefix = "BRANCH-PER-FEATURE-PREFIX"

  @documentation = "Resets 'develop' and 'QA' local branches to their remote state"


  # def options(opts)
  #   opts.base = 'master'
  #   opts.exclude = []
  # 
  #   [
  #     ['-a', '--base NAME',
  #       "A reference to the commit from which 'develop' and 'QA' branches are based, defaults to #{opts.base}.",
  #       lambda { |n| opts.base = n }],
  #     ['-v', '--verbose',
  #       "Show more info...",
  #       lambda { |n| opts.verbose = true }],
  # 
  #   ]
  # end

  def execute(opts, argv)
    #if argv.length != 1
    #  run('bpf-cycle-init', '--help')
    #  terminate
    #end

    #source = argv.pop

    puts 'Initialize a new BPF development cycle...'

    unless opts.remote
      repo = Repository.new(Dir.getwd)
      remote_name = repo.config(true, "--get", "gitbpf.remotename").chomp
      opts.remote = remote_name.empty? ? 'origin' : remote_name
    end

    #git('fetch', opts.remote, '--all', '--tags')
    puts 'Fetching tags...'
    git('fetch', '--all', '--tags')
    git('checkout', 'develop')
    # consider origin/develop exists
    git('reset', '--hard', '#{opts.remote}/develop')
    git('checkout', 'QA')
    # consider origin/QA exists
    git('reset', '--hard', '#{opts.remote}/QA')
    git('checkout', 'master')

    puts "Done... Local repository ready for new BPF development cycle ('develop' and 'QA' local branches had been reset)."
  end

end
