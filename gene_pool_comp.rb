def get_likes(likes, total_likes = [])
	return total_likes unless likes
	likes.map { |like| total_likes << like }
	get_likes(likes.next_page, total_likes)
end

def get_comments(comments, total_comments = [])
	return total_comments unless comments
	comments.each do |comment|
		if comment['message'].downcase.delete(' ').include? WINNING_PHRASE
			total_comments << comment['from']
		end
	end
	get_comments(comments.next_page, total_comments)
end

def valid_users
	@user_post_likes & @user_post_comments
end

def get_winner
	winner = valid_users.sample
	if verify_winner(winner)
		details = @graph.get_object("#{winner['id']}?fields=name,link")
		{ name: details['name'], link: details['link'] }
	else
		get_winner
	end
end

def verify_winner(winner)
	puts "Verifying #{winner['name']}"
	return true if @graph.get_connections(winner['id'], 'likes').length > 0
	false
end

require 'koala'
require 'dotenv'

Dotenv.load

API_KEY = ENV['API_KEY']
PAGE_ID = '578972198948524'
POST_ID = '771957389650003'
WINNING_PHRASE = 'tackle52'

Koala.config.api_version = 'v2.3'

@graph = Koala::Facebook::API.new(API_KEY)

puts 'Getting post likes'
@user_post_likes = get_likes(@graph.get_connections(POST_ID, 'likes'))

puts 'Getting post comments'
@user_post_comments = get_comments(@graph.get_connections(POST_ID, 'comments'))

winner = get_winner
puts "\nOut of #{valid_users.length} valid entries, the winner is:-"
puts "#{winner[:name]} ( #{winner[:link]} )"
