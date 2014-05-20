module ActionMailerThemer

  private

  def themed_mail(params)
    theme = params.delete(:theme)

    # TODO Extract this into the theme
    if theme == "default"
      template_path = mailer_name
      @host = ActionMailer::Base.default_url_options[:host]
    elsif theme == "nsw"
      template_path = ["../../lib/themes/#{theme}/views/#{mailer_name}", mailer_name]
      self.prepend_view_path "lib/themes/#{theme}/views"
      @host = "planningalerts.nsw.gov.au"
    else
      raise "Unknown theme #{theme}"
    end

    mail(params.merge(template_path: template_path))
  end
end