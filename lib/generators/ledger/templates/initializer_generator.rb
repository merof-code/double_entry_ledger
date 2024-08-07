require "ledger"

Ledger.configure do |config|
  config.person_class_name = <%= options[:person_class] || "no_person_class" %>
  config.tenant_class_name = <%= options[:tenant_class] || "no_tenant_class" %>
  config.running_inside_transactional_fixtures = false
end
