require 'rom'
require 'byebug'

$LOAD_PATH.unshift(Pathname(__FILE__).join('../../lib').realpath)

rom = ROM.setup(:github, 'repos/rom-rb/rom') do
  relation(:commits) do
    dataset :commits

    def recent
      take(10)
    end
  end

  mappers do
    define(:commits) do
      model name: 'Commit'

      register_as :entity

      attribute :sha

      embedded :details, from: :commit, type: :hash do
        model name: 'Details'

        attribute :message

        embedded :author, type: :hash do
          model name: 'DetailsAuthor'

          attribute :name
          attribute :email
          attribute :timestamp, from: :date, type: :datetime
        end
      end

      embedded :author, type: :hash do
        model name: 'CommitAuthor'

        attribute :login
      end
    end
  end
end

commits = rom.relation(:commits).as(:entity).recent

commits.each do |commit|
  puts "sha: #{commit.sha}"
  puts "  author: #{commit.author.login}"
  puts "  time: #{commit.details.author.timestamp}"
end
