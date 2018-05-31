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
        @rateh=[]
        @compare=[]
        #Get Instagram Url
        list_acc=['seo8']
        for f in 0..list_acc.length-1    
            begin
                    #@@bot.navigate.to "https://www.instagram.com/explore/tags/#{URI.encode(i[0])}"
                    doc = Nokogiri::HTML(open("https://www.instagram.com/#{list_acc[f]}"))
                    @acc = doc.text
                    @acc = @acc.split('"edge_followed_by":{"count":')[1]
                    @acc = (@acc.split('},"followed_by_viewer"')[0]).to_i
                    #@follower.push(@acc)
                    rescue OpenURI::HTTPError=> e
                        if e.message == '404 Not Found'   
                            @follower.push('Wrong acc')
                        end               
            end
            @@bot = Selenium::WebDriver.for :chrome 
            @@bot.navigate.to "https://www.instagram.com/#{list_acc[f]}"  
            sleep 1
            if @@bot.find_elements(:class, '_2di5p').size>0
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
                @@bot.quit()
                #avoid duplicate when save dom
                @post_dom=@post_dom.uniq
                #Get exactly 100 post
                @post_dom=@post_dom[0..99]
                #remove some unnecessary words and characters(Example:#abc(ew)=>#abc)
                for i in 0..@post_dom.length-1
                    #remove all special characters and all single character "#"
                    @post_dom[i]=@post_dom[i].gsub(/[!@$%^&*()+-.~`,:;<>?|'"{}\\\/\[\]]/,' ')
                    @post_dom[i]=@post_dom[i].gsub(/(#[' '])/,' ')
                    #remove \n
                    @post_dom[i]=@post_dom[i].gsub("\n",' ')
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
                @post_dom.clear
                @appearance = @hashtags.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
                @appearance = @appearance.sort_by {|_key, value| value}
                @appearance = @appearance.last(20).reverse
                @hashtags.clear
                for i in @appearance  
                    begin
                        #@@bot.navigate.to "https://www.instagram.com/explore/tags/#{URI.encode(i[0])}"
                        url=URI.parse "https://www.instagram.com/explore/tags/#{URI.encode(i[0])}"
                        doc = Nokogiri::HTML(open(url))
                        appearance_time = doc.text
                        appearance_time = appearance_time.split('"edge_hashtag_to_media":{"count":')[1]
                        appearance_time = (appearance_time.split(',"page_info":{"')[0]).to_i
                        @appearance_times.push(appearance_time)
                        @rateh.push(appearance_time/@acc.to_f)
                        if appearance_time/@acc.to_f>0.125
                            @compare.push(0)
                        else 
                            @compare.push(appearance_time)
                        end
                        rescue OpenURI::HTTPError=> e
                            if e.message == '404 Not Found'   
                                @appearance_times.push(0)
                                @rateh.push(0)
                                @compare.push(0)
                            end
                    end
                end
                @sum=@compare.inject(0){|sum,x| sum + x }
                @rate_s=@sum/@acc.to_f   
            #excel
                workbook = RubyXL::Parser.parse("C:/Sites/new1.xlsx")
                worksheet=workbook[0]
                for i in 0..@appearance.length-1
                    worksheet.add_cell(f*6+1, 1, list_acc[f])
                    worksheet.add_cell(f*6+1, 2, 'followers')
                    worksheet.add_cell(f*6+2, 2, @acc)
                    worksheet.add_cell(f*6+5, 1, @rate_s)
                    worksheet.add_cell(f*6+5, 2, @sum)
                    worksheet.add_cell(f*6+1, i+3, @appearance[i][0])
                    worksheet.add_cell(f*6+2, i+3, @appearance[i][1])
                    worksheet.add_cell(f*6+3, i+3, @appearance_times[i])
                    worksheet.add_cell(f*6+4, i+3, @rateh[i])
                    worksheet.add_cell(f*6+5, i+3, @compare[i])
                end
                workbook.write("C:/Sites/new1.xlsx") 
                @appearance.clear
                @appearance_times.clear
                @rateh.clear
                @compare.clear
            else
                @@bot.quit()
            end
        end
            
    end
end
