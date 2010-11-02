class Avatar < ActiveRecord::Base
  before_validation_on_create :ensure_tempfile_exists
  before_validation_on_create :move_file
  before_validation_on_create :avatar_limit
  belongs_to :user
  belongs_to :comment
  belongs_to :forum_post
    
  def ensure_tempfile_exists
    unless File.exists?(tempfile_path)
      errors.add :file, "not found, try uploading again"
      return false
    end
  end

  # fix this
  def avatar_limit
    user = User.find(user_id)
    count = user.avatars.count(:conditions => ["show = ?", true])
    limit = CONFIG["member_avatar_limit"]

    if count >= limit
      errors.add :beyond, "your allowed number of avatars"
      return false
    end
  end

  # to create the file name
  def src_name(ext)
    self.src = "avatar#{Avatar.count + 1}#{user_id}#{Time.now.to_i}.#{ext}"
  end

  def delete_tempfile
    FileUtils.rm_f(tempfile_path)
  end

  def move_resizefile
    delete_tempfile
    FileUtils.mv(resizefile_path, tempfile_path)
  end

  def tempfile_path
    "#{RAILS_ROOT}/public/data/#{$PROCESS_ID}.upload"
  end

  def resizefile_path
    "#{RAILS_ROOT}/public/data/#{$PROCESS_ID}.resize"
  end

  def file_path
    "#{RAILS_ROOT}/public/avatars/#{src}"
  end

  # Assigns a CGI file to the post. This writes the file to disk and generates a unique file name.
  def file=(f)
    return if f.nil? || f.size == 0
      
    # Checking size
    return errors.add(:file, "file is too big") if f.size > 5242880

    file_ext = content_type_to_file_ext(f.content_type) || find_ext(f.original_filename)
    src_name(file_ext)

    # Checking extention
    unless %w(jpg png gif).include?(file_ext.downcase)
      errors.add(:file, "is an invalid content type: " + file_ext.downcase)
      return false
    end

    if f.local_path
      # Large files are stored in the temp directory, so instead of
      # reading/rewriting through Ruby, just rely on system calls to
      # copy the file to danbooru's directory.
      FileUtils.cp(f.local_path, tempfile_path)
    else
      File.open(tempfile_path, 'wb') {|nf| nf.write(f.read)}
    end

    # Checking image dimensions
    imgsize = ImageSize.new(File.open(tempfile_path, "rb"))
    width = imgsize.get_width
    height = imgsize.get_height

    # Resize image if it's too big
    unless width < 150 or height < 150
      size = Danbooru.reduce_to({:width=>width, :height=>height}, {:width=>150, :height=>150})
      path, ext = tempfile_path, file_ext
      Danbooru.resize(ext, path, resizefile_path, size, 95)
      move_resizefile
    end
  end

  def find_ext(file_path)
    ext = File.extname(file_path)
    if ext.blank?
      return "txt"
    else
      ext = ext[1..-1].downcase
      ext = "jpg" if ext == "jpeg"
      return ext
    end
  end

  def content_type_to_file_ext(content_type)
    case content_type.chomp
    when "image/jpeg"
      return "jpg"

    when "image/gif"
      return "gif"

    when "image/png"
      return "png"

    else
      nil
    end
  end

  # this replaces the image storage method    
  def move_file
    FileUtils.mv(tempfile_path, file_path)
    FileUtils.chmod(0664, file_path)

    delete_tempfile
  end

  # default staff level
  def can_be_seen_by?(user)
    return show || CONFIG["staff"].call(user)
  end

  # hiding avatar, might add more later
  def hide_avatar
    if show and self.user.avatar_id == id
      self.user.avatar_id = nil
      self.user.save
    end
    self.show = !show
    self.save
  end
end
