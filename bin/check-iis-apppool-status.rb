#! /usr/bin/env ruby


require 'sensu-plugin/check/cli'

class IISAppPoolRunning < Sensu::Plugin::Check::CLI
    option :AppPool,
        long: '--apppool',
        short: '-a NAME',
        default: :all

    def run
        require 'win32ole'
        wmi = WIN32OLE.connect("winmgmts:\\\\.\\root\\WebAdministration")
        if config[:AppPool] == :all
            pools = wmi.ExecQuery("SELECT * FROM ApplicationPool")
        else
            pools = wmi.ExecQuery("SELECT * FROM ApplicationPool WHERE name = '#{config[:AppPool]}'")
        end
        crit = Array.new
        warn = Array.new
        unkn = Array.new
        good = Array.new
        pools.each do |pool|
            case pool.getstate
            when 0, 2
                warn.push(pool.name)
            when 4
                unkn.push(pool.name)
            when 3
                crit.push(pool.name)
            when 1
                good.push(pool.name)
            end
        end

        if crit.empty?
            if warn.empty?
                if unkn.empty?
                    if not good.empty?
                        ok "#{good.join(', ') } running"
                    else
                        warning "no pools returned a status"
                    end
                else
                    unknown "#{warn.join(', ') } in an unknown status"
                end
            else
                warning "#{warn.join(', ') } either starting or stopping"
            end
        else
            critical "#{crit.join(', ') } stopped"
        end
    end
end
