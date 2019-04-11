class AbuseReporter < FeedbackReporter
  PROJECT_PATH = "authtoken=#{ArchiveConfig.ABUSE_AUTH}&portal=#{ArchiveConfig.ABUSE_PORTAL}&department=#{ArchiveConfig.ABUSE_DEPARTMENT}"
  attr_accessor :ip_address

  def template
    "abuse_reports/report"
  end

  def request_headers
    {
      'orgId' => ArchiveConfig.ABUSE_ORG_ID,
      'Authorization' => ArchiveConfig.ABUSE_OAUTH_TOKEN
    }
  end

  def request_body
    {
      'subject' => title,
      'departmentId' => ArchiveConfig.SUPPORT_DEPARTMENT_ID,
    }
  end
end
