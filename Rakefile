desc 'Make everything happen'
task default: %i(bootstrap-backend frontend analytics) do
  sh('chef update')
  sh('chef push provisioner')
end

%w(bootstrap-backend frontend analytics).each do |role|
  desc "Update policy for #{role}"
  task role.to_sym do
    sh("chef install #{role}.rb") unless File.exist?("#{role}.lock.json")
    sh("chef update #{role}.rb")
    sh("chef push reference #{role}.rb")
  end
end

desc 'Cleanup'
task :cleanup do
  sh('chef install cleanup.rb') unless File.exist?('cleanup.lock.json')
  sh('chef update cleanup.rb')
  sh('chef push provisioner cleanup.rb')
end
