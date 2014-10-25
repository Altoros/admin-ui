require 'date'
require 'set'
require 'thread'
require_relative 'has_instances_view_model'
require_relative '../utils'

module AdminUI
  class SpacesViewModel < AdminUI::HasInstancesViewModel
    def do_items
      spaces = @cc.spaces

      # spaces have to exist.  Other record types are optional
      return result unless spaces['connected']

      applications      = @cc.applications
      apps_routes       = @cc.apps_routes
      deas              = @varz.deas
      organizations     = @cc.organizations
      routes            = @cc.routes
      service_instances = @cc.service_instances
      spaces_auditors   = @cc.spaces_auditors
      spaces_developers = @cc.spaces_developers
      spaces_managers   = @cc.spaces_managers

      applications_connected      = applications['connected']
      apps_routes_connected       = apps_routes['connected']
      routes_connected            = routes['connected']
      service_instances_connected = service_instances['connected']
      spaces_roles_connected      = spaces_auditors['connected'] && spaces_developers['connected'] && spaces_managers['connected']

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      routes_used_set   = apps_routes['items'].to_set { |app_route| app_route[:route_id] }

      space_role_counters             = {}
      space_service_instance_counters = {}
      space_route_counters_hash       = {}
      space_app_counters_hash         = {}

      count_space_roles(spaces_auditors, space_role_counters)
      count_space_roles(spaces_developers, space_role_counters)
      count_space_roles(spaces_managers, space_role_counters)

      service_instances['items'].each do |service_instance|
        Thread.pass
        space_id = service_instance[:space_id]
        space_service_instance_counters[space_id] = 0 if space_service_instance_counters[space_id].nil?
        space_service_instance_counters[space_id] += 1
      end

      routes['items'].each do |route|
        Thread.pass
        space_id = route[:space_id]
        space_route_counters = space_route_counters_hash[space_id]
        if space_route_counters.nil?
          space_route_counters = { 'total_routes'  => 0,
                                   'unused_routes' => 0
                                 }
          space_route_counters_hash[space_id] = space_route_counters
        end

        if apps_routes_connected
          space_route_counters['unused_routes'] += 1 unless routes_used_set.include?(route[:id])
        end
        space_route_counters['total_routes'] += 1
      end

      instance_hash = create_instance_hash(deas)

      applications['items'].each do |application|
        Thread.pass
        space_id = application[:space_id]
        space_app_counters = space_app_counters_hash[space_id]
        if space_app_counters.nil?
          space_app_counters = { 'total'           => 0,
                                 'reserved_memory' => 0,
                                 'reserved_disk'   => 0,
                                 'used_memory'     => 0,
                                 'used_disk'       => 0,
                                 'used_cpu'        => 0,
                                 'instances'       => 0
                               }
          space_app_counters_hash[space_id] = space_app_counters
        end

        space_app_counters[application[:state]] = 0 if space_app_counters[application[:state]].nil?
        space_app_counters[application[:package_state]] = 0 if space_app_counters[application[:package_state]].nil?

        add_instance_metrics(space_app_counters, application, instance_hash)

        space_app_counters['total'] += 1
        space_app_counters[application[:state]] += 1
        space_app_counters[application[:package_state]] += 1
      end

      items = []

      spaces['items'].each do |space|
        Thread.pass
        space_id = space[:id]

        organization                   = organization_hash[space[:organization_id]]
        space_role_counter             = space_role_counters[space_id]
        space_service_instance_counter = space_service_instance_counters[space_id]
        space_app_counters             = space_app_counters_hash[space_id]
        space_route_counters           = space_route_counters_hash[space_id]

        row = []

        row.push(space[:name])

        if organization
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        row.push(space[:created_at].to_datetime.rfc3339)

        if space[:updated_at]
          row.push(space[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if space_role_counter
          row.push(space_role_counter)
        elsif spaces_roles_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_route_counters
          row.push(space_route_counters['total_routes'])
          row.push(space_route_counters['total_routes'] - space_route_counters['unused_routes'])
          row.push(space_route_counters['unused_routes'])
        elsif routes_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        if space_app_counters
          row.push(space_app_counters['instances'])
        elsif applications_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_service_instance_counter
          row.push(space_service_instance_counter)
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_app_counters
          row.push(Utils.convert_bytes_to_megabytes(space_app_counters['used_memory']))
          row.push(Utils.convert_bytes_to_megabytes(space_app_counters['used_disk']))
          row.push(space_app_counters['used_cpu'] * 100)
          row.push(space_app_counters['reserved_memory'])
          row.push(space_app_counters['reserved_disk'])
          row.push(space_app_counters['total'])
          row.push(space_app_counters['STARTED'] || 0)
          row.push(space_app_counters['STOPPED'] || 0)
          row.push(space_app_counters['PENDING'] || 0)
          row.push(space_app_counters['STAGED']  || 0)
          row.push(space_app_counters['FAILED']  || 0)
        elsif applications_connected
          row.push(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
        end

        row.push('organization' => organization,
                 'space'        => space)

        items.push(row)
      end

      result(items, (0..20).to_a, (0..3).to_a)
    end

    private

    def count_space_roles(input_space_role_array, output_space_role_counter_hash)
      input_space_role_array['items'].each do |input_space_role_array_entry|
        Thread.pass
        space_id = input_space_role_array_entry[:space_id]
        output_space_role_counter_hash[space_id] = 0 if output_space_role_counter_hash[space_id].nil?
        output_space_role_counter_hash[space_id] += 1
      end
    end
  end
end
