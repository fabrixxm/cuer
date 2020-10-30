subdir('icons')

desktop_file = i18n.merge_file(
  input: 'net.kirgroup.Cuer.desktop.in',
  output: 'net.kirgroup.Cuer.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

metainfo_file = 'net.kirgroup.Cuer.metainfo.xml.in'
i18n.merge_file(
    input:  metainfo_file,
    output: 'net.kirgroup.Cuer.metainfo.xml',
    type: 'xml',
    po_dir: join_paths (meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'metainfo')
)
appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('validate metainfo file',
        appstream_util,
        args: ['validate',
               '--no-net',
               '--pedantic',
               metainfo_file]
  )
endif


install_data('net.kirgroup.Cuer.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif
