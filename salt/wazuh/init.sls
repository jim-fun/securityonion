{%- set HOSTNAME = salt['grains.get']('host', '') %}
{% set VERSION = salt['pillar.get']('static:soversion', 'HH1.1.4') %}
{% set MASTER = salt['grains.get']('master') %}
# Add ossec group
ossecgroup:
  group.present:
    - name: ossec
    - gid: 945

# Add ossecm user
ossecm:
  user.present:
    - uid: 943
    - gid: 945
    - home: /opt/so/conf/wazuh
    - createhome: False
    - allow_uid_change: True
    - allow_gid_change: True

# Add ossecr user
ossecr:
  user.present:
    - uid: 944
    - gid: 945
    - home: /opt/so/conf/wazuh
    - createhome: False
    - allow_uid_change: True
    - allow_gid_change: True

# Add ossec user
ossec:
  user.present:
    - uid: 945
    - gid: 945
    - home: /opt/so/conf/wazuh
    - createhome: False
    - allow_uid_change: True
    - allow_gid_change: True

wazuhdir:
  file.directory:
    - name: /opt/so/conf/wazuh
    - user: 945
    - group: 945

wazuhalertlogdir:
  file.directory:
    - name: /opt/so/log/wazuh/logs/alerts
    - user: 945
    - group: 945
    - makedirs: True

wazuharchlogdir:
  file.directory:
    - name: /opt/so/log/wazuh/logs/archives
    - user: 945
    - group: 945
    - makedirs: True

# Add wazuh agent
wazuhpkgs:
 pkg.installed:
   - skip_suggestions: False
   - pkgs:
     - wazuh-agent: 3.10.2-1

# Add Wazuh agent conf
wazuhagentconf:
  file.managed:
    - name: /var/ossec/etc/ossec.conf
    - source: salt://wazuh/files/agent/ossec.conf
    - user: 0
    - group: 945
    - template: jinja

# Add Wazuh server conf
wazuhserverconf:
  file.managed:
    - name: /opt/so/conf/wazuh/etc/ossec.conf
    - source: salt://wazuh/files/server/ossec.conf
    - user: 0
    - group: 945
    - template: jinja

# Add Wazuh agent conf
wazuhagentregister:
  file.managed:
    - name: /usr/sbin/wazuh-register-agent
    - source: salt://wazuh/files/agent/wazuh-register-agent
    - user: 0
    - group: 0
    - mode: 755
    - template: jinja

wazuhmgrwhitelist:
   file.managed:
    - name: /usr/sbin/wazuh-manager-whitelist
    - source: salt://wazuh/files/wazuh-manager-whitelist
    - user: 0
    - group: 0
    - mode: 755
    - template: jinja

so-wazuh:
  docker_container.running:
    - image: {{ MASTER }}:5000/soshybridhunter/so-wazuh:{{ VERSION }}
    - hostname: {{HOSTNAME}}-wazuh-manager
    - name: so-wazuh
    - detach: True
    - port_bindings:
      - 0.0.0.0:1514:1514/udp
      - 0.0.0.0:1514:1514/tcp
      - 0.0.0.0:55000:55000
    - binds:
      - /opt/so/conf/wazuh/etc:/var/ossec/data/etc:rw
      - /opt/so/log/wazuh:/var/ossec/data/logs:rw


# Register the agent
registertheagent:
  cmd.run:
    - name: /usr/sbin/wazuh-register-agent
    - cwd: /
    #- stateful: True

# Whitelist manager IP
whitelistmanager:
  cmd.run:
    - name: /usr/sbin/wazuh-manager-whitelist
    - cwd: /
