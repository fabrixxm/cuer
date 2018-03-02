cuer_sources = [
  'main.vala',
  'window.vala',
  'camera.vala',
  'history.vala',
]

cuer_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gstreamer-1.0', version: '>= 1.0'),
  dependency('libnotify', version: '>= 0.7'),
]

gnome = import('gnome')

cuer_sources += gnome.compile_resources('cuer-resources',
  'cuer.gresource.xml',
  c_name: 'cuer'
)

executable('cuer', cuer_sources,
  vala_args: '--target-glib=2.50',
  dependencies: cuer_deps,
  install: true,
)
