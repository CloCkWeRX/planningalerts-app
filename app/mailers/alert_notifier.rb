class AlertNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :application, :applications

  def alert(theme, alert, applications, comments = [])
    @alert, @applications, @comments = alert, applications, comments


    themed_mail(:theme => theme, :from => email_from(theme), :to => alert.email,
      :subject => render_to_string(:partial => "subject",
        :locals => {:applications => applications, :comments => comments, :alert => alert}).strip,
      "return-path" => ::Configuration::BOUNCE_EMAIL_ADDRESS,
      "List-Unsubscribe" => "<" + unsubscribe_alert_url(host: host(theme), id: alert.confirm_id) + ">")
  end
end
