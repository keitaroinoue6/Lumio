class ContactsController < ApplicationController
  def new
    @contact = Contact.new(topic: "cloud")
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.valid?
      redirect_to root_path, notice: "お問い合わせを受け付けました。2営業日以内にご返信いたします。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(
      :topic, :company, :industry, :name, :department,
      :email, :phone, :budget, :start_date, :engagement,
      :detail, :consent
    )
  end
end
