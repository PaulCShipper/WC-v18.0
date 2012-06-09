module PostMethods
  module PixivPost
    # to download pixiv stuff
    def pixiv_download
      unless self.post_mechanize
        pixiv_login
      end
    
      # url to the page now
      page = post_mechanize.get(source)

      # examine the page and extract what we need
      self.new_tags << "artist:" + page.parser.xpath("/html/body/div[1]/div[2]/div[1]/div[1]/h2").text
      self.new_tags << "pixiv"
      self.title = page.parser.xpath("//meta[@property='og:title']")[0]["content"]
      self.source = page.parser.xpath("//meta[@property='og:image']")[0]["content"]
      self.description = page.parser.xpath("//meta[@property='og:description']")[0]["content"]

      # if it's a pool
      if page.link_with(:href => /mode=manga&illust_id=/)
        pixiv_pool
        return false
      end
      return true
    end

    # gets the cookie or log into pixiv and returns the mechanize
    def pixiv_login

      self.post_mechanize = Mechanize.new
      uri = URI.parse "http://pixiv.net/"
    
      if !File.exist? "#{RAILS_ROOT}/tmp/pixiv.cookie"
        pixiv_form
      else
        post_mechanize.cookie_jar.load "#{RAILS_ROOT}/tmp/pixiv.cookie"
        if post_mechanize.cookies.first.expired?
          pixiv_form
        end
      end
    end

    # logs into pixiv and returns the cookie after saving it in tmp
    def pixiv_form
      login_page = post_mechanize.get('http://www.pixiv.net')

      # make sure id and pass are hidden in local_config.rb
      login = login_page.form_with(:action => '/login.php') do |f|
        f.pixiv_id = ""
        f.pass = ""
        f.checkbox_with(:name => "skip").check
      end.click_button

      post_mechanize.cookie_jar.save_as "#{RAILS_ROOT}/tmp/pixiv.cookie"
    end

    def pixiv_pool
      ext = source[/\.[^\.]+$/]
      base = source.sub(/_m\.[^\.]+$/, "_big_p")
      num = 0
      post_id = nil
      @user = User.find_by_id user_id
      begin
        alt_source = base + num.to_s + ext
        @post = self.clone
        @post.updater_user_id = self.user_id
        @post.updater_ip_addr = self.ip_addr
        @post.source = alt_source
        @post.new_tags = self.new_tags
        @post.save
        logger.info("\n\n saved source---------------- #{@post.source}\n\n")
        post_id = @post.id
        num += 1
      end until(@post.errors.invalid?(:source) or !@user.can_upload?)
        logger.info("\n\n---------------- end of pixiv_pool\n\n")
      post_id
    end
  end
end
