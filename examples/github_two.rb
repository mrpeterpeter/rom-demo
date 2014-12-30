require 'rom-yaml'
require './lib/github_adapter'

setup = ROM.setup(github: 'github://repos/rom-rb/rom')

setup.schema do
  base_relation :commits do
    repository :github

    attribute 'sha'
    attribute 'commit'
  end
end

setup.relation(:commits) do
  def recent
    project('sha', 'commit', 'author').take(10)
  end
end

setup.mappers do

  define :commits, symbolize_keys: true do
    model name: 'Commit'

    attribute :sha

    embedded :details, from: 'commit', type: :hash do
      model name: 'Details'
      attribute :message

      embedded :author, type: :hash do
        model name: 'DetailsAuthor'
        attribute :name
        attribute :email
        attribute :timestamp, from: 'date', type: :datetime
      end
    end

    embedded :author, type: :hash do
      model name: 'CommitAuthor'
      attribute :login
    end
  end

end

rom = setup.finalize

commits = rom.read(:commits).recent

commits.each do |commit|
  puts "sha: #{commit.sha}"
  puts "  author: #{commit.author.login}"
  puts "  time: #{commit.details.author.timestamp}"
end
