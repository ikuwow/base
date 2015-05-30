require 'serverspec'
set :backend, :exec

describe 'Linux Kernel parameters' do
    context linux_kernel_parameter('vm.swappiness') do
        its(:value) { should eq 10 }
    end
end

describe command('date +%Z') do
    its(:stdout) { should match 'JST' }
end

