#!/bin/bash
# Dominik Zorgnotti
# Adds SSO events to the rsyslog export
# Unsupported by VMware

cat <<EOF > /etc/vmware-syslog/vmware-services-sso-audit.conf
input(type="imfile" File="/var/log/audit/sso-events/audit_events.log" Tag="ssoAudit" Severity="info" Facility="local0")
EOF
systemctl restart rsyslog
