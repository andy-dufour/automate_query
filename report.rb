
require "net/https"
require "uri"
require "json"

def get_nodes(role, automate_url, enterprise, token, user)
  uri = URI.parse("https://#{automate_url}/compliance/nodes?filters=role:#{role}&per_page=1000")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  request.add_field('chef-delivery-enterprise',enterprise)
  request.add_field('chef-delivery-token',token)
  request.add_field('chef-delivery-user',user)

  response = http.request(request)
  nodes_hash = JSON.parse(response.body)
  nodes_hash
end

def get_report(report_id, automate_url, enterprise, token, user)
  # https://ec2-52-36-215-216.us-west-2.compute.amazonaws.com/compliance/reports/4a3382bf-9172-476f-aa84-c6877d9cdcd1
  uri = URI.parse("https://#{automate_url}/compliance/reports/#{report_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  request.add_field('chef-delivery-enterprise',enterprise)
  request.add_field('chef-delivery-token',token)
  request.add_field('chef-delivery-user',user)

  response = http.request(request)
  report_hash = JSON.parse(response.body)
  report_hash
end

def num_failed(control)
  failed = 0
  if control['results']
    control['results'].each do |result|
      if result['status'] == 'failed'
        failed = failed + 1
      end
    end
  end
  failed
end



report_array = ['Node Name,Profile Name,Profile Title,Profile Version,Profile Summary,Control ID,Control Title,Control Impact,Number of Failed Results']

automate_fqdn = ARGV[0]
ent = ARGV[1]
token = ARGV[2]
user = ARGV[3]
role = ARGV[4]

nodes = get_nodes(role,automate_fqdn,ent,token,user)

nodes.each do |node|
  report = get_report(node['latest_report']['id'],automate_fqdn,ent,token,user)
  if report['profiles']
    report['profiles'].each do |profile|
      if profile['controls']
        profile['controls'].each do |control|
          if num_failed(control) > 0
            report_array.push "#{node['name']},#{profile['name']},#{profile['title']},#{profile['version']},#{profile['summary']},#{control['id']},#{control['title']},#{control['impact']},#{num_failed(control)}"
          end
        end
      end
    end
  end
end

File.open("report.csv", "w+") do |f|
  f.puts(report_array)
end
#response.status
