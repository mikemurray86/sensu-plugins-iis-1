#! /usr/bin/env ruby
#
# metrics-iis-current-connections.rb
#
# DESCRIPTION:
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   iis
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#  Tested on iis 2012RC2.
#
# LICENSE:
#   Yohei Kawahara <inokara@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

#
# IIS Current Connections Metric
#
class IisCurrentConnectionsMetric < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.iis_current_connections"

  option :site,
         short: '-s sitename',
         default: '_Total'

  def run
    io = IO.popen("typeperf -sc 1 \"Web Service(#{config[:site]})\\Current\ Connections\"")
    current_connection = io.readlines[2].split(',')[1].delete('"').to_f

    output [config[:scheme], config[:site]].join('.'), current_connection
    ok
  end
end
