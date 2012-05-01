module UsersHelper
  
  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, *args)
    opts = args.extract_options!
    opts[:size] ||= 90
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{opts[:size]}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar')
  end
  
end
