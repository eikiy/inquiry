module ApplicationHelper
  def notice_message
    flash_messages = []
    flash.each do |type, message|
      type = "success" if type == "notice"
      type = "warning" if type == "alert"
      type = "danger" if type == "error"
      text = content_tag(:div, link_to("x", "#", :class => "close", "data-dismiss" => "alert", :onclick => "document.getElementById('close').style.display='none'") + message, :id => "close", :class => "alert fade in alert-#{type}")
      flash_messages << text if message
    end
    flash_messages.join("\n").html_safe
  end

  def has_to_show_welcome
    cookies['new_viewer'] != 'false' && (not request.path_info.start_with? '/users/')
  end

  def welcome_message(message)
    text = content_tag(:div, link_to("x", "#", :class => "close", "data-dismiss" => "alert", :onclick => "document.getElementById('close').style.display='none'; document.cookie='new_viewer= false';") + message, :id => "close", :class => "alert fade in alert-success")
    text.html_safe if message
  end

  def category_cloud
    @categories = Category.includes(:subcategories).where("id < ?", 100)

    content = @categories.reduce('') do |all, c|
      all + "<tr><td width='20%'>#{c.title} #{c.id}</td>" +
        "<td width='80%'>" +
      c.subcategories.reduce('') do |sum, sub_category|
        sum + "#{sub_category.title} #{sub_category.id} "
      end +
        "</td></tr>"
    end

    "<table class='table table-bordered'>" + content + "</table>"
  end

  def online_status(user)
    content_tag :span, user.nickname, class: "user-#{user.id} online_status #{'online' if user.online?}"
  end

  def user_status(user)
    if user.online?
      content_tag :span, '上線中', class: "user-#{user.id} online_status online"
    else
      content_tag :span, '離線', class: "user-#{user.id} online_status"
    end

  end

  def get_resolved_url_obj(url)
    if (image_match = /\.(jpg|jpeg|tiff|png|gif|bmp)$/i.match(url)) and image_match.present?
      # image matches
      { type: "image", match_object: image_match }
    elsif (audio_match = /\.(wav|mp3|wma|midi|aif|aifc|aiff|au|ea)$/i.match(url)) and audio_match.present?
      # audio matches
      { type: "audio", match_object: audio_match }
    elsif (video_match = /\.(mp4|webm|ogg)$/i.match(url)) and video_match.present?
      # video matches
      { type: "video", match_object: video_match }
    elsif (youtube_match = /^(?:https?:\/\/)?(?:m\.|www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?(.+)&v=))((\w|-){11})(\S*)?$/i.match(url)) and youtube_match.present?
      # youtube matches
      { type: "youtube", match_object: youtube_match }
    else
      { type: "others" }
    end
  end

  def render_resolve_url(work)
    url = work.attach_url
    obj = get_resolved_url_obj(url)
    case obj[:type]
    when "image"
      tag :img, src: "#{url}"
    when "audio"    #compare to 2
      content_tag :audio, '', controls: "controls", src: "#{url}", style: "width:100%;"
    when "video"
      content_tag :video, '', controls: "controls", src: "#{url}", width: "100%", height: "100%"
    when "youtube"
      matches = obj[:match_object]
      queryobj = {}
      queryobj["rel"] = 0
      hashes = ""
      overrides = Rack::Utils.parse_query(URI.parse(matches[0]).query)
      overrides.delete("v")
      queryobj = queryobj.merge(overrides)
      if matches[4] != nil
        splits = matches[4].split('#')
        if splits.length > 1
          hashes += "#" + splits[1]
        end
      end
      queryobj["enablejsapi"] = 1;
      if queryobj["t"].present? 
        timeRe = /((?<min>\d+)[m])?((?<sec>\d+)[s])?/
        time = queryobj["t"].scan(timeRe)[0]
        queryobj["start"] = (time[0] ? time[0].to_i : 0) * 60 + (time[1] ? time[1].to_i : 0) 
      end
      querystr = Rack::Utils.build_query(queryobj)
      content_tag :iframe, '', src: "https://www.youtube.com/embed/#{matches[2]}?#{querystr}#{hashes}", width: '100%', height:'100%', frameborder: '0'
    else
      content_tag :div, :data => { :remote_url => url }, class: "remote-preview" do
        content_tag(:div,'', style: 'background-image:url(' + work.remote_image_url + ')', class: 'preview-image')  +
          content_tag(:p, work.remote_description,  class: 'preview-description')
      end
    end
  end

  def render_avatar_file(file)
    image_match = /\.(jpg|jpeg|tiff|png|gif|bmp)$/i.match(file)
    audio_match = /\.(wav|mp3|wma|ogg|midi|aif|aifc|aiff|au|ea)$/i.match(file)
    if image_match.present?
      tag :img, src: "#{file}", style:'margin: 0 auto;display:block;', width: '99.8%'
    elsif audio_match.present?
      content_tag :audio, '', controls: "controls", src: "#{file}"
    end
  end

  def render_with_p_tags(str)
    str.gsub!(/\r\n?/, "\n")
    lines = str.split("\n")
    lines.collect {|line| concat(content_tag(:p, line.presence || "&nbsp;".html_safe))}
    ""
  end

  def date_description(d)
    if d.year == Time.current.year
      d.strftime('%_m/%d')
    else
      d.strftime('%Y/%_m/%d')
    end
  end

  def rasf(text)
    Rinku.auto_link(simple_format(text), :all, 'target="_blank"').html_safe
  end

  def work_square(w)
    if w.attach_avatar.present?
      render_avatar_file(w.attach_avatar.square_large.url)
    elsif w.attach_url.present?
      render_resolve_url(w)
    elsif w.attach_content.present?
      content_tag(:div,'', style: 'background-color:black;width:100%;height:100%;display: table;')  do
        content_tag(:p, w.subject, style:'vertical-align: middle;display: table-cell;text-align:center;color:#dcdcdc;font-size:22px')
      end
    else
    end
  end


  def work_square_personal(w)
    if w.attach_avatar.present?
      render_avatar_file(w.attach_avatar.square_large.url)
    elsif w.attach_url.present?
      render_resolve_url(w)
    elsif w.attach_content.present?

        raw('<p class="onThePhoto" style="color: #fff">' + w.subject + '</p>')

    else
    end
  end


  def work_square_all(w)
    subject = ''
	if w.attach_avatar.present? && w.attach_url.present?
	  w.remote_image_url = w.attach_avatar.square_limit
	  subject += render_resolve_url(w)
    else
	  if w.attach_avatar.present?
	    subject += render_avatar_file(w.attach_avatar.square_limit.url)
	  elsif w.attach_url.present?
	    subject += render_resolve_url(w)
	  end
	end
    if w.attach_content.present?
      subject += sanitize w.attach_content
    end

    subject.html_safe
  end

  def ckeditor_content(user)
    if user.user_info.category
      if user.user_info.category.title == '美術設計'
        "製作​​​​​​​時間： \n\n內容簡介： \n\n                        \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '工業設計'
        "製作​​​​​​​時間： \n\n準備素材： \n\n使用工具：                \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '文字編輯'
        "製作​​​​​​​時間： \n\n概念發想： \n\n                        \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '程式開發'
        "製作​​​​​​​時間： \n\n功能簡介： \n\n使用的language或library： \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '行銷企畫'
        "製作​​​​​​​時間： \n\n概念發想： \n\n                        \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '音樂人'
        "製作​​​​​​​時間： \n\n準備素材： \n\n使用工具：                \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '影像製作'
        "製作​​​​​​​時間： \n\n準備素材： \n\n使用工具：                \n\n參考文件或連結：\n\n"
      elsif user.user_info.category.title == '其他'
        "描述你的工作成果..."
      end
    else
      '(您尚未選擇您的作品類別哦)'
    end

  end

  def li_link_button(tag_show, tag_name, class_name = 'btn-default')
    if tag_show.present? && tag_name.present?
      raw("<li><p>" +
      link_to(sanitize(tag_show), tag_path(tag_name)) +
      "</p></li>")
    end
  end

  def tag_link_button(tag_show, tag_name, class_name = 'btn-default')
    if tag_show.present? && tag_name.present?
      link_to(sanitize(tag_show), tag_path(tag_name), class: "btn #{class_name}")
    end
  end

  def notice_size
     size = PublicActivity::Activity.where(recipient_type: "User", recipient_id: current_user.id).where("created_at > ?", current_user.noticed_at).size 
     if size > 0
      "<span class='badge'>#{(size > 10) ? 10 : size}</span>".html_safe
     end
  end

end

