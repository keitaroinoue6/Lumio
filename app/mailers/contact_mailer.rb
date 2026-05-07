class ContactMailer < ApplicationMailer
  default to: "k-inoue@movin24.com"

  def inquiry_notification(contact)
    @contact = contact
    mail(
      subject: "【お問い合わせ】#{@contact.company} #{@contact.name} 様より",
      reply_to: @contact.email
    )
  end
end
