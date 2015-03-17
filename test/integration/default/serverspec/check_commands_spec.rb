require 'serverspec'
set :backend, :exec

commands = %w{vim tree patch locate rsync}

commands.each do |c|
    describe command("which #{c}") do
        its(:exit_status) { should eq 0 }
    end
end

describe command("which man") do
    its(:exit_status) { should eq 0 }
end

