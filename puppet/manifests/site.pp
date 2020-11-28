## the main manifest

node default {
  if $facts['role']   {
    notify {"my role is: ${facts['role']}":
      loglevel => info
    }
    include "roles::${facts['role']}"
  } else {
    notify {'Fatal: role is not defined': }
    fail ('role is not defined')
  }
}
