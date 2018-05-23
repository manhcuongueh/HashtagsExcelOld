class Crawl


    def find_user(insta_url)
        @@bot.navigate.to "#{insta_url}"
        sleep 1
        post_dom=@@bot.find_elements(:class, '_4rbun').attribute('innerHTML')
        #click on follower list
        #for i in 0..99
           #@@bot.action.send_keys(:page_down).perform
           #sleep 1
        #end
        
    end

    
    def crawl_followers   
        #read inner HTML of follower list element
        follower_dom=@@bot.find_element(:class, '_p4iax').attribute('innerHTML')
        begin
            doc = Nokogiri::HTML(follower_dom)
            #get followers by href
            user_href=doc.css('div._f5wpw a').map { |link| link['href'] }
            #remove duplicate    
            user_href=user_href.uniq
            
            for i in user_href
               @@bot.navigate.to "https://www.instagram.com#{i}"
                #follower URL
                title="https://www.instagram.com#{i}"
                if image_url=@@bot.find_elements(:class,'_rewi8').size > 0
                    #profile image
                    image_url=@@bot.find_element(:class,'_rewi8')['src']
                    #post number
                    post_number=@@bot.find_element(:xpath,'/html/body/span/section/main/div/header/section/ul/li[1]/span/span').text.to_i
                    #followers
                    followers=@@bot.find_element(:xpath,'/html/body/span/section/main/div/header/section/ul/li[2]').text.to_i
                    #following                             
                    following=@@bot.find_element(:xpath,'/html/body/span/section/main/div/header/section/ul/li[3]').text.to_i
                    #description
                    description=@@bot.find_element(:class,'_tb97a').text
                    #save follower
                    users=User.new(
                        id: user_href.index(i)+1 ,
                        title: title,
                        image_url: image_url,
                        post_number: post_number,
                        followers: followers,
                        following: following,
                        description: description) 
                    users.save
                end
            end
        end
        @@bot.quit()
           
    end
end
