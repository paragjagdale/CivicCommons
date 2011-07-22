class AttachedFile < Contribution

  # supported files:
  # xls, ppt, pdf, doc, txt, xlsx, docx, pptx, rtf, jpg, png

  has_attached_file :attachment,
    :storage => :s3,
    :s3_credentials => S3Config.credential_file,
    :path => IMAGE_ATTACHMENT_PATH,
    :styles => {:thumb => "75x75>", :medium => "300x300>", :large => "800x800>"}

  validates_attachment_presence :attachment

  before_attachment_post_process :is_image?

  # Return true if attachment is an image
  # Returns false if it is not an image
  # Does not return nil since before_attachment_post_process relies requires
  # true or false
  def is_image?
    !(attachment_content_type =~ /^image.*/).nil?
  end

end
