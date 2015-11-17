desc 'Make everything happen'
task default: %i(server-backend server-frontend analytics supermarket compliance) do
  sh('chef provision --no-policy --recipe cluster -c .chef/config.rb')
end

desc 'Provision development cluster'
task dev: %i(server-backend server-frontend analytics supermarket compliance) do
  sh('chef provision --no-policy --recipe dev -c .chef/config.rb')
end

%w(server-backend server-frontend analytics supermarket compliance).each do |role|
  desc "Update policy for #{role}"
  task role.to_sym do
    sh("chef install policies/#{role}.rb") unless File.exist?("policies/#{role}.lock.json")
    sh("chef update policies/#{role}.rb")
    sh("chef push reference policies/#{role}.rb -c .chef/config.rb")
  end
end

desc 'Update all the policies'
task update: %i(server-backend server-frontend analytics supermarket compliance)

desc 'Cleanup'
task :cleanup do
  sh('chef provision --no-policy --recipe cleanup -c .chef/config.rb')
end
