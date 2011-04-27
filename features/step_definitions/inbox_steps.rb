Then /^the inbox should be empty$/ do
  Then %{I should see "My Inbox (0 comments, 0 unread)"}
end

Then /^I should see a feedback message for the work "([^"]*)"$/ do |work|
  Then %{I should see "to #{work}"}
end

Then /^I should see a tag wrangling message from "([^"]*)" on the tag "([^"]*)"$/ do |user, tag|
  Then %{I should see "#{user} to #{tag}"}
end
