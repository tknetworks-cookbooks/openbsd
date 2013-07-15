#
# Author:: Ken-ichi TANABE (<nabeken@tknetworks.org>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :openbsd_interface,
       :inet    => nil,
       :inet6   => nil,
       :dhcp    => false,
       :tunnel  => nil,
       :inner   => nil,
       :mtu     => nil,
       :config  => [],
       :rdomain => 0,
       :tunneldomain => 0,
       :extra_commands => [] do

  if node["platform"] != "openbsd"
    raise "openvpn_interface is only for OpenBSD"
  end

  if (not params[:name] =~ /^(gre|enc)/) && params[:inet].nil? && params[:inet6].nil?
    raise "ipv4 or ipv6 address required"
  end

  begin
    t = resources("template[/etc/hostname.#{params[:name]}")
  rescue
    t = template "/etc/hostname.#{params[:name]}" do
          owner "root"
          group node["etc"]["passwd"]["root"]["gid"]
          mode  0640
          variables({
            "inet"   => params[:inet],
            "inet6"  => params[:inet6],
            "dhcp"   => params[:dhcp],
            "inner"  => params[:inner],
            "rdomain" => params[:rdomain],
            "tunnel"  => params[:tunnel],
            "mtu"     => params[:mtu],
            "config"  => params[:config],
            "tunneldomain"   => params[:tunneldomain],
            "extra_commands" => params[:extra_commands]
          })
          source case params[:name]
                 when /^enc/
                   "hostname.enc.if.erb"
                 else
                   "hostname.if.erb"
                 end
        end
  end
end

define :openbsd_ike,
       :mode  => nil,
       :proto => nil,
       :from  => nil,
       :to    => nil,
       :peer  => 'any',
       :rdomain => 0,
       :psk   => nil do

  if %w{mode from to psk}.any? { |k| params[k.to_sym].nil? }
    raise "mode, from, to, psk is required"
  end

  unless %w{passive active dynamic}.any? { |k| params[:mode] == k }
    raise "mode must be 'passive', 'active', or 'dynamic'"
  end

  t = nil
  begin
    t = resources("template[/etc/ipsec_chef.conf]")
  rescue
    t = template "/etc/ipsec_chef.conf" do
          owner "root"
          group node["etc"]["passwd"]["root"]["gid"]
          mode  0600
          variables(
            "rules" => []
          )
          source "ipsec_chef.conf.erb"
          notifies :run, "execute[reload-ipsec-conf-rdomain-#{params[:rdomain]}]"
        end
  end
  t.variables["rules"].push params
end

define :openbsd_reload_ipsec_conf, :rdomain => 0 do
  rdomain = params[:rdomain]

  begin
    resources("execute[#{params[:name]}-rdomain-#{params[:rdomain]}]")
  rescue
    execute "#{params[:name]}-rdomain-#{params[:rdomain]}" do
      extend Chef::Mixin::ShellOut
      if rdomain == 0
        command "/sbin/ipsecctl -f /etc/ipsec.conf"
      else
        command "/sbin/route -T #{rdomain} exec /sbin/ipsecctl -f /etc/ipsec.conf"
      end
      action :nothing
      only_if do
        shell_out("/usr/bin/pgrep isakmpd", :env => nil).status.success?
      end
    end
  end
end

define :openbsd_ipsec do
  unless %w{passive active dynamic}.any? { |k| params[:name] == k }
    raise "name must be 'passive', 'active', or 'dynamic'"
  end

  # retrieve IPsec configurations from databag
  configured = false
  begin
    gw_hostname = node["openbsd"]["ipsec"]["gw_hostname"]

    ipsec_conf = data_bag_item("ipsec", gw_hostname).find_all { |e|
      e.first != "id"
    }

    ipsec_conf.each do |conf|
      # ゲートウェイが冗長構成になっている場合、ホスト名が必ずしも gw_hostname と一致しない。
      # そこで特定のattributeがあればgw_hostnameの一致していると扱う。
      my, remote = conf.last.partition { |k, v|
        node["openbsd"]["ipsec"]["is_gateway"] ? k == node["openbsd"]["ipsec"]["gw_fqdn"] : k == node["fqdn"]
      }.map { |c| c.flatten }

      # skip if not include myself
      if my.empty?
        next
      end
      if remote.empty?
        raise "something seems to be wrong."
      end

      configured = true

      my_gre = get_gre(my.last)
      my_lo = get_loopback(my.last)
      remote_gre = get_gre(remote.last)
      remote_lo = get_loopback(remote.last)
      has_rdomain = my.last.has_key?("rdomain")
      unless has_rdomain
        my.last["rdomain"] = 0
      end

      Chef::Log.info "configuring #{my.first} -> #{remote.first}"

      ipsec_mode = params[:name]
      mypeer = params[:peer]

      openbsd_reload_ipsec_conf "reload-ipsec-conf" do
        rdomain my.last["rdomain"]
      end

      openbsd_interface my_lo.first do
        rdomain my.last["rdomain"] if has_rdomain
        inet "#{my_lo.last}/32"
      end
      openbsd_interface my_gre.first do
        tunneldomain my.last["rdomain"] if has_rdomain
        tunnel "#{my_lo.last} #{remote_lo.last}"
        inner "#{my_gre.last} #{remote_gre.last} netmask 255.255.255.255"
      end
      openbsd_ike "#{my.first} -> #{remote.first}" do
        mode  ipsec_mode
        proto "gre"
        from  "#{my_lo.last}/32"
        to    "#{remote_lo.last}/32"
        psk   node["openbsd"]["ipsec"]["psk"]
        peer  mypeer
        rdomain my.last["rdomain"]
      end

      if has_rdomain
        enc_if = get_enc(my.last)
        openbsd_interface enc_if.first do
          rdomain my.last["rdomain"]
        end

        # Add lines
        Chef::Log.info("rdomain is enabled. Add lines to execute isakmpd and ipsec w/ rdomain.")
        execute "add-isakmpd-rdomain-#{my.last["rdomain"]}" do
          rdomain = my.last["rdomain"]
          oneliner = %Q[route -T #{rdomain} exec isakmpd -K -v]
          command %Q[echo '#{oneliner}' >> /etc/rc.local]
          not_if do
            ::File.open("/etc/rc.local").readlines.any? { |l|
              l.start_with?(oneliner)
            }
          end
        end

        execute "add-ipsecctl-rdomain-#{my.last["rdomain"]}" do
          rdomain = my.last["rdomain"]
          oneliner = %Q[route -T #{rdomain} exec ipsecctl -f /etc/ipsec.conf]
          command %Q[echo '#{oneliner}' >> /etc/rc.local]
          not_if do
            ::File.open("/etc/rc.local").readlines.any? { |l|
              l.start_with?(oneliner)
            }
          end
        end
      else
        begin
          resources('service[isakmpd]')
        rescue
          service "isakmpd" do
            parameters({:flags => "-K -v"})
            action [:enable, :start]
          end
        end
        begin
          resources('service[ipsec]')
        rescue
          service "ipsec" do
            action :enable
          end
        end
      end
    end

    if not configured
      Chef::Log.info("No configure found for #{node['fqdn']}")
    end
  rescue => e
    Chef::Log.info("Could not load data bag 'ipsec', '#{gw_hostname}', this is optional, moving on... reason: #{e}")
  end
end
