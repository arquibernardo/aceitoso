class ContactoMailer < ActionMailer::Base
  def contactar(email)
   @email=email
   mail(:to=>email.destino,:subject => "Contacto formulario web",:from => "juanantonioruz@gmail.com")
  end
end
