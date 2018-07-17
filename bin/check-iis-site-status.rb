#! /usr/bin/env ruby


require 'sensu-plugin/check/cli'

class IISSiteRunning < Sensu::Plugin::Check::CLI
    option :Site,
        long: '--site NAME',
        short: '-s NAME',
        default: :all

    def run
        require 'win32ole'
        wmi = WIN32OLE.connect("winmgmts:\\\\.\\root\\WebAdministration")
        if config[:Site] == :all
            sites = wmi.ExecQuery("SELECT * FROM Site")
        else
            sites = wmi.ExecQuery("SELECT * FROM Site WHERE name = '#{config[:Site]}'")
        end
        crit = Array.new
        warn = Array.new
        unkn = Array.new
        good = Array.new
        sites.each do |site|
            case site.getstate
            when 0, 2
                warn.push(site.name)
            when 4
                unkn.push(site.name)
            when 3
                crit.push(site.name)
            when 1
                good.push(site.name)
            end
        end

        if crit.empty?
            if warn.empty?
                if unkn.empty?
                    if not good.empty?
                        ok "#{good.join(', ') } running"
                    else
                        warning "no sites returned a status"
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
