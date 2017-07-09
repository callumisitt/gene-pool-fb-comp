def get_likes(likes)
	return false unless likes
	likes.map { |like| @user_likes << like }
	get_likes(likes.next_page)
end

def get_comments(comments)
	return false unless comments
	comments.each do |comment|
		if comment['message'].downcase.delete(' ').include? WINNING_PHRASE
			@user_comments << comment['from']
		end
	end
	get_comments(comments.next_page)
end

def valid_users
	@user_likes & @user_comments
end

def get_winner
	winner = valid_users.sample
	details = @graph.get_object(winner['id'])
	{ name: details['name'], link: details['link'] }
end

require 'koala'
require 'dotenv'

Dotenv.load

API_KEY = ENV['API_KEY']
OBJECT_ID = '771957389650003'
WINNING_PHRASE = 'tackle52'

@user_likes = []
@user_comments = []

Koala.config.api_version = 'v2.3'

@graph = Koala::Facebook::API.new(API_KEY)
@post = @graph.get_object(OBJECT_ID)

puts 'Getting likes'
get_likes @graph.get_connections(OBJECT_ID, 'likes')

puts 'Getting comments'
get_comments @graph.get_connections(OBJECT_ID, 'comments')

winner = get_winner
puts "\nOut of #{valid_users.length} valid entries, the winner is:-"
puts "#{winner[:name]} (#{winner[:link]})"
