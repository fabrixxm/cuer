project('cuer','c', 'vala',
  version: '0.1.0',
  meson_version: '>= 0.40.0',
)
i18n = import('i18n')


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
