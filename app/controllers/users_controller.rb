class UsersController < ApplicationController
    def index    
        @appearance 
        @appearance_times
        @hashtags
    end
    
    def create
        
        #declare dom of posts
        @post_dom=[]
        #declare hashtags of posts
        @hashtags=[]
        #declare times of appreance 
        @appearance_times=[] 
        #Get Instagram Url
        @insta_url=params[:insta_url]
        #run chrome
        @@bot = Selenium::WebDriver.for :chrome 
       
        @@bot.navigate.to "#{@insta_url}"  
        sleep 1
        #scroll down the account page and save dom
        for i in 0..24
            @@bot.action.send_keys(:page_down).perform
            sleep 1
            #save dom after 8 times press page down button
            if i%8==0
                # elements contain the content of a post
                @dom=@@bot.find_elements(:class, '_2di5p')
                for i in @dom
                #Get description of a post
                @post_dom.push(i['alt'])
                end
            end 
         end
         #avoid duplicate when save dom
         @post_dom=@post_dom.uniq
         #Get exactly 100 post
         @post_dom=@post_dom[0..99]
         #remove some unnecessary words and characters(Example:#abc(ew)=>#abc)
        for i in 0..@post_dom.length-1
            #remove all special characters and all single character "#"
            @post_dom[i]=@post_dom[i].gsub(/[!@$%^&*()+-.,:;<>?|'"{}\\\/\[\]]/,' ')
            @post_dom[i]=@post_dom[i].gsub(/(#[' '])/,' ')
            #remove \n
            @post_dom[i]=@post_dom[i].gsub("\n",'')
            #remove all none-hashtag words and space
            @post_dom[i]=@post_dom[i].gsub(/(^|\s)[^#]+/,'')
            @post_dom[i]=@post_dom[i].gsub(/\s/, '')
            #split all hashtags
            post_hashtag=@post_dom[i].split('#')
            #remove first element
            post_hashtag.shift
            #save all hashtags into a array
            for e in post_hashtag
              @hashtags.push(e)
            end
        end
        #calculate appearance times
        @appearance = @hashtags.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
        @appearance = @appearance.sort_by {|_key, value| value}
        @appearance = @appearance.last(20).reverse
        #Crawl used time by global
        for i in @appearance  
            begin
                #@@bot.navigate.to "https://www.instagram.com/explore/tags/#{URI.encode(i[0])}"
                url=URI.parse "https://www.instagram.com/explore/tags/#{URI.encode(i[0])}"
                doc = Nokogiri::HTML(open(url))
                appearance_time = doc.text
                appearance_time = appearance_time.split('"edge_hashtag_to_media":{"count":')[1]
                appearance_time = appearance_time.split(',"page_info":{"')[0]
                @appearance_times.push(appearance_time)
                rescue OpenURI::HTTPError=> e
                    if e.message == '404 Not Found'   
                        @appearance_times.push('Wrong hashtags')
                    end
            end
        end
        render 'index'
    end
end
