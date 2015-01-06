# chef-squirrelmail-cookbook

This cookbook install and configure a mail transport agent based on Qmail with LDAP support.

## Supported Platforms

* DEBIAN 7.0.1

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef-squirrelmail']['squirrel_home']</tt></td>
    <td>String</td>
    <td>default config files</td>
    <td><tt>/etc/squirrelmail</tt></td>
  </tr>
</table>

default['chef-squirrelmail']['squirrel_home'] = '/etc/squirrelmail'
default['chef-squirrelmail']['apache2_home'] = '/etc/apache2'
default['chef-squirrelmail']['site_name'] = 'webmail'
default['chef-squirrelmail']['site_home'] = '/usr/share/squirrelmail'
default['chef-squirrelmail']['data_home'] = '/usr/share/squirrelmail/data'
default['chef-squirrelmail']['apache_owner'] = 'www-data'
default['chef-squirrelmail']['apache_group'] = 'www-data'


## Usage

### chef-squirrelmail::default

Include `chef-squirrelmail` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef-squirrelmail::default]"
  ]
}
```

## License and Authors

Author : DSI (<stephane.lii@informatique.gov.pf>)
