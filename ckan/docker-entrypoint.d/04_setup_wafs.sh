
# Add WAFs for spatial harvesting

if [[ $CKAN__PLUGINS == *"spatial"* ]]; then

  # Make sure WAF organizations are created
  pip install ckanapi
  ORGANIZATION_NAMES="acom cgd cisl eol gdex hao library mmm opensky ral rda ucp"
  for org in $ORGANIZATION_NAMES; do
        /srv/app/.local/bin/ckanapi action organization_create name=${org} title=${org}
  done

  # Now make sure WAFs are created.  Each must be attached to an organization.
  set -x
  whoami

  #rm -rf /var/www/html
  ls -l /var/www/*

  # Create web-accessible folder structure
  if [ ! -d "/var/www/html" ]; then
      mkdir -p /var/www/html
  fi

  cd /var/www/html
  for org in $ORGANIZATION_NAMES; do
      waf_folder="dash-${org}-prod"
      waf_url="https://github.com/NCAR/${waf_folder}.git"
      # Make sure WAF folders exist
      if [ ! -d "/var/www/html/${waf_folder}" ]; then
          git clone ${waf_url}
      fi

      # Make sure harvest source exists
      ckan -c ~/ckan.ini harvester source create "${waf_folder}" "http://nginx:9000/${waf_folder}" "waf" "${waf_folder}" "TRUE" "${org}" "MANUAL" '{"user" : "admin", "read_only": true}'
  done

  # Return to home directory for supervisord startup
  cd
fi
