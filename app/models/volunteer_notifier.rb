class VolunteerNotifier < ActionMailer::Base

  def volunteer_added(survey, updates)
    setup_volunteer_added_email
    @subject += 'Volunteer Added'
    @updates = updates
    @body[:url] = "#{StaticData::BASE_URL}/survey/show/#{survey.id}"
  end

  def survey_missing_volunteers(survey)
    setup_survey_missing_volunteers
    @subject += 'Survey without any volunteers!'
    @body[:url] = "#{StaticData::BASE_URL}/survey/show/#{survey.id}"
  end

  def forgot_password(volunteer)
    setup_forgot_email(volunteer)
    @subject    += 'Reset Password'
    @body[:url]  = "#{StaticData::BASE_URL}/volunteer/change_password/#{volunteer.reset_password_code}"
  end

  protected

  def setup_forgot_email(volunteer)
    @recipients       = "#{volunteer.email}"
    @from             = StaticData::INFO_EMAIL
    @subject          = "COASST.org: "
    @sent_on          = Time.now
    @body[:volunteer] = volunteer
  end

  def setup_volunteer_added_email()
    @recipients = [StaticData::INFO_EMAIL, StaticData::ADMIN_EMAIL]
    @from       = StaticData::INFO_EMAIL
    @subject    = "COASST.org: "
    @sent_on    = Time.now
  end

  def setup_survey_missing_volunteers()
    @recipients = [StaticData::INFO_EMAIL, StaticData::ADMIN_EMAIL]
    @from       = StaticData::INFO_EMAIL
    @subject    = "COASST.org: "
    @sent_on    = Time.now
  end

end
