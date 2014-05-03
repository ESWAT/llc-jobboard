class UserMailer < ActionMailer::Base
  default from: "no-reply@ladieslearningcode.com"

  def confirmation_email(email, job_post)
    @job_post = job_post
    mail(to: email, subject: "Your Job Post with Ladies Learning Code")
  end
end
