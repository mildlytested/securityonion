# Copyright 2014,2015,2016,2017,2018 Security Onion Solutions, LLC

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

{% set access_key = salt['pillar.get']('master:access_key', '') %}
{% set access_secret = salt['pillar.get']('master:access_secret', '') %}

# Minio Setup
minioconfdir:
  file.directory:
    - name: /opt/so/conf/minio/etc
    - user: 939
    - group: 939
    - makedirs: True

miniodatadir:
  file.directory:
    - name: /nsm/minio/data
    - user: 939
    - group: 939
    - makedirs: True

#redisconfsync:
#  file.recurse:
#    - name: /opt/so/conf/redis/etc
#    - source: salt://redis/etc
#    - user: 939
#    - group: 939
#    - template: jinja

minio/minio:
  docker_image.present

minio:
  docker_container.running:
    - image: minio/minio
    - hostname: so-minio
    - user: socore
    - port_bindings:
      - 0.0.0.0:9000:9000
    - environment:
      - MINIO_ACCESS_KEY: {{ access_key }}
      - MINIO_SECRET_KEY: {{ access_secret }}
    - binds:
      - /nsm/minio/data:/data:rw
      - /opt/so/conf/minio/etc:/root/.minio:rw
    - entrypoint: "/usr/bin/docker-entrypoint.sh server /data"
    - network_mode: so-elastic-net
