project('net.kirgroup.Cuer','c', 'vala',
  version: '0.3.0',
  meson_version: '>= 0.40.0',
)


gettext_name = meson.project_name()

i18n = import('i18n')


add_project_arguments(
	'-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
	language:'c'
)

config_dir = join_paths(get_option('sysconfdir'), meson.project_name())
conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('APP_NAME', get_option('name'))
conf_data.set('VERSION', meson.project_version())
conf_data.set('CONFIGDIR', config_dir)


# SOURCE DIRS
data_dir = join_paths(meson.source_root(), 'data')
icons_dir = join_paths(data_dir, 'icons')
po_dir = join_paths(meson.source_root(), 'po')

# DEST DIRS
localedir = join_paths (get_option ('prefix'), get_option ('localedir'))
datadir = join_paths (get_option ('prefix'), get_option ('datadir'))



subdir('data')
subdir('src')
subdir('po')
meson.add_install_script('build-aux/meson/postinstall.py')
