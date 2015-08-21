desc 'Make everything happen'
task default: %i(server-backend server-frontend analytics) do
  sh('chef provision --no-policy --recipe cluster')
end

desc 'Provision development cluster'
task dev: %i(server-backend server-frontend analytics) do
  sh('chef provision --no-policy --recipe dev')
end

%w(server-backend server-frontend analytics).each do |role|
  desc "Update policy for #{role}"
  task role.to_sym do
    sh("chef install policyfiles/#{role}.rb") unless File.exist?("policyfiles/#{role}.lock.json")
    sh("chef update policyfiles/#{role}.rb")
    sh("chef push reference policyfiles/#{role}.rb")
  end
end

desc 'Update all the policies'
task update: %i(server-backend server-frontend analytics)

desc 'Cleanup'
task :cleanup do
  sh('chef provision --no-policy --recipe cleanup')
end
