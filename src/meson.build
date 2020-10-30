cuer_sources = [
  'main.vala',
  'camera.vala',
  'historyempty.vala',
  'history.vala',
  'window.vala',
  'notification_overlay.vala',
]

cuer_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gstreamer-1.0', version: '>= 1.0'),
  dependency('libnotify', version: '>= 0.7'),
  dependency('libhandy-1', version: '>= 1.0'),
]


config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

gnome = import('gnome')

cuer_sources += gnome.compile_resources('cuer-resources',
  'cuer.gresource.xml',
  c_name: 'cuer',
  export: true,
)

cuer_sources += gnome.compile_resources('cuer-icon-resources',
  join_paths(icons_dir, 'icons.gresource.xml'),
  c_name: 'cuer_icons',
  export: true,
)

cuer_c_args = [
  '-DHANDY_USE_UNSTABLE_API',
]


executable('net.kirgroup.Cuer', cuer_sources, config_file,
  vala_args: '--target-glib=2.50',
  dependencies: cuer_deps,
  c_args: cuer_c_args,
  install: true,
)
