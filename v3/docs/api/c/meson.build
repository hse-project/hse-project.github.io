hse_3_proj = subproject(
    'hse-3',
    required: 'c' in apis,
    default_options: [
        'warning_level=0',
        'default_library=static',
        'cli=false',
        'docs=enabled',
        'tests=false',
        'tools=disabled',
        'samples=false',
        'bindings=none',
    ]
)

if not hse_3_proj.found()
    subdir_done()
endif

c_docs = hse_3_proj.get_variable('docs')

generated_docs += custom_target(
    'c-doxybook2',
    build_by_default: true,
    output: '.',
    command: [
        doxybook2,
        '--input',
        # This must be kept in sync with HSE. Note the version in the path.
        meson.project_build_root() / 'subprojects/hse-3/docs/doxygen/output/xml',
        '--output',
        '@OUTPUT@',
        '--config',
        meson.current_source_dir() / '../.doxybook/config.json',
        '--templates',
        meson.current_source_dir() / '../.doxybook/templates'
    ],
    depends: [
        c_docs,
    ]
)
