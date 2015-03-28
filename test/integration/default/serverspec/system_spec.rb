require 'serverspec'
set :backend, :exec

describe command('date +%Z') do
    its(:stdout) { should match 'JST' }
end

