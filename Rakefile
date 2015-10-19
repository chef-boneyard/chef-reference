desc 'Make everything happen'
task default: %i(server-backend server-frontend analytics supermarket) do
  sh('chef provision --no-policy --recipe cluster')
end

desc 'Provision development cluster'
task dev: %i(server-backend server-frontend analytics supermarket) do
  sh('chef provision --no-policy --recipe dev')
end

%w(server-backend server-frontend analytics supermarket).each do |role|
  desc "Update policy for #{role}"
  task role.to_sym do
    sh("chef install policies/#{role}.rb") unless File.exist?("policies/#{role}.lock.json")
    sh("chef update policies/#{role}.rb")
    sh("chef push reference policies/#{role}.rb")
  end
end

desc 'Update all the policies'
task update: %i(server-backend server-frontend analytics supermarket)

desc 'Cleanup'
task :cleanup do
  sh('chef provision --no-policy --recipe cleanup')
end
