include:
  - patch.needs_restarting
{% if grains.os == "CentOS" %}
  - yum.packages
{% endif %}

patch_os:
  pkg.uptodate:
    - name: patch_os
    - refresh: True
    - onchanges_in: needs_restarting
