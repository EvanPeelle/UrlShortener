require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'
require 'pry'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end

# Quick and dirty form for testing application
#
# If building a real application you should probably
# use views: 
# http://www.sinatrarb.com/intro#Views%20/%20Templates
form = <<-eos
    <form id='myForm'>
        <input type='text' name="url">
        <input type="submit" value="Shorten"> 
    </form>
    <h2>Results:</h2>
    <h3 id="display"></h3>
    <h3><a href="/sites">View Links</a></h3>
    <h3><a href="/statistics">View Statistics</a></h3>
    <script src="jquery.js"></script>

    <script type="text/javascript">
        $(function() {
            $('#myForm').submit(function() {
            $.post('/new', $("#myForm").serialize(), function(data){
                $('#display').html(data);
                });
            return false;
            });
    });
    </script>
eos

# Models to Access the database 
# through ActiveRecord.  Define 
# associations here if need be
#
# http://guides.rubyonrails.org/association_basics.html
class Link < ActiveRecord::Base
    validates_presence_of :short_url, :long_url
    has_one :statistic

end

class Statistic < ActiveRecord::Base
  belongs_to :link
end

get '/' do
  form
end

post '/new' do
    surl = makeRandomString
    puts "saving: " + surl
    link = Link.find_or_create_by_long_url(
           :long_url => params[:url],
           :short_url => surl)
    link.save()
    stat = Statistic.find_or_create_by_link_id(
           :link_id => link.id,
           :clicks => 0)
    stat.save()
    "localhost/" + link.short_url #return the shortened url
end

get '/sites' do
    Link.find(:all).map{|i| '<p>'+ 
                               i.long_url + 
                               ' - ' +
                               '<a href='+ i.short_url + '>' +
                               i.short_url + '</a>' +
                            '</p>'}
end

get '/statistics' do
  Statistic.find(:all).map{|i| '<p>' + (i.link.long_url).to_s + ' ' + (i.clicks).to_s + '</p>'}
end

get '/jquery.js' do
    send_file 'jquery.js'
end

get '*.*' do
end

get '/*' do
  temp = params[:splat].first
  link = Link.find_by_short_url(temp)
  if link
    stat = Statistic.find_by_link_id(link.id)
    stat.clicks = stat.clicks + 1
    stat.save()
    redirect 'http://'+link.long_url
  else 
    halt 404
  end
end


def makeRandomString 
  (0...5).map{(65+rand(26)).chr}.join
end

####################################################
####  Implement Routes to make the specs pass ######
####################################################
