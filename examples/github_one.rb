require 'rom'

$LOAD_PATH.unshift(Pathname(__FILE__).join('../../lib').realpath)

rom = ROM.setup(:github, 'orgs/rom-rb') do
  relation(:repos) do
    dataset :repos

    def most_popular
      select { |repo| repo[:watchers] > 10 }
        .sort_by { |repo| repo[:watchers] }
        .reverse
    end
  end

  mappers do
    define(:repos) do
      model name: 'Repo'

      register_as :entity

      attribute :id
      attribute :name
      attribute :stars, from: :watchers
    end
  end
end

rom.relation(:repos).as(:entity).most_popular.each do |repo|
  puts "name #{repo.name} with #{repo.stars} stars"
end
