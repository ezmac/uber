<?php
/**
 * Debian local configuration file
 *
 * This file overrides the settings made by phpMyAdmin interactive setup
 * utility.
 *
 * For example configuration see
 *   /usr/share/doc/phpmyadmin/examples/config.sample.inc.php
 * or
 *   /usr/share/doc/phpmyadmin/examples/config.manyhosts.inc.php
 *
 * NOTE: do not add security sensitive data to this file (like passwords)
 * unless you really know what you're doing. If you do, any user that can
 * run PHP or CGI on your webserver will be able to read them. If you still
 * want to do this, make sure to properly secure the access to this file
 * (also on the filesystem level).
 */

if (!function_exists('check_file_access')) {
	function check_file_access($path)
	{
	    if (is_readable($path)) {
		return true;
	    } else {
		error_log(
		    'phpmyadmin: Failed to load ' . $path
		    . ' Check group www-data has read access and open_basedir restrictions.'
		);
		return false;
	    }
	}
}

// Load secret generated on postinst
if (check_file_access('/var/lib/phpmyadmin/blowfish_secret.inc.php')) {
    require('/var/lib/phpmyadmin/blowfish_secret.inc.php');
}

// Load autoconf local config
if (check_file_access('/var/lib/phpmyadmin/config.inc.php')) {
    require('/var/lib/phpmyadmin/config.inc.php');
}

/**
 * Server(s) configuration
 */
$i = 0;
// The $cfg['Servers'] array starts with $cfg['Servers'][1].  Do not use $cfg['Servers'][0].
// You can disable a server config entry by setting host to ''.
$i++;

/**
 * Read configuration from dbconfig-common
 * You can regenerate it using: dpkg-reconfigure -plow phpmyadmin
 */
if (check_file_access('/etc/phpmyadmin/config-db.php')) {
    require('/etc/phpmyadmin/config-db.php');
}

/* Configure according to dbconfig-common if enabled */

/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'cookie';
/* Server parameters */
$cfg['Servers'][$i]['host'] = '127.0.0.1';
//$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
/* Select mysqli if your server has it */
$cfg['Servers'][$i]['extension'] = 'mysql';
/* Optional: User for advanced features */
 $cfg['Servers'][$i]['controluser'] = 'pma';
 $cfg['Servers'][$i]['controlpass'] = 'pmapass';

/* Storage database and tables */
 $cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
 $cfg['Servers'][$i]['bookmarktable'] = 'pma_bookmark';
 $cfg['Servers'][$i]['relation'] = 'pma_relation';
 $cfg['Servers'][$i]['table_info'] = 'pma_table_info';
 $cfg['Servers'][$i]['table_coords'] = 'pma_table_coords';
 $cfg['Servers'][$i]['pdf_pages'] = 'pma_pdf_pages';
 $cfg['Servers'][$i]['column_info'] = 'pma_column_info';
 $cfg['Servers'][$i]['history'] = 'pma_history';
 $cfg['Servers'][$i]['table_uiprefs'] = 'pma_table_uiprefs';
 $cfg['Servers'][$i]['tracking'] = 'pma_tracking';
 $cfg['Servers'][$i]['designer_coords'] = 'pma_designer_coords';
 $cfg['Servers'][$i]['userconfig'] = 'pma_userconfig';
 $cfg['Servers'][$i]['recent'] = 'pma_recent';
 $i++;
/* Uncomment the following to enable logging in to passwordless accounts,
 * after taking note of the associated security risks. */
// $cfg['Servers'][$i]['AllowNoPassword'] = TRUE;

/*
 * End of servers configuration
 */

/*
 * Directories for saving/loading files from server
 */
$cfg['UploadDir'] = '/data/phpmyadmin/upload';
$cfg['SaveDir'] = '/data/phpmyadmin/save';

/* Support additional configurations */
foreach (glob('/etc/phpmyadmin/conf.d/*.php') as $filename)
{
    include($filename);
}


