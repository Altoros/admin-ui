require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class GatewaysViewModel < AdminUI::Base
    def initialize(logger, varz)
      super(logger)

      @varz = varz
    end

    def do_items
      gateways = @varz.gateways

      # gateways have to exist.  Other record types are optional
      return result unless gateways['connected']

      items = []
      hash  = {}

      gateways['items'].each do |gateway|
        Thread.pass
        row = []

        row.push(gateway['name'])

        data = gateway['data']

        if gateway['connected']
          row.push(data['index'])
          row.push('RUNNING')
          row.push(DateTime.parse(data['start']).rfc3339)
          row.push(data['config']['service']['description'])
          row.push(data['cpu'])

          # Conditional logic since mem becomes mem_bytes in 157
          if data['mem']
            row.push(data['mem'])
          elsif data['mem_bytes']
            row.push(data['mem_bytes'])
          else
            row.push(nil)
          end

          # For some reason nodes is not an array.
          num_nodes = 0
          num_nodes = data['nodes'].length if data['nodes']
          row.push(num_nodes)

          capacity = 0
          data['nodes'].each_value do |node|
            capacity += node['available_capacity'] if node['available_capacity'] && node['available_capacity'] > 0
          end

          row.push(capacity)

          hash[gateway['name']] = gateway
        else
          row.push(nil)
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil, nil, nil)

          row.push(gateway['uri'])
        end

        items.push(row)
      end

      result(true, items, hash, (0..8).to_a, [0, 2, 3, 4])
    end
  end
end
